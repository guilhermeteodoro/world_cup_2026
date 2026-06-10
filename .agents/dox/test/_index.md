# Purpose

Test suite (Minitest).

# Local Contracts

- `integration/` — happy-path smoke tests: routes, redirects, status codes. No HTML content assertions.
- `services/` — business logic, parser edge cases, error handling.
- `views/` — Phlex rendering via `ComponentTestHelper`, assert HTML with Nokogiri.
- Sticker catalog seeded once at suite startup, shared via transactional rollback. Don't re-seed.

# Work Guidance

- Minimal data: only records needed for assertion. Use inline dumps (`"SA26|1|1-5|1:1"`).
- Content assertions belong in view tests, not integration tests.

# Verification

```bash
bin/rails test
```
