---
name: dox
description: Find, create, and update DOX documentation files following the adapted mirror-tree convention under .agents/dox/. Use when editing source files, creating new folders, or when closeout pass is needed.
---

## About

The binding DOX rules live in the root `AGENTS.md` (DOX section). This skill provides operational helpers — commands, templates, and checks.

## Path Transform

```
# Folder contract
source_folder → .agents/dox/{source_folder}/_index.md

# File contract (rare)
source_file   → .agents/dox/{dirname}/{basename_no_ext}.md
```

## Commands

Walk the DOX chain for a path:
```bash
echo "=== Root ===" && head -5 AGENTS.md
for segment in app app/services; do
  f=".agents/dox/${segment}/_index.md"
  [ -f "$f" ] && echo "=== $f ===" && cat "$f"
done
```

List all DOX files:
```bash
find .agents/dox -name "*.md" | sort
```

Check for orphaned DOX (source folder no longer exists):
```bash
for f in $(find .agents/dox -name "_index.md"); do
  src=$(echo "$f" | sed 's|^.agents/dox/||; s|/_index.md$||')
  [ ! -d "$src" ] && echo "ORPHAN: $f → $src"
done
```

Check for undocumented folders (source exists but no DOX):
```bash
for d in app/models app/services app/controllers app/ui app/ui/components app/ui/fragments app/views test config db; do
  [ ! -f ".agents/dox/${d}/_index.md" ] && echo "MISSING: $d"
done
```

## New DOX File Template

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

## Closeout Checklist

After editing source files, run through:

1. Which DOX files govern the paths I touched?
2. Did my change affect purpose, scope, ownership, contracts, or workflows?
3. If yes → update the nearest owning DOX file
4. Did I change parent-level structure? → update parent DOX + Child DOX Index
5. Any stale text to remove?
6. Any orphaned DOX files (folder renamed/deleted)?
