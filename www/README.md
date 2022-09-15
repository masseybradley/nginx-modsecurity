# App

## Development

1. Install the `node_modules`:
```
docker run --rm -it --entrypoint npm -v ${PWD}/var/www/app/app:/var/www/app -w /var/www/app node install
```
1. Generate a password for the PostgreSQL database:
```
echo "POSTGRES_PASSWORD=$(openssl rand -hex 32)" > .env
```
1. Start the services: `docker-compose up -d --no-start`
1. Start the postgresql service: `docker-compose up -d postgresql`
1. Make and apply the django migrations: 
```
docker-compose run --rm --entrypoint /srv/www/manage.py api makemigrations
docker-compose run --rm --entrypoint /srv/www/manage.py api migrate
```

## Production

1. Build the static [`react` image](`react/Dockerfile`): `docker build --rm -f react/Dockerfile -t app react`
