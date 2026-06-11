# Trade export is virtual — collections are not mutated on consolidation

Status: superseded by [ADR-0008](0008-sticker-trader-as-source-of-truth.md)

Consolidating a trade creates `Trade` and `TradeSticker` records but does not update `user_stickers`. The export feature computes a virtual post-trade collection (subtract copies for given stickers, add for received) and serializes it in dump or manual format so the user can paste it into their external sticker app.

We chose this because: (1) the external app remains the source of truth for collection state, (2) trade confirmation/editing isn't implemented yet — the current "consolidate" is a one-click action with no negotiation step, and (3) users will re-import from their external app anyway, which overwrites collection state. Auto-mutating collections would create drift between our data and the external app.

**Consequences:**

- Users must manually apply the export to their external app, then re-dump and re-import to sync.
- When trade history + real confirmation flow are added, we'll need to decide whether consolidation should mutate `user_stickers` directly or keep the virtual approach.
- Re-importing a collection will likely need to reconcile with existing trade history (TBD).
