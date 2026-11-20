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

# Reinstalls from the JBW fork's compose files, which pass the JBW settings to the app.
# Upstream's files (the installer's default) drop INSTANCE_NAME and the push keys.
run_install() {
  export RAKAZO_DOWNLOAD_BASE="https://raw.githubusercontent.com/waqarahmed1011/rakazo/claude/loving-ride-r8uxm7/infra/compose"
  curl -fsSL "$RAKAZO_DOWNLOAD_BASE/install-images.sh" -o install-images.sh
  curl -fsSL "$RAKAZO_DOWNLOAD_BASE/docker-compose.images.yml" -o docker-compose.images.yml
  bash install-images.sh
}
