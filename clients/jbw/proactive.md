# Proactive bots without the bill

Bots should notice work and offer it, so the owner only taps Yes or Not now. The Nov 24 Head Chief
loop (80 runs in a day from monitors pinging it) is what this setup prevents.

## The four rules

1. **Watch, don't poll.** Use a routine's **When something changes** trigger (a Gmail search, a
   Drive folder, a sheet range, a command's output). The platform fingerprints the result with no
   model call and only starts a run when something actually changed. Use a clock schedule only
   for things that must happen at a time (the morning plan, a Friday summary). Never schedule a
   bot more often than every 2 hours.
2. **Offer, don't ask.** When a bot finds work nobody asked for, it creates a ticket with
   `proposed` set. That shows up first on the Dashboard and as a phone notification with
   Approve / Deny. Nothing runs until a person taps Yes. Questions in chat are only for things a
   card can't answer.
3. **Silence is the default.** A run with nothing new ends with no message. Monitors never
   message a chief on a schedule; they offer or escalate only on a change or a breach.
4. **Each bot has a daily cap.** Bot settings > **Runs on its own per day** (default 40). Hitting it
   ends the extra runs before any model call and tells the owner once. Set monitors to 20.

## Setup

1. Tag every bot with its team (Office, Projects, Finance, Marketing, Systems) and tag each chief
   `Chief` too. Each tag gets a group chat.
2. In each tag group's **Group settings**, set **Lead** to that team's chief. Unaddressed messages
   go to the chief, and when a member's run fails, the chief is asked to retry or reassign it
   before it reaches your Stuck list.
3. Settings > Labs: the Board is on for the whole server (offers are Board tickets).

## Morning plan (Head Chief, weekdays 6:30 AM)

Routine prompt:

```
Build today's plan. Read the Jobs, Calendar and Deadlines, and Inbox Log tabs, open tickets,
and anything waiting on Jameel.
1. For each piece of work a team should do today that nobody has asked for, create one proposed
   ticket owned by the bot that will do it. Title = what it will do, description = why today.
   At most 5. Skip anything already on the board.
2. Post one message, at most 6 lines: the 3 decisions only Jameel can make today, then
   "N offers waiting on the dashboard".
3. If nothing needs Jameel and there is nothing to offer, post nothing.
```

## Watchers per team (all "When something changes")

| Bot | Watches | Does on change |
|---|---|---|
| Office Chief | Gmail search `is:unread -category:promotions` | Logs it, drafts replies, offers anything needing action |
| Paperwork and Permits | Drive "COIs" and "Permits" folders | Logs new files; offers renewal requests 30 days before expiry |
| Each Job Manager | That job's tab, Budget columns | Offers a fix when a line passes 80% or goes over |
| Billing Clerk | Drive "Bank exports" folder | Categorizes, offers payment reminders for overdue invoices |
| Ops and Safety Monitor | Dashboard is enough; no routine | Daily 5 PM: one line only if a bot broke a rule or hit its cap |

## Line to add to every bot's instructions

```
When you notice work in your area that nobody asked for, offer it with ticket_create and
proposed set, instead of asking in chat or doing it. Never message another bot on a schedule.
If a run finds nothing new, end with no message.
```
