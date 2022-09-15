# syntax=docker/dockerfile:experimental
ARG OPENRESTY_VERSION
FROM openresty/openresty:${OPENRESTY_VERSION:-"1.21.4.1"}-bullseye as build

ARG OPENRESTY_VERSION
ENV OPENRESTY_VERSION=${OPENRESTY_VERSION:-"1.21.4.1"}

ARG NGINX_VERSION
ENV NGINX_VERSION=${NGINX_VERSION:-"1.21.4"}

ARG MODSECURITY_VERSION
ENV MODSECURITY_VERSION=${MODSECURITY_VERSION:-"3.0.7"}

ARG MODSECURITY_NGINX_VERSION
ENV MODSECURITY_NGINX_VERSION=${MODSECURITY_NGINX_VERSION:-"1.0.3"}

ARG OWASP_CRS_VERSION
ENV OWASP_CRS_VERSION=${OWASP_CRS_VERSION:-"3.3.2"}

ENV LUAJIT_LIB=/usr/local/openresty/luajit/lib
ENV LUAJIT_INC=/usr/local/openresty/luajit/include/luajit-2.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        automake \
        ca-certificates \
        curl \
        g++ \
        gcc \
        git \
        liblua5.1-0-dev \
        libmaxminddb-dev \
        libpcre3-dev \
        libreadline-dev \
        libssl-dev \
        libtool \
        libxml2 \
        libxslt1-dev \
        luarocks \
        make \
        openssh-client \
        wget \
        zlib1g-dev

RUN mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /src/ModSecurity
RUN --mount=type=ssh git clone --depth 1 -b v${MODSECURITY_VERSION} --single-branch git@github.com:SpiderLabs/ModSecurity.git . && \
    git submodule update --init --remote && \
    ./build.sh && \
    ./configure --with-lua --with-maxmind && \
    make && \
    make install

RUN --mount=type=ssh git clone -b v${MODSECURITY_NGINX_VERSION} --depth 1 git@github.com:SpiderLabs/ModSecurity-nginx.git /src/ModSecurity-nginx

WORKDIR /src/openresty
RUN curl -L https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz |tar -C /src/openresty --strip-components=1 -xz && \
    NGINX_ARGS=$(openresty -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    ./configure \
         --add-dynamic-module=/src/ModSecurity-nginx \
         --with-http_stub_status_module \
         --with-http_sub_module \
         --with-luajit \
        ${NGINX_ARGS} && \
    make -j2 && \
    make install
         
# --with-http_mirror_module \

RUN wget https://github.com/coreruleset/coreruleset/archive/v${OWASP_CRS_VERSION}.tar.gz && \
    tar -C /usr/local -xzvf v${OWASP_CRS_VERSION}.tar.gz

ARG OPENRESTY_VERSION
FROM openresty/openresty:${OPENRESTY_VERSION:-"1.21.4.1"}-bullseye

ARG OWASP_CRS_VERSION
ENV OWASP_CRS_VERSION=${OWASP_CRS_VERSION:-"3.3.2"}

EXPOSE 8000
EXPOSE 8443

RUN groupadd -g 101 openresty && \
    useradd -u 101 openresty -m -d /home/openresty -k /etc/skel -g 101

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        clamdscan \
        liblua5.1-0 \
        libmaxminddb0 && \
    apt-get clean

COPY --from=build /usr/local/ /usr/local/
COPY usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY usr/local/bin/clamdscan.lua /usr/local/bin/clamdscan.lua
COPY etc/nginx/modsec/ /etc/nginx/modsec/
COPY etc/nginx/conf.d/ etc/nginx/conf.d/

RUN mv /usr/local/coreruleset-${OWASP_CRS_VERSION} /usr/local/coreruleset && \
    mv /usr/local/coreruleset/crs-setup.conf.example /usr/local/coreruleset/crs-setup.conf && \
    mv /usr/local/coreruleset/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/coreruleset/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf && \
    mv /usr/local/coreruleset/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /usr/local/coreruleset/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

RUN mkdir -p \
        /opt/modsecurity/var/upload \
        /opt/modsecurity/var/log \
        /opt/modsecurity/var/tmp \
        /var/run/nginx \
        /var/run/openresty/nginx-client-body \
        /var/run/openresty/nginx-proxy \
        /var/run/openresty/nginx-fastcgi \
        /var/run/openresty/nginx-uwsgi \
        /var/run/openresty/nginx-scgi \
        /usr/local/openresty/nginx/logs && \
    chown -R openresty:openresty \
        /opt/modsecurity/var \
        /var/run/nginx \
        /var/run/openresty \
        /usr/local/openresty/nginx/logs

USER openresty
