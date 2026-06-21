# Scout Ruby SDK

Official Ruby SDK for the [Scout](https://usescout.sh) web-intelligence API: search, scrape, screenshot, extract, crawl, and company enrichment.

- Built on the Ruby standard library (`net/http`, `json`).
- Automatic retries with backoff and jitter, configurable timeouts, and idempotency keys on writes.

## Requirements

- Ruby 2.7+

## Installation

```sh
gem install scout-sdk
```

Or in a Gemfile:

```ruby
gem "scout-sdk"
```

## Authentication

Generate an API key at [platform.usescout.sh/settings](https://platform.usescout.sh/settings). The client reads `SCOUT_API_KEY` from the environment by default:

```ruby
require "scout"

client = Scout::Client.new                  # uses SCOUT_API_KEY
client = Scout::Client.new(api_key: "sk_...") # or pass it explicitly
```

## Quickstart

```ruby
require "scout"

client = Scout::Client.new

results = client.search.create(
  queries: ["best climate tech startups 2026"],
  depth: "standard",
  country: "us",
)
puts results
```

## Examples

```ruby
# Scrape a page to Markdown
page = client.page.markdown(url: "https://example.com")

# Screenshot
shot = client.page.screenshot(url: "https://example.com", full_page: true, format: "png")

# Structured extraction
data = client.extract.create(
  urls: ["https://example.com/pricing"],
  output_schema: { type: "object", properties: { plans: { type: "array" } } },
)

# Company enrichment + logo
company = client.company.enrich(domain: "stripe.com")
logo = client.company.logo(domain: "stripe.com", format: "svg")

# Crawl a site
crawl = client.site.crawl(start_url: "https://example.com", max_pages: 50, same_host_only: true)

# Chat completion grounded with web search
completion = client.chat.completions.create(
  messages: [{ role: "user", content: "Summarize the latest on EU AI regulation." }],
  web_search: true,
)
```

## Error handling

Every failure is a `Scout::Error`. HTTP errors map to a specific subclass by status code, each carrying `status`, `request_id`, `code`, and the parsed `body`:

```ruby
begin
  client.search.create(queries: ["..."])
rescue Scout::RateLimitError => e
  puts "Slow down. Retry-After: #{e.headers['retry-after']}"
rescue Scout::AuthenticationError
  puts "Check your API key."
rescue Scout::Error => e
  puts "#{e.status} #{e.request_id} #{e.message}"
end
```

| Status | Error class |
|--------|-------------|
| 400 | `Scout::BadRequestError` |
| 401 | `Scout::AuthenticationError` |
| 402 | `Scout::InsufficientCreditsError` |
| 403 | `Scout::PermissionDeniedError` |
| 404 | `Scout::NotFoundError` |
| 409 | `Scout::ConflictError` |
| 422 | `Scout::UnprocessableEntityError` |
| 429 | `Scout::RateLimitError` |
| >=500 | `Scout::InternalServerError` |
| network | `Scout::ConnectionError` / `Scout::TimeoutError` |

## Retries & timeouts

Transient failures (connection errors, timeouts, 408/409/429/5xx) are retried automatically, **2 times by default**, with exponential backoff and jitter, honoring `Retry-After`. Write methods send an auto-generated `Idempotency-Key`.

```ruby
client = Scout::Client.new(timeout: 30, max_retries: 4)
```

## Auto-pagination

List endpoints return an `Enumerator` that walks every page for you:

```ruby
client.search.iterate.each { |run| puts run }
client.monitors.iterate.each { |monitor| puts monitor }
```

## Streaming

Stream chat completions and live run progress (search, jobs, find-all, monitors). Each returns an `Enumerator`, or takes a block:

```ruby
# Token-by-token chat
client.chat.completions.stream(messages: [{ role: "user", content: "Summarize EU AI regulation." }]) do |chunk|
  print chunk["choices"][0]["delta"]["content"].to_s
end

# Live progress events from a deep-search run
client.search.stream_events(search_id) do |event|
  puts event["type"]
end
```

`stream_events` is also available on `jobs`, `lists.runs`, and `monitors`.

## Versioning

This SDK follows [SemVer](https://semver.org/) and sends the targeted Scout API version on every request; see [`CHANGELOG.md`](./CHANGELOG.md).

## Contributing

Issues and pull requests are welcome at [Scout-AI-Labs/scout-ruby](https://github.com/Scout-AI-Labs/scout-ruby).

## License

[MIT](./LICENSE)
