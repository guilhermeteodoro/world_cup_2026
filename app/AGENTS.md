# Purpose

Application source code. Standard Rails layout with one deviation: UI components live in `app/ui/` (ADR-0006).

# Ownership

All runtime application code. This doc owns guidance for `app/helpers/`, `app/assets/`, `app/javascript/`, and `app/jobs/` — folders without their own AGENTS.md files.

## JavaScript Controllers (`app/javascript/controllers/`)

- `ui_state_controller.js` — generalized sessionStorage persistence. Manages boolean `open` state with toggle action. Exposes static `read(key, name)` / `write(key, name, value)` for other controllers to reuse without mounting the controller.
- Other controllers that need persistence should import and use `UiStateController.read/write` rather than accessing sessionStorage directly.
- Stimulus controller registration lives in `index.js` — keep alphabetical-ish, one import+register pair per controller.

# Local Contracts

- No business logic in controllers — delegate to services or models
- Services are the boundary for multi-step operations
- UI layer uses Phlex exclusively (no ERB for components)

# Child DOX Index

- [models/AGENTS.md](models/AGENTS.md) — domain entities and their relationships
- [services/AGENTS.md](services/AGENTS.md) — business operations and parser pipeline
- [controllers/AGENTS.md](controllers/AGENTS.md) — request handling contracts
- [ui/AGENTS.md](ui/AGENTS.md) — Phlex presentation layer
- [views/AGENTS.md](views/AGENTS.md) — full-page Phlex view classes
