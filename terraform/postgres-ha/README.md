# PostgreSQL HA (CloudNativePG)

Requires CloudNativePG 1.30.1 CRDs and a Ready operator installed separately.
The Kubernetes provider requires the CRD during plan/inspection. This module
creates a basic-auth Secret and CNPG Cluster; the operator owns child Pods,
PVCs and Services. Default: two instances, automatic failover, Ready wait and
15 minute create/update/delete timeouts. On one node this covers Pod failure,
not node failure. No backup/PITR or pooler is configured.

| Variable | Type | Default |
|---|---|---|
| namespace | string | required |
| database | string | required |
| username | string | required |
| password | sensitive string | executor-owned, required |
| tags | map(string) | executor-owned, required |
| image | string | CNPG PostgreSQL 16.14-system-trixie, digest below |
| storage | string | 1Gi |
| storage_class | string | empty: cluster default |
| labels | map(string) | {} |
| annotations | map(string) | {} |
| instances | number | 2; integer >= 2 |

Image: `ghcr.io/cloudnative-pg/postgresql:16.14-system-trixie@sha256:04f35778ca3b55b52a81dae969bef179ead315b9f02d2b4b21a3415de269b836`.
This uses the CNPG default image family with major 16 matching terraform/postgres,
rather than CNPG 1.30.1's default major 18. Official postgres Alpine images are
not CNPG compatible. All other existing variable defaults/types are preserved.
Metadata rejects secret-looking and platform-owned keys as terraform/postgres.

Outputs: host (string: `<cluster>-rw.<namespace>.svc`), port (number: 5432),
database (string), username (string), password (sensitive string), uri
(sensitive string), jdbcUrl (string, no credentials), asyncUri (sensitive
string). Connection URI credentials are percent-encoded. The read/write Service
follows the current primary. Password must come from the executor, never Git.

Cleanup must destroy the Cluster before removing the operator. Terraform owns
only Cluster/Secret; Kubernetes ownerReference garbage collection removes its
children. Never delete a namespace with unproven foreign objects.

Validation: terraform fmt -check, terraform init -backend=false, terraform
validate, terraform test. Mock-provider tests cover the contract; live readiness,
failover, data persistence and cleanup require the product acceptance on kind.
