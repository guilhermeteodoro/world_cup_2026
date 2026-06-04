# 6. Presentation Layer Organization

Date: 2026-06-03

## Status

Accepted

## Context

The application uses Phlex for views and components, with RubyUI as the low-level component library. As the codebase grows, storing pages, layouts, reusable UI elements, and domain-specific compositions all under `app/views` and `app/components` makes navigation harder and reduces architectural clarity.

The existing structure conflates:

* Route-backed response artifacts (`app/views/`)
* Domain-free building blocks (`app/components/ruby_ui/`)
* Domain-aware reusable compositions (`app/components/nav.rb`, `app/components/sticker_list.rb`)
* Page shells (`app/components/layout.rb`)

## Decision

The application adopts the following structure:

```text
app/
├── views/
│   ├── base.rb
│   ├── logged_in.rb
│   ├── pages/
│   ├── users/
│   └── ...
│
├── ui/
│   ├── base.rb
│   ├── components/
│   │   ├── ruby_ui/
│   │   └── locale_switcher.rb
│   ├── fragments/
│   │   ├── nav.rb
│   │   ├── user_menu.rb
│   │   ├── sticker_list.rb
│   │   └── collection_importer.rb
│   └── layouts/
│       └── application.rb
│
├── javascript/
├── controllers/
├── models/
└── ...
```

### app/ui/base.rb

`UI::Base` — the shared Phlex superclass for all UI layers. Includes Rails helpers (routes, `t`), registers common elements, includes RubyUI. Analogous to `ApplicationRecord` or `ApplicationController`.

### app/views/

Route-backed Phlex pages and their base classes (`Views::Base`, `Views::LoggedIn`). Also conventional Rails templates (ERB, Jbuilder). Reusable UI elements must not live here.

### app/ui/components/

Domain-free visual building blocks. No knowledge of stickers, users, trades, or any business concept. RubyUI lives here at `app/ui/components/ruby_ui/`, keeping its `RubyUI::*` namespace.

### app/ui/fragments/

Reusable domain-aware UI compositions. May reference business concepts. Sibling dependencies are allowed (a fragment may render another fragment).

### app/ui/layouts/

Page structures and application shells. Not routable pages.

### Dependency Direction

```text
Views (may use any layer below)
  ↓
Layouts (no sibling deps)
  ↓
Fragments (may compose other Fragments)
  ↓
Components (no sibling deps, may use RubyUI)
```

No upward dependencies. A component must not reference a fragment. A fragment must not reference a layout or view.

### Inflection

`UI` is added as an acronym in `inflections.rb` so Rails resolves `app/ui/` to the `UI::` namespace.

## Consequences

### Positive

* Clear separation between pages and reusable UI.
* Easier navigation and discoverability.
* Scales well as the Phlex codebase grows.
* Preserves Rails conventions around views and responses.
* RubyUI stays updatable via its generators.

### Negative

* Introduces an additional top-level directory (`app/ui`).
* Requires discipline to maintain boundaries.

## Decision Guide

1. Final application response? → `app/views/`
2. Generic visual building block (no domain knowledge)? → `app/ui/components/`
3. Reusable domain-specific composition? → `app/ui/fragments/`
4. Page structure or application shell? → `app/ui/layouts/`
