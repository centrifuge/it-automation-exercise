# DNS, redirects and email records for the northwind.test and
# preview.northwind.test zones.
#
# Applied by a person, from a laptop, after the merge plan is reviewed. The
# write credential for this stack is not available to CI.
#
# In the production repo these are edge_dns_record and
# edge_ruleset resources. Here they are terraform_data so the root plans
# with no provider downloads and no credentials.

terraform {
  required_version = ">= 1.5.0"

  # backend "gcs" {
  #   bucket = "northwind-state"
  #   prefix = "edge/prod/edge-dns"
  # }
}

variable "zone_ids" {
  description = "Zone identifier per zone name. Supplied by the operator's tfvars in production."
  type        = map(string)
  default = {
    "northwind.test"         = "zone-id-placeholder-prod"
    "preview.northwind.test" = "zone-id-placeholder-dev"
  }
}

locals {
  records = {
    apex = {
      zone    = "northwind.test"
      name    = "@"
      type    = "A"
      content = "192.0.2.10"
      proxied = true
    }
    www = {
      zone    = "northwind.test"
      name    = "www"
      type    = "CNAME"
      content = "northwind-marketing.hosting.test"
      proxied = true
    }
    app = {
      zone    = "northwind.test"
      name    = "app"
      type    = "CNAME"
      content = "app-frontend.hosting.test"
      proxied = true
    }
    docs = {
      zone    = "northwind.test"
      name    = "docs"
      type    = "CNAME"
      content = "northwind-docs.hosting.test"
      proxied = true
    }
    dash = {
      zone    = "northwind.test"
      name    = "dash"
      type    = "CNAME"
      content = "northwind-dash.hosting.test"
      proxied = true
    }
    status = {
      zone    = "northwind.test"
      name    = "status"
      type    = "CNAME"
      content = "status-page-vendor.example"
      proxied = false
    }
    partners = {
      zone    = "northwind.test"
      name    = "partners"
      type    = "CNAME"
      content = "northwind-partners.hosting.test"
      proxied = true
    }
    nightly = {
      zone    = "preview.northwind.test"
      name    = "nightly.app"
      type    = "CNAME"
      content = "app-frontend.hosting.test"
      proxied = true
    }
    preview = {
      zone    = "preview.northwind.test"
      name    = "preview.app"
      type    = "CNAME"
      content = "app-frontend.hosting.test"
      proxied = true
    }

    # Mail. These records are why this stack is not auto-applied: a wrong
    # value here stops inbound or outbound company email, and nothing in the
    # browser tells you it happened.
    mx_primary = {
      zone    = "northwind.test"
      name    = "@"
      type    = "MX"
      content = "10 mx1.mail-vendor.example"
      proxied = false
    }
    mx_secondary = {
      zone    = "northwind.test"
      name    = "@"
      type    = "MX"
      content = "20 mx2.mail-vendor.example"
      proxied = false
    }
    spf = {
      zone    = "northwind.test"
      name    = "@"
      type    = "TXT"
      content = "v=spf1 include:_spf.mail-vendor.example -all"
      proxied = false
    }
    dmarc = {
      zone    = "northwind.test"
      name    = "_dmarc"
      type    = "TXT"
      content = "v=DMARC1; p=reject; rua=mailto:dmarc-reports@northwind.test"
      proxied = false
    }
  }

  redirects = {
    apex_to_www = {
      zone       = "northwind.test"
      expression = "(http.host eq \"northwind.test\")"
      target     = "https://www.northwind.test${"$"}{http.request.uri.path}"
      status     = 301
    }
    legacy_help = {
      zone       = "northwind.test"
      expression = "starts_with(http.request.uri.path, \"/help\")"
      target     = "https://docs.northwind.test/"
      status     = 302
    }
  }
}

resource "terraform_data" "record" {
  for_each = local.records

  input = merge(each.value, {
    zone_id = var.zone_ids[each.value.zone]
  })
}

resource "terraform_data" "redirect" {
  for_each = local.redirects

  input = merge(each.value, {
    zone_id = var.zone_ids[each.value.zone]
  })
}

output "hostnames" {
  description = "Every hostname this stack publishes."
  value = distinct(sort([
    for k, r in local.records :
    r.name == "@" ? r.zone : "${r.name}.${r.zone}"
  ]))
}
