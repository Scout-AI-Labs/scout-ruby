# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Company enrichment: profiles, logos, fonts, industry codes, styleguide.
    class Company < Base
      # Full company profile from a domain.
      def enrich(domain:, **params)
        @client.request(:post, "/v1/company", body: compact({ domain: domain }.merge(params)))
      end

      # Resolve a company from a work email address.
      def by_email(email:, **params)
        @client.request(:post, "/v1/company/by-email", body: compact({ email: email }.merge(params)))
      end

      # Resolve a company from its name.
      def by_name(name:, **params)
        @client.request(:post, "/v1/company/by-name", body: compact({ name: name }.merge(params)))
      end

      # Resolve a company from a stock ticker.
      def by_ticker(ticker:, **params)
        @client.request(:post, "/v1/company/by-ticker", body: compact({ ticker: ticker }.merge(params)))
      end

      # A condensed company profile (faster, fewer fields).
      def simple(domain:, **params)
        @client.request(:post, "/v1/company/simple", body: compact({ domain: domain }.merge(params)))
      end

      # Brand fonts detected on the company's site.
      def fonts(domain:, **params)
        @client.request(:post, "/v1/company/fonts", body: compact({ domain: domain }.merge(params)))
      end

      # Brand styleguide (colors, typography, logos) for a company.
      def styleguide(domain:, **params)
        @client.request(:post, "/v1/company/styleguide", body: compact({ domain: domain }.merge(params)))
      end

      # Company logo metadata. Choose mode:, format:, variant:.
      def logo(domain:, **params)
        @client.request(:post, "/v1/company/logo", body: compact({ domain: domain }.merge(params)))
      end
    end
  end
end
