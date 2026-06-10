# Purpose

Phlex-based presentation layer. All UI rendering goes here — not in `app/views/` (see ADR-0006).

# Ownership

- `components/` — reusable UI atoms (locale switcher, RubyUI library wrappers)
- `fragments/` — domain-specific composable UI pieces (sticker list, album grid, nav, collection importer)
- `layouts/` — page layout wrappers (application layout)

# Local Contracts

- Components are generic and reusable across contexts
- Fragments are domain-aware and compose components
- Layouts wrap full pages and handle head/body/nav structure
- All classes live under `UI::Components`, `UI::Fragments`, or `UI::Layouts` modules
- Views (full pages) live in `app/views/` as Phlex classes under `Views::` module — they compose fragments and components

# Work Guidance

- Use Phlex's `def view_template` method
- Components accept keyword args, not positional
- Fragments may query-render sticker data (they receive collections, not raw queries)
- Test UI rendering via `ComponentTestHelper` in view tests
- RubyUI components are vendored wrappers — don't modify directly
- Check ADR-0004 for i18n key conventions in Phlex

# Child DOX Index

- [components/_index.md](components/_index.md) — reusable UI atoms
- [fragments/_index.md](fragments/_index.md) — domain-specific composable pieces
