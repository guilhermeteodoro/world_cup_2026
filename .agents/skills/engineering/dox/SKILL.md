---
name: dox
description: Find, create, and update DOX documentation files following the adapted mirror-tree convention under .agents/dox/. Use when editing source files, creating new folders, or when closeout pass is needed.
---

## Convention

DOX files live under `.agents/dox/` mirroring the source tree structure.

- **Root `AGENTS.md`** stays at the repo root (DOX rail)
- **Folder contracts** → `.agents/dox/{path}/_index.md`
- **File contracts** (rare) → `.agents/dox/{path}/{filename_without_ext}.md`

Examples:
```
app/services/           → .agents/dox/app/services/_index.md
app/models/             → .agents/dox/app/models/_index.md
app/ui/fragments/       → .agents/dox/app/ui/fragments/_index.md
app/services/trade_comparer.rb → .agents/dox/app/services/trade_comparer.md (rare)
```

## Path Transform

```
source_folder + "/_index.md" → ".agents/dox/" + source_folder + "/_index.md"
source_file                  → ".agents/dox/" + dirname(source_file) + "/" + basename_no_ext + ".md"
```

## Read Before Editing

1. Identify every file or folder you expect to touch
2. Walk from root to each target path
3. Read root `AGENTS.md`
4. For each path segment, check if `.agents/dox/{accumulated_path}/_index.md` exists
5. Read every DOX file found along each route
6. Use the nearest DOX file as the local contract; parent docs for repo-wide rules
7. If docs conflict, the closer doc controls local details

## When to Create a DOX File

Create `.agents/dox/{path}/_index.md` when a folder becomes a durable boundary with its own:
- Purpose or ownership
- Local contracts or rules
- Work guidance or quality standards
- Verification steps

Do NOT create file-level DOX unless the file is a durable boundary that outgrows its folder's `_index.md`.

## Child Doc Shape

Default section order:

```markdown
# Purpose

What this folder/area owns and why it exists.

# Ownership

What belongs here vs. elsewhere.

# Local Contracts

Interfaces, invariants, or rules specific to this scope.

# Work Guidance

Current standards for editing files in this scope.

# Verification

How to check work in this scope (commands, tests, lints).

# Child DOX Index

Links to child DOX files that cover sub-scopes.
```

Omit empty sections. Keep each section concise and operational.

## Closeout Pass (After Editing)

Every meaningful change requires a DOX pass before the task is done:

1. Identify which DOX files govern the paths you touched
2. Check if any change affects: purpose, scope, ownership, contracts, workflows, inputs/outputs, constraints
3. Update the nearest owning DOX file if so
4. Update parent DOX files if parent-level structure changed
5. Remove stale or contradictory text
6. Check for orphaned DOX files (source folder was renamed/deleted)
7. Refresh Child DOX Index in affected `_index.md` files

Small edits that don't change behavior or contracts may leave docs unchanged — but the pass still happens.

## Style

- Concise, current, operational
- Document stable contracts, not diary entries
- Broad rules in parent docs, concrete details in child docs
- Direct bullets with explicit names
- No duplication across files unless each scope needs a local version
- Delete stale notes immediately

## Commands

Find all DOX files:
```bash
find .agents/dox -name "*.md" | sort
```

Find DOX for a specific path:
```bash
# For app/services/
cat .agents/dox/app/services/_index.md

# Walk the chain
cat AGENTS.md
cat .agents/dox/app/_index.md 2>/dev/null
cat .agents/dox/app/services/_index.md 2>/dev/null
```

Check for orphaned DOX (source no longer exists):
```bash
for f in $(find .agents/dox -name "_index.md"); do
  src=$(echo "$f" | sed 's|^.agents/dox/||; s|/_index.md$||')
  [ ! -d "$src" ] && echo "ORPHAN: $f → $src"
done
```
