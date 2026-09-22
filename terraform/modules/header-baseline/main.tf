# Shared response-header baseline.
#
# Both zone header stacks consume this module so a directive change lands in
# one place instead of being copied per zone. This module declares no
# resources and is never applied on its own.

terraform {
  required_version = ">= 1.5.0"
}

locals {
  script_src = concat(["'self'"], var.extra_script_src)
  style_src  = concat(["'self'", "'unsafe-inline'"], var.extra_style_src)
  font_src   = concat(["'self'", "data:"], var.extra_font_src)
  frame_src  = concat(["'self'"], var.extra_frame_src)

  directives = {
    "default-src" = ["'self'"]
    "script-src"  = local.script_src
    "style-src"   = local.style_src
    "font-src"    = local.font_src
    "frame-src"   = local.frame_src
    "img-src"     = ["'self'", "data:", "https:"]
    "object-src"  = ["'none'"]
    "base-uri"    = ["'self'"]
    "connect-src" = ["'self'"]
  }

  security_headers = {
    "X-Content-Type-Options"    = "nosniff"
    "Referrer-Policy"           = "strict-origin-when-cross-origin"
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains"
  }
}

output "directives" {
  description = "Directive name to value list. Consumers override per bundle."
  value       = local.directives
}

output "security_headers" {
  description = "Non-CSP response headers applied to every target."
  value       = local.security_headers
}
