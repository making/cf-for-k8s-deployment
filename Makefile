.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash -euo pipefail
DOMAIN := cf.maki.lol

sync:
	@vendir sync

validate:
	@ytt version
	@kapp version
	@bosh -v
	@cf -v

generate-values:
	@./config/_deps/cf-for-k8s/hack/generate-values.sh \
	    -d $(DOMAIN) > configuration-values/deployment-values.yml

configure-app-registry:
	@./hack/configure-app-registry.sh

render-config:
	@ytt --ignore-unknown-comments \
	    -f config \
	    -f configuration-values > rendered/cf-for-k8s.yml

install: render-config
	@kapp deploy -a cf -f rendered/cf-for-k8s.yml -c

uninstall:
	@kapp delete -a cf -y

login:
	@cf login -a api.$(shell bosh int configuration-values/deployment-values.yml --path /system_domain) \
	          -u admin \
	          -p $(shell bosh int configuration-values/deployment-values.yml --path /cf_admin_password) \
	          --skip-ssl-validation \
	          -o system

password:
	@bosh int configuration-values/deployment-values.yml --path /cf_admin_password

enable-diego-docker:
	@cf enable-feature-flag diego_docker

create-system-space:
	@cf create-space system -o system

create-demo-org:
	@cf create-org demo
	@cf create-space demo -o demo
	@cf target -o demo -s demo

test:
	@./hack/smoke-test.sh

post-install: login \
			  enable-diego-docker \
			  create-system-space \
              create-demo-org

install-elephantsql-service-broker: login
	@./hack/install-elephantsql-service-broker.sh

uninstall-elephantsql-service-broker: login
	@cf delete-service-broker elephantsql -f
	@cf delete-org elephantsql -f