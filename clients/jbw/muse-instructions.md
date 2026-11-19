# Muse Task List: JBW Platform Setup

Give these to Muse **one task at a time, in order**. Each task says what it needs from the
previous one. Paste the whole block, including the rules.

**Rules that go with every task (already included in each block):**

- Ask me before paying, starting a paid plan, or confirming any purchase.
- Secrets (API keys, tokens, passwords) go **only** into the field or prompt where they're used.
  Never put them in a chat message, note, email, document or screenshot to me.
- If a page looks different from these steps, stop and tell me what you see. Don't guess.

Files Muse needs (from the `jbw-agent-platform` repo, folder `clients/jbw/`):
`server/cloud-init.yaml`, `bot-roster.md`, `baseline-log.md`.

---

## Task 1: Publish the JBW app image on GitHub (about 10 min + 30 to 60 min of waiting)

```
Goal: build the JBW version of the platform on GitHub so the server can download it.

1. Open https://github.com/waqarahmed1011/rakazo/actions (I'm signed in to GitHub).
2. If GitHub says workflows are disabled for this fork, click
   "I understand my workflows, go ahead and enable them".
3. In the left list, click the workflow named "fork-image".
   If it shows "This workflow has a workflow_dispatch event trigger", click "Run workflow",
   choose branch "claude/loving-ride-r8uxm7", and click the green "Run workflow" button.
4. Wait until the run shows a green check (30 to 60 minutes). If it turns red, stop and send
   me the name of the step that failed.
5. Open https://github.com/waqarahmed1011?tab=packages, click the package "rakazo/app",
   then "Package settings". Under "Danger Zone", "Change visibility", set it to Public and
   confirm. (It contains no secrets; public lets the server download it without a login.)

Report back: "Image published" and the time the run finished.
Rules: ask me before paying for anything. Never put secrets in chat, notes or email.
If a page looks different from these steps, stop and tell me what you see.
```

Note: enabling Actions also turns on the fork's copy of upstream's own CI workflows. They run
on public-repo minutes (free). If the Actions tab gets noisy, disable the ones you don't need there.

---

## Task 2: Create the server (done on Contabo) (about 15 min + 15 min of waiting)

Before this task: use the filled-in cloud-init file I give you (it has the three account
emails already). Don't use the copy in the repo; that one only has placeholder emails.

```
Goal: create one server that installs the JBW platform by itself.

1. Go to https://www.hetzner.com/cloud and sign up (or sign in) with my email.
   Hetzner asks for ID or payment verification on new accounts. STOP and ask me before
   entering any payment details.
2. In the Hetzner Console, create a project named "JBW".
3. Click "Add Server" and choose:
   - Location: Helsinki
   - Image: Ubuntu 24.04
   - Type: Shared vCPU, Regular Performance, CPX42 (8 vCPU, 16 GB RAM). If CPX42 isn't
     available in Helsinki, pick Falkenstein or Nuremberg instead with the same type.
   - Networking: public IPv4 and IPv6 both on
   - SSH keys: skip (Hetzner will email a root password instead)
   - Backups: turn ON
   - Cloud config: paste the ENTIRE contents of the cloud-init.yaml file I gave you,
     exactly as is.
   - Name: jbw-platform
4. Before clicking "Create & Buy now", tell me the monthly price shown and wait for my OK.
5. After it's created, copy the server's IPv4 address.
6. Wait 15 minutes, then open https://jbw.<IP with dots replaced by dashes>.sslip.io
   (example: 65.21.10.4 becomes https://jbw.65-21-10-4.sslip.io).
   You should see "Sign in to JBW". If not, wait 10 more minutes and try again.

Report back: the server IP, the platform URL, and whether the "Sign in to JBW" page loads.
Rules: ask me before paying for anything. Never put secrets in chat, notes or email.
If a page looks different from these steps, stop and tell me what you see.
```

---

## Task 3: Get the account passwords off the server (about 5 min)

```
Goal: read the first-time passwords the server created, without sending them anywhere.

1. In the Hetzner Console, open server "jbw-platform", click ">_ Console" (top right).
2. Log in as root with the root password Hetzner emailed me when the server was created.
3. Type: cat /root/jbw-accounts.txt   and press Enter.
4. It lists three emails with passwords: mine, Dad's and the office admin's.
   Save each into my password manager under "JBW platform - <email>".
   Do NOT send them to me in chat or email.
5. If the file doesn't exist, type: tail -40 /var/log/jbw-setup.log
   and tell me the last 5 lines (they contain no passwords).

Report back: "3 accounts saved to the password manager", or the log lines if it failed.
Rules: never put secrets in chat, notes or email. If a page looks different, stop and tell me.
```

