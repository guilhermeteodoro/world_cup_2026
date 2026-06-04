#!/usr/bin/env bash
set -o errexit

bundle install
npm install
npm run build
bundle exec rake assets:precompile
bundle exec rake assets:clean
