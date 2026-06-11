# Purpose

Service objects for multi-step business operations.

# Local Contracts

- All services: initialize with dependencies, call with `#call`, return structured results.
- Parser pipeline: `DumpParser` and `ManualParser` both produce `{ owned: Set<position>, duplicates: Hash<position, copies> }`. `CollectionImporter` consumes that structure.
- `StickerListParser` delegates line parsing to `ManualParser.parse_team_lines` (shared regex logic).
- Parsers raise `ParseError` on invalid input — never return partial results.
- `CollectionImporter` is destructive: soft-deletes all existing `user_stickers` and trades, then bulk-inserts new rows with `state: glued` and `state: duplicate` from the parsed data.
- `TradeComparer` returns `Result` (Data.define) with: `a_gives_b`, `b_gives_a`, `balanced` (by category), `leftovers`.
- `TradeExporter` is read-only — computes a virtual post-trade state without persisting. Uses `position` for dump serialization.

# Work Guidance

- Use `Data.define` for structured return values (not hashes).
- Test parser edge cases in service tests, not integration tests.
