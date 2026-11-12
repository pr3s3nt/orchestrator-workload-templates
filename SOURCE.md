# Source provenance

- Repository: https://github.com/pr3s3nt/poc
- Commit: `bb8cff1d04f1c4b506ad2dd4c80f82377399e854`
- Path: `backend/template-sources/standard`
- Runtime files copied unchanged; product examples and README are omitted.
- Test setup for https://github.com/pr3s3nt/poc/issues/45.

## Terraform modules added in v0.2.0

- Repository: https://github.com/pr3s3nt/terraform-modules
- Commit: `020ca92a00ee95eeac088c6c64cdceea0f722652`
- Copied unchanged:
  - `modules/k8s-namespace/main.tf` → `terraform/namespace/main.tf`
  - `modules/postgres-k8s/main.tf` → `terraform/postgres/main.tf`
  - `modules/redis-k8s/main.tf` → `terraform/redis/main.tf`
- No infrastructure was applied as part of preparing this test repository.

## v0.3.0 changes — issue #47

Standard templates now contain the reviewed compatible security defaults and
field-level security merge. Redis adds one sensitive connection_string output;
other Terraform resources remain unchanged. Render tests cover all three
controllers and app/init/sidecar roles; Redis fmt/init/validate pass.

## v0.4.0 changes — issue #54

Synced from https://github.com/pr3s3nt/poc at commit `cc4320afda2afce37fe8c6231a42a3c33314b064`:
- `backend/template-sources/standard` → `templates/standard` (runtime files already identical).
- `backend/internal/adapters/terraform/modules/postgres-k8s/main.tf` → `terraform/postgres/main.tf` (adds `uri`, `jdbcUrl`).
- `backend/internal/adapters/terraform/modules/redis-k8s/main.tf` → `terraform/redis/main.tf` (adds `uri`); the v0.3.0 `connection_string` output is kept.
- `backend/terraform-modules/mysql/main.tf` → `terraform/mysql/main.tf` (old contract; replaced in v0.4.1).
- `backend/terraform-modules/persistent-storage/main.tf` → `terraform/persistent-storage/main.tf`.

All five modules pass `terraform fmt -check` and `terraform validate` (Terraform 1.9.8). No infrastructure was applied while preparing this release.

## v0.4.1 changes — issue #54

`projects/platform-resources/terraform/mysql/` (README, main.tf, tests) from
https://github.com/pr3s3nt/poc commit `cc4320afda2afce37fe8c6231a42a3c33314b064`
replaces `terraform/mysql`: executor-owned password and issue #52 `uri`/`jdbcUrl`
outputs. `terraform fmt -check`, `validate` and `terraform test` (3 passed) with
Terraform 1.9.8. Other files are unchanged from v0.4.0.

## v0.4.2 changes — issue #54

`terraform/postgres/main.tf` adds the sensitive `asyncUri` output
(`postgresql+asyncpg://`). This is a release-repository addition requested by the
user; it is not yet present in the `pr3s3nt/poc` module copies. `terraform fmt
-check` and `validate` pass with Terraform 1.9.8.

## v0.5.0 changes — issue pr3s3nt/poc#71

Synced from https://github.com/pr3s3nt/poc at commit `dfa6470c84767cb1c005351a236861e54e3bc878`:
`backend/template-sources/standard` → `templates/standard`. Adds the
`backend-migrate` workload template ("Backend API có migrate") and
`resources/migrate.tpl`, which renders a one-shot `<workload>-migrate` Job run
before the Environment app bundle (ADR-042). Other runtime files are unchanged;
Terraform modules are unchanged.

## MongoDB catalog and module — issue pr3s3nt/poc#78

Synced from https://github.com/pr3s3nt/poc at commit
`9d15a22410e3cff0e16b88da64d39ded8df6638a`:

- `projects/platform-resources/terraform/mongodb` → `terraform/mongodb`.
- `projects/platform-resources/resource-catalog/mongodb` → `resource-catalog/mongodb`.

Files copied unchanged. Type requires database; username/storage are optional
with app/10Gi defaults. Image and placement belong to the Definition. Module
exposes exactly host/port/database/username/password/connection; the last two
are sensitive. No PVC or namespace outputs are exposed.

Validated with Terraform 1.9.8 and signed HashiCorp Kubernetes provider 2.38.0:
fmt check, validate and all three mock-provider tests pass. YAML Type equals
the source bootstrap Type; both source Definitions map the same inputs and six
outputs. Source bootstrap integration test and documentation checker pass.
No infrastructure was applied and no target Console registration was performed.
Definition source pins and image digest are explicit values to fill after
inspecting this module on the destination installation.
