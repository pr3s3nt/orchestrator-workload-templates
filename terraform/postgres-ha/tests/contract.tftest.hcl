mock_provider "kubernetes" {}
variables {
  namespace = "ha-test"
  database  = "appdb"
  username  = "app"
  password  = "p@ss:w/rd%1"
  tags      = { orchestrator-instance = "1234567890abcdef" }
}
run "ha_contract" {
  command = plan
  assert {
    condition     = output.host == "postgres-1234567890abcdef-rw.ha-test.svc" && output.port == 5432 && output.database == var.database && output.username == var.username && output.password == var.password
    error_message = "The five scalar outputs must preserve the postgres contract."
  }
  assert {
    condition     = output.uri == "postgresql://app:p%40ss%3Aw%2Frd%251@postgres-1234567890abcdef-rw.ha-test.svc:5432/appdb" && output.jdbcUrl == "jdbc:postgresql://postgres-1234567890abcdef-rw.ha-test.svc:5432/appdb" && output.asyncUri == "postgresql+asyncpg://app:p%40ss%3Aw%2Frd%251@postgres-1234567890abcdef-rw.ha-test.svc:5432/appdb"
    error_message = "All three connection strings must keep encoding and driver schemes."
  }
  assert {
    condition     = kubernetes_secret_v1.auth.type == "kubernetes.io/basic-auth" && kubernetes_secret_v1.auth.data.username == var.username && kubernetes_secret_v1.auth.data.password == var.password && kubernetes_manifest.this.manifest.spec.instances == 2 && kubernetes_manifest.this.manifest.spec.storage.size == "1Gi"
    error_message = "CNPG must bootstrap from executor credentials with two instances."
  }
}
run "sensitive_outputs" {
  command = plan
  assert {
    condition     = nonsensitive(output.password) == nonsensitive(var.password) && startswith(nonsensitive(output.uri), "postgresql://") && startswith(nonsensitive(output.asyncUri), "postgresql+asyncpg://")
    error_message = "Password and credential-bearing URIs must remain sensitive."
  }
}
run "reject_single_instance" {
  command = plan
  variables { instances = 1 }
  expect_failures = [var.instances]
}
run "reject_fractional_instances" {
  command = plan
  variables { instances = 2.5 }
  expect_failures = [var.instances]
}
run "configured_storage" {
  command = plan
  variables {
    instances     = 3
    storage       = "2Gi"
    storage_class = "fast"
  }
  assert {
    condition     = kubernetes_manifest.this.manifest.spec.instances == 3 && kubernetes_manifest.this.manifest.spec.storage.storageClass == "fast" && kubernetes_manifest.this.manifest.spec.storage.size == "2Gi"
    error_message = "CNPG must consume the configured instance count and storage."
  }
}
