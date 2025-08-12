import json, time, uuid, jwt
from pathlib import Path
from jwt.algorithms import RSAAlgorithm, ECAlgorithm

cfg = json.loads(Path("okta.json").read_text())
OKTA_DOMAIN = cfg["okta_domain"].rstrip("/")
CLIENT_ID = cfg["client_id"]
JWK_PATH = cfg.get("jwk_path", "private.jwk")

token_url = f"{OKTA_DOMAIN}/oauth2/v1/token"

jwk_text = Path(JWK_PATH).read_text()
jwk = json.loads(jwk_text)

alg = jwk.get("alg") or ("RS256" if jwk.get("kty") == "RSA"
                         else {"P-256":"ES256","P-384":"ES384","P-521":"ES512"}.get(jwk.get("crv"), "ES256"))

key_obj = (RSAAlgorithm if jwk["kty"] == "RSA" else ECAlgorithm).from_jwk(jwk_text)

now = int(time.time())
claims = {
    "iss": CLIENT_ID, "sub": CLIENT_ID, "aud": token_url,
    "iat": now, "exp": now + 300, "jti": str(uuid.uuid4())
}
headers = {k:v for k,v in {"kid": jwk.get("kid")}.items() if v}

print(jwt.encode(claims, key_obj, algorithm=alg, headers=headers))

