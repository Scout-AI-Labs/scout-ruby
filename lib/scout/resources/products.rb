# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Product extraction from storefronts.
    class Products < Base
      # Crawl a store and extract its products.
      def extract(url:, **params)
        @client.request(:post, "/v1/products", body: compact({ url: url }.merge(params)))
      end

      # Extract a single product from one product-detail URL.
      def one(url:, **params)
        @client.request(:post, "/v1/products/one", body: compact({ url: url }.merge(params)))
      end
    end
  end
end
