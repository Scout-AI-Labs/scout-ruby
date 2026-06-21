# frozen_string_literal: true

module Scout
  # Base class for every error raised by the SDK. Carries the HTTP status,
  # parsed body, request id, and machine-readable code when available.
  class Error < StandardError
    attr_reader :status, :request_id, :body, :code, :headers

    def initialize(message, status: nil, request_id: nil, body: nil, code: nil, headers: nil)
      super(message)
      @status = status
      @request_id = request_id
      @body = body
      @code = code
      @headers = headers || {}
    end
  end

  # No HTTP response was received (DNS, refused connection, reset).
  class ConnectionError < Error; end

  # The request exceeded the configured timeout before a response arrived.
  class TimeoutError < ConnectionError; end

  # Base for every error carrying an HTTP status from the API.
  class APIError < Error; end

  class BadRequestError < APIError; end          # 400
  class AuthenticationError < APIError; end       # 401
  class InsufficientCreditsError < APIError; end  # 402
  class PermissionDeniedError < APIError; end     # 403
  class NotFoundError < APIError; end             # 404
  class ConflictError < APIError; end             # 409
  class UnprocessableEntityError < APIError; end  # 422
  class RateLimitError < APIError; end            # 429
  class InternalServerError < APIError; end       # >=500

  STATUS_ERRORS = {
    400 => BadRequestError,
    401 => AuthenticationError,
    402 => InsufficientCreditsError,
    403 => PermissionDeniedError,
    404 => NotFoundError,
    409 => ConflictError,
    422 => UnprocessableEntityError,
    429 => RateLimitError,
  }.freeze

  # Build the most specific APIError for an HTTP status.
  def self.api_error_from_status(status, message, request_id: nil, body: nil, code: nil, headers: nil)
    klass = STATUS_ERRORS[status] || (status >= 500 ? InternalServerError : BadRequestError)
    klass.new(message, status: status, request_id: request_id, body: body, code: code, headers: headers)
  end
end
