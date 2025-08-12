#Purpose
I've been instructed to implement an Okta app that makes API calls, instead of just using an entire org API token. This is better because it is not tied to a single user. Also allows more security since the token is bound to OAuth scopes (here it will only be able to read apps through `okta.apps.read`). Essentially the script will do the equivalent of the following curl request
`curl -X GET "https://{YourOktaDomain}/api/v1/apps/" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: SSWS {YourApiToken}"` but through an OAuth client credentials grant

This script is meant to be as minimalist as possible and is based on the following guide: https://developer.okta.com/docs/guides/implement-oauth-for-okta-serviceapp/main/

Basically it is setting up an app to handle the client credentials flow but with Okta as the resource server
This script only works on Linux (for now). Requires `python3-jwt` package (`sudo apt install python3-jwt`). Also make sure you have curl and python `sudo apt install curl` `sudo apt install python3`

#Setting up the app in Okta

In admin panel go to `Applications` -> `Create App Integration`
Select `API Services` and hit next
Name the app
Click edit to the right of `Client Credentials`
Next to `Client authentication` check `Public key / Private key`
Make sure `Save keys in Okta` is checked then click `Add key`
Click `Generate new key`
Make sure the private key is in JSON format by clicking the JSON option, then click Copy to clipboard
The private key should look something like:
```
{
    "d": "Tmi2hsBHl0BEIe4Mm3RVQhTt0aEdyDklXIfxtYddNPAvvsP62y2Oj-asday-asdMQHc3vHNLhIDZasdD3PW-qK7XEzdasdXMerhwZy4neaG4M5m3hdP2Toh9iiytqo2-HgCNSsY1nmk_SJoHtYQz8F_r362YEpT19W_eVjxrS2Ax0BGMRRYv06Hcht_2cM6hh1bbQMoNObwh14An12KeWtEUcc_H4kZJ0LSxQccEGoK7JHmH9fWsihB-N7A3r4a39gkDBTrF39lxzYwm1YYKWwhFaV0Vq68PMM8Mo06HfzWkPyW81OgHJzwTBjX_0NnRMqBdU1z5w9aiUG539khz8Q",
    "p": "1ZsCegkKkSZvVF60PvF71wGmWB8QLasdlhCeCFmfsnHYcc-CurGxJ3LSCsZwG_RiN28I4_FhZcgE3lwpO9ybGnL74AsnxvNKajg6R6RJzP1qcHYfgD6Wcoc0XzRE5nZ4K1C3P_q5p6cPOIMm-EygnuR1dbnGrnUIB50-UD_V238",
    "q": "wR3DuuPB7kh6MUiEqDAYAc_onHuRGasdwJZyWKpievoFqBV5DseEzvbtLsPo8sBrL2JhXRFfhbMbR-M7fZTs81bSTMkQ6g8wybSF0BL89jHLeHNh5-IXAwBligqz0-y7jDUM5aNIb8REUe9nhUiFvwEBUHszj21f15XTt9VM8tE",
    "dp": "sPUyzxCwbWFO97FhV4fM1WkrenN5f1VyCKQJl9dPwpAoBNkpasdIHSs1MPIGLFKAD3ZwAg6VZrGWvvPQwSPYZsf9PDVhpaMl8etU9Mb40NbcGADzxdWT45t42qo9rkNU-GVs-pbmuSpgJKwaW7d3lUqkuHvISfzwQwaUefz4WVc",
    "dq": "vmcCXHnC85UyJPVDFjCU-vRqfB646Kf9D6VGCHW1s1pfyWGighfasdl0AO_X9cAR7h4psQE4FTKKa053kVIMbb_kiSCVNLDVgYojhQuzrWlbG99nYKFh3uu9MWVr-D8oiwyjMqbS_J-eXMqWXqsqczAig591LqzAGmb24AHGZIE",
    "qi": "VcgJoTvhEgpg_PxYYwFdgKOeroP85efZCwOjItULJRtFSYoo7lL-Pd60jDtdAlkT2njX44_PvFRMblqj9ch4EasdW8FZFeIfbeVGGeJVYAfA5MlamP-4S4USa99YRKqGsh2d1AS41AMj5_cUl3W5JpwST83I7K6YYh9JELDhJtQ",
    "kty": "RSA",
    "e": "AQAB",
    "kid": "7J3M_fJl7lrVDLeOI0Z-yWJWQPERySLasdtJo4q6944",
    "n": "oSKyvkwxAw-zZ0lxkIvP5xms0Nmi0eK4cc7RT-C_N3wpasdtjFHIIe55VeUBqMRwFGKw-pwcJIcm2tL97kOg3KOU8jU8Zh6vv-JKlIVLGWasdbZ0DKnINH1wFLJSJ6zPBsChJ3BgLI81JQd65qLx-gS20Hok2wOCIasdywI7XIv5zpNjNmPqTCeerkUzD6cbh9dcJ9DH-I4RDCasd8GaNYd0alRjQ6D6OucZ1e_M4Zgj_rk2LHD6cSry2F5PNsP-r8i7oa7P_iEA3rriyMFWP4wpFrx6Jsa6gz-MqwTGllBkAc54WG_eGu_jz8J9G5hRLSZWr-mfNDRw7DPDG8pArw"
}
```

Paste this into a file and save it in the project's root directory as `private_key.jwk`
Click `done`
Click `Save`
Click `Save` again / confirm
Under `General Settings`, click `Edit` and uncheck `Require Demonstrating Proof of Possession (DPoP) header in token requests`
Click `Save`
Next to `Client ID` at the top, copy and paste the client ID into the `client_id` field in the okta.json file in the project's root directory e.g. `  "client_id": "0oau3zlvasdGrN9Pa697cd",`
Copy the okta domain and make sure `okta_domain` field in the okta.json file is set to your Okta domain's full url e.g. `  "okta_domain": "https://integrator-6273166.okta.com",`
Select the `Okta API Scopes` tab and click `Grant` on `okta.apps.read`
Click the `Admin roles` tab and click the `Edit assignments` button
Select the Role `Application Administrator` then click `Save Changes`. You can also make a custom role if you want

Run the script in the script's root directory `./script.sh`

TODO: Check: Is DPoP (Demonstrating Proof of Possession) necessary / more secure? How can you implement it?

#High level overview of flow
1. Generate a signed JWT. This JWT will last for 300 seconds.
2. Make a post request to https://{YourOktaDomain}/oauth2/v1/token with the JWT as the client_assertion url parameter
3. The response will be given as JSON with an access_token parameter. This access token should last for 300 seconds. Save that access token.
4. Make the final get request to https://{YourOktaDomain}/api/v1/apps/ with the header "Authorization: Bearer {YourAccessToken}"

Let me know if you run into any issues.
