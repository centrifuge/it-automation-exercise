# cloud platform project IAM for both projects.
#
# Applied by a person, from a laptop, after the merge plan is reviewed. The
# write credential for this stack is not available to CI.
#
# In the production repo these are cloud-platform IAM-member resources. Here
# they are terraform_data so the root plans with no provider downloads and no
# credentials.

terraform {
  required_version = ">= 1.5.0"

  # backend "gcs" {
  #   bucket = "northwind-state"
  #   prefix = "cloud-platform/access"
  # }
}

locals {
  # Composite key so the same principal can hold more than one role.
  grants_by_key = {
    for g in local.grants :
    "${g.project}/${g.role}/${g.principal}" => g
  }

  roles_in_use = distinct(sort([for g in local.grants : g.role]))
}

resource "terraform_data" "project_iam_member" {
  for_each = local.grants_by_key

  input = {
    project   = local.projects[each.value.project]
    role      = each.value.role
    member    = each.value.principal
    ticket    = each.value.ticket
    review_by = each.value.review_by
  }
}

# Fails the plan if a grant is missing its paper trail. Roles are not checked
# against an allowlist: the review is what decides whether a role is
# appropriate.
check "grants_have_a_ticket" {
  assert {
    condition     = alltrue([for g in local.grants : can(regex("^REQ-[0-9]{4}$", g.ticket))])
    error_message = "Every grant needs a ticket reference of the form REQ-0000."
  }
}

output "principals" {
  description = "Every principal holding at least one grant."
  value       = distinct(sort([for g in local.grants : g.principal]))
}

output "roles_in_use" {
  value = local.roles_in_use
}
