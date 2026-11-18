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

## PostgreSQL HA — Refs pr3s3nt/poc#75 (merged, untagged)

`terraform/postgres-ha` is authored directly in this release repository, per
user decision 2026-11-11. No copy is added to poc/platform-catalog. CNPG 1.30.1
operator is installed separately; the module pins the CNPG PostgreSQL 16.14
multi-architecture image, creates Cluster/basic-auth Secret and preserves all
eight postgres outputs. Existing terraform/postgres is unchanged.

Terraform 1.9.8: fmt -check, validate and test (5 passed) pass. Tests use a mock
provider; live kind failover/cleanup acceptance is recorded separately in poc.
Merged into main at the user's request together with MongoDB. No release tag
is created as part of this merge; v0.6.0 remains the planned HA release tag.


## Portable MongoDB Definition file — Refs pr3s3nt/poc#79

The MongoDB Definition sample now authors Git `url/ref/path`. Console explicitly
checks the full file, resolves its immutable pin, shows the reviewed commit and
registers that canonical draft. Source/module IDs and content hashes are internal
metadata, no longer fields a user must collect through DevTools.

Requires the Definition document enhancement in poc commit
`7b45f4a6b08dcd7a91c1a510ac9c80bb7fba6106` (merged into product main at `9bf70931`).
MongoDB Type and Terraform module bytes are unchanged from main `04136a3`.
YAML parsing/mapping checks pass; the product feature browser scenario checked
real Git MongoDB import, portable exports and REUSED/CONFLICT history invariance.

## Namespace-owned placement and template HTTPRoute — Refs pr3s3nt/poc#84

Initially implemented on feature branch `features/Httproute`. Runtime changes
copied from `pr3s3nt/poc` commit `1a33bed7`:

- `backend/template-sources/standard/bundle.yaml`: declares capability
  `endpoint-httproute-v1` and orders the HTTPRoute template after Service.
- `backend/template-sources/standard/resources/httproute.tpl`: constructs route
  from the platform-authorized endpoint intent and actual rendered Service.

Terraform module bytes are unchanged. The MongoDB Definition sample references
its namespace as provider source; the namespace Definition supplies cluster
identity. Gateway/endpoint Type and Definition samples document the separate
preexisting Gateway resource (no Gateway apply/adoption/destroy).

Product focused route renderer/guard, Gateway registration/readiness and
namespace placement checks pass, including missing/modified/duplicate route
rejection and legacy endpoint checks. Frontend typecheck/lint/build and docs checks
pass. Real native/Score batch Deploy, shared namespace-bound PostgreSQL,
authenticated SQL, template routes through the existing Gateway, update/restart
identity preservation and Console product cleanup passed on kind. Full frontend
passes 1067 tests/typecheck/lint/build; full product backend and main have the
same 103 failing top-level tests and 8 skips, with both builds passing. This is
not a full green backend gate. Execution evidence:
https://github.com/pr3s3nt/poc/blob/main/orchestrator_docs/verification/2026-11-16-namespace-template-routes.md.
No shared Gateway/controller/DNS/TLS was changed. Inspect the tested feature
commit `5407998b0e08dc0da51c19c28517dfa191e7a3ee` with a
backend supporting #84; older deployed template pins are not automatically changed.

## Echo Gateway metadata refinement — Refs pr3s3nt/poc#84

Approved 2026-11-17. Gateway Definition sample `987c5ce` now uses the generic
Echo envelope; it requires product implementation `35bcd06c` or later. Product
merge `df719115` includes current main `ab37e2d4`. The cluster still uses its
dedicated existing-cluster adapter/Driver Account; Gateway readiness and admission
are checked separately before render/CD. Legacy existing-gateway revisions are
retained, with no implicit migration or physical Gateway ownership.

All Terraform and template bytes are identical to tested runtime pin `5407998`.
The sample YAML parses and exposes the required gateway envelope. Real merged
native/Score batch deploy, update, restart and product cleanup passed. A new
review application confirms executed READY Echo Gateway resources and reaches
both actual workloads in a browser. Full merged frontend passes 1076 tests and
typecheck/lint/build. Backend comparison, source attribution and cleanup are
recorded in the product verification record:
https://github.com/pr3s3nt/poc/blob/main/orchestrator_docs/verification/2026-11-17-echo-gateway.md.
That checkpoint preceded user acceptance; no tag was made.

## Accepted template main integration — 2026-11-18

User approved merging the template feature into main after product merge
`pr3s3nt/poc@6084919e`, without repeating product tests. Gateway/Endpoint examples
now use the approved display names and explicit `class: default` matching criteria
shared across apps/environments. Example keys, infrastructure placeholders and
references remain unchanged. Terraform/template runtime bytes remain identical
to accepted pin `5407998`; source pins already deployed are not auto-upgraded.
No new release tag or main-installation catalog import is performed.

## Complete resource catalog — issue #1

User approved the complete example catalog after reviewing all seven existing
Terraform modules. This slice adds missing cluster/namespace/workload/PostgreSQL
(normal and HA)/Redis/MySQL/PVC Types and Definitions. The resulting catalog has
10 Types and 11 Definitions. Existing Gateway/Endpoint/MongoDB keys are preserved;
Gateway and namespace now select cluster default, MongoDB criteria is default
without a staging restriction. PostgreSQL HA alone uses class ha. All module
source references use reviewed commit b8e98a7; no module/template runtime file
is modified. Workload template-source IDs and Driver Account keys remain
installation-specific; image placeholders require real approved digests.

Validation parses all 21 public YAML documents and the actual HCL of all seven
modules, checks required variables, input/output names/types/sensitivity, executor
owned password/tags exclusion, default/ha criteria and closed typed references.
All seven modules are covered; 55 local Markdown links/anchors are checked.
Runtime module/template paths remain byte-identical to origin/main. No full
product tests, Terraform plan/apply, cluster/cloud operation or Console database
mutation is performed; live import/readiness is not claimed. The samples require
the documented destination prerequisites and Type compatibility before import.
This work is on features/complete-resource-catalog, pending user review and main
merge; it does not publish a release tag or change pins in any installation.
