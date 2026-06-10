# Purpose

Full-page Phlex view classes rendered by controllers.

# Local Contracts

- Namespace: `Views::{Controller}::{Action}` (e.g., `Views::Users::ShowOwner`)
- Views compose UI fragments and components — no complex logic.
- Initialized with keyword args from controller (the data they need to render).
- One `.text.erb` template exists: `trades/comparison` for clipboard text export.
- `Views::Trades::Show` renders the trade negotiation page: four zones (give/pool per user), sticker chips with add/remove forms, status badges, receipt confirmation section, accept/cancel actions.
- `Views::Trades::Index` renders the user's pending trades dashboard.
