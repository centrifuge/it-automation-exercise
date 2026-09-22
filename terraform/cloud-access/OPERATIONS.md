# cloud-access operations

**Path:** `terraform/cloud-access`
**State:** `state://northwind-state/cloud-platform/access`
**Apply owner:** a person, locally, after the merge plan is reviewed
**Code owner:** see `ci/CODEOWNERS`

## Scope

Project level IAM for `nw-production` and `nw-development`. Every
grant lives in `grants.tf`.

Not in scope, and not managed here: workforce directory group membership, SSO
group assignment, repository access, VPN accounts, laptop enrolment and the
password manager. Those are changed by hand in each system's admin console.

## Adding or removing a grant

1. Open a PR editing `grants.tf`. Each entry needs a `ticket` and a
   `review_by` date. The plan fails without a ticket reference.
2. Prefer `group:` over `user:`. Individual grants are the exception and should
   name why in the request.
3. CI plans the stack on the PR, read only. The plan shows exactly which
   principal gains or loses which role.
4. Get the review, merge, then apply.

## Apply

```bash
scripts/apply.sh cloud-access
```

## Verification

```bash
gcloud projects get-iam-policy nw-production --format=json
```

Then `terraform plan` again. It must report no changes.

## Recovery

Removing a grant takes effect within a minute or two and is reversible by
re-adding it. Adding a grant is the direction that needs care: the audit log
records what the principal did while it was held, and reverting the grant does
not undo those actions.

## Quarterly access review

Every entry whose `review_by` has passed must be re-confirmed by the person who
owns the system it grants access to, or removed. The current process is to read
`grants.tf`, list the entries by hand into a spreadsheet, send that spreadsheet
to each owner, and collect replies over email. The next review is due
**30 September**.
