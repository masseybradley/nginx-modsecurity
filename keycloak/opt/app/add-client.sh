#!/bin/bash

REALM=$1
CLIENT=$2
CLIENT_SECRET="$3"

echo "Add the client $CLIENT"

CID=$($KC_ADM get clients -r $REALM --fields 'id,clientId' | jq -r '.[]?|select(.clientId=="'$CLIENT'").id')

set -x
CLIENT_PARAMS=(
  "-r" "$REALM"
  "-s" "clientId=$CLIENT"
  "-s" "secret=$CLIENT_SECRET"
  "-s" "enabled=true"
  "-s" "authorizationServicesEnabled=true"
  "-s" "clientAuthenticatorType=client-secret"
  "-s" "standardFlowEnabled=false"
  "-s" "implicitFlowEnabled=false"
  "-s" "directAccessGrantsEnabled=false"
  "-s" "serviceAccountsEnabled=true"
)

if [ "$CID" == "" ]; then
    echo "Creating $CLIENT client"
    $KC_ADM create clients "${CLIENT_PARAMS[@]}"
else
    echo "Updating $CLIENT client"
    $KC_ADM update clients/$CID "${CLIENT_PARAMS[@]}"
fi
