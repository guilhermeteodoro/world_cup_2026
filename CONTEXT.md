# Sticker Album 2026

Tool to compare World Cup 2026 sticker album dumps between collectors and find trading opportunities.

Based on the [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) app (by MoovTech — https://moovtech.app/stickers2026/), which tracks owned and duplicate stickers and provides a dump/restore feature.

## Language

**Sticker**:
A collectible item identified by a team code and number (e.g. BRA 5). Physically printed and glued into an album.
_Avoid_: Card, figurinha (in code)

**Owned**:
A sticker that has been glued into the album. The collector has exactly one copy pasted.
_Avoid_: Collected, have

**Duplicate**:
An extra copy of a sticker beyond the one glued. Available for trading.
_Avoid_: Spare, extra, surplus

**Missing**:
A sticker not present in the album at all — the collector has zero copies.
_Avoid_: Needed, wanted

**Dump**:
A pipe-delimited string exported by the app that encodes owned stickers (as sequential ID ranges) and duplicates (as ID:count pairs). Format: `SA26|1|<owned_ranges>|<duplicates>`.
_Avoid_: Export, backup

**Trade**:
An exchange where collector A gives duplicates that B is missing, and vice versa. Always pairwise.
_Avoid_: Swap, exchange

**Shiny**:
A special category of stickers: all FWC stickers (00–19) plus sticker 1 of every other team. 69 total.
_Avoid_: Holographic, special

**Coke**:
The Coca-Cola promo sticker category: all CC stickers (1–14). 14 total.
_Avoid_: Promo, sponsor

**Normal**:
All stickers that are not Shiny or Coke — stickers 2–20 of every team except FWC and CC. 911 total.
_Avoid_: Regular, common

**Balanced trade**:
A suggested 1:1 exchange within the same category, capped at the minimum each side can offer. Shiny for shiny, coke for coke, normal for normal.
_Avoid_: Fair trade, even swap

**Leftovers**:
Duplicates that couldn't be matched within their category in a balanced trade. Available for cross-category negotiation.
_Avoid_: Remainder, unmatched

## Example dialogue

> "I have BRA 5 as a duplicate and you're missing it — I can give it to you."
> "You have MEX 11 as a duplicate and I'm missing it — I need it from you."
> "Neither of us has NED 7 — no one can help there."
