# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Whole-site operations: crawl and sitemap discovery.
    class Site < Base
      # Crawl a site from start_url:.
      def crawl(start_url:, **params)
        @client.request(:post, "/v1/site/crawl", body: compact({ start_url: start_url }.merge(params)))
      end

      # Discover a site's URLs (sitemap) from start_url:.
      def map(start_url:, **params)
        @client.request(:post, "/v1/site/map", body: compact({ start_url: start_url }.merge(params)))
      end
    end
  end
end
