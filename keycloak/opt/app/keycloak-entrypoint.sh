#!/bin/bash

if [ -z "$APP_SECRET" ]
then
    echo "\$APP_SECRET is empty"
    exit 1
fi

KEYCLOAK_ARGS="
    -Dkeycloak.profile.feature.token_exchange=enabled
    -Dkeycloak.profile.feature.admin_fine_grained_authz=enabled
    -Dkeycloak.profile.feature.scripts=enabled
"

# Configure keycloak to use the keystore
# https://www.keycloak.org/docs/latest/server_installation/#configure-keycloak-to-use-the-keystore
if [ "$KEYCLOAK_KEYSTORE" = true ]; then
    /opt/jboss/keycloak/bin/jboss-cli.sh --file=/opt/app/keystore.cli
fi

if [ ! -e /.keycloak.initialized ]; then
    # Local start of keycloak, not exposed to the outside.
    /opt/jboss/tools/docker-entrypoint.sh -b 127.0.0.1 \
      -Dkeycloak.profile.feature.upload_scripts=enabled \
      "$KEYCLOAK_ARGS" &
    KC_PID=$!

    export KC_SERVER=http://127.0.0.1:8080/y-keycloak

    # Wait for keycloak to be up and running
    while true; do
        curl -q -f $KC_SERVER &>/dev/null && break
        echo "Waiting for keycloak to startup"
        sleep 2
    done

    export KC_ADM=/opt/jboss/keycloak/bin/kcadm.sh

    # Create temporary session token
    $KC_ADM config credentials \
      --realm master \
      --server "$KC_SERVER" \
      --user "$KEYCLOAK_USER" \
      --password "$KEYCLOAK_PASSWORD"

    /opt/app/setup-realm.sh app
    /opt/app/setup-clients.sh app app $APP_SECRET

    if [ -n "${KEYCLOAK_FRONTEND_URL}" ]; then
      echo "Updating to frontendUrl ${KEYCLOAK_FRONTEND_URL} "
      $KC_ADM update realms/app --realm master \
         -s attributes.frontendUrl="${KEYCLOAK_FRONTEND_URL}"
    fi

    # Remove saved token
    rm -rf /opt/jboss/.keycloak/kcadm.config

    # Stop temporary keycloak
    kill $KC_PID
    sleep 1
fi

# Let keycloak start as expected
exec /opt/jboss/tools/docker-entrypoint.sh "$KEYCLOAK_ARGS" "$@"
