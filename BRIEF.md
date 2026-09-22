# Candidate brief

## 1. Format

| Item | Detail |
| --- | --- |
| Time | 90 minutes maximum |
| Type | Take-home. Do it when it suits you |
| Deliverable | A written proposal of 1 to 2 pages |
| Code | Optional. See section 2 |
| Follow-up | A 45 minute discussion with the hiring manager |

## 2. Rules for code

Do not build the system. Write the proposal.

You can add a proof of concept. Keep it minimal. A 20 line script that shows the idea is enough. A proposal with no code is complete.

## 3. What we assess

We assess how you think about operational work. Four things matter:

1. What you automate.
2. What you leave alone.
3. How you reason about failure.
4. How you explain the change to the people who must use it.

We do not assess cloud architecture knowledge. We do not test a specific tool. If a detail of Terraform, edge service or cloud platform is new to you, say so in the proposal. This costs you nothing.

**If you need a fact that is not in this brief, do one of two things. Ask us. Or state your assumption and continue.** Both are correct. Do not guess in silence.

## 4. The company

Northwind Labs is a fictional company. It has 40 staff. Six of them are engineers.

The company runs five sites: a customer web app, a docs site, a marketing site, an internal dashboard and a partner portal. edge service sits in front of two DNS zones. Two cloud platform projects sit behind
edge service.

All infrastructure is in one repository, `northwind-ops`. You have a copy. All of the infrastructure is Terraform. CI plans it.

The IT and automation team is two people. P. Raman has run the team alone for some time. P. Raman wrote most of what you see. You are the second person.

## 5. The current state

The repository has three Terraform stacks.

| Stack | Owns | Applied by |
| --- | --- | --- |
| `edge-headers` | Response security headers for both zones | CI, automatically, on merge to `main` |
| `edge-dns` | DNS records, redirects and the company email records | A person, from a laptop, after merge |
| `cloud-access` | Project IAM for both cloud platform projects | A person, from a laptop, after merge |

CI plans every pull request. The plan is read-only.

After merge, `edge-headers` applies itself. The other two stacks wait. A person must run `scripts/apply.sh`. There are two reasons:

1. No CI credential can write to those stacks.
2. An apply by a person puts that person's name in the cloud audit log.

Nothing records which changes are merged but not yet applied. At Northwind, someone who wants to know reads CI, then the chat
channel, then `terraform plan`.

The same two people also handle the request queue. Any member of staff can file a request. `requests/QUEUE.md` holds the open requests. It also shows the last 20 closed requests.

## 6. How to read the repository

Read these files in this order:

1. `README.md`
2. The `OPERATIONS.md` next to each stack
3. `requests/QUEUE.md`

Then plan a stack. You need no credentials.

```bash
cd terraform/edge-headers
terraform init
terraform plan
```

Allow 20 to 25 minutes for reading. Read the code as well as the documentation.

The repository is a snapshot. It has no pull request history, no CI
history and no chat logs.

## 7. Choose one track

Write your proposal about one track. We score both tracks the same way. Choose the track you have more to say about.

### Track A: the gap between merge and apply

A change to `edge-dns` or `cloud-access` is merged. It then waits for a person with the correct credentials. Nobody can see what is pending. Nothing reports a forgotten apply. New requests keep arriving.

Propose how to improve this.

Your proposal must answer one question. It must also state what your answer
costs.

**For `edge-dns`, which of these three must the apply become?**

1. Fully automatic on merge.
2. A CI run behind a human approval step.
3. A manual local apply, with better documentation.

There is no correct answer. We assess the reasoning, not the choice.

### Track B: joiner, mover, leaver

A person joins, changes role or leaves. Today this needs a pull request against `cloud-access` plus manual edits in several admin consoles. Those consoles are not in this repository. See the last section of `README.md`.

Nobody can answer "who has access to what, and why" without reading Terraform by hand.

Propose how to improve this.

Your proposal must answer one question. It must also state what your answer
costs.

**When HR marks a person as leaving, which of these three must deprovisioning
do?**

1. Run automatically for all access.
2. Run automatically for some kinds of access only.
3. Stay a checklist that a person runs.

There is no correct answer. We assess the reasoning, not the choice.

## 8. Required contents

Keep the proposal to 1 to 2 pages. Use headings and bullets. Use this order.

**8.1 Current state.** Write a few sentences. Report anything in the repository that you think matters.

**8.2 Your changes.** State what you would change. State the order. Three changes you would finish are better than ten you would start.

**8.3 The decision.** Give your answer to the question in your track. State what your answer costs.

**8.4 Rollback and blast radius.** This section is mandatory. For each change, answer four questions:

1. What is the worst result if the change is wrong?
2. Who detects it first?
3. How do you reverse it?
4. How long does it take to reverse?

**8.5 Scope.** State what you are not doing in this proposal. State why.

**8.6 One paragraph for a non-engineer.** M. Lindqvist is the operations coordinator at Northwind. They are careful. They use a browser and a web form. They have never used a terminal.

Write the paragraph that M. Lindqvist reads. Tell them three things:

1. What your change does.
2. What it needs from them.
3. What to do when it fails.

Write one paragraph. Address it to them, not to us. We read this paragraph
closely.

**8.7 Priorities.** The queue in `requests/QUEUE.md` is open. The quarterly access review is due on 30 September 2026. State what you would do in your first two weeks. State what you would leave until later.

**8.8 AI usage.** See section 9.

## 9. AI tools

Use AI tools. We use them daily.

Add a final section with two parts:

1. The prompts you used, or a link to the transcript.
2. **What you changed in the output.**

We read part 2 closely. Report where the model was wrong. Report where it was generic. Report where it invented a fact. Report what you kept and what you rewrote.

We prefer an AI-drafted submission with an honest annotation to a weaker
submission written without help.

## 10. How to submit

Send one file. Use Markdown or PDF. Name it `PROPOSAL.md` or `PROPOSAL.pdf`.

If you wrote a proof of concept, put it in the same folder, or link a gist.

Reply to the email thread that linked you to this exercise.

Ask questions before you start. Asking a question does not harm your result.
