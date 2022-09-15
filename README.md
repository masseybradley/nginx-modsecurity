# openresty

[OpenResty official docker image] extended with [Modsecurity] and [Modsecurity-nginx] configured with the [coreruleset] distributed with a React JS frontend and Django Graphene backend.

## Development

### openresty

Build the `openresty` docker image: `docker buildx build --ssh=default --rm -t openresty openresty`

Run a container: `docker run --rm -p 8000:8000 openresty`

### app

React JS frontend application.

1. Install the `node_modules`:
```
docker run --rm -it --entrypoint npm -v ${PWD}/www/var/www/app/app:/var/www/app -w /var/www/app node install
```

### api

Django Graphene backend application.


### keycloak

Create credentials:
```
echo "KEYCLOAK_PASSWORD=$(openssl rand -base64 32) > .env"
echo "POSTGRES_PASSWORD=$(openssl rand -base64 32) >> .env"
```

Connect to the `jboss-cli.sh` GUI:
```
docker cp keycloak:/opt/jboss/ /opt/jboss
docker exec -it keycloak /opt/jboss/keycloak/bin/add-user.sh user password
/opt/jboss/keycloak/bin/jboss-cli.sh --gui --connect --user=user --password=password
```


[OpenResty official docker image]: https://hub.docker.com/r/openresty/openresty
[Modsecurity]: https://github.com/SpiderLabs/ModSecurity
[Modsecurity-nginx]: https://github.com/SpiderLabs/ModSecurity-nginx
[coreruleset]: https://github.com/coreruleset/coreruleset
