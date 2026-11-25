#!/usr/bin/env bash
# Updates a running JBW server to the latest JBW image and turns on its newer settings
# (product name, push notifications for the installed app). Safe to run again.
# Run as root in the server console:
#   curl -fsSL https://raw.githubusercontent.com/waqarahmed1011/jbw-agent-platform/claude/loving-ride-r8uxm7/clients/jbw/server/update-server.sh | bash
set -euo pipefail
BASE="https://raw.githubusercontent.com/waqarahmed1011/jbw-agent-platform/claude/loving-ride-r8uxm7/clients/jbw/server"
if [[ ! -f /opt/jbw/rakazo/.env ]]; then
  echo "STOP: no /opt/jbw/rakazo/.env on this server. Report where the platform is installed."
  exit 1
fi
cd /opt/jbw/rakazo
curl -fsSL "$BASE/lib-env.sh" -o /opt/jbw/lib-env.sh
curl -fsSL "$BASE/add-composio.sh" -o /opt/jbw/add-composio.sh
chmod 700 /opt/jbw/add-composio.sh
# shellcheck disable=SC1091
source /opt/jbw/lib-env.sh
# shellcheck disable=SC1091
[[ -f /opt/jbw/settings.env ]] && source /opt/jbw/settings.env
CONTACT=${OPERATOR_EMAIL:-$(grep -m1 -oE '[^[:space:]]+@[^[:space:]]+' /root/jbw-accounts.txt 2>/dev/null || true)}
[[ -n "$CONTACT" ]] || { echo "STOP: no operator email found. Report this."; exit 1; }

set_env INSTANCE_NAME JBW
# Shows the hold-to-talk mic and the Call button (they need a voice provider in Settings, Voice).
set_env PHONE_CALLS_ENABLED true
# The ticket Board: bots propose work as offer cards and pick up approved tickets.
set_env TICKET_BOARD_ENABLED true
ensure_push_keys "$CONTACT"

run_install
echo "Updated: $(cat /root/jbw-url.txt 2>/dev/null || echo 'the JBW platform')"
