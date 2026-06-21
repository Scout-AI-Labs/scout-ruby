# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Operations on async find-all runs.
    class ListRuns < Base
      def list(limit: nil, offset: nil)
        @client.request(:get, "/v1/lists/runs", query: { limit: limit, offset: offset })
      end

      def iterate(limit: 50, &block)
        paginate("/v1/lists/runs", limit: limit, &block)
      end

      def get(findall_id)
        @client.request(:get, "/v1/lists/runs/#{findall_id}")
      end

      def cancel(findall_id)
        @client.request(:post, "/v1/lists/runs/#{findall_id}/cancel")
      end

      # Enrich the run's entities with additional fields.
      def enrich(findall_id, **body)
        @client.request(:post, "/v1/lists/runs/#{findall_id}/enrich", body: compact(body))
      end

      # Extend the run with more matching entities.
      def extend(findall_id, **body)
        @client.request(:post, "/v1/lists/runs/#{findall_id}/extend", body: compact(body))
      end

      def events(findall_id)
        @client.request(:get, "/v1/lists/runs/#{findall_id}/events")
      end
    end

    # Find-all ("lists"): build a list of entities matching a query, then enrich
    # or extend the run.
    class Lists < Base
      attr_reader :runs

      def initialize(client)
        super
        @runs = ListRuns.new(client)
      end

      # Run a find-all synchronously.
      def create(query:, **params)
        @client.request(:post, "/v1/lists", body: compact({ query: query }.merge(params)))
      end

      # Start an async find-all run; poll runs.get(id) for progress.
      def run(query:, **params)
        @client.request(:post, "/v1/lists/runs", body: compact({ query: query }.merge(params)))
      end
    end
  end
end
