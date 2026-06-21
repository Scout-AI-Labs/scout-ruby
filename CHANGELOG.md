# Changelog

All notable changes to this project are documented here. This project adheres
to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-06-21

Initial release.

- Zero-dependency client built on the Ruby standard library (`net/http`, `json`).
- Full coverage of the Scout REST API: `search`, `page`, `extract`, `company`, `lists`, `products`, `site`, `jobs`, `monitors`, `chat`.
- Typed error hierarchy (`AuthenticationError`, `RateLimitError`, `InsufficientCreditsError`, ...).
- Automatic retries with exponential backoff + jitter, honoring `Retry-After`.
- Idempotency keys on writes.
- Auto-pagination via `Enumerator` (`#iterate`).
