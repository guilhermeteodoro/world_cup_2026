# Purpose

HTTP request handlers. Thin — delegate to services, render Phlex views.

# Local Contracts

- Auth: cookie-session (`session[:user_id]` → `current_user`). No password — email-only login.
- Controllers render Phlex view objects: `render Views::Users::ShowOwner.new(user: @user, current_user: current_user)`
- Data passed to views via keyword args — no leaking instance variables.
- `TradesController` handles the trade negotiation lifecycle: create (pre-loaded with balanced suggestion), show, update (add/remove stickers), accept, cancel, index.
- `ReceiptsController` handles the receipt confirmation phase (after agreement): toggle confirm/unconfirm per trade_sticker, end confirmation (triggers state transitions for confirmed stickers). Nested under trades (`/trades/:trade_id/receipts`).
- Trade creation computes the balanced trade at request time (ADR-0002) and persists it as the starting point for negotiation.
- Modifying a trade resets the other participant's acceptance.
- `UserStickersController#glue_all` transitions `to_be_glued` stickers to `glued` (or `duplicate` if already owned). `#update` handles both `copies` param (add/remove duplicates) and `state` param (glue a `to_be_glued` sticker).
- Flash messages use i18n keys.
- Soft delete via `discard!` — never `destroy!` for user-facing deletions (trades, user_stickers).
- Guard invalid state transitions in controller actions (e.g., check `agreed?` before `discard!`). Never override gem methods like `discard` — use explicit checks.
- `AnonymousTradesController` handles one-sided bookkeeping for trades with non-users. Self-referencing trade (user_a = user_b = current_user), immediately agreed + confirmed, soft-deletes given duplicates and creates `to_be_glued` rows for received stickers.
