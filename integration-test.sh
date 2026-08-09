#!/usr/bin/env bash
# Invoked by the platform's test stage (catalog/tasks/run-integration-tests.yaml).
#
# NOTE on scope: this exercises the application code directly (node server.js), not the
# built container image referenced by $IMAGE_REF - the platform's test stage doesn't
# currently provide a container runtime inside the step to actually run an arbitrary
# image (see platform-cicd's catalog/tasks/run-integration-tests.yaml). A real
# run-the-built-image integration test is a reasonable platform follow-up, not something
# this app repo can work around on its own.
set -euo pipefail

npm ci
node server.js &
APP_PID=$!
trap 'kill "${APP_PID}" 2>/dev/null || true' EXIT

for _ in $(seq 1 10); do
  if curl -fs http://localhost:3000/healthz >/dev/null; then
    echo "app is healthy"
    exit 0
  fi
  sleep 1
done

echo "error: app did not become healthy within 10s" >&2
exit 1
