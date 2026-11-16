# Rakazo Viability Test Plan

Goal: decide whether Rakazo (open source, Apache 2.0) is a good base for a white-labeled client
platform. Fill in the Result, Time, Cost and Notes for each test as you go. When you are done,
I'll turn this file into the viability report.

Fork: https://github.com/waqarahmed1011/rakazo
Upstream: https://github.com/elie222/rakazo (version tested: 0.12.0, Nov 16 2026)

---

## 0. Deploy on Railway

1. Create a new Railway workspace just for this (keeps the sandbox computers away from anything else).
   Hobby plan is fine for testing.
2. In that workspace, go to Account Settings, then Tokens, and create a workspace token.
3. Open https://railway.com/new/template/rakazo-template
   - `OWNER_EMAIL`: your email
   - `RAILWAY_API_TOKEN`: the token from step 2 (it lets Rakazo create the bot computers)
4. Deploy and wait until the service shows healthy. Open the generated HTTPS domain.
5. Sign in with your email and the `OWNER_PASSWORD` from the Rakazo service's Variables tab.
   Change the password right away in account settings.

Do not turn on service sleeping and keep it at one replica (per the Rakazo docs).

| Check | Result |
|---|---|
| Deployed and healthy | |
| Time from click to first sign-in | |

## 1. Connect a model

1. Get a free Gemini API key at https://aistudio.google.com/apikey
2. In Rakazo: Settings, then Models. Add the Google / Gemini connection and paste the key there
   (never paste keys into a bot chat).
3. Pick a Flash model as the default and a Pro model for Chief (the orchestrator bot).
4. Settings, then Models: set an **Approval model** (Flash is fine). This is what makes Auto mode work.
5. Settings, then Approvals: set Mode to **Ask** for now.
6. Send Chief "hi, what can you do?"

Heads up: the free tier has low rate limits. If bots error out with "429" or "quota" messages
during the bigger tests, write it down as a rate limit, not a Rakazo failure. Your Gemini credits
or Claude later will fix it.

| Check | Result |
|---|---|
| Chief replies | |
| Model used | |

## 2. Test cases

Score each one: **Works** / **Partial** / **Fails**. Note setup time, cost (Usage page) and anything weird.

### A. Email intake with approval (best-evidence use case from the research)
Connect a test Gmail account (Settings, Integrations). Create a bot "Intake" with instructions:
"When a new email arrives that is a job or service request, pull out customer name, address,
job type, urgency and preferred time. Post a summary in this chat and draft a reply confirming
we got it. Never send without approval."
Add a routine triggered by incoming email. Send 3 test emails from another account, one of them
vague and one of them spam.

| Result | Setup time | Cost | Notes (did it ask before sending? did it handle the vague one / spam?) |
|---|---|---|---|
| | | | |

### B. Social post drafting with approval
Bot "Social": "Draft 3 posts a week for [fake HVAC company]. Show me each draft for approval.
After approval, schedule through the connected scheduler, never by clicking in the social site."
Connect Buffer (or skip scheduling and only test drafting + approval).

| Result | Setup time | Cost | Notes |
|---|---|---|---|
| | | | |

### C. Computer use on a site with no API
Ask a bot to fill out a public web form (any contact form or a test form like
https://httpbin.org/forms/post) using its computer. Then ask it to log into a site where you take
over the screen to type the password yourself.

| Result | Setup time | Cost | Notes (speed, did the login handoff work?) |
|---|---|---|---|
| | | | |

### D. Agent team: Chief delegating to specialists
Make a group with Chief + Intake + Social + one "Research" bot. Ask Chief: "Find 5 HVAC companies
in Phoenix, draft an intro email to each, and draft one social post about spring AC tune-ups."
Watch for bots talking in circles. Stop it if it runs more than 10 minutes.

| Result | Total time | Cost | Notes (did it split the work? any loops?) |
|---|---|---|---|
| | | | |

### E. Client isolation (this decides how you host clients)
Create two spaces: "Client A Plumbing" and "Client B Dental". In A, tell a bot a fake secret fact
("our gate code is 4471") and connect an integration. In B, ask a bot what the gate code is and
check whether A's integration or computer logins show up.

| Result | Notes (any memory, computer or credential leaking between spaces?) |
|---|---|
| | |

### F. Audit log and cost visibility
Export the audit log (organization settings). Open the Usage page.

| Check | Result |
|---|---|
| Audit log shows approvals + tool calls from tests A–D | |
| Cost per test visible | |
| Total spend for all tests | |

## 3. Your gut check

| Question | Answer |
|---|---|
| Would a 10-person plumbing owner figure this UI out with a 30 min walkthrough? | |
| Which test would you demo first on a sales call? | |
| What broke or annoyed you most? | |
| Overall: build on Rakazo / build our own / unsure | |

---

## What I already checked in the code (no need to test)

- **License:** Apache 2.0. You can modify, rebrand and charge for it. You must keep the LICENSE and
  NOTICE files and can't call your product "Rakazo."
- **Built in already:** spaces (isolated workspaces), approvals (Ask / Auto / Never + allow and block
  lists + a spending limit), an audit log that can't be edited, routines (schedule / email / webhook),
  group chats and subagents, computer use, voice and calls, MCP + thousands of integrations,
  any model, and Stripe billing with model credits charged at cost.
- **Rebrand effort for the client-facing web app:** small. About 50 English UI strings in
  `packages/i18n/locales/en/messages.po`, about 20 files in `apps/web/src`, the page title and icons in
  `apps/web/index.html` and `apps/web/public`, plus the auth emails in `packages/auth/src`. The other
  ~2,500 mentions are in the marketing site, the desktop app and translations, which clients
  don't need. Estimate: 1 to 2 days to build a brand config that swaps name, logo and colors per client.
- **Biggest risk:** it moves very fast (3 releases in 5 days). Heavy custom changes in the fork
  will be painful to keep up to date. The plan is to keep our changes small (branding plus our own
  bot templates and plugins) and update from upstream weekly.
- **Shared spaces share one computer and its logins.** For client isolation, use one space per
  client at minimum, and ideally one deployment per client.
