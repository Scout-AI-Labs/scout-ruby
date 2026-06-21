# frozen_string_literal: true

require_relative "lib/scout/version"

Gem::Specification.new do |spec|
  spec.name = "scout-sdk"
  spec.version = Scout::VERSION
  spec.authors = ["Scout AI Labs"]
  spec.summary = "Official Ruby SDK for the Scout web-intelligence API"
  spec.description = "Search, scrape, screenshot, extract, crawl, and company " \
                     "enrichment via the Scout API."
  spec.homepage = "https://usescout.sh"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "homepage_uri" => "https://usescout.sh",
    "source_code_uri" => "https://github.com/Scout-AI-Labs/scout-ruby",
    "bug_tracker_uri" => "https://github.com/Scout-AI-Labs/scout-ruby/issues",
    "changelog_uri" => "https://github.com/Scout-AI-Labs/scout-ruby/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies - built on the Ruby standard library.
end
