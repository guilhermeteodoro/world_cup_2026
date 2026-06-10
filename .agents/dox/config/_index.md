# Purpose

Rails configuration.

# Local Contracts

- Routes use `param: :slug` for users (not `:id`). Users nested: `/u/:slug/`.
- Two locales: `en` (default), `pt-BR`. Add keys to both when adding user-facing text.
- Production DB: `/var/data/production.sqlite3` (Render persistent disk).
- Phlex autoload path registered in `initializers/phlex.rb`.
