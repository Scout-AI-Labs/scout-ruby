# frozen_string_literal: true

require "minitest/autorun"
require "socket"
require "json"
require "scout"

# End-to-end tests against a minimal in-process HTTP mock. Uses only the
# standard library plus Minitest (bundled with Ruby).
class ScoutTest < Minitest::Test
  def setup
    @flaky = 0
    @server = TCPServer.new("127.0.0.1", 0)
    @port = @server.addr[1]
    @thread = Thread.new { serve }
    @client = Scout::Client.new(
      api_key: "sk_live_xyz",
      base_url: "http://127.0.0.1:#{@port}",
      max_retries: 3
    )
  end

  def teardown
    @thread.kill
    @server.close
  end

  def test_post_round_trip_sends_auth_and_idempotency
    res = @client.search.create(queries: ["hello world"], depth: "standard")
    assert_equal "Bearer sk_live_xyz", res["auth"]
    refute_empty res["idem"].to_s
    assert_equal "standard", res["echo"]["depth"]
    assert_equal ["hello world"], res["echo"]["queries"]
  end

  def test_get_encodes_query
    res = @client.search.list(limit: 5)
    assert_equal [{ "id" => 1 }], res["items"]
  end

  def test_retries_on_500_then_succeeds
    res = @client.send(:request, :post, "/v1/flaky", body: {})
    assert res["ok"]
    assert_equal 3, res["tries"]
  end

  def test_401_maps_to_authentication_error
    error = assert_raises(Scout::AuthenticationError) do
      @client.send(:request, :post, "/v1/nope", body: {})
    end
    assert_equal 401, error.status
    assert_equal "req_abc123", error.request_id
    assert_includes error.message, "invalid api key"
  end

  def test_pagination_enumerator
    items = @client.search.iterate(limit: 5).to_a
    assert_equal [{ "id" => 1 }], items
  end

  private

  def serve
    loop do
      conn = @server.accept
      handle(conn)
    rescue IOError, Errno::EBADF
      break
    end
  end

  def handle(conn)
    request_line = conn.gets
    method, path, = request_line.split(" ")
    headers = {}
    while (line = conn.gets) && line != "\r\n"
      key, value = line.split(": ", 2)
      headers[key.downcase] = value.strip
    end
    body = headers["content-length"] ? conn.read(headers["content-length"].to_i) : ""
    parsed = body.empty? ? {} : JSON.parse(body)

    status, obj = route(method, path, headers, parsed)
    payload = JSON.generate(obj)
    conn.write("HTTP/1.1 #{status} X\r\n")
    conn.write("Content-Type: application/json\r\n")
    conn.write("X-Request-Id: req_abc123\r\n")
    conn.write("Content-Length: #{payload.bytesize}\r\n\r\n")
    conn.write(payload)
    conn.close
  end

  def route(_method, path, headers, parsed)
    case path
    when "/v1/search"
      [200, { "ok" => true, "auth" => headers["authorization"],
              "idem" => headers["idempotency-key"], "echo" => parsed }]
    when "/v1/flaky"
      @flaky += 1
      @flaky < 3 ? [500, { "detail" => "transient" }] : [200, { "ok" => true, "tries" => @flaky }]
    when "/v1/nope"
      [401, { "detail" => "invalid api key" }]
    when %r{/v1/searches}
      [200, { "items" => [{ "id" => 1 }] }]
    else
      [404, {}]
    end
  end
end
