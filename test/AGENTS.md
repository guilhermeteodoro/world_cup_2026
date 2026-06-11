# Purpose

Test suite (Minitest).

# Local Contracts

- `integration/` — happy-path smoke tests: routes, redirects, status codes. No HTML content assertions.
- `services/` — business logic, parser edge cases, error handling.
- `views/` — Phlex rendering via `ComponentTestHelper`, assert HTML with Nokogiri.
- Sticker catalog seeded once at suite startup, shared via transactional rollback. Don't re-seed or depend on seed order.

# Work Guidance

- **Minimal data** — create only the records needed for the assertion. Use small inline dumps (`"SA26|1|1-5|1:1"`) instead of `sample_dump`. A test for balanced trading needs 5 stickers per user, not 591.
- **No content assertions in integration tests** — if you're asserting `response.body` includes specific text, it probably belongs in a view test.
- **Edge cases in unit tests** — integration tests cover the happy path. Parser edge cases, empty states, error handling, and rendering variations go in service or view tests.

# Verification

```bash
bin/rails test
```
