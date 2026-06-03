# Sticker Trader

Web app for World Cup 2026 sticker collectors to find and record trades with friends.

Based on the [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) app (by MoovTech — https://moovtech.app/stickers2026/), which tracks owned and duplicate stickers and provides a dump/restore feature.

## Language

**Sticker**:
A collectible item identified by a country code and number (e.g. BRA 5). Physically printed and glued into an album.
_Avoid_: Card, figurinha (in code)

**Country**:
A group in the album (e.g. BRA, FWC, CC). Has a code, emoji flag, and localized name via i18n. Not always a real country (FWC = FIFA World Cup, CC = Coca-Cola).
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
A user's sticker state, represented by the `user_stickers` pivot table. Row exists = user owns that sticker (glued). The `copies` attribute tracks tradeable extras.
_Avoid_: Album, inventory

**Copies**:
The number of extra tradeable copies a user has beyond the one glued. 0 = owned but no extras. No row = missing entirely.
_Avoid_: Quantity, count, duplicates (as column name)

**Missing**:
A sticker not present in the user's collection at all — no `user_stickers` row exists.
_Avoid_: Needed, wanted

**Duplicate**:
An extra copy of a sticker available for trading. A sticker is a duplicate when its `user_stickers.copies > 0`.
_Avoid_: Spare, extra, surplus

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
A suggested 1:1 exchange within the same category, capped at the minimum each side can offer. Shiny for shiny, coke for coke, normal for normal. Stickers selected in album order.
_Avoid_: Fair trade, even swap

**Leftovers**:
Duplicates that couldn't be matched within their category in a balanced trade. Available for cross-category negotiation.
_Avoid_: Remainder, unmatched

**Trade participation**:
A virtual model (ActiveModel) representing one user's perspective of a trade. Has other_user, given stickers, received stickers, and confirmed_at. Built by `User#trade_history` from the Trade records.
_Avoid_: Trade entry, trade record

**Trade**:
A persisted record of a consolidated balanced trade between two users. Links to the specific stickers exchanged via `trade_stickers`.
_Avoid_: Swap, exchange

**Trade sticker**:
A pivot record linking a trade to a specific sticker, with a giver and receiver. Records who gave what to whom.
_Avoid_: Trade item, trade line

**User**:
Someone who has registered their name, email, and sticker collection. Identified by a session cookie (email login, no password). Has a public profile at `/u/<slug>`.
_Avoid_: Collector, participant

## Key components

**StickerList**:
Phlex component (`Components::StickerList`) — the standard way to display stickers. Takes a stickers array, groups by country, renders as monospace text. Supports an optional copy-to-clipboard button via `copyable: true`.

**CollectionImporter**:
Phlex component (`Components::CollectionImporter`) — the import method form fields shared between registration and collection edit. Contains a Combobox for method selection, a "How to export?" link that opens a video tutorial dialog, and the dump/manual textareas.

**LocaleSwitcher**:
Phlex component (`Components::LocaleSwitcher`) — flag-based language toggle (🇧🇷/🇬🇧). Used on home page and user settings.

## Example dialogue

> "I have BRA 5 as a duplicate and you're missing it — I can give it to you."
> "You have MEX 11 as a duplicate and I'm missing it — I need it from you."
> "Neither of us has NED 7 — no one can help there."
> "Let's do 11 shiny for 11 shiny, then negotiate the leftovers."
> "I consolidated the trade — now I can see what I gave and received."