---

## Task 4: Gemini API key (about 10 min)

```
Goal: a paid-tier Gemini API key for the platform. (The free tier can use our data for
training, so it must be on a billing account. My existing credits cover the cost.)

1. Go to https://aistudio.google.com/apikey signed in as me.
2. Create an API key in a new Google Cloud project named "jbw-platform".
3. Make sure that project has billing linked (AI Studio shows "Set up billing" or "Paid tier"
   next to the key). If it asks for a card or to start billing, STOP and ask me.
4. Keep the key on screen; you'll paste it straight into the platform in Task 7.

Report back: "Gemini key created on a billing-linked project" (not the key itself).
Rules: ask me before paying. Never put the key in chat, notes or email.
```

---

## Task 5: Update the server to the new JBW version (about 10 min)

Before this task: the "fork-image" run for the latest commit must be green
(https://github.com/waqarahmed1011/rakazo/actions/workflows/fork-image.yml).

```
Goal: the server runs the new JBW version: JBW name everywhere, phone notifications, view-only members.

1. Open the server's web console in the Contabo control panel (VNC / console) and log in as root.
2. Type this one line and press Enter:
   curl -fsSL https://raw.githubusercontent.com/waqarahmed1011/jbw-agent-platform/claude/loving-ride-r8uxm7/clients/jbw/server/update-server.sh | bash
3. Wait until it prints "Updated:" (about 5 minutes). If it prints "STOP:", copy that line exactly.
4. Open the platform URL, reload, and sign in. The page title says JBW and the account menu
   has no "Get the mobile app" item.

Report back: "Server updated" or the STOP line / last 5 lines on screen (they contain no secrets).
Rules: never put secrets in chat, notes or email. If a page looks different, stop and tell me.
```

---

## Task 6: OpenAI key for voice (about 5 min)

```
Goal: an API key so the app can turn speech into text, read replies aloud and take calls
(about $0.003 a minute to listen, about $0.015 a minute to speak).

Important: my main OpenAI organization shares data with OpenAI (that's how it gets free
tokens). Voice hears Dad and the office, so this key must come from a SEPARATE organization
with data sharing off.

1. Go to https://platform.openai.com signed in as me. Use the organization switcher (top left)
   to create a new organization named "JBW". If you can't create one, STOP and ask me.
2. In the JBW organization: Settings, Data controls. Make sure sharing with OpenAI is OFF.
3. If the JBW organization has no billing, STOP and ask me before adding a card.
4. In the JBW organization, create an API key named "jbw-voice". Keep it on screen for Task 8.
Never use a key from my main (sharing) organization for voice.

Report back: "Voice key created" (not the key).
Rules: ask me before paying. Never put the key in chat, notes or email.
```

---

## Task 7: Composio key for Gmail, Calendar and Drive (about 10 min)

```
Goal: let the platform connect Google accounts through Composio, which is already approved by
Google (our own Google app would log everyone out every 7 days).

1. Go to https://platform.composio.dev (the developer platform, NOT dashboard.composio.dev)
   and sign in with my email. Choose the free plan. If it asks for a card, STOP and ask me.
2. Create a project "jbw-platform", then Settings, API Keys: create a key with WRITE access
   (session_management must be write). A key starting with "ck_" is the wrong kind.
3. In the server console (as in Task 5), type:  bash /opt/jbw/add-composio.sh
   Paste the key when asked and press Enter (nothing shows while pasting; that's normal).
4. Wait for "Composio added."

Report back: "Composio added" (not the key).
Rules: ask me before paying. Never put the key in chat, notes or email.
```

---

## Task 8: Set up the platform (about 45 min)

```
Goal: spaces, models, approvals and accounts set up in the JBW platform.
Use the platform URL from Task 2 and the passwords from my password manager (Task 3).

A. Sign in as ME (operator account).
   1. Settings, Account: change my password; save the new one in the password manager.
   2. Settings, Models: add a Google Gemini connection and paste the Gemini key from Task 4.
      Default model: the newest STABLE "Flash" model (not a preview or "Hydrogen"-style
      model; previews returned broken responses). Approval model: the same Flash model.
      Also add an OpenAI connection with a key from my MAIN OpenAI organization (the one with
      free daily tokens; create a key named "jbw-public-only"). Do NOT make it the default and
      do NOT pick it for any bot today. It is only for IDOT Watch later (public pages only).
      Then add a THIRD connection: OpenAI with a key from the separate "JBW" organization
      (data sharing off, the same org as the voice key; create a second key there named
      "jbw-backup"). Label it "OpenAI (backup)". In Settings, Models, set it as the BACKUP model
      for Chief, Inbox, Scheduler and Paperwork (a mid-priced OpenAI chat model, not the
      cheapest). Never use the "public data only" connection as a backup for these bots.
   3. Settings, Approvals: Mode = Ask.
   4. Create two spaces (the + at the top of the sidebar, "New private space"):
      "BTG Construction" and "JBW Engineering".
   5. In each space: Settings, Members, Invite. Make one invite link for Dad and one for the
      office admin (links work once). Save the 4 links in the password manager.
   6. In the BTG Construction space, create these bots using the exact instructions in
      bot-roster.md: Chief, Inbox, Scheduler, Paperwork. Give Chief the newest "Pro" model.
      Make a group "BTG Office" with all four.
   7. In the JBW Engineering space, create "Chief (JBW)" from bot-roster.md.

B. Sign out. Sign in as DAD.
   1. Change his password; save it. Open both invite links meant for Dad and click Join.
   2. Settings, Models: add the same Gemini key. Settings, Approvals: Ask.
   3. Settings, Voice: provider OpenAI, paste the voice key from Task 6.
      Then test: hold the mic next to the message box and speak (it should type your words),
      and press Call at the top right of a bot's chat for a spoken conversation.

C. Sign out. Sign in as the OFFICE ADMIN.
   1. Change the password; save it. Open both invite links meant for the admin and Join.
   2. Settings, Models: same Gemini key. Settings, Approvals: Ask.
   3. In the BTG Construction space, open Integrations (the "Connect apps" button): connect
      Gmail, Google Calendar and Google Drive with BTG's office Gmail account (the same email
      as this admin account). Google shows a Composio sign-in screen; that is expected. If
      Google shows an "unverified app" warning, STOP and ask me.
      If an earlier Google Calendar entry shows "Needs an OAuth client ID", open it and
      click Remove, then connect Calendar again.
   4. Create the routines listed in bot-roster.md for Inbox (every 30 min, weekdays 7 AM
      to 6 PM) under this account. Do NOT turn on Paperwork's routines yet.

D. Sign in as ME again. In each space, Settings, Members: nobody needs view-only today, so
   leave everyone as they are. (Use "Make view-only" on a person later for anyone who should
   read and chat but not change bots, memory or routines.)

Report back: a checklist of A1 to D with done / stopped-for-you / failed, plus anything that
looked different from these steps.
Rules: ask me before paying. Secrets go only into the field where they're used, never into
chat, notes or email. If a page looks different, stop and tell me what you see.
```

---

## Task 9: Put the app on Dad's and the admin's phones (about 10 min per phone, with them)

```
Goal: the JBW app is an icon on each phone and approvals arrive as notifications.
This needs the person and their phone: STOP and ask me to set up a time with them first.

iPhone (Safari only; Chrome on iPhone can't install it):
1. Open the platform URL in Safari and sign in.
2. Tap Share, then "Add to Home Screen", then Add. Open JBW from the new home screen icon.
3. Send any message to Chief. When the phone asks to allow notifications, tap Allow.
   (iPhone only shows notifications for the icon version, not the Safari tab.)

Android (Chrome):
1. Open the platform URL in Chrome and sign in.
2. Tap the menu (three dots), then "Add to Home screen" or "Install app".
3. Open JBW from the icon, send any message to Chief, and tap Allow for notifications.

Test on each phone: close the app, then from a computer signed in as that person ask Chief
"read https://idot.illinois.gov and summarize it in one line". Reading a website needs approval
in Ask mode, so an approval notification should arrive on the phone.
- Android: it has Approve and Deny buttons. Tap Deny.
- iPhone: tap the notification; the app opens on the approval card. Tap Deny.

Report back: per phone, "installed / notification arrived / buttons or tap worked", or what failed.
Rules: never send anything to anyone without my OK. If a screen looks different, stop and tell me.
```

---

## Task 10: Baseline reminders (5 working days, starts BEFORE the bots go live)

```
Goal: get 5 days of "before" numbers from the office admin.

1. Make a Google Sheet "BTG Baseline Log" in my Drive with the tables in baseline-log.md.
   Share it with the office admin (edit access).
2. Draft a short message to the admin explaining: for 5 working days, log the minutes spent on
   (1) email and scheduling and (2) project paperwork, about 10 minutes a day.
   Show me the draft and wait for my OK before sending.
3. Each working day at 4:30 PM for 5 days, check whether that day's rows are filled in.
   If not, draft a one-line reminder and send it after my OK.

Report back: daily, "Day N logged / not logged".
Rules: never send anything to anyone without my OK.
```

Turn on Inbox's routine only after Task 10 has 5 full days.
