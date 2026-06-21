# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # Async tasks ("jobs"): submit a task, then poll or stream events.
    class Jobs < Base
      # Submit a job. Returns a task id to poll with get(task_id).
      def create(task:, **params)
        @client.request(:post, "/v1/jobs", body: compact({ task: task }.merge(params)))
      end

      def list(limit: nil, offset: nil)
        @client.request(:get, "/v1/jobs", query: { limit: limit, offset: offset })
      end

      def iterate(limit: 50, &block)
        paginate("/v1/jobs", limit: limit, &block)
      end

      def get(task_id)
        @client.request(:get, "/v1/jobs/#{task_id}")
      end

      def cancel(task_id)
        @client.request(:post, "/v1/jobs/#{task_id}/cancel")
      end

      def events(task_id)
        @client.request(:get, "/v1/jobs/#{task_id}/events")
      end

      def start_run(**body)
        @client.request(:post, "/v1/jobs/runs", body: compact(body))
      end

      def run_result(run_id)
        @client.request(:get, "/v1/jobs/runs/#{run_id}")
      end

      def run_events(run_id)
        @client.request(:get, "/v1/jobs/runs/#{run_id}/events")
      end
    end
  end
end
