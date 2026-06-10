# Purpose

ActiveRecord models representing the domain: users, stickers, collections, and trades.

# Ownership

- `User` — registered collector with email login, slug-based public profile
- `Sticker` — a single collectible item (belongs to Country, has position/number/category)
- `Country` — album group (code, emoji, color, group_name)
- `UserSticker` — pivot: user owns sticker, `copies` tracks tradeable extras
- `Trade` — persisted record of a consolidated balanced trade between two users
- `TradeSticker` — pivot: links trade to sticker with giver/receiver
- `TradeParticipation` — virtual model (ActiveModel) for one user's view of a trade

# Local Contracts

- `UserSticker` row exists = user owns that sticker (glued). `copies` = extra tradeable copies.
- No `UserSticker` row = sticker is missing from user's collection.
- `Trade` has `user_a` and `user_b` — order is arbitrary (whoever initiated is `user_a`).
- `Sticker.category` returns one of: `shiny`, `coke`, `normal` (see CONTEXT.md for definitions).
- The sticker catalog (994 stickers, 49 countries) is seeded data — never modified at runtime.

# Work Guidance

- Keep models thin: associations, validations, scopes, simple computed attributes
- Complex multi-model operations belong in services
- Use `position` (1–994) for dump format operations, `number` for display format
- `TradeParticipation` is virtual — no table, built from Trade records via `User#trade_history`
