"""Builds cloud-init.yaml: one file to paste into Hetzner's "Cloud config" box.

Embeds the theme (shrunk icon), setup.sh and add-telegram.sh. Run: python3 server/build-cloud-init.py
"""
import base64
import io
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
        "OPERATOR_EMAIL=you@example.com\n"
        "DAD_EMAIL=dad@example.com\n"
        "ADMIN_EMAIL=office@example.com\n"
    )),
    ("/opt/jbw/theme/theme.json", "0644", None, (client / "theme" / "theme.json").read_text()),
    ("/opt/jbw/theme/icon.png", "0644", base64.b64encode(buf.getvalue()).decode(), None),
    ("/opt/jbw/setup.sh", "0700", None, (here / "setup.sh").read_text()),
    ("/opt/jbw/add-telegram.sh", "0700", None, (here / "add-telegram.sh").read_text()),
]

out = ["#cloud-config", "write_files:"]
for path, mode, b64, text in files:
    out += [f"  - path: {path}", f"    permissions: '{mode}'"]
    if b64 is not None:
        out += ["    encoding: b64", f"    content: {b64}"]
    else:
        out += ["    content: |", block(text)]
out += ["runcmd:", "  - [bash, /opt/jbw/setup.sh]", ""]
target = here / "cloud-init.yaml"
target.write_text("\n".join(out))
print(f"{target} {target.stat().st_size} bytes (Hetzner limit 32768)")
