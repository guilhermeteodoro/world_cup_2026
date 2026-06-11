# Purpose

Phlex-based presentation layer. Replaces `app/views/` for component rendering (ADR-0006).

# Ownership

- `components/` — generic reusable atoms (no domain knowledge)
- `fragments/` — domain-aware composable pieces
- `layouts/` — page wrappers (application layout)

This doc owns `layouts/`. Components and fragments have their own AGENTS.md.

# Local Contracts

- Namespace: `UI::Components::`, `UI::Fragments::`, `UI::Layouts::`
- Components are domain-free. If it needs sticker/trade knowledge → fragment.
- Fragments receive pre-loaded data (arrays, objects) — they don't execute queries.
- Full-page views live in `app/views/` under `Views::` module — they compose fragments.

# Work Guidance

- Test rendering via `ComponentTestHelper` — assert HTML with Nokogiri.
- i18n: use relative keys per ADR-0004.

# Child DOX Index

- [components/AGENTS.md](components/AGENTS.md) — reusable UI atoms
- [fragments/AGENTS.md](fragments/AGENTS.md) — domain-specific composable pieces
