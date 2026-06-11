---
description: Enforce replace block N for full method/block rewrites to avoid stray end bugs
alwaysApply: true
---

When rewriting an entire method, function, class, or block construct using the `edit` tool, **always use `replace block N`** (pointing N at the opening line of the construct). Never hand-count the closing `end`/`}`/`end` with `replace N..M` for full rewrites — tree-sitter resolves the boundary automatically.

Use `replace N..M` only when changing specific lines *inside* a construct while keeping the construct's boundaries intact.
