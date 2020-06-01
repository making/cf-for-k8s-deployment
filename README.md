# cf-for-k8s deployment


```
# change DOMAIN in Makefile
make generate-values
export APP_REGISTRY_USERNAME=<docker username>
export APP_REGISTRY_PASSWORD=<docker password>
make configure-app-registry
make install
make post-install
make test
```