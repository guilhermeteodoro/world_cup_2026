# 7. DOX convention: co-located AGENTS.md files

Date: 2026-06-10

## Status

Accepted (supersedes original mirror-tree adaptation)

## Context

The original adaptation (`.agents/dox/` mirror tree) made DOX files invisible to agents. The hidden directory didn't appear in workspace trees or directory listings, so agents consistently skipped the "read DOX before editing" rule — they never encountered the files during normal navigation.

The upstream DOX convention (co-located `AGENTS.md` in each governed folder) solves this: agents see the file every time they `read` a directory before editing files in it.

## Decision

DOX files are co-located `AGENTS.md` files inside the source folders they govern:
- `app/controllers/AGENTS.md` governs `app/controllers/`
- `app/ui/fragments/AGENTS.md` governs `app/ui/fragments/`

The root `AGENTS.md` remains the DOX rail.

## Consequences

- **Discoverable**: agents see `AGENTS.md` in every directory listing — impossible to miss.
- **One extra file per governed folder**: minimal visual noise (one markdown file alongside source).
- **No path transform needed**: the file is where it governs, no mirror-tree mapping.
- **Renames track automatically**: moving a folder moves its AGENTS.md with it.
