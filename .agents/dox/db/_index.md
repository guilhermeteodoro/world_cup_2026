# Purpose

Database schema, migrations, and seed data.

# Ownership

- `schema.rb` — authoritative schema (auto-generated)
- `migrate/` — sequential migrations
- `seeds.rb` — sticker catalog seeding (994 stickers, 49 countries)

# Local Contracts

- Schema is the source of truth — never edit manually
- Migrations are append-only in production
- Seeds load the fixed sticker catalog from structured data
- Catalog is immutable at runtime (ADR-0001)

# Work Guidance

- Run `bin/rails db:migrate` after adding migrations
- Never modify seed data without understanding downstream impact on all collections
- Test suite shares seeded catalog via transactional rollback
