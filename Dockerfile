# syntax=docker/dockerfile:experimental
ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION} as build

RUN apt-get update && \
    apt-get install -y \
        openssh-client \
        git \
        wget \
        libxml2 \
        libxslt1-dev \
        libpcre3 \
        libpcre3-dev \
        zlib1g \
        zlib1g-dev \
        openssl \
        libssl-dev \
        libtool \
        automake \
        gcc \
        g++ \
        make && \
    rm -rf /var/cache/apt

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    tar -C /usr/src -xzvf nginx-${NGINX_VERSION}.tar.gz

RUN mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /src
RUN --mount=type=ssh git clone --depth 1 -b v3/master --single-branch git@github.com:SpiderLabs/ModSecurity.git . && \
    git submodule update --init --remote && \
    ./build.sh && \
    ./configure && \
    make && \
    make install && \
    rm -rf /src

RUN --mount=type=ssh git clone --depth 1 git@github.com:SpiderLabs/ModSecurity-nginx.git /src

WORKDIR /usr/src/nginx-${NGINX_VERSION}
RUN NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    ./configure --with-compat --with-http_dav_module --add-dynamic-module=/src ${NGINX_ARGS} && \
    make modules


FROM nginx:${NGINX_VERSION}

COPY nginx.conf /etc/nginx/nginx.conf
COPY main.conf modsecurity.conf unicode.mapping /etc/nginx/modsec/
COPY --from=build /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/ngx_http_modsecurity_module.so
COPY --from=build /usr/local/modsecurity/ /usr/local/modsecurity/
