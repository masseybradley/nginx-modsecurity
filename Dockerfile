# syntax=docker/dockerfile:experimental
ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION:-"1.19.2"} as build

ARG MODSECURITY_VERSION
ENV MODSECURITY_VERSION=${MODSECURITY_VERSION:-"3.0.4"}

ARG OWASP_CRS_VERSION
ENV OWASP_CRS_VERSION=${OWASP_CRS_VERSION:-"3.2.0"}

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
        libmaxminddb-dev \
        make && \
    rm -rf /var/cache/apt

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    tar -C /usr/src -xzvf nginx-${NGINX_VERSION}.tar.gz

RUN mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /src
RUN --mount=type=ssh git clone --depth 1 -b v${MODSECURITY_VERSION} --single-branch git@github.com:SpiderLabs/ModSecurity.git . && \
    git submodule update --init --remote && \
    ./build.sh && \
    ./configure && \
    make && \
    make install && \
    rm -rf /src

RUN --mount=type=ssh git clone -b v1.0.1 --depth 1 git@github.com:SpiderLabs/ModSecurity-nginx.git /src

WORKDIR /usr/src/nginx-${NGINX_VERSION}
RUN NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    ./configure --with-compat --with-http_dav_module --add-dynamic-module=/src ${NGINX_ARGS} && \
    make modules

RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${OWASP_CRS_VERSION}.tar.gz && \
    tar -C /usr/local -xzvf v${OWASP_CRS_VERSION}.tar.gz

FROM nginx:${NGINX_VERSION:-"1.19.2"}

ARG OWASP_CRS_VERSION
ENV OWASP_CRS_VERSION=${OWASP_CRS_VERSION:-"3.2.0"}

RUN apt-get update && \
    apt-get install -y libmaxminddb0 && \
    rm -rf /var/cache/apt

COPY nginx.conf /etc/nginx/nginx.conf
COPY main.conf modsecurity.conf unicode.mapping /etc/nginx/modsec/ 
RUN sed -i "s/_OWASP_CRS_VERSION_/${OWASP_CRS_VERSION}/g" /etc/nginx/modsec/main.conf
COPY --from=build /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/ngx_http_modsecurity_module.so
COPY --from=build /usr/local/modsecurity/ /usr/local/modsecurity/
COPY --from=build /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION} /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}

RUN mv /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/crs-setup.conf.example /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/crs-setup.conf && \
    mv /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf && \
    mv /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /usr/local/owasp-modsecurity-crs-${OWASP_CRS_VERSION}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
