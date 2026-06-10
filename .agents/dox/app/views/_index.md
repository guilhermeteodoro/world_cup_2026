# Purpose

Phlex view classes that represent full pages. Rendered by controllers. Compose fragments and components into complete pages.

# Ownership

Each subfolder maps to a controller:
- `collections/` — CollectionsController views (Edit)
- `diffs/` — DiffsController views (Show, Create/results)
- `pages/` — PagesController views (Home)
- `registrations/` — RegistrationsController views (New)
- `sessions/` — SessionsController views (New)
- `trades/` — TradesController views (Export)
- `users/` — UsersController views (ShowOwner, ShowVisitor, Edit)

# Local Contracts

- View classes live under `Views::{Controller}::{Action}` (e.g., `Views::Users::ShowOwner`)
- Views are initialized with the data they need (keyword args from controller)
- Views compose UI fragments and components — they don't contain complex logic
- One `.text.erb` template exists for trade comparison clipboard export

# Work Guidance

- Keep views as composition: arrange fragments, pass data, handle conditionals
- Extract repeated visual patterns to fragments
- Use i18n relative keys per ADR-0004
