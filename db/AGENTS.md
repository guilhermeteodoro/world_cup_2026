# Purpose

Database schema, migrations, and seed data.

# Local Contracts

- Catalog is immutable at runtime (ADR-0001). Seeds load 994 stickers across 49 countries.
- Migrations are append-only in production.
- Test suite shares seeded catalog via transactional rollback.
- All tables have `deleted_at` column for soft deletion (discard gem, `default_scope -> { kept }` in ApplicationRecord).
- `user_stickers.state` is a string column (`glued`, `duplicate`, `to_be_glued`). No DB-level default — model owns defaults.
- Partial unique index `index_user_stickers_unique_glued` on `[user_id, sticker_id] WHERE state = 'glued' AND deleted_at IS NULL` prevents double-glue.

# Schema Conventions

- **Models own defaults and validations.** Do not add default values at the database level.
- **DB-level constraints only for race conditions and data integrity** that can't be guaranteed at the app layer: unique indexes, foreign keys, not-null on columns that would corrupt data if nil.
- When in doubt, keep the constraint in the model and add a DB constraint only if concurrent requests could violate it.
- **Prefer datetime columns over booleans.** A boolean can always be inferred from a datetime (`present?` = true). Datetimes carry more information (when it happened) at no extra cost. Use `_at` suffix (e.g., `confirmed_at`, `auto_agreed_at`).
