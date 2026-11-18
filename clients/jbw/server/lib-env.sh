# Shared by the JBW server scripts: edit one KEY=value line in the platform's .env.
set_env() {
  local key=$1 value=$2
  if grep -qE "^[#[:space:]]*${key}=" .env; then
    sed -i -E "s|^[#[:space:]]*${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

env_value() {
  grep -E "^${1}=" .env | tail -1 | cut -d= -f2-
}

# Web Push keys (P-256): the public key goes to browsers, the private key stays here.
ensure_push_keys() {
  [[ -n "$(env_value WEB_PUSH_PRIVATE_KEY)" ]] && return 0
  local pem
  pem=$(mktemp)
  openssl ecparam -name prime256v1 -genkey -noout -out "$pem"
  local b64url='base64 -w0 | tr "+/" "-_" | tr -d "="'
  set_env WEB_PUSH_PRIVATE_KEY "$(openssl ec -in "$pem" -outform DER 2>/dev/null | tail -c +8 | head -c 32 | eval "$b64url")"
  set_env WEB_PUSH_PUBLIC_KEY "$(openssl ec -in "$pem" -pubout -outform DER 2>/dev/null | tail -c 65 | eval "$b64url")"
  set_env WEB_PUSH_CONTACT "mailto:$1"
  rm -f "$pem"
}
