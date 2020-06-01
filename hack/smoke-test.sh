#!/bin/bash
set -eu
export SMOKE_TEST_API_ENDPOINT=api.$(bosh int $(dirname $0)/../configuration-values/deployment-values.yml --path /system_domain)
export SMOKE_TEST_APPS_DOMAIN=$(bosh int $(dirname $0)/../configuration-values/deployment-values.yml --path /app_domains/0)
export SMOKE_TEST_USERNAME=admin
export SMOKE_TEST_PASSWORD=$(bosh int $(dirname $0)/../configuration-values/deployment-values.yml  --path /cf_admin_password)
export SMOKE_TEST_SKIP_SSL=true

$(dirname $0)/../config/_deps/cf-for-k8s/hack/run-smoke-tests.sh