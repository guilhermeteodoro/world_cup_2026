# Purpose

Domain-specific composable UI pieces.

# Local Contracts

- `StickerList` — groups stickers by country, renders as monospace `CODE: 1, 2, 3`. Optional `copyable: true` for clipboard button.
- `AlbumGrid` — interactive card grid. Each card is a controller wrapper with: a placeholder (in-flow, sets height), a hover wrapper (owns `scale` transition), a cardGroup (owns `clip-path` for fold + inline transform/filter), a topCard (color/border/text), a fold-flap (clipped square, top-right), and a badge (outside clip-path). Uses `album-card` Stimulus controller for click-to-glue, +/- copies, and state transitions. To-be-glued cards show a folded corner with rotation/offset.
- `CollectionImporter` — shared between registration and collection edit. Contains combobox (import method), textareas, and video tutorial dialog.
- Fragments receive data, don't query. Compose RubyUI components internally.
