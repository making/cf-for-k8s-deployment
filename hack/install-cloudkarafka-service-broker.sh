#!/bin/bash
set -euox pipefail

cf create-org cloudkarafka
cf create-space cloudkarafka -o cloudkarafka
cf target -o cloudkarafka -s cloudkarafka

wget -q https://repo1.maven.org/maven2/am/ik/servicebroker/cloud-karafka-service-broker/0.1.0/cloud-karafka-service-broker-0.1.0.jar -O cloudkarafka-service-broker.jar
cat <<EOF > cloudkarafka-service-broker.yml
applications:
- name: cloudkarafka-service-broker
  instances: 1
  memory: 256M
  path: cloudkarafka-service-broker.jar
  env:
    SERVER_TOMCAT_MAX_THREADS: 4
    JAVA_OPTS: -XX:ReservedCodeCacheSize=32M -Xss512k -Duser.timezone=Asia/Tokyo
    INFO_JAVA_VERSION: \${java.runtime.version}
    INFO_JAVA_VENDOR: \${java.vm.vendor}
    SPRING_SECURITY_USER_PASSWORD: ${CLOUDKARAFKA_API_KEY}
    CLOUDKARAFKA_API_KEY: ${CLOUDKARAFKA_API_KEY}
    BPL_THREAD_COUNT: 20
    BPL_JVM_THREAD_COUNT: 20
EOF
cf push cloudkarafka-service-broker -f cloudkarafka-service-broker.yml
set +e
cf create-service-broker cloudkarafka admin ${CLOUDKARAFKA_API_KEY} https://cloudkarafka-service-broker.${APPS_DOMAIN}
set -e
cf enable-service-access cloudkarafka

rm -f cloudkarafka-service-broker.jar
rm -f cloudkarafka-service-broker.yml