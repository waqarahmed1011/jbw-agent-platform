#!/usr/bin/env bash
# Adds the Composio API key (Gmail, Calendar, Drive and Sheets connections) without it ever
# appearing on screen or in chat. Run as root in the server console:  bash /opt/jbw/add-composio.sh
set -euo pipefail
cd /opt/jbw/rakazo
# shellcheck disable=SC1091
source /opt/jbw/lib-env.sh

read -r -s -p "Paste the Composio API key, then press Enter: " KEY
echo
[[ ${#KEY} -ge 16 && "$KEY" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "That doesn't look like a Composio API key."; exit 1; }
set_env COMPOSIO_API_KEY "$KEY"
unset KEY

run_install
echo "Composio added. In the app: Settings, Integrations, Gmail, Connect."
