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

      # Stream a chat completion as OpenAI-style chunk hashes. Read token text
      # from chunk["choices"][0]["delta"]["content"]. Returns an Enumerator
      # when no block is given.
      def stream(messages:, **params, &block)
        body = compact({ messages: messages, stream: true }.merge(params))
        enum = Enumerator.new do |y|
          @client.stream(:post, "/v1/chat/completions", body: body) do |evt|
            break if evt[:data] == "[DONE]"

            y << JSON.parse(evt[:data])
          end
        end
        block ? enum.each(&block) : enum
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
