# Purpose

HTTP request handlers. Thin — delegate to services, render Phlex views.

# Local Contracts

- Auth: cookie-session (`session[:user_id]` → `current_user`). No password — email-only login.
- Controllers render Phlex view objects: `render Views::Users::ShowOwner.new(user: @user, current_user: current_user)`
- Data passed to views via keyword args — no leaking instance variables.
- Trade creation computes the balanced trade at request time (ADR-0002) — no stored trade proposals.
- Flash messages use i18n keys.
