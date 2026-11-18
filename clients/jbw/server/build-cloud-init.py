"""Builds cloud-init.yaml: one file to paste into the server provider's cloud-init / user data box.

Embeds the theme (shrunk icon), setup.sh, lib-env.sh and add-composio.sh. Run: python3 server/build-cloud-init.py                 (template with placeholder emails)
     OPERATOR_EMAIL=.. DAD_EMAIL=.. ADMIN_EMAIL=.. python3 server/build-cloud-init.py /path/outside/repo.yaml
"""
import base64
import io
import os
import sys
from pathlib import Path

from PIL import Image

here = Path(__file__).resolve().parent
client = here.parent

icon = Image.open(client / "theme" / "icon.png").convert("RGB").resize((256, 256), Image.LANCZOS)
buf = io.BytesIO()
icon.save(buf, format="PNG", optimize=True)


def block(text: str, indent: int = 6) -> str:
    pad = " " * indent
    return "\n".join(pad + line if line else "" for line in text.splitlines())


files = [
    ("/opt/jbw/settings.env", "0600", None, (
        "# EDIT THESE THREE LINES before pasting (emails only, never passwords or keys)\n"
        f"OPERATOR_EMAIL={os.environ.get('OPERATOR_EMAIL', 'you@example.com')}\n"
        f"DAD_EMAIL={os.environ.get('DAD_EMAIL', 'dad@example.com')}\n"
        f"ADMIN_EMAIL={os.environ.get('ADMIN_EMAIL', 'office@example.com')}\n"
    )),
    ("/opt/jbw/theme/theme.json", "0644", None, (client / "theme" / "theme.json").read_text()),
    ("/opt/jbw/theme/icon.png", "0644", base64.b64encode(buf.getvalue()).decode(), None),
    ("/opt/jbw/setup.sh", "0700", None, (here / "setup.sh").read_text()),
    ("/opt/jbw/lib-env.sh", "0644", None, (here / "lib-env.sh").read_text()),
    ("/opt/jbw/add-composio.sh", "0700", None, (here / "add-composio.sh").read_text()),
]

out = ["#cloud-config", "write_files:"]
for path, mode, b64, text in files:
    out += [f"  - path: {path}", f"    permissions: '{mode}'"]
    if b64 is not None:
        out += ["    encoding: b64", f"    content: {b64}"]
    else:
        out += ["    content: |", block(text)]
out += ["runcmd:", "  - [bash, /opt/jbw/setup.sh]", ""]
# A filled-in copy holds real emails: write it outside the repo (this repo is public).
target = Path(sys.argv[1]) if len(sys.argv) > 1 else here / "cloud-init.yaml"
target.write_text("\n".join(out))
print(f"{target} {target.stat().st_size} bytes (cloud-init user data limit 32768)")
