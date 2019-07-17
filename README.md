# nginx-modsecurity

Official Docker Hub [nginx](https://hub.docker.com/_/nginx/ "nginx") image extended with [Modsecurity](https://github.com/SpiderLabs/ModSecurity "Modsecurity") and [Modsecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx "Modsecurity-nginx").

Build the image:
```
export NGINX_VERSION=1.17.1
docker build --rm \
    --pull \
    --ssh=default \
    -f Dockerfile \
    --build-arg NGINX_VERSION=${NGINX_VERSION:-latest} \
    -t localhost/nginx/modsecurity:${NGINX_VERSION:-latest} \
    . || {
        printf "failed to build modsecurity image.\n"
    }
```
