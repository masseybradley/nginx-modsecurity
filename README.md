# openresty-modsecurity

[OpenResty official docker image] extended with [Modsecurity] and [Modsecurity-nginx] configured with the [coreruleset].

## Development

Build the docker image: `docker buildx build --ssh=default --rm -t openresty .`

Run a container: `docker run --rm -p 8000:8000 openresty`


[OpenResty official docker image]: https://hub.docker.com/r/openresty/openresty
[Modsecurity]: https://github.com/SpiderLabs/ModSecurity
[Modsecurity-nginx]: https://github.com/SpiderLabs/ModSecurity-nginx
[coreruleset]: https://github.com/coreruleset/coreruleset
