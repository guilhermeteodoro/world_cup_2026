# Purpose

Domain entities. Thin models — associations, validations, scopes, computed attributes.

# Local Contracts

- `UserSticker` row exists = owned (glued). `copies` field = tradeable extras beyond the glued one. No row = missing.
- `Trade` links two users (`user_a`/`user_b`) — order is arbitrary (initiator is `user_a`).
- `TradeSticker` records direction: `giver` and `receiver` per sticker.
- `TradeParticipation` is a virtual model (ActiveModel, no table) — built by `User#trade_history` from Trade records.
- Sticker catalog (994 stickers, 49 countries) is seeded, immutable at runtime (ADR-0001).
- `Sticker.category` → `shiny`, `coke`, or `normal` (definitions in CONTEXT.md).
- `position` (1–994) is the internal sequential ID used by dump format. `number` is the per-country display number.
