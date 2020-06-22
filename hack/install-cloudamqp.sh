#!/bin/bash
set -euox pipefail

cf create-org cloudamqp
cf create-space cloudamqp -o cloudamqp
cf target -o cloudamqp -s cloudamqp

rm -rf cloudamqp-service-broker
git clone https://github.com/making/cloudamqp-service-broker
cd cloudamqp-service-broker
cat <<EOF > cloudamqp-service-broker.yml
applications:
- name: cloudamqp-service-broker
  instances: 1
  memory: 256M
  env:
    JAVA_OPTS: -XX:ReservedCodeCacheSize=32M -Xss512k -Duser.timezone=Asia/Tokyo
    SERVICE_BROKER_ADMIN_PASSWORD: ${CLOUDAMQP_BROKER_ADMIN_PASSWORD}
    SERVICE_BROKER_CLOUDAMQP_APIKEY: ${SERVICE_BROKER_CLOUDAMQP_APIKEY}
    BPL_THREAD_COUNT: 20
    BPL_JVM_THREAD_COUNT: 20
EOF
cf push cloudamqp-service-broker -f cloudamqp-service-broker.yml
set +e
cf create-service-broker cloudamqp admin ${CLOUDAMQP_BROKER_ADMIN_PASSWORD} https://cloudamqp-service-broker.${APPS_DOMAIN}
set -e
cf enable-service-access cloudamqp

rm -f cloudamqp-service-broker.jar
rm -f cloudamqp-service-broker.yml