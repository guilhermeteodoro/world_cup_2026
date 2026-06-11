# Purpose

Generic reusable UI atoms. No domain knowledge.

# Local Contracts

- Custom components: `UI::Components::{Name}`
- `ruby_ui/` — vendored RubyUI library. Don't modify directly; override via subclassing if needed.
- If a component needs sticker/trade/collection knowledge, it belongs in `fragments/` instead.

# Components

## Collapsible

Multi-part component for show/hide sections. Backed by `ui-state` Stimulus controller with optional `sessionStorage` persistence.

```ruby
render UI::Components::Collapsible.new(open: true, persist_key: "unique-key") do |c|
  c.trigger(class: "cursor-pointer") do
    c.icon { "▾" }
    "Header text"
  end
  c.content(class: "p-4") do
    "Body content"
  end
end
```

- `open:` — initial state (default `true`)
- `persist_key:` — opt-in `sessionStorage` persistence key; without it state resets on navigation
- `c.trigger` — clickable area, wires `click->ui-state#toggle` and `aria-expanded`
- `c.content` — the body; gets `hidden` class when collapsed
- `c.icon` — optional rotate indicator (0° open, -90° closed)

## UiState (Stimulus controller)

Generalized state persistence controller (`app/javascript/controllers/ui_state_controller.js`). Collapsible uses it internally. Other components can use its static `read(key, name)` / `write(key, name, value)` methods for arbitrary sessionStorage-backed state. Public methods: `open()`, `close()`, `toggle()` — each persists if `keyValue` is set.
