# Purpose

Domain entities. Thin models — associations, validations, scopes, computed attributes.

# Local Contracts

- `UserSticker` represents a physical sticker copy. Each row has a `state`: `glued`, `duplicate`, or `to_be_glued`. Multiple rows per user+sticker allowed (except one glued per sticker, enforced by partial unique index).
- Allocation is inferred: a `duplicate` referenced by a `TradeSticker` in an agreed trade is locked.
- Soft delete via `discard` gem (`deleted_at` column). `default_scope -> { kept }` on `ApplicationRecord` — all queries exclude discarded records unless explicitly unscoped.
- Never override gem methods (`discard`, `destroy`, etc.) to add guards. State checks live in the calling controller.
- `Trade` links two users (`user_a`/`user_b`) — order is arbitrary (initiator is `user_a`). Has `user_a_accepted_at`/`user_b_accepted_at` for negotiation, `user_a_auto_agreed_at`/`user_b_auto_agreed_at` for sticky acceptance, `confirmed_at` for completion, and `user_a_receipt_ended_at`/`user_b_receipt_ended_at` for the receipt confirmation phase.
- Auto-agree: `auto_agree!(user)` sets both `accepted_at` and `auto_agreed_at`. When auto-agreed, `reset_acceptance_for` is a no-op for that user — their acceptance persists through modifications.
- `Trade.between(user_a, user_b)` scope finds trades between two specific users regardless of column order. Use instead of chaining `.involving` twice.
- `TradeSticker` records direction (`giver`/`receiver`) and links to the specific `user_sticker` copy via `user_sticker_id`. Has `confirmed_at` for per-sticker receipt confirmation toggle.
- `TradeParticipation` is virtual (ActiveModel, no table) — built by `User#trade_history` from Trade records.
- Sticker catalog is seeded, immutable at runtime (ADR-0001).
- `position` (1–994) is the internal sequential ID used by dump format. `number` is the per-country display number.
