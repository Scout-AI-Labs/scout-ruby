# frozen_string_literal: true

require_relative "base"

module Scout
  module Resources
    # OpenAI-compatible chat completions, optionally grounded with web search.
    class ChatCompletions < Base
      # Create a chat completion. Set web_search: true to ground in live results.
      def create(messages:, **params)
        @client.request(:post, "/v1/chat/completions", body: compact({ messages: messages }.merge(params)))
      end
    end

    class Chat < Base
      attr_reader :completions

      def initialize(client)
        super
        @completions = ChatCompletions.new(client)
      end
    end
  end
end
