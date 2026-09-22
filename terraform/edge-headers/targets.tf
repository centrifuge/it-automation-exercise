# Which hosts get which bundle, and every expression derived from that map.
#
# Two things in this file are generated and must not be hand edited: each
# rule's match expression, and the restrictive catch-all's exclusion list.
# To serve a new host, add it to local.targets. To widen a policy, edit the
# lists in variables.tf.

locals {
  targets = {
    app = {
      hosts         = ["app.northwind.test"]
      host_prefixes = []
      bundle        = "app"
    }

    preview = {
      hosts         = []
      host_prefixes = ["nightly.app.", "preview.app."]
      bundle        = "preview"
    }

    docs = {
      hosts         = ["docs.northwind.test"]
      host_prefixes = []
      bundle        = "docs"
    }

    dash = {
      hosts         = ["dash.northwind.test"]
      host_prefixes = []
      bundle        = "dash"
    }

    status = {
      hosts         = ["status.northwind.test"]
      host_prefixes = []
      bundle        = "marketing"
    }

    partners = {
      hosts         = ["partners.northwind.test"]
      host_prefixes = []
      bundle        = "partners"
    }

    marketing = {
      hosts         = ["northwind.test", "www.northwind.test"]
      host_prefixes = []
      bundle        = "marketing"
    }
  }

  # Per-bundle directive overrides layered onto the shared baseline. A key set
  # here replaces the baseline's value for that directive, so script-src
  # overrides concat rather than drop the baseline hosts.
  bundle_extra = {
    app = {
      "connect-src" = var.connect_src_app
      "script-src"  = concat(module.baseline.directives["script-src"], var.script_src_hashes_app)
    }
    preview = {
      "connect-src" = var.connect_src_preview
      "script-src"  = concat(module.baseline.directives["script-src"], var.script_src_hashes_app)
    }
    docs = {
      "connect-src" = var.connect_src_docs
    }
    dash = {
      "connect-src" = var.connect_src_dash
    }
    marketing = {}
    partners = {
      "frame-src" = concat(["'self'"], var.frame_src_partners)
    }
  }

  # Generated. edge service applies the last matching rule for a given header.
  # No two target expressions overlap today, so rule order does not matter. If
  # two ever overlap, set an explicit order in main.tf.
  target_expression = {
    for name, t in local.targets :
    name => join(" or ", concat(
      [for h in t.hosts : "(http.host eq \"${h}\")"],
      [for p in t.host_prefixes : "starts_with(http.host, \"${p}\")"],
    ))
  }

  # Every host this stack serves explicitly. The catch-all must exclude all of
  # them or it would override the specific rules.
  served_hosts    = flatten([for t in local.targets : t.hosts])
  served_prefixes = flatten([for t in local.targets : t.host_prefixes])

  catch_all_expression = join(" and ", concat(
    [for h in local.served_hosts : "not http.host eq \"${h}\""],
    [for p in local.served_prefixes : "not starts_with(http.host, \"${p}\")"],
  ))

  policy_for = {
    for name, t in local.targets :
    name => merge(module.baseline.directives, local.bundle_extra[t.bundle])
  }

  rendered_policy = {
    for name, d in local.policy_for :
    name => join("; ", [for k in sort(keys(d)) : "${k} ${join(" ", d[k])}"])
  }

  catch_all_policy = join("; ", [
    for k in sort(keys(module.baseline.directives)) :
    "${k} ${join(" ", module.baseline.directives[k])}"
  ])
}
