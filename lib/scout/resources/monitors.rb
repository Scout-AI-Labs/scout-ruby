# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Scheduled searches ("monitors"): run a query on a cadence and receive new
    # results via webhook.
    class Monitors < Base
      # Create a monitor with a query: and a cadence: or cron: schedule.
      def create(query:, **params)
        @client.request(:post, "/v1/monitors", body: compact({ query: query }.merge(params)))
      end

      def list(limit: nil, offset: nil)
        @client.request(:get, "/v1/monitors", query: { limit: limit, offset: offset })
      end

      def iterate(limit: 50, &block)
        paginate("/v1/monitors", limit: limit, &block)
      end

      def get(monitor_id)
        @client.request(:get, "/v1/monitors/#{monitor_id}")
      end

      # Update a monitor's query, schedule, or webhook.
      def update(monitor_id, **params)
        @client.request(:patch, "/v1/monitors/#{monitor_id}", body: compact(params))
      end

      def delete(monitor_id)
        @client.request(:delete, "/v1/monitors/#{monitor_id}")
      end

      def pause(monitor_id)
        @client.request(:post, "/v1/monitors/#{monitor_id}/pause")
      end

      def resume(monitor_id)
        @client.request(:post, "/v1/monitors/#{monitor_id}/resume")
      end

      def run(monitor_id)
        @client.request(:post, "/v1/monitors/#{monitor_id}/run")
      end

      def events(monitor_id)
        @client.request(:get, "/v1/monitors/#{monitor_id}/events")
      end

      # Stream a monitor's events live (SSE).
      def stream_events(monitor_id, &block)
        stream_sse("/v1/monitors/#{monitor_id}/events", &block)
      end
    end
  end
end
