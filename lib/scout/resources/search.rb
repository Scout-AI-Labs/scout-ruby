# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Web search, agentic AI queries, and search-run history.
    class Search < Base
      # Run a web search. Pass queries: plus optional depth:, country:, etc.
      def create(queries:, **params)
        @client.request(:post, "/v1/search", body: compact({ queries: queries }.merge(params)))
      end

      # Answer a natural-language question by reading a page (and its links).
      def ai_query(url:, question:, **params)
        @client.request(:post, "/v1/ai-query", body: compact({ url: url, question: question }.merge(params)))
      end

      # List prior search runs (most recent first).
      def list(limit: nil, offset: nil)
        @client.request(:get, "/v1/searches", query: { limit: limit, offset: offset })
      end

      # Auto-paginating enumerator over all search runs.
      def iterate(limit: 50, &block)
        paginate("/v1/searches", limit: limit, &block)
      end

      # Fetch a single search run by id.
      def get(search_id)
        @client.request(:get, "/v1/searches/#{search_id}")
      end

      # Cancel an in-flight search run.
      def cancel(search_id)
        @client.request(:post, "/v1/searches/#{search_id}/cancel")
      end

      # Fetch the event stream (as JSON) for a search run.
      def events(search_id)
        @client.request(:get, "/v1/searches/#{search_id}/events")
      end

      # Stream a deep-search run's progress events live (SSE).
      def stream_events(search_id, &block)
        stream_sse("/v1/searches/#{search_id}/events", &block)
      end
    end
  end
end
