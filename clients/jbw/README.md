# Client: JBW Engineering / BTG Construction

Showcase client (Dad's companies). Free to the client, hosting and AI usage re-billed at cost.
Not one of the 3 paid pilots in the business plan.

| | |
|---|---|
| Companies | JBW Engineering (civil/structural, pre-launch for IDOT work), BTG Construction (GC, operating) |
| Size | 5 to 15 people. Users: Dad + office admin |
| Email/docs | Google Workspace (operator is admin) |
| First workflows | 1. Email + scheduling, 2. Project paperwork (both measured on BTG) |
| Platform | Branded Rakazo fork, one instance, 2 spaces (BTG Construction, JBW Engineering) |
| URL | `https://jbw.<server-ip-dashed>.sslip.io` until a real domain is set |
| Channels | Telegram (text + voice notes), email, web app (installable on phones) |
| Models | Gemini Flash (workers, approvals) + Gemini Pro (Chief), paid tier. Claude later |

## Files

| File | What it is |
|---|---|
| [muse-instructions.md](muse-instructions.md) | Step-by-step tasks for Meta Muse to do the setup |
| [server/cloud-init.yaml](server/cloud-init.yaml) | Paste into Hetzner's "Cloud config" box. Edit the 3 emails first |
| [server/setup.sh](server/setup.sh), [server/add-telegram.sh](server/add-telegram.sh) | What cloud-init runs (already embedded in cloud-init.yaml) |
| [server/build-cloud-init.py](server/build-cloud-init.py) | Rebuilds cloud-init.yaml after editing the scripts or theme |
| [theme/](theme/) | JBW name, icon and colors (navy #1A3852, orange #F09A3A) |
| [bot-roster.md](bot-roster.md) | Every bot's instructions, model and routine |
| [baseline-log.md](baseline-log.md) | 5-day time log before go-live |
| [screenshots/](screenshots/) | The branded sign-in page, light and dark |

## Monthly cost (estimate)

| Item | Cost |
|---|---|
| Hetzner CPX42, Helsinki, + backups | about €36 + €7 (about $47) |
| Gemini API | $10 to $40, depending on email volume |
| OpenAI voice transcription | under $5 |
| Telegram | free |
| **Total** | **about $60 to $90/mo** |

## What's verified and what isn't

Verified here: the JBW theme (name, icon, colors) renders on the sign-in page in light and dark
mode, the theme tests pass, and the type check and repo checks pass after merging upstream.

Not yet tested on a real server: `setup.sh` / cloud-init (written to Rakazo's documented install
steps, but it has never run on a Hetzner box), Telegram webhook registration, and Let's Encrypt
certificates for the sslip.io hostname. If HTTPS fails, the fix is a real subdomain
(e.g. `ops.<jbw-domain>.com` pointed at the server IP) and editing `/etc/caddy/Caddyfile`.

## Keeping the fork current

The fork's branch `claude/loving-ride-r8uxm7` carries 3 small changes on top of upstream:
theme name/icon support, the `fork-image` workflow, and a docs paragraph. Merge upstream weekly;
each push rebuilds the image. On the server, pull the new image with
`cd /opt/jbw/rakazo && bash install-images.sh`.
