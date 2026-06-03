# ⚽ Sticker Trader

Web app for World Cup 2026 sticker collectors to find and record trades with friends.

## What it does

1. Register your sticker collection (import from the [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) app or paste manually)
2. Share your profile link (`/u/<slug>`) with a friend
3. Friend registers their collection
4. Both see a trade comparison: what you can give each other, with a balanced suggestion by category
5. Consolidate a trade to keep a record of what was exchanged

## Concepts

Stickers are classified into three **categories** that determine trade fairness:

- **Shiny** — FWC stickers (00–19) + sticker 1 of every country (68 total)
- **Coke** — CC stickers (1–14) (14 total)
- **Normal** — everything else (912 total)

The app suggests balanced trades within each category and lists leftovers for cross-category negotiation.

## Import methods

### 1. Sticker Album 2026 app export (dump)

Paste the pipe-delimited string from the app's dump/restore feature:

```
SA26|1|2-3,6,9-13,...|10:1,38:3,...
```

### 2. Manual (text format)

Paste your **missing stickers** list and your **duplicates** list. Supports emoji prefixes/suffixes and plain numbers:

```
🇧🇷 BRA: 2, 3, 4, 6
MEX 🇲🇽: 5, 8, 9
```

## Tech stack

- Ruby on Rails 8
- PostgreSQL (production) / SQLite (development)
- Phlex 2 (views, composition-based layout)
- RubyUI (components)
- Tailwind CSS 4 + tw-animate-css
- jsbundling-rails (esbuild)
- Hotwire (Turbo + Stimulus)
- i18n (pt-BR + English)

## Development

```bash
bin/setup
bin/dev
```

## Checks

```bash
bundle exec rubocop -A
bin/rails test
```

## Tests

```bash
bin/rails test
```

## Documentation

- [CONTEXT.md](CONTEXT.md) — domain language glossary
- [TASKS.md](TASKS.md) — implementation task plan
- [docs/adr/](docs/adr/) — architecture decision records
- Source app: [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) (MoovTech)
