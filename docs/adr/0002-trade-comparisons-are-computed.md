# Trade comparisons are computed, not persisted

Trade comparisons between two users are calculated on-the-fly from their live `user_stickers` data rather than stored in a `trades` table. Any logged-in user viewing another user's collection page sees the potential trade immediately.

We considered persisting trades as a table (slug, user_a, user_b) for history and shareable links. We chose stateless computation because the app (Sticker Album 2026) is the source of truth — users re-import after buying packs or trading physically, so any persisted comparison would go stale immediately. A `trades` table can be added later if trade confirmation or history becomes a feature.
