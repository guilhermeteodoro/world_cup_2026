# Sticker Trader

Web app for World Cup 2026 sticker collectors to find and record trades with friends.

Based on the [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) app (by MoovTech — https://moovtech.app/stickers2026/), which tracks owned and duplicate stickers and provides a dump/restore feature.

## Language

**Sticker**:
A collectible item identified by a country code and number (e.g. BRA 5). Has a name (player name, "Team Logo", or "Team Photo"). Physically printed and glued into an album.
_Avoid_: Card, figurinha (in code)

**Country**:
A group in the album (e.g. BRA, FWC, CC). Has a code, emoji flag, dominant color (hex), group name, and localized name via i18n. Not always a real country (FWC = FIFA World Cup, CC = Coca-Cola).
_Avoid_: Team, group

**Sticker catalog**:
The fixed set of 994 stickers in the album, seeded in the database. Each sticker belongs to a country, has a number, category, and sequential position.
_Avoid_: Card list, checklist

**Category**:
A classification of stickers that determines trade fairness. Three values: shiny, coke, normal.
_Avoid_: Type, tier, rarity

**Shiny**:
A category: all FWC stickers (00–19) plus sticker 1 of every country except CC. 68 total.
_Avoid_: Holographic, special

**Coke**:
A category: all CC stickers (1–14). 14 total.
_Avoid_: Promo, sponsor

**Normal**:
A category: all stickers that are not shiny or coke — stickers 2–20 of every country except FWC and CC. 912 total.
_Avoid_: Regular, common

**Collection**:
A user's full set of sticker copies, represented by `user_stickers` rows. Each physical copy is its own row with a state. A user's active collection is all non-deleted rows.
_Avoid_: Inventory

**Missing**:
A sticker not present in the user's collection at all — no `user_stickers` row exists.
_Avoid_: Needed, wanted

**Duplicate**:
An extra copy of a sticker available for trading. Represented as a `user_sticker` row with state `duplicate`. A user can have multiple duplicate rows for the same sticker.
_Avoid_: Spare, extra, surplus

**Glue**:
The act of applying a sticker to the album. Transitions a `to_be_glued` row to `glued`, or creates a `glued` row directly on import.
_Avoid_: Add, own, collect

**Unglue**:
The destructive act of removing a glued sticker from the album. Soft-deletes the row. In the real world, ungluing almost always trashes the sticker.
_Avoid_: Remove, delete

**To be glued**:
A sticker copy that has been received (from a trade or other source) but not yet applied to the album. Displayed in the AlbumGrid as a slightly rotated card over an empty slot. Tapping glues it.
_Avoid_: Available, received, pending

**Allocated**:
An inferred state (not stored). A `duplicate` sticker referenced by a `trade_sticker` in an agreed trade. Cannot be offered in other trades (exclusive allocation).
_Avoid_: Locked, reserved, committed

**Dump**:
A pipe-delimited string exported by the Sticker Album 2026 app that encodes owned stickers (as sequential ID ranges) and duplicates (as ID:count pairs). Format: `SA26|1|<owned_ranges>|<duplicates>`.
_Avoid_: Export, backup

**Sticker list diff**:
A utility that takes two arbitrary sticker lists (in display format) and shows what's in each list that isn't in the other. Operates on parsed text resolved against the sticker catalog.
_Avoid_: Compare (reserved for trade comparison between users)

**Trade comparison**:
A computed view showing what a logged-in user can exchange with another user. Calculated on-the-fly from both users' live collections.
_Avoid_: Trade session, swap

**Balanced trade**:
A suggested 1:1 exchange within the same category, capped at the minimum each side can offer. Shiny for shiny, coke for coke, normal for normal. Stickers selected in album order. Used as the starting point when creating a new trade.
_Avoid_: Fair trade, even swap

**Leftovers**:
Duplicates that couldn't be matched within their category in a balanced trade. Available for cross-category negotiation.
_Avoid_: Remainder, unmatched

**Trade**:
A persisted negotiation between two users. Has its own URL (`/trades/:id`). Created with the balanced suggestion pre-loaded, both users can modify freely until agreement. Private to participants only.
_Avoid_: Swap, exchange

**Agreement**:
The state when both trade participants have accepted the current sticker arrangement. Either user modifying the trade resets the other's acceptance. Agreement locks (allocates) the stickers involved.
_Avoid_: Confirmation, deal

**Receipt confirmation**:
A two-phase process after agreement. Phase 1: the receiver toggles individual stickers as confirmed/unconfirmed (`trade_sticker.confirmed_at`). Phase 2: the receiver "ends confirmation" — confirmed stickers trigger the state transition (giver's copy soft-deleted, receiver gets a `to_be_glued` row); unconfirmed stickers are left untransitioned. Each side ends independently (`user_a_receipt_ended_at` / `user_b_receipt_ended_at`).
_Avoid_: Delivery confirmation

**Anonymous trade**:
A one-sided bookkeeping entry for trades with non-users. No negotiation or receipt dance — state transitions happen immediately. Records what was given and received.
_Avoid_: Offline trade, unregistered trade

**Trade sticker**:
A pivot record linking a trade to a specific sticker copy (`user_sticker`), with a giver and receiver. Records who gave what to whom.
_Avoid_: Trade item, trade line

**Trade participation**:
A virtual model (ActiveModel) representing one user's perspective of a trade. Has other_user, given stickers, received stickers, and confirmed_at. Built by `User#trade_history` from the Trade records.
_Avoid_: Trade entry, trade record

**User**:
Someone who has registered their name, email, and sticker collection. Identified by a session cookie (email login, no password). Has a public profile at `/u/<slug>`.
_Avoid_: Collector, participant

## Key components

**StickerList**:
Phlex fragment (`UI::Fragments::StickerList`) — the standard way to display stickers as text. Takes a stickers array, groups by country, renders as monospace text. Supports an optional copy-to-clipboard button via `copyable: true`.

**AlbumGrid**:
Phlex fragment (`UI::Fragments::AlbumGrid`) — interactive card grid for managing a collection. Displays stickers as colored cards grouped by country in collapsible sections. Cards can be tapped to glue/unglue, with +/- buttons for tracking copies.

**CollectionImporter**:
Phlex fragment (`UI::Fragments::CollectionImporter`) — the import method form fields shared between registration and collection edit. Contains a Combobox for method selection, a "How to export?" link that opens a video tutorial dialog, and the dump/manual textareas.

**LocaleSwitcher**:
Phlex component (`UI::Components::LocaleSwitcher`) — flag-based language toggle (🇧🇷/🇬🇧). Used on home page and user settings.

## Example dialogue

> "I have BRA 5 as a duplicate and you're missing it — I can give it to you."
> "You have MEX 11 as a duplicate and I'm missing it — I need it from you."
> "Neither of us has NED 7 — no one can help there."
> "Let's do 11 shiny for 11 shiny, then negotiate the leftovers."
> "I created the trade with the suggestion loaded — tweak it if you want."
> "I accepted — your turn. If you change anything I'll need to re-accept."
> "We agreed — now I'm waiting to receive the stickers."
> "Got all 11 — confirming receipt. Now I have 11 stickers to be glued."
> "Glue all — done, they're in my album."
