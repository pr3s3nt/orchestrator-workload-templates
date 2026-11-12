terraform {
  required_version = ">= 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0, < 3.0.0"
    }
  }
}

# The Kubernetes target is bound by the executor through the provider
# environment; the module never configures a host, token or kubeconfig.
provider "kubernetes" {}

variable "namespace" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?$", var.namespace))
    error_message = "namespace must be a DNS label."
  }
}

variable "database" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z_][A-Za-z0-9_-]{0,62}$", var.database))
    error_message = "database must be a PostgreSQL identifier."
  }
}

variable "username" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z_][A-Za-z0-9_-]{0,62}$", var.username))
    error_message = "username must be a PostgreSQL identifier."
  }
}

# CNPG-compatible PostgreSQL 16 image, pinned to its multi-architecture index.
# The stock postgres Alpine image cannot run the CNPG instance manager.
variable "image" {
  type    = string
  default = "ghcr.io/cloudnative-pg/postgresql:16.14-system-trixie@sha256:04f35778ca3b55b52a81dae969bef179ead315b9f02d2b4b21a3415de269b836"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._/-]*(:[A-Za-z0-9._-]{1,128})?@sha256:[0-9a-f]{64}$", var.image))
    error_message = "image must be a digest-pinned reference (name[:tag]@sha256:<64 hex>)."
  }
}

variable "storage" {
  type    = string
  default = "1Gi"
  validation {
    condition     = can(regex("^[1-9][0-9]{0,3}(Mi|Gi)$", var.storage))
    error_message = "storage must be a whole number of Mi or Gi."
  }
}

# Empty selects the cluster default storage class. The module never creates or
# changes a storage class.
variable "storage_class" {
  type    = string
  default = ""
}

# Optional nonsecret metadata consumed by the PostgreSQL objects. Secret-looking
# keys are refused so a credential output cannot become public metadata.
variable "labels" {
  type    = map(string)
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.labels :
      can(regex("^([a-z0-9]([-a-z0-9.]{0,251}[a-z0-9])?/)?[A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?$", k)) &&
      can(regex("^([A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?)?$", v)) &&
      !can(regex("(?i)(password|secret|token|credential)", k)) &&
      !startswith(k, "app.kubernetes.io/") && !startswith(k, "orchestrator")
    ])
    error_message = "labels must be valid nonsecret Kubernetes labels outside the platform-owned keys."
  }
}

variable "annotations" {
  type    = map(string)
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.annotations :
      can(regex("^([a-z0-9]([-a-z0-9.]{0,251}[a-z0-9])?/)?[A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?$", k)) &&
      !can(regex("(?i)(password|secret|token|credential)", k)) &&
      !startswith(k, "app.kubernetes.io/") && !startswith(k, "orchestrator")
    ])
    error_message = "annotations must have valid nonsecret keys outside the platform-owned keys."
  }
}

# Executor-owned: the stable password (one secret-store reference per
# instance, reused across retries) and the stable platform tags.
variable "password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
  validation {
    condition     = can(regex("^[0-9a-f]{8,64}$", lookup(var.tags, "orchestrator-instance", "")))
    error_message = "tags must carry the stable orchestrator-instance key."
  }
}

locals {
  key         = var.tags["orchestrator-instance"]
  name        = "postgres-${local.key}"
  host        = "${local.name}-rw.${var.namespace}.svc"
  label_key   = "^[A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?$"
  label_value = "^([A-Za-z0-9]([-A-Za-z0-9_.]{0,61}[A-Za-z0-9])?)?$"
  platform_labels = {
    for k, v in var.tags : k => v
    if can(regex(local.label_key, k)) && can(regex(local.label_value, v))
  }
  platform_annotations = {
    for k, v in var.tags : k => v
    if can(regex(local.label_key, k))
  }
  selector = {
    "app.kubernetes.io/name"     = "postgres"
    "app.kubernetes.io/instance" = local.name
  }
  labels = merge(var.labels, local.platform_labels, local.selector, {
    "app.kubernetes.io/managed-by" = "orchestrator"
  })
  annotations = merge(var.annotations, local.platform_annotations)
}

variable "instances" {
  type    = number
  default = 2
  validation {
    condition     = var.instances >= 2 && floor(var.instances) == var.instances
    error_message = "instances must be an integer of at least 2."
  }
}

resource "kubernetes_secret_v1" "auth" {
  metadata {
    name        = "${local.name}-auth"
    namespace   = var.namespace
    labels      = local.labels
    annotations = local.annotations
  }
  type = "kubernetes.io/basic-auth"
  data = {
    username = var.username
    password = var.password
  }
}

resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name        = local.name
      namespace   = var.namespace
      labels      = local.labels
      annotations = local.annotations
    }
    spec = {
      instances = var.instances
      imageName = var.image
      bootstrap = {
        initdb = {
          database = var.database
          owner    = var.username
          secret   = { name = kubernetes_secret_v1.auth.metadata[0].name }
        }
      }
      storage = merge({ size = var.storage }, var.storage_class == "" ? {} : { storageClass = var.storage_class })
      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }
  }
  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

output "host" { value = local.host }
output "port" { value = 5432 }
output "database" { value = var.database }
output "username" { value = var.username }

output "password" {
  value     = var.password
  sensitive = true
}

# Connection strings (issue #52). Credentials are percent-encoded; uri carries
# the password and is therefore sensitive. jdbcUrl has no credentials.
output "uri" {
  value     = "postgresql://${urlencode(var.username)}:${urlencode(var.password)}@${local.host}:5432/${urlencode(var.database)}"
  sensitive = true
}

output "jdbcUrl" { value = "jdbc:postgresql://${local.host}:5432/${var.database}" }

# Same connection for async drivers such as SQLAlchemy asyncpg. Sensitive for the
# same reason as uri. Release-repository addition (pr3s3nt/poc#54).
output "asyncUri" {
  value     = "postgresql+asyncpg://${urlencode(var.username)}:${urlencode(var.password)}@${local.host}:5432/${urlencode(var.database)}"
  sensitive = true
}
