# Purpose

Database schema, migrations, and seed data.

# Local Contracts

- Catalog is immutable at runtime (ADR-0001). Seeds load 994 stickers across 49 countries.
- Migrations are append-only in production.
- Test suite shares seeded catalog via transactional rollback.
