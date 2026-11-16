#!/usr/bin/env bash
# Adds the Telegram bot token to the server without it ever appearing on screen or in chat.
# Run in the Hetzner web console as root:  bash /opt/jbw/add-telegram.sh
set -euo pipefail
cd /opt/jbw/rakazo

read -r -s -p "Paste the Telegram bot token, then press Enter: " TOKEN
echo
[[ "$TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]] || { echo "That doesn't look like a BotFather token."; exit 1; }

set_env() {
  local key=$1 value=$2
  if grep -qE "^[#[:space:]]*${key}=" .env; then
    sed -i -E "s|^[#[:space:]]*${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}
set_env TELEGRAM_BOT_TOKEN "$TOKEN"
set_env TELEGRAM_WEBHOOK_SECRET_TOKEN "$(openssl rand -hex 32)"
unset TOKEN

bash install-images.sh
echo "Telegram added. In the app: Settings, Messaging, pick a bot, Connect a chat app, telegram."
