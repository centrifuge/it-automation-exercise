# Almost every header change is a one-line edit to one of the lists in this
# file. The rules, their match expressions, and the restrictive catch-all are
# all generated from these lists in targets.tf. Nothing else needs editing to
# allow a new URL.
#
# Use a scheme and host, for example https://api.example. A trailing / or
# /* limits it to that path prefix. A bare https: allows every host on the
# internet and must not be used.

variable "connect_src_app" {
  description = "APIs and endpoints app.northwind.test may call."
  type        = list(string)
  default = [
    "'self'",
    "https://api.northwind.test",
    "https://telemetry.northwind.test",
    "https://uploads.northwind.test",
  ]
}

variable "connect_src_preview" {
  description = "APIs and endpoints the preview and nightly builds may call."
  type        = list(string)
  default = [
    "'self'",
    "https://api.preview.northwind.test",
    "https://telemetry.preview.northwind.test",
  ]
}

variable "connect_src_docs" {
  description = "Endpoints the docs site may call (search index, feedback)."
  type        = list(string)
  default = [
    "'self'",
    "https://search.northwind.test",
  ]
}

variable "connect_src_dash" {
  description = "Endpoints the internal dashboard may call."
  type        = list(string)
  default = [
    "'self'",
    "https://api.northwind.test",
    "https://metrics.northwind.test",
  ]
}

variable "script_src_hosts" {
  description = "Script hosts allowed on every target. Adding one here widens the policy for all hosts served by this stack."
  type        = list(string)
  default = [
    "https://cdn.northwind.test",
  ]
}

variable "script_src_hashes_app" {
  description = "sha256 hashes of inline scripts shipped by the app bundle. The browser console prints the exact hash to paste in."
  type        = list(string)
  default = [
    "'sha256-K1pQ0mXtLb7YvJ2sRfDgH9wZ4cAe8NqTuVx3B6yOiUE='",
  ]
}

variable "frame_src_partners" {
  description = "Sites the partner portal is allowed to embed in an iframe."
  type        = list(string)
  default = [
    "https://embed.calendar-vendor.example",
  ]
}
