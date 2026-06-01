# Rules

## Data Safety

- **NEVER** run destructive database commands (`db:drop`, `db:reset`, `db:migrate`, `db:rollback`, `DELETE`, `TRUNCATE`) without explicit user confirmation.
- **NEVER** run `bin/rails test` or any command that may trigger `db:test:prepare` without explicit user confirmation — it can have side effects.
- When in doubt, ask before running any command that could modify data.
- Prefer `ruby -c` for syntax checking over running the full test suite.
