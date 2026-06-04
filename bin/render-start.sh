#!/usr/bin/env bash
set -o errexit

# Database operations run at startup because the persistent disk
# (/var/data/) is only mounted at runtime, not during builds.
bundle exec rake db:prepare
bundle exec rake db:seed

# Start the server (config/puma.rb reads PORT, WEB_CONCURRENCY, RAILS_MAX_THREADS)
bundle exec puma -C config/puma.rb
