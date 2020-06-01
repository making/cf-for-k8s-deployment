#!/bin/bash
set -euo pipefail

cf create-org elephantsql
cf create-space elephantsql -o elephantsql
cf target -o elephantsql -s elephantsql

SPRING_SECURITY_USER_PASSWORD=$(mktemp | sed 's|/||g')
wget -O elephantsql-service-broker.yml https://github.com/making/elephantsql-service-broker/raw/master/manifest.yml
cf push --no-start -f elephantsql-service-broker.yml
cf set-env elephantsql-service-broker ELEPHANTSQL_API_KEY ${ELEPHANTSQL_API_KEY}
cf set-env elephantsql-service-broker SPRING_SECURITY_USER_PASSWORD ${SPRING_SECURITY_USER_PASSWORD}
cf start elephantsql-service-broker

set +e
cf create-service-broker elephantsql admin ${SPRING_SECURITY_USER_PASSWORD} https://elephantsql-service-broker.$(bosh int $(dirname $0)/../configuration-values/deployment-values.yml --path /app_domains/0)
set -e
cf enable-service-access elephantsql
rm -f elephantsql-service-broker.yml