# Purpose

Domain-specific composable UI pieces.

# Local Contracts

- `StickerList` — groups stickers by country, renders as monospace `CODE: 1, 2, 3`. Optional `copyable: true` for clipboard button.
- `AlbumGrid` — interactive card grid. Emits Turbo Frame requests to `UserStickersController` for glue/unglue/copy changes.
- `CollectionImporter` — shared between registration and collection edit. Contains combobox (import method), textareas, and video tutorial dialog.
- Fragments receive data, don't query. Compose RubyUI components internally.
