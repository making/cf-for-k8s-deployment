#!/bin/bash
set -euox pipefail

cf create-org shared-mysql
cf create-space shared-mysql -o shared-mysql
cf target -o shared-mysql -s shared-mysql

wget -q https://repo1.maven.org/maven2/am/ik/servicebroker/shared-smysql-service-broker/0.0.5/shared-smysql-service-broker-0.0.5.jar -O shared-mysql-service-broker.jar
cat <<EOF > shared-mysql-service-broker.yml
applications:
- name: shared-mysql-service-broker
  instances: 1
  memory: 256M
  path: shared-mysql-service-broker.jar
  health-check-type: http
  health-check-http-endpoint: /actuator/health
  env:
    SERVER_TOMCAT_MAX_THREADS: 4
    JAVA_OPTS: -XX:ReservedCodeCacheSize=32M -Xss512k -Duser.timezone=Asia/Tokyo
    INFO_JAVA_VERSION: \${java.runtime.version}
    INFO_JAVA_VENDOR: \${java.vm.vendor}
    SERVICE_BROKER_ADMIN_PASSWORD: ${SHARED_MYSQL_BROKER_ADMIN_PASSWORD}
    SPRING_DATASOURCE_USERNAME: ${SHARED_MYSQL_USERNAME}
    SPRING_DATASOURCE_PASSWORD: ${SHARED_MYSQL_PASSWORD}
    SPRING_DATASOURCE_URL: jdbc:mysql://${SHARED_MYSQL_HOSTNAME}:${SHARED_MYSQL_PORT}/${SHARED_MYSQL_DATABASE}?allowPublicKeyRetrieval=true&useSSL=false
    BPL_THREAD_COUNT: 20
    BPL_JVM_THREAD_COUNT: 20
EOF
cf push shared-mysql-service-broker -f shared-mysql-service-broker.yml
set +e
cf create-service-broker shared-mysql admin SERVICE_BROKER_ADMIN_PASSWORD https://shared-mysql-service-broker.${APPS_DOMAIN}
set -e
cf enable-service-access shared-mysql

rm -f shared-mysql-service-broker.jar
rm -f shared-mysql-service-broker.yml