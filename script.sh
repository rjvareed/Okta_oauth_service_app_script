#!/bin/bash
okta_domain=$(jq -r .okta_domain okta.json)
echo "Generating JWT"
jwt=$(python3 generate_jwt.py)
echo -e "\e[31mJWT=$jwt\e[0m\n"
echo -e "Getting access token at endpoint $okta_domain/oauth2/v1/token"
echo -e "\e[32mcurl --location --request POST \"$okta_domain/oauth2/v1/token\" --header \"Accept: application/json\" --header \"Content-Type: application/x-www-form-urlencoded\" --data-urlencode \"grant_type=client_credentials\" --data-urlencode \"scope=okta.apps.read\" --data-urlencode \"client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer\" --data-urlencode \"client_assertion=$jwt\"\e[0m"
response=$(curl --location --request POST "$okta_domain/oauth2/v1/token" --header "Accept: application/json" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "grant_type=client_credentials" --data-urlencode "scope=okta.apps.read" --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" --data-urlencode "client_assertion=$jwt")
echo -e "\nResponse:\n$response\n"
access_token=$(echo $response | jq -r '.access_token')
echo -e "\e[31mAccess token=$access_token\e[0m\n"
echo "Making final request"
echo -e "\e[32mcurl -X GET \"$okta_domain/api/v1/apps/\" --header \"Accept: application/json\" --header \"Content-Type: application/json\" --header \"Authorization: Bearer $access_token\"\e[0m"
api_response=$(curl -X GET "$okta_domain/api/v1/apps/" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $access_token")
echo -e "\nAPI response:\n$api_response"
