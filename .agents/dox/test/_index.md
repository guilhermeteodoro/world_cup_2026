# Purpose

Test suite. Minitest with Rails test helpers.

# Ownership

- `integration/` — broad smoke tests: routes, redirects, status codes
- `services/` — service object unit tests (parsers, comparer, importer, exporter)
- `views/` — Phlex component/fragment rendering tests via ComponentTestHelper

# Local Contracts

- Integration tests: happy-path only, no HTML content assertions
- View tests: render Phlex components directly, assert HTML with Nokogiri
- Service tests: edge cases, error handling, business logic in isolation
- Sticker catalog (994 stickers, 49 countries) is seeded once at suite startup — shared via transactional rollback

# Work Guidance

- Minimal data: create only records needed for the assertion
- Use small inline dumps (`"SA26|1|1-5|1:1"`) instead of `sample_dump`
- Don't re-seed or depend on seed order
- Run full suite: `bin/rails test`

# Verification

```bash
bin/rails test
```
