# 7. Adapted DOX with mirror tree under .agents/dox/

Date: 2026-06-10

## Status

Accepted

## Context

We want hierarchical, folder-scoped documentation contracts for AI agents (the DOX model from agent0ai/dox). DOX's upstream convention places `AGENTS.md` files inside every source folder they govern.

Rails projects separate files by type. Scattering `AGENTS.md` files throughout `app/models/`, `app/services/`, etc. adds visual noise for developers and conflicts with the "docs live in docs/" convention this project already uses (`docs/adr/`, `CONTEXT.md`, `.agents/skills/`).

AI agents don't need co-location — they need **predictability**. A deterministic path transform plus a skill that teaches the convention provides the same lookup speed without polluting the source tree.

## Decision

Adopt DOX's content model (hierarchical contracts, depth = specificity, update-after-editing discipline) with a single adaptation: child DOX files live under `.agents/dox/` in a nested structure that mirrors the source tree.

Path convention:

| Source path | DOX file |
|-------------|----------|
| `app/services/` (folder contract) | `.agents/dox/app/services/_index.md` |
| `app/services/trade_comparer.rb` (rare, file-level) | `.agents/dox/app/services/trade_comparer.md` |

Rules:
- Root `AGENTS.md` stays at the repo root (DOX rail, auto-discovered by tools)
- Folder-level contracts use `_index.md` (sorts first, signals "meta")
- File-level contracts are rare — only when a file is a durable boundary with its own purpose/rules
- DOX hierarchy, child doc shape, style rules, and closeout pass apply unchanged
- A project skill (`dox`) teaches agents the path transform and enforces the discipline

## Consequences

- **Easier**: Source tree stays clean; developers see only code in code folders. DOX files are browsable as a coherent tree under `.agents/dox/`.
- **Harder**: Mirror tree can drift from source on renames/deletes — the closeout pass must check for stale DOX files. No filesystem nudge (co-located file) reminds agents to update docs.
- **Mitigated by**: The `dox` skill enforces the lookup and closeout pass. `_index.md` convention makes the transform trivial and reversible.
