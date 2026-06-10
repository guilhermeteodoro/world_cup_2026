# Purpose

Generic reusable UI atoms. No domain knowledge.

# Local Contracts

- Custom components: `UI::Components::{Name}`
- `ruby_ui/` — vendored RubyUI library. Don't modify directly; override via subclassing if needed.
- If a component needs sticker/trade/collection knowledge, it belongs in `fragments/` instead.
