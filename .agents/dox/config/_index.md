# Purpose

Rails configuration: routes, environments, initializers, locales, database.

# Ownership

- `routes.rb` — URL structure (RESTful, nested under users)
- `environments/` — per-environment settings (development, test, production)
- `initializers/` — boot-time setup (Phlex, RubyUI, CSP, assets)
- `locales/` — i18n translations (en.yml, pt-BR.yml)
- `database.yml` — SQLite config for all environments

# Local Contracts

- Routes use `param: :slug` for users (not `:id`)
- Production DB lives at `/var/data/production.sqlite3` (Render persistent disk)
- Two locales: `en` (default) and `pt-BR`
- Phlex initializer registers the `app/ui/` autoload path

# Work Guidance

- Route changes must match controller actions and Phlex view paths
- Add i18n keys to both locale files when adding user-facing text
- Don't modify credentials without explicit consent
