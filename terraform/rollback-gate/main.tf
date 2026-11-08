terraform {
  required_version = ">= 1.5"
}

variable "permit" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Acceptance fixture: false fails during Plan, before any Apply or cloud call.
resource "terraform_data" "gate" {
  input = var.tags
  lifecycle {
    precondition {
      condition     = var.permit
      error_message = "Issue 49 acceptance gate is intentionally closed."
    }
  }
}

output "ready" {
  value = var.permit ? "open" : "closed"
}
