# Purpose

Reusable UI atoms. Generic components that don't carry domain knowledge.

# Ownership

- `LocaleSwitcher` — flag-based language toggle (🇧🇷/🇬🇧)
- `ruby_ui/` — vendored RubyUI component library (alert, badge, button, card, collapsible, combobox, dialog, dropdown_menu, form, input, link, popover, textarea, toast, typography)

# Local Contracts

- Custom components live at `UI::Components::{Name}`
- RubyUI wrappers live at `UI::Components::RubyUI::{Name}::{Subcomponent}`
- Don't modify RubyUI components directly — override via subclassing or wrapper if needed

# Work Guidance

- Keep components domain-free — if it needs sticker/trade knowledge, it's a fragment
- Use RubyUI components as building blocks inside fragments
