# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Single-page operations: markdown, html, screenshot, images, extract.
    class Page < Base
      # Fetch a page rendered to clean Markdown.
      def markdown(url:, **params)
        @client.request(:post, "/v1/page/markdown", body: compact({ url: url }.merge(params)))
      end

      # Fetch a page's HTML.
      def html(url:, **params)
        @client.request(:post, "/v1/page/html", body: compact({ url: url }.merge(params)))
      end

      # Capture a screenshot of a page.
      def screenshot(url:, **params)
        @client.request(:post, "/v1/page/screenshot", body: compact({ url: url }.merge(params)))
      end

      # Extract the images on a page.
      def images(url:, **params)
        @client.request(:post, "/v1/page/images", body: compact({ url: url }.merge(params)))
      end

      # Structured extraction scoped to a single page.
      def extract(url:, **params)
        @client.request(:post, "/v1/page/extract", body: compact({ url: url }.merge(params)))
      end
    end
  end
end
