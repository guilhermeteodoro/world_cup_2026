# Figurinhas 2026

Web app for World Cup 2026 sticker collectors to find trades with friends.

## What it does

1. Register your sticker collection (import from the [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) app or paste manually)
2. Share your profile link with a friend
3. Friend registers their collection
4. Both see a trade comparison: what you can give each other, with a balanced suggestion by category

## Concepts

Stickers are classified into three **categories** that determine trade fairness:

- **Shiny** — FWC stickers (00–19) + sticker 1 of every team (69 total)
- **Coke** — CC stickers (1–14) (14 total)
- **Normal** — everything else (911 total)

The app suggests balanced trades within each category (shiny for shiny, coke for coke, normal for normal) and lists leftovers for cross-category negotiation.

## Import methods

### 1. Sticker Album 2026 app export (dump)

Paste the pipe-delimited string from the app's dump/restore feature:

```
SA26|1|2-3,6,9-13,...|10:1,38:3,...
```

### 2. Manual (text format)

Paste your **missing stickers** list and your **duplicates** list as exported by the app's share feature:

**Missing:**
```
FWC: 00, 3, 4, 6, 7, 13, 14, 15, 19
BRA: 2, 3, 4, 6, 7, 8, 10, 11, 15, 16, 19, 20
...
```

**Duplicates:**
```
FWC: 9(1x), 10(1x), 12(1x)
MEX: 4(3x), 5(1x), 8(3x)
...
```

## User flow

```
┌─────────────────────────────────────────────────────┐
│  User A visits site                                 │
│  → Picks import method                             │
│  → Enters name + pastes sticker data               │
│  → Account created (session cookie)                │
│  → Lands on their collection page /u/<slug>        │
│  → Shares link with friend                         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Friend (logged out) opens /u/<slug>               │
│  → Sees User A's stats + duplicates list           │
│  → Decides to register                            │
│  → Same flow: name + sticker data → account        │
│  → Now logged in, views /u/<slug> again            │
│  → Sees full trade comparison                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Updating collection                               │
│  → User updates stickers in the mobile app         │
│  → Re-exports, pastes fresh data on the site       │
│  → Full re-import (wipe + replace)                 │
│  → All trade comparisons reflect new state         │
└─────────────────────────────────────────────────────┘
```

## Tech stack

- Ruby on Rails 8
- PostgreSQL
- Phlex (views)
- RubyUI (components)
- Tailwind CSS
- Hotwire (Turbo Drive + Turbo Frames)
- Deployed on [Render](https://render.com/)

## Schema

```
users
  id
  slug (unique)
  name (string)
  created_at / updated_at

stickers (seeded — 994 rows)
  id
  team (string — "FWC", "CC", "BRA", etc.)
  number (string — "00", "1", "2", ..., "20")
  category (enum — shiny, coke, normal)
  position (integer — sequential 1–994 for ordering)

user_stickers (pivot)
  user_id (FK → users)
  sticker_id (FK → stickers)
  copies (integer, default: 0 — tradeable extras)
  unique index on [user_id, sticker_id]
```

## Architecture decisions

See [docs/adr/](docs/adr/) for recorded decisions.

## Development

```bash
bin/setup
bin/dev
```

## Related

- [CONTEXT.md](CONTEXT.md) — domain language glossary
- Source app: [Sticker Album 2026](https://apps.apple.com/br/app/sticker-album-2026/id6761956390?l=en-GB) (MoovTech)
