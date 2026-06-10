# Purpose

HTTP request handlers. Thin — delegate to services, render Phlex views.

# Local Contracts

- Auth: cookie-session (`session[:user_id]` → `current_user`). No password — email-only login.
- Controllers render Phlex view objects: `render Views::Users::ShowOwner.new(user: @user, current_user: current_user)`
- Data passed to views via keyword args — no leaking instance variables.
- `TradesController` handles the full trade negotiation lifecycle: create (pre-loaded with balanced suggestion), show, update (add/remove stickers), accept, cancel, confirm_receipt, confirm_all_receipts, index.
- Trade creation computes the balanced trade at request time (ADR-0002) and persists it as the starting point for negotiation.
- Modifying a trade resets the other participant's acceptance.
- `UserStickersController#glue_all` transitions `to_be_glued` stickers to `glued` (or `duplicate` if already owned).
- Flash messages use i18n keys.
- Soft delete via `discard!` — never `destroy!` for user-facing deletions (trades, user_stickers).
