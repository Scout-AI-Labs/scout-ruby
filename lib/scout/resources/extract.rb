# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Multi-URL structured extraction.
    class Extract < Base
      # Extract structured data from one or more URLs. Provide objective: or
      # output_schema: (JSON Schema) to shape the result.
      def create(urls:, **params)
        @client.request(:post, "/v1/extract", body: compact({ urls: urls }.merge(params)))
      end
    end
  end
end
