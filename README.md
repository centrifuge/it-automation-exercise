> **Candidates:** the exercise brief is in [BRIEF.md](BRIEF.md). Read it first, then return here.

# northwind-ops

Infrastructure as code for Northwind Labs. One repo, three Terraform stacks,
the CI that plans them, and the scripts we run by hand.

## Layout

| Path | What it is |
|---|---|
| `terraform/edge-headers/` | Response security headers (CSP and friends) for both zones |
| `terraform/edge-dns/` | DNS records, redirects and the email records for both zones |
| `terraform/cloud-access/` | Project IAM for the two cloud platform projects |
| `terraform/modules/header-baseline/` | Shared header directives, consumed by `edge-headers` |
| `ci/terraform-stacks.json` | The stack registry. CI and `scripts/apply.sh` both read it |
| `ci/workflows/tf-plan.yml` | Read-only plans on every PR |
| `ci/workflows/tf-edge-apply.yml` | The one automatic apply |
| `scripts/apply.sh` | Apply a stack from a laptop, after merge |
| `scripts/capture-headers.sh` | Snapshot live response headers, before and after |
| `oncall/roster.example.yaml` | On-call roster template |
| `requests/QUEUE.md` | Open requests from the rest of the company |

## How a change ships

1. Branch, edit, open a PR.
2. `TF Plan` runs a read-only plan of all three stacks. It changes nothing.
3. Get the review named in `ci/CODEOWNERS`, and merge.
4. Then it depends on the stack:

| Stack | Applied by |
|---|---|
| `edge-headers` | CI, automatically, on merge |
| `edge-dns` | a person, `scripts/apply.sh edge-dns` |
| `cloud-access` | a person, `scripts/apply.sh cloud-access` |

The two manual stacks have no CI write credential. Someone with the right local
credentials runs the apply from their own machine, which is also what puts a
human name in the cloud audit log.

Each stack has an `OPERATIONS.md` next to it describing its own plan, apply,
verification and recovery steps.

## Working on this repo

Every stack plans locally with no credentials and no network access to a
provider. The real stacks use an edge service and a cloud-platform provider; in this
checkout the resources are modelled with `terraform_data`, which is built into
Terraform, so `init` downloads nothing.

```bash
cd terraform/edge-headers
terraform init
terraform plan
terraform output
```

Run `terraform fmt -recursive` and `terraform validate` before pushing. CI
checks both.

Northwind Labs is fictional. `northwind.test` and `preview.northwind.test` are
reserved example names, not Northwind hosts. Do not run `scripts/capture-headers.sh`.
It would send requests to hosts nobody here controls. Read the script instead.

## What is not in here

workforce directory and SSO group membership, source control repository and team access,
VPN accounts, laptop enrolment, the password manager, and the paging tool's
per-person notification settings. Those are changed by hand in each system's
own admin console.
