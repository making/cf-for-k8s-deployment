#!/bin/bash
set -euo pipefail

cf target -o system -s system

cat <<EOF > stratos.yml
applications:
- name: console
  docker:
    image: splatform/stratos:stable
  instances: 1
  memory: 128M
  disk_quota: 384M
  services:
  - console-db
EOF

set +e
cf create-service elephantsql turtle console-db
set -e

cf push -f stratos.yml