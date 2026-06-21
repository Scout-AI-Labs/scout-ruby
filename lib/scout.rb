# frozen_string_literal: true

require_relative "scout/version"
require_relative "scout/errors"
require_relative "scout/client"

# Scout - official Ruby SDK for the Scout web-intelligence API.
#
#   require "scout"
#   client = Scout::Client.new            # reads SCOUT_API_KEY
#   client.search.create(queries: ["climate tech startups"])
module Scout
end
