import json, time, uuid, jwt
from pathlib import Path
from jwt.algorithms import RSAAlgorithm

cfg = json.loads(Path("okta.json").read_text())
OKTA_DOMAIN = cfg["okta_domain"].rstrip("/")
CLIENT_ID = cfg["client_id"]
JWK_PATH = cfg.get("jwk_path", "private.jwk")

token_url = f"{OKTA_DOMAIN}/oauth2/v1/token"

jwk_text = Path(JWK_PATH).read_text()
jwk = json.loads(jwk_text)

key_obj = RSAAlgorithm.from_jwk(jwk_text)

now = int(time.time())

claims = {
    "iss": CLIENT_ID,
    "sub": CLIENT_ID,
    "aud": token_url,
    "iat": now,
    "exp": now + 300,
    "jti": str(uuid.uuid4())
}
headers = {
    "alg":"RS256",
    "kid":jwk.get("kid"),
    "typ":"JWT"
}

print(jwt.encode(claims, key_obj, algorithm="RS256", headers=headers))
