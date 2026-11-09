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
