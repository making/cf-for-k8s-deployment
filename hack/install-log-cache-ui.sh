#!/bin/bash
set -euo pipefail

cf create-org log-cache-ui
cf create-space log-cache-ui -o log-cache-ui
cf target -o log-cache-ui -s log-cache-ui

REDIRECT_URLS=https://log-cache-ui.${APPS_DOMAIN}/login/oauth2/code/uaa
UAA_UI_CLIENT_SECRET=$(mktemp | sed 's|/||g')

uaac target uaa.${SYSTEM_DOMAIN}
uaac token client get admin -s ${ADMIN_CLIENT_SECRET}

set +e
uaac client add log_cache_ui \
  --name log_cache_ui \
  --secret ${UAA_UI_CLIENT_SECRET} \
  --authorized_grant_types refresh_token,authorization_code \
  --scope openid,doppler.firehose,logs.admin \
  --access_token_validity 43200 \
  --refresh_token_validity 259200 \
  --redirect_uri ${REDIRECT_URLS}
set -e
