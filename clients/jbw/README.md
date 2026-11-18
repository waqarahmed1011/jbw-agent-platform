# Client: JBW Engineering / BTG Construction

Showcase client (Dad's companies). Free to the client, hosting and AI usage re-billed at cost.
Not one of the 3 paid pilots in the business plan.

| | |
|---|---|
| Companies | JBW Engineering (civil/structural, pre-launch for IDOT work), BTG Construction (GC, operating) |
| Size | 5 to 15 people. Users: Dad + office admin |
| Email | BTG works out of a Gmail account (connected to the Inbox bot). Company domains jbwinc.com and btgconstructioninc.com are on Spacemail, which the platform can't connect to directly yet |
| First workflows | 1. Email + scheduling, 2. Project paperwork (both measured on BTG) |
| Platform | Branded Rakazo fork, one instance, 2 spaces (BTG Construction, JBW Engineering) |
| URL | `https://jbw.<server-ip-dashed>.sslip.io` until a real domain is set |
| Channels | Installed web app (home screen icon, push approvals, voice), email |
| Models | Gemini Flash (workers, approvals) + Gemini Pro (Chief), paid tier. Claude later |

## Files

| File | What it is |
|---|---|
| [muse-instructions.md](muse-instructions.md) | Step-by-step tasks for Meta Muse to do the setup |
| [server/cloud-init.yaml](server/cloud-init.yaml) | Paste into a new server's cloud-init / user data box. Edit the 3 emails first |
| [server/setup.sh](server/setup.sh), [server/lib-env.sh](server/lib-env.sh), [server/add-composio.sh](server/add-composio.sh) | What cloud-init runs (already embedded in cloud-init.yaml) |
| [server/update-server.sh](server/update-server.sh) | Moves a running server to the latest JBW image and settings |
| [server/build-cloud-init.py](server/build-cloud-init.py) | Rebuilds cloud-init.yaml after editing the scripts or theme |
| [theme/](theme/) | JBW name, icon and colors (navy #1A3852, orange #F09A3A) |
| [bot-roster.md](bot-roster.md) | Every bot's instructions, model and routine |
| [baseline-log.md](baseline-log.md) | 5-day time log before go-live |
| [screenshots/](screenshots/) | The branded sign-in page, light and dark |

## Monthly cost (estimate)

| Item | Cost |
|---|---|
| Contabo Cloud VPS 4 (live server) | per the Contabo invoice |
| Gemini API | $10 to $40, depending on email volume |
| OpenAI voice (talk to type, spoken replies, calls) | about $3 to $8 |
| Composio (Google connections) | free tier |
| **Total** | **server plus about $15 to $50/mo** |

## What's verified and what isn't

Verified locally against the full app (API, worker, web, Postgres) with a scripted test model:
the JBW name and icon on sign-in and in the app, no "Rakazo" text in the account menu or any
settings tab, view-only members refused when they try to change the space but able to chat, an
approval answered through the notification path (and refused for anyone but its owner), and
pushes refused for any address that is not a public push service.

Live in production: the server at `jbw.155-133-197-249.sslip.io` with HTTPS (Contabo).

Not yet tested: a real push to a real phone (needs Task 9), Composio sign-in for the BTG Gmail
(Task 8), and `setup.sh` from scratch on a fresh server (the live one was set up by Muse).

## Keeping the fork current

The fork's branch `claude/loving-ride-r8uxm7` carries a few changes on top of upstream:
theme name/icon and `INSTANCE_NAME` white-labeling, view-only space members, push approvals
for the installed web app, the plugin-source token, and the `fork-image` workflow. Merge upstream weekly;
each push rebuilds the image. On the server, pull the new image with
`server/update-server.sh` (Task 5 in muse-instructions.md).
