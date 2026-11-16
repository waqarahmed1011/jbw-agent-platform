#!/usr/bin/env bash
# Sets up the JBW agent platform on a fresh Hetzner Ubuntu 24.04 server.
# Runs once from cloud-init as root. Log: /var/log/jbw-setup.log
# Result: https://jbw.<server-ip-with-dashes>.sslip.io, accounts in /root/jbw-accounts.txt
set -euo pipefail
exec > >(tee -a /var/log/jbw-setup.log) 2>&1

# Filled in before pasting (see settings.env in cloud-init.yaml).
# shellcheck disable=SC1091
source /opt/jbw/settings.env
: "${OPERATOR_EMAIL:?}" "${DAD_EMAIL:?}" "${ADMIN_EMAIL:?}"

FORK_RAW="https://raw.githubusercontent.com/waqarahmed1011/rakazo/claude/loving-ride-r8uxm7/infra/compose"
APP_IMAGE="ghcr.io/waqarahmed1011/rakazo/app"
APP_TAG="clients"

IP=$(curl -fsS http://169.254.169.254/hetzner/v1/metadata/public-ipv4)
HOST="jbw.${IP//./-}.sslip.io"
echo "Setting up ${HOST}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q caddy ufw unattended-upgrades openssl
curl -fsSL https://get.docker.com | sh

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443
ufw --force enable

mkdir -p /opt/jbw/rakazo
cd /opt/jbw/rakazo
cp -r /opt/jbw/theme ./theme
cat > docker-compose.override.yml <<'YAML'
services:
  web:
    volumes:
      - ./theme:/theme:ro
YAML

export RAKAZO_DOWNLOAD_BASE="$FORK_RAW"
curl -fsSLO "$FORK_RAW/install-images.sh"
bash install-images.sh --prepare-only

set_env() {
  local key=$1 value=$2
  if grep -qE "^[#[:space:]]*${key}=" .env; then
    sed -i -E "s|^[#[:space:]]*${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

# Use the JBW fork image; fall back to upstream if the fork image hasn't been published yet.
if docker manifest inspect "${APP_IMAGE}:${APP_TAG}" > /dev/null 2>&1; then
  set_env RAKAZO_IMAGE "$APP_IMAGE"
  set_env RAKAZO_IMAGE_TAG "$APP_TAG"
else
  echo "WARNING: ${APP_IMAGE}:${APP_TAG} not found, using upstream image (colors only, no JBW name/icon)."
fi
set_env RAKAZO_HOST "$HOST"
set_env BETTER_AUTH_URL "https://${HOST}"
set_env WEB_ORIGIN "https://${HOST}"
set_env API_URL "https://${HOST}"
set_env SIGNUPS_ENABLED false
set_env RAKAZO_THEME /theme/theme.json

bash install-images.sh

cat > /etc/caddy/Caddyfile <<CADDY
${HOST} {
  reverse_proxy 127.0.0.1:5173
}
CADDY
systemctl reload caddy || systemctl restart caddy

# Accounts: one per person, random first password, changed on first sign-in.
compose=(docker compose --env-file .env -f docker-compose.images.yml -f docker-compose.override.yml)
umask 077
{
  echo "JBW platform: https://${HOST}"
  echo "Change each password after the first sign-in (Settings, Account)."
  echo
} > /root/jbw-accounts.txt
for OWNER_EMAIL in "$OPERATOR_EMAIL" "$DAD_EMAIL" "$ADMIN_EMAIL"; do
  OWNER_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)
  export OWNER_EMAIL OWNER_PASSWORD
  "${compose[@]}" exec -T -e OWNER_EMAIL -e OWNER_PASSWORD api node dist/cli/bootstrap-owner.js
  echo "${OWNER_EMAIL}  ${OWNER_PASSWORD}" >> /root/jbw-accounts.txt
  unset OWNER_EMAIL OWNER_PASSWORD
done

echo "https://${HOST}" > /root/jbw-url.txt
echo "DONE: https://${HOST}"
