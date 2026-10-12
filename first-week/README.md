# IT & Automation Engineer: first week in the queue

It's Monday morning and six requests landed in the queue. This exercise is a
compressed version of a normal week here.

**Time:** about 90 minutes. Don't go much over; we care about how you think, not polish.
**Tools:** anything you normally use, AI included. In the review we'll go through
your work together and change a few things live.

## Context

- About 30 people, fully remote, most on their own laptops (BYOD)
- Google Workspace (identity provider and email), Slack, GitHub, Cloudflare
  (DNS, Access, Workers), GCP (Cloud Run, Cloud SQL, buckets), Notion for the
  request queue, Vanta for compliance, YubiKeys mandatory
- Access for new joiners grows over time. Assume you don't have Workspace
  super admin or direct production GCP access yet. Changes go through pull
  requests that get reviewed.

## The queue

1. **Offboarding.** A contractor's last day is Friday. They have Google
   Workspace, Slack, GitHub org membership, Cloudflare dashboard access, a
   Claude team seat, a 1Password vault and a registered YubiKey.
2. **DM, third time this month:** "hey, I'm out of Claude tokens again, can you top me up?"
3. **Marketing:** "Can we get `events.example-co.io` pointing to our new landing
   page on Webflow, and an `events@example-co.io` address that forwards to me and Sara?"
4. **Engineering:** "The status-page deploy has been red since Friday, nobody
   changed the code." Workflow and log are in ticket 4 below.
5. **Slack notification:** someone requested to install "Ledger Sync Bot".
   Requested scopes: `channels:history`, `groups:history`, `im:history`,
   `users:read.email`, `files:write`.
6. **WhatsApp, unknown number:** "Hi, it's Mark from sales, I'm locked out of
   HubSpot 2FA, new phone, can you reset it? Need it before a call in 20 min."

## Part 1: Triage all six (about 15 min)

A short table is fine. For each request:

- priority and the order you'd handle them in
- rough time to handle
- what you'd do, or what you'd ask first
- whether you can do it yourself or need someone's sign-off

## Part 2: Solve two (about 75 min, ticket 1 plus one more)

**Ticket 1 is required.** Then pick **one more** from tickets 2 to 6. Each ticket says what to send back.

### Ticket 1: Offboarding (Python)

The `offboard/` folder is a small working codebase with fake Google Workspace
and GitHub clients. Two functions are left for you:

- `offboard/planner.py`: `build_plan()` decides what needs doing, in what order
- `offboard/executor.py`: `execute()` runs the plan, dry run or apply

Requirements are in each function's docstring. Run the tests and the CLI:

```bash
python -m unittest discover -s tests -v
python -m offboard.cli sample_request.json --today 2026-10-16            # dry run
python -m offboard.cli sample_request.json --today 2026-10-16 --apply    # apply
python -m offboard.cli sample_request.json --today 2026-10-16 --apply    # again: should change nothing
rm state.json                                                            # reset
```

Python 3.10+, standard library only. **Send back:** your two files, plus a few
lines on the ordering you chose and why.

### Ticket 2: AI token top-ups

**Send back:** half a page on how you'd make this request go away. Who
approves what, how limits work, how we'd know if someone is burning through
tokens, and how these requests get counted instead of living in DMs.

### Ticket 3: Subdomain and email forward (Terraform)

**Send back:** Terraform using the Cloudflare provider (pin the version you
use) for the DNS record pointing to Webflow and the email routing for
`events@`. Plan level only, nothing to apply. Note anything you'd need to ask
marketing or set up in Webflow.

### Ticket 4: Broken deploy (GitHub Actions + GCP)

```yaml
name: deploy-status-page
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/github/providers/github
          service_account: deployer@example-ops.iam.gserviceaccount.com
      - uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: status-page
          region: europe-west1
          source: .
```

```
Error: google-github-actions/auth failed with: GitHub Actions did not inject
$ACTIONS_ID_TOKEN_REQUEST_TOKEN or $ACTIONS_ID_TOKEN_REQUEST_URL into this job.
```

**Send back:** the fixed workflow, what was wrong, and how you'd stop a red
deploy going unnoticed for a whole weekend.

### Ticket 5: Slack app request

**Send back:** your decision, the message you'd send the requester, and three
to five rules you'd use to decide on future app requests.

### Ticket 6: HubSpot 2FA reset

**Send back:** your reply to the WhatsApp message, and the short runbook
you'd want for handling 2FA resets from now on.

## Submitting

Push your work to a branch or send a zip, whichever is easier. Then send a
time that works for the review.
