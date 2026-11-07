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
