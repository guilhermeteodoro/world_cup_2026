# i18n: relative keys via Phlex translation_path

## Context

Phlex-Rails includes `Phlex::Rails::Helpers::Translate` which resolves dot-prefixed keys (`.title`) relative to the class name. The class `Views::Users::Show` resolves `.title` to `views.users.show.title`.

We had a custom `def t(key)` in `Components::Base` that called `I18n.t` directly, bypassing this feature.

## Decision

- Remove the custom `t` override; let `Phlex::Rails::Helpers::T` (already included) handle translations.
- All Phlex views and components use relative keys: `t(".key")`.
- Locale YAML is structured to match class paths:
  - `views.pages.home.*` → `Views::Pages::Home`
  - `views.users.show.*` → `Views::Users::Show`
  - `components.collection_importer.*` → `Components::CollectionImporter`
  - `components.sticker_list.*` → `Components::StickerList`
- ERB templates (no class context) use full paths: `t("views.users.show.key")`.
- Controller flash messages stay at top-level Rails conventions: `sessions.create.*`, `registrations.create.*`.
- Shared global keys (`app_name`, `categories.*`, `countries.*`) remain at the YAML root.

## Consequences

- Adding a new view/component automatically has a namespace — just add keys matching the class path.
- No more duplicated keys across different files.
- ERB templates are the exception — they must use full paths.
- Renaming a class requires moving its locale keys (the class path changes).
