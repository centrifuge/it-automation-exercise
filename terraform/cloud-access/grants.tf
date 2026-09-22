# Human and service access to the two cloud platform projects.
#
# Every entry needs a ticket reference and a review date. Entries whose
# review_by has passed are meant to be re-confirmed or removed at the
# quarterly access review.
#
# Group grants are preferred over individual ones. Several of the entries
# below predate that preference and were never migrated.

locals {
  projects = {
    prod = "nw-production"
    dev  = "nw-development"
  }

  grants = [
    # Groups.
    {
      principal = "group:engineering@northwind.test"
      role      = "roles/viewer"
      project   = "dev"
      ticket    = "REQ-0412"
      review_by = "2026-12-31"
    },
    {
      principal = "group:platform@northwind.test"
      role      = "roles/editor"
      project   = "dev"
      ticket    = "REQ-0412"
      review_by = "2026-12-31"
    },
    {
      principal = "group:platform@northwind.test"
      role      = "roles/viewer"
      project   = "prod"
      ticket    = "REQ-0412"
      review_by = "2026-12-31"
    },

    # Individuals.
    {
      principal = "user:p.raman@northwind.test"
      role      = "roles/owner"
      project   = "prod"
      ticket    = "REQ-0088"
      review_by = "2026-12-31"
    },
    {
      principal = "user:d.okafor@northwind.test"
      role      = "roles/cloudsql.viewer"
      project   = "prod"
      ticket    = "REQ-0503"
      review_by = "2026-12-31"
    },
    {
      principal = "user:j.tanaka@northwind.test"
      role      = "roles/logging.viewer"
      project   = "prod"
      ticket    = "REQ-0517"
      review_by = "2026-10-31"
    },
    {
      principal = "user:t.reyes@northwind.test"
      role      = "roles/storage.objectViewer"
      project   = "prod"
      ticket    = "REQ-0466"
      review_by = "2026-06-30"
    },
    {
      principal = "user:t.reyes@northwind.test"
      role      = "roles/viewer"
      project   = "dev"
      ticket    = "REQ-0466"
      review_by = "2026-06-30"
    },

    # Service accounts.
    {
      principal = "service:tf-plan@nw-production.identity.test"
      role      = "roles/viewer"
      project   = "prod"
      ticket    = "REQ-0201"
      review_by = "2026-12-31"
    },
    {
      principal = "service:tf-plan@nw-production.identity.test"
      role      = "roles/iam.securityReviewer"
      project   = "prod"
      ticket    = "REQ-0201"
      review_by = "2026-12-31"
    },
    {
      principal = "service:app-runtime@nw-production.identity.test"
      role      = "roles/secretmanager.secretAccessor"
      project   = "prod"
      ticket    = "REQ-0233"
      review_by = "2026-12-31"
    },
    {
      principal = "service:etl-loader@nw-development.identity.test"
      role      = "roles/bigquery.dataEditor"
      project   = "dev"
      ticket    = "REQ-0349"
      review_by = "2026-12-31"
    },
  ]
}
