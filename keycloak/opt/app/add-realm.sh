#!/bin/bash

REALM=$1

CID=$(/opt/jboss/keycloak/bin/kcadm.sh get realms | jq -r '.[]?|select(.realm=="'$REALM'").realm')

set -x

REALM_PARAMS=(
  "-s" "realm=$REALM"
  "-s" "enabled=true"
)

CREATE_REALM_PARAMS=(
  "-s" "accessTokenLifespan=600"
  "-s" "registrationAllowed=false"
  "-s" "userManagedAccessAllowed=true"
)

if [ "$CID" == "" ]; then
    echo "Creating $REALM realm"
    $KC_ADM create realms "${REALM_PARAMS[@]}" "${CREATE_REALM_PARAMS[@]}"
else
    echo "Updating $REALM realm"
    $KC_ADM update realms/$CID "${REALM_PARAMS[@]}"
fi
