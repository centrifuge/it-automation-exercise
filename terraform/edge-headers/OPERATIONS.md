# edge-headers operations

**Path:** `terraform/edge-headers`
**State:** `gs://northwind-state/edge/prod/edge-headers`
**Apply owner:** CI, automatically, on merge to `main`
**Code owner:** see `ci/CODEOWNERS`

## Scope

Content-Security-Policy and the other response security headers for
`northwind.test` and `preview.northwind.test`. This is the only stack in the repo
that CI applies. Everything else is planned in CI and applied by a person.

## Allowing a new URL

Almost every change is one line in a plain list. The rules, their expressions
and the catch-all exclusion list are all generated from those lists.

| You want to | Add it to |
|---|---|
| let the app call a new API | `connect_src_app` in `variables.tf` |
| let preview builds call a new API | `connect_src_preview` in `variables.tf` |
| ship a new inline script | `script_src_hashes_app` in `variables.tf` |
| load a script from a new host | `script_src_hosts` in `variables.tf` |
| embed a new site in the partner portal | `frame_src_partners` in `variables.tf` |
| change a directive for every host at once | `terraform/modules/header-baseline` |

To serve a brand new hostname, add it to `local.targets` in `targets.tf`. Until
you do, the catch-all applies the restrictive default to it.

## Plan

```bash
cd terraform/edge-headers
terraform init
terraform plan
```

## Apply

Merge to `main`. `ci/workflows/tf-edge-apply.yml` plans and applies the
saved plan when there are changes. There is no manual step.

Break glass, only when CI apply is unavailable:

```bash
cd terraform/edge-headers
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Verification

A successful apply means Terraform accepted the plan. It does not mean the
live headers are correct. After every apply:

```bash
scripts/capture-headers.sh after
```

Compare the snapshot against the one taken before the change. If a host is
added to a rule expression, add the same host to the capture script before
relying on this verification.

## Recovery

A bad header ships to production the moment the PR merges. Revert the commit
and let CI apply the revert. The revert path is the same one minute pipeline as
the change, so recovery time is bounded by how quickly someone notices.
