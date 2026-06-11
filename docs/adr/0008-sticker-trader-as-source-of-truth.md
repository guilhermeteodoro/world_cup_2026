# Sticker Trader is the source of truth for collections

Status: accepted (supersedes ADR-0005)

Sticker Trader now owns collection state directly. Trades mutate `user_stickers` — giver copies are soft-deleted on receipt confirmation, receiver copies are created as `to_be_glued`. The external Sticker Album 2026 app is no longer the authoritative source; import is an onboarding convenience, and reimporting is a destructive reset.

We chose this because: (1) the AlbumGrid gives users full in-app collection management, making the external app redundant for day-to-day use, (2) the new trade lifecycle (negotiate → agree → confirm receipt) requires the app to track sticker state transitions that can't be deferred to an external tool, and (3) users were already treating Sticker Trader as their primary tool.

**Consequences:**

- `user_stickers` rows represent individual physical copies with states: `glued`, `duplicate`, `to_be_glued`.
- The `copies` column is removed; multiple rows per user+sticker replace it.
- Reimporting a collection is a destructive action that soft-deletes all existing data (stickers, trades) and rebuilds from the dump.
- Soft deletion (via `discard` gem) is used throughout — configured in `ApplicationRecord` with `deleted_at` column on all tables.
