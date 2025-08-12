#!/bin/bash
okta_domain=$(jq -r .okta_domain okta.json)
echo "Generating JWT"
jwt=$(python3 generate_jwt.py)
echo -e "\x1b\x5b\x33\x31\x6d""JWT=$jwt""\x1b\x5b\x30\x6d\n"
echo -e "Getting access token at endpoint $okta_domain/oauth2/v1/token"
response=$(curl --location --request POST "$okta_domain/oauth2/v1/token" --header "Accept: application/json" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "grant_type=client_credentials" --data-urlencode "scope=okta.apps.read" --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" --data-urlencode "client_assertion=$jwt")
echo -e "$response\n"
access_token=$(echo $response | jq -r '.access_token')
echo -e "\x1b\x5b\x33\x31\x6d""Access token=$access_token""\x1b\x5b\x30\x6d\n"
echo -e "Making final request\nAPI response:"
curl -X GET "$okta_domain/api/v1/apps/" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $access_token"
echo
