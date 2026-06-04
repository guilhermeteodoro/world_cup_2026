# Frontend

Conventions for writing client-side JavaScript in this project.

## Stack

- **Stimulus** — Hotwire's modest JS framework. Controllers live in `app/javascript/controllers/`.
- **@rails/request.js** — handles fetch with automatic CSRF tokens, JSON content-type, and Rails-friendly responses.
- **esbuild** — bundler, configured in `package.json`.

## Stimulus Controllers

### Registration

Every controller must be registered in `app/javascript/controllers/index.js`:

```js
import MyController from "./my_controller"
application.register("my-controller", MyController)
```

Forgetting this is a common mistake — the controller won't connect without it.

### Naming

- File: `app/javascript/controllers/my_feature_controller.js`
- Registration: `application.register("my-feature", ...)`
- HTML: `data-controller="my-feature"`

RubyUI controllers live in `app/javascript/controllers/ruby_ui/` and use the `ruby-ui--` prefix (e.g., `ruby-ui--collapsible`).

### Private methods

Use JavaScript's native `#` prefix for private class methods and fields. This prevents accidental invocation from `data-action` attributes in the DOM.

```js
export default class extends Controller {
  // Public — callable from data-action
  toggle() { ... }

  // Private — internal only
  #render() { ... }
  #debounceTimer = null
}
```

## Making Requests

Use `@rails/request.js` instead of raw `fetch`. It handles:
- CSRF token injection
- `Content-Type: application/json`
- Response parsing

```js
import { post, patch, destroy } from "@rails/request.js"

// POST with JSON body
const response = await post(url, { body: { sticker_id: 42 } })
if (response.ok) {
  const data = await response.json
}

// PATCH
await patch(url, { body: { copies: 3 } })

// DELETE
await destroy(url)
```

Do NOT manually set headers or read CSRF meta tags.

## Optimistic UI Pattern

For interactive features that need to feel instant:

1. Update the DOM immediately on user action
2. Fire the request in the background
3. Revert on failure

```js
glue() {
  this.gluedValue = true
  this.#render()

  post(this.createUrlValue, { body: { ... } })
    .then(async (response) => {
      if (!response.ok) {
        this.gluedValue = false
        this.#render()
      }
    })
}
```

## Debouncing

For rapid-fire actions (e.g., incrementing a counter), debounce the server sync:

```js
#debounceTimer = null

#debouncedSync() {
  clearTimeout(this.#debounceTimer)
  this.#debounceTimer = setTimeout(() => {
    patch(this.updateUrlValue, { body: { copies: this.copiesValue } })
  }, 500)
}
```

Update the UI on every tap, send one request after the user stops (500ms).

## Collapsible Sections

The RubyUI collapsible controller (`ruby-ui--collapsible`) provides:

- `toggle()` — toggle open/close
- `open()` / `close()` — programmatic control from other controllers
- Targets: `content` (the expandable area), `icon` (rotates -90deg when closed)
- Value: `open` (Boolean, default false)

To control multiple collapsibles from a parent controller:

```js
const el = this.element.querySelector('[data-controller="ruby-ui--collapsible"]')
const controller = this.application.getControllerForElementAndIdentifier(el, "ruby-ui--collapsible")
controller.open()
```

## JSON API Endpoints

When a Stimulus controller needs a backend endpoint, create a standard Rails controller that:
- Responds with `render json: { ... }` or `head :no_content`
- Uses `before_action` for auth
- Keeps routes RESTful

The controller does NOT need `respond_to` blocks — just render JSON directly since these endpoints are only called from JS.
