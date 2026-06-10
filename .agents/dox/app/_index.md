# Purpose

Application source code. Standard Rails layout with one deviation: UI components live in `app/ui/` (ADR-0006).

# Ownership

All runtime application code. This doc owns guidance for `app/helpers/`, `app/assets/`, `app/javascript/`, and `app/jobs/` — folders without their own DOX files.

# Local Contracts

- No business logic in controllers — delegate to services or models
- Services are the boundary for multi-step operations
- UI layer uses Phlex exclusively (no ERB for components)

# Child DOX Index

- [models/_index.md](models/_index.md) — domain entities and their relationships
- [services/_index.md](services/_index.md) — business operations and parser pipeline
- [controllers/_index.md](controllers/_index.md) — request handling contracts
- [ui/_index.md](ui/_index.md) — Phlex presentation layer
- [views/_index.md](views/_index.md) — full-page Phlex view classes
