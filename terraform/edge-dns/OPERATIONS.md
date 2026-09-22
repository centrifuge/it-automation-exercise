# edge-dns operations

**Path:** `terraform/edge-dns`
**State:** `gs://northwind-state/edge/prod/edge-dns`
**Apply owner:** a person, locally, after the merge plan is reviewed
**Code owner:** see `ci/CODEOWNERS`

## Scope

DNS records, redirects and the email records (MX, SPF, DMARC) for both zones.

## Plan

CI plans this stack on every pull request that touches `terraform/`, read
only. To reproduce locally:

```bash
cd terraform/edge-dns
terraform init
terraform plan
```

## Apply

CI does not hold a write credential for this stack. After the change is merged:

```bash
scripts/apply.sh edge-dns
```

The wrapper refuses to run on a dirty checkout, or on a checkout that is not at
`origin/main`. It replans, prints the plan, and requires you to type `apply`
before it does anything. Applies are sequential and it stops on the first
failure.

## Verification

```bash
dig +short app.northwind.test
dig +short MX northwind.test
dig +short TXT _dmarc.northwind.test
```

Then `terraform plan` again. It must report no changes.

## Recovery

Revert the commit, merge, and apply the revert the same way. DNS changes are
subject to the record TTL, so a revert is not instant for anyone who has
already cached the bad answer. The email records have a 1 hour TTL.
