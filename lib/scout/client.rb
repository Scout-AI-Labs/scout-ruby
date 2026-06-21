# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "securerandom"

require_relative "version"
require_relative "errors"
require_relative "resources/search"
require_relative "resources/page"
require_relative "resources/extract"
require_relative "resources/company"
require_relative "resources/lists"
require_relative "resources/products"
require_relative "resources/site"
require_relative "resources/jobs"
require_relative "resources/monitors"
require_relative "resources/chat"

module Scout
  # Client for the Scout web-intelligence API.
  #
  #   client = Scout::Client.new            # reads SCOUT_API_KEY
  #   client.search.create(queries: ["climate tech startups"])
  class Client
    DEFAULT_BASE_URL = "https://core.usescout.sh"
    DEFAULT_TIMEOUT = 60
    DEFAULT_MAX_RETRIES = 2
    RETRY_STATUSES = [408, 409, 429, 500, 502, 503, 504].freeze

    attr_reader :base_url, :timeout, :max_retries

    attr_reader :search, :page, :extract, :company, :lists,
                :products, :site, :jobs, :monitors, :chat

    def initialize(api_key: nil, base_url: nil, timeout: DEFAULT_TIMEOUT,
                   max_retries: DEFAULT_MAX_RETRIES, default_headers: {})
      @api_key = api_key || ENV["SCOUT_API_KEY"]
      raise Error, "Missing API key. Pass api_key: or set SCOUT_API_KEY." if @api_key.nil? || @api_key.empty?

      @base_url = (base_url || DEFAULT_BASE_URL).sub(%r{/+\z}, "")
      @timeout = timeout
      @max_retries = max_retries
      @default_headers = default_headers || {}

      # Resource groups - a faithful 1:1 mirror of the REST API tags.
      @search = Resources::Search.new(self)
      @page = Resources::Page.new(self)
      @extract = Resources::Extract.new(self)
      @company = Resources::Company.new(self)
      @lists = Resources::Lists.new(self)
      @products = Resources::Products.new(self)
      @site = Resources::Site.new(self)
      @jobs = Resources::Jobs.new(self)
      @monitors = Resources::Monitors.new(self)
      @chat = Resources::Chat.new(self)
    end

    # Issue a request with retries and typed error mapping. Internal.
    def request(method, path, body: nil, query: nil)
      uri = URI.join(@base_url + "/", path.sub(%r{\A/}, ""))
      uri.query = URI.encode_www_form(compact(query)) if query && !compact(query).empty?

      is_write = method != :get
      body_json = body.nil? || method == :get ? nil : JSON.generate(body)

      attempt = 0
      loop do
        begin
          return attempt_request(method, uri, body_json, is_write)
        rescue Error => e
          raise e unless retriable?(e) && attempt < @max_retries

          sleep(backoff_seconds(attempt, e))
          attempt += 1
        end
      end
    end

    private

    def attempt_request(method, uri, body_json, is_write)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      req = build_request(method, uri, body_json, is_write)
      begin
        res = http.request(req)
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise TimeoutError, "Request timed out after #{@timeout}s: #{e.message}"
      rescue SocketError, SystemCallError, IOError => e
        raise ConnectionError, e.message
      end

      parse_response(res)
    end

    def build_request(method, uri, body_json, is_write)
      klass = {
        get: Net::HTTP::Get, post: Net::HTTP::Post,
        patch: Net::HTTP::Patch, delete: Net::HTTP::Delete
      }.fetch(method)
      req = klass.new(uri)
      req["Authorization"] = "Bearer #{@api_key}"
      req["Accept"] = "application/json"
      req["User-Agent"] = "scout-ruby/#{VERSION}"
      req["Scout-Version"] = API_VERSION
      @default_headers.each { |k, v| req[k.to_s] = v }
      if body_json
        req["Content-Type"] = "application/json"
        req.body = body_json
      end
      req["Idempotency-Key"] = SecureRandom.uuid if is_write
      req
    end

    def parse_response(res)
      status = res.code.to_i
      request_id = res["x-request-id"]
      headers = res.to_hash.transform_values { |v| v.is_a?(Array) ? v.first : v }
      raw = res.body
      parsed =
        if raw.nil? || raw.empty?
          nil
        elsif (res["content-type"] || "").include?("json")
          begin
            JSON.parse(raw)
          rescue JSON::ParserError
            raw
          end
        else
          raw
        end

      return parsed if status.between?(200, 299)

      raise Scout.api_error_from_status(
        status, error_message(parsed, status),
        request_id: request_id, body: parsed, code: error_code(parsed), headers: headers
      )
    end

    def retriable?(err)
      return true if err.is_a?(ConnectionError)
      return RETRY_STATUSES.include?(err.status) unless err.status.nil?

      false
    end

    def backoff_seconds(attempt, err)
      retry_after = err.headers["retry-after"]
      if retry_after
        secs = Float(retry_after, exception: false)
        return [secs, 60.0].min if secs
      end
      base = [0.5 * (2**attempt), 8.0].min
      base * (0.5 + rand * 0.5)
    end

    def compact(hash)
      (hash || {}).reject { |_, v| v.nil? }
    end

    def error_message(body, status)
      if body.is_a?(Hash)
        detail = body["detail"] || body["error"] || body["message"]
        return detail if detail.is_a?(String)
        return detail["message"] if detail.is_a?(Hash) && detail["message"].is_a?(String)
      end
      return body if body.is_a?(String) && !body.empty?

      "Scout API returned HTTP #{status}"
    end

    def error_code(body)
      return nil unless body.is_a?(Hash)
      return body["code"] if body["code"].is_a?(String)

      err = body["error"]
      err["code"] if err.is_a?(Hash) && err["code"].is_a?(String)
    end
  end
end
