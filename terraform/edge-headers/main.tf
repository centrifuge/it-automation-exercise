# Response headers for the northwind.test and preview.northwind.test zones.
#
# This is the only stack in the repo that CI applies on merge. Header changes
# are availability sensitive: a wrong policy breaks a page in the browser and
# waiting for someone to be at a laptop is worse than shipping it.
#
# In the production repo the resources below are edge_ruleset entries in
# the http_response_headers_transform phase. Here they are terraform_data so
# the root plans with no provider downloads and no credentials.

terraform {
  required_version = ">= 1.5.0"

  # Production backend, commented out so this root plans locally.
  # backend "gcs" {
  #   bucket = "northwind-state"
  #   prefix = "edge/prod/edge-headers"
  # }
}

module "baseline" {
  source = "../modules/header-baseline"

  extra_script_src = var.script_src_hosts
}

# One rule per target, most specific first.
resource "terraform_data" "target_rule" {
  for_each = local.targets

  input = {
    description = "CSP for ${each.key}"
    expression  = local.target_expression[each.key]
    headers = merge(
      { "Content-Security-Policy" = local.rendered_policy[each.key] },
      module.baseline.security_headers,
    )
  }
}

# Restrictive default for anything on these zones that no rule above matched.
# A new host is locked down until it is added to local.targets.
resource "terraform_data" "catch_all_rule" {
  input = {
    description = "CSP catch-all"
    expression  = "(${local.catch_all_expression})"
    headers = merge(
      { "Content-Security-Policy" = local.catch_all_policy },
      module.baseline.security_headers,
    )
  }
}

output "hosts_served" {
  description = "Every host this stack sets headers on explicitly."
  value       = sort(local.served_hosts)
}

output "host_prefixes_served" {
  description = "Prefix matches this stack sets headers on."
  value       = sort(local.served_prefixes)
}
