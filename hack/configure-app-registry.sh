#!/bin/bash
APP_REGISTRY_HOSTNAME=${APP_REGISTRY_HOSTNAME:-https://index.docker.io/v1/}
APP_REGISTRY_REPOSITORY=${APP_REGISTRY_REPOSITORY:-${APP_REGISTRY_USERNAME}}
set -eu
cat <<EOF >"$(dirname $0)/../configuration-values/app-registry-values.yml"
#@data/values
---
app_registry:
  hostname: ${APP_REGISTRY_HOSTNAME}
  repository: ${APP_REGISTRY_USERNAME}
  username: ${APP_REGISTRY_USERNAME}
  password: ${APP_REGISTRY_PASSWORD}
EOF
