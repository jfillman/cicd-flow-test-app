#!/usr/bin/env bash
# Invoked by the platform's run-tests Task (catalog/tasks/run-tests.yaml) inside the
# resolved build-agent image (see cicd.yaml's build.agent) as part of the build stage.
# That step does NOT pre-install dependencies - this script owns npm ci itself.
set -euo pipefail
npm ci
npm test
