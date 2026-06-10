# Purpose

Domain-specific composable UI pieces. Each fragment renders a meaningful chunk of the sticker-trader UI.

# Ownership

- `StickerList` — renders stickers as grouped monospace text, optional copy-to-clipboard
- `AlbumGrid` — interactive card grid for managing a collection (glue/unglue, +/- copies)
- `CollectionImporter` — import method form (combobox + dump/manual textareas + video tutorial dialog)
- `Nav` — top navigation bar
- `UserMenu` — user dropdown menu

# Local Contracts

- Fragments receive pre-loaded data (sticker arrays, user objects) — they don't execute queries
- `StickerList` groups by country, formats as `CODE: 1, 2, 3`
- `AlbumGrid` emits Turbo Frame interactions for `UserStickersController`
- `CollectionImporter` is shared between registration and collection edit flows

# Work Guidance

- Fragments compose RubyUI components and plain HTML
- Keep fragments focused on one visual concern
- Test rendering via `ComponentTestHelper` — assert HTML structure with Nokogiri
