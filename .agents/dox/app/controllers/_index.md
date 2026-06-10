# Purpose

HTTP request handlers. Thin controllers that delegate to services and render Phlex views.

# Ownership

- `ApplicationController` — base: session auth, locale detection, `current_user` helper
- `PagesController` — static pages (home)
- `RegistrationsController` — new user signup with collection import
- `SessionsController` — email-based login/logout (no password)
- `UsersController` — profile show (owner vs visitor views), edit, update
- `CollectionsController` — collection re-import (edit/update)
- `UserStickersController` — individual sticker glue/unglue/copy adjustments (AlbumGrid interactions)
- `TradesController` — trade consolidation (create) and post-trade export
- `DiffsController` — sticker list diff tool (show form + create comparison)

# Local Contracts

- Auth is cookie-session based: `session[:user_id]` → `current_user`
- Controllers render Phlex view objects (e.g., `Views::Users::ShowOwner.new(...)`)
- No business logic in controllers — delegate to services
- Flash messages use i18n keys

# Work Guidance

- Use `before_action` for auth guards (`require_login`, `require_owner`)
- Pass only the data the view needs — no instance variables leaking
- Trade creation computes balanced trade at request time (see ADR-0002)
