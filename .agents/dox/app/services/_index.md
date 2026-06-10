# Purpose

Service objects that encapsulate business operations involving multiple models or complex logic.

# Ownership

- `DumpParser` — parses SA26 pipe-delimited dump format into owned positions + duplicates
- `ManualParser` — parses human-readable missing/duplicates text lists into same structure
- `StickerListParser` — parses display format (country: numbers) into Sticker records
- `CollectionImporter` — takes parsed data and replaces a user's entire collection
- `TradeComparer` — computes trade opportunities between two users (full diff + balanced suggestion)
- `TradeExporter` — builds virtual post-trade collection state and serializes to dump/manual formats

# Local Contracts

- Parsers return `{ owned: Set<position>, duplicates: Hash<position, copies> }`
- Parsers raise `ParseError` on invalid input (never return partial results)
- `TradeComparer#call` returns a `Result` Data object with `a_gives_b`, `b_gives_a`, `balanced`, `leftovers`
- `CollectionImporter` is destructive: wipes existing `user_stickers` and bulk-inserts
- `TradeExporter` is read-only: computes a virtual state without persisting

# Work Guidance

- Services are initialized with dependencies, called with `#call`
- Use `Data.define` for structured return values
- Parsers must handle the Sticker Album 2026 app's exact export format
- `StickerListParser` delegates line parsing to `ManualParser.parse_team_lines` (shared logic)
- Test edge cases in service tests, not integration tests
