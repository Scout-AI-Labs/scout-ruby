# frozen_string_literal: true

module Scout
  module Resources
    # Base class for resource groups. Holds the client and shared helpers.
    class Base
      COMMON_ITEM_KEYS = %w[items data results searches runs jobs monitors].freeze

      def initialize(client)
        @client = client
      end

      private

      # Drop nil values so we never send explicit nulls.
      def compact(hash)
        hash.reject { |_, v| v.nil? }
      end

      # Lazily walk every item across pages of an offset-paginated endpoint.
      # Returns an Enumerator when no block is given.
      def paginate(path, limit: 50)
        return enum_for(:paginate, path, limit: limit) unless block_given?

        offset = 0
        loop do
          page = @client.request(:get, path, query: { limit: limit, offset: offset })
          items = extract_items(page)
          items.each { |item| yield item }
          break if items.length < limit

          offset += items.length
        end
      end

      def extract_items(payload)
        return payload if payload.is_a?(Array)

        if payload.is_a?(Hash)
          COMMON_ITEM_KEYS.each do |key|
            return payload[key] if payload[key].is_a?(Array)
          end
          payload.each_value { |v| return v if v.is_a?(Array) }
        end
        []
      end
    end
  end
end
