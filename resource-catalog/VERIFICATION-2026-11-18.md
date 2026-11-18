# Live catalog execution — 2026-11-18, issue #1

The user authorized removing old test apps/workloads and deploying the exact new
catalog on existing kind. Platform Keycloak, Console/Vault, shared Gateway,
Traefik, CNPG operator and StorageClass are preserved. No cloud operation occurs.
Catalog source is `8aed1e0`; module/template sources remain pinned to reviewed
`b8e98a7`. Product images reuse accepted main `6084919e`; no product source change
or full-suite rerun is part of this runtime execution.

## Old test cleanup

Six non-platform test Applications were admitted for deletion using fresh
product deletion-preview tokens and exact name confirmations. Three completed
immediately; three returned CLEANUP_INCOMPLETE with remaining namespace-local
bootstrap RBAC, a legacy Deployment/Pod and a migration Job/Pod. Those failures
and receipts are retained. Subsequent user instruction explicitly authorized
removing the remnants rather than developing a cleanup fix in this task.

A bounded plan checked namespace identity, exact original/observed object UIDs,
persisted deployment artifact identities, application/environment/workload
labels, bootstrap Role rules and RoleBinding subject. Six exact objects were
removed with fresh UID/resourceVersion preconditions and foreground deletion;
no namespace was force-deleted. Fresh product deletion admissions then completed
SUCCEEDED for the remaining three apps. Native namespace/PV absence was checked.
The retained main installation lists only Platform Keycloak; its original Types,
Definitions and Driver Accounts are API-identical. This is administrative remnant
cleanup plus product Retry, not a product-code fix or proof the old bug is fixed.

## Exact new catalog in a separate trial installation

The main installation has incompatible historical Type schemas and an active SSO
Application. A separate Docker Console/PostgreSQL/Vault installation uses the
same authorized kind workload target. It does not replace the main installation's
Types or reset its SSO configuration. Private stack volumes, metadata snapshots,
backups and credentials are retained outside Git.

All **10 Types and 11 Definitions** were registered through product APIs. Types
match the published catalog. Destination values replace only the documented
placeholders: READY Internal account key, inspected template-source ID,
Gateway/domain/listener and approved MySQL/MongoDB image digests. Terraform
Definitions pass actual import/prepare against their pinned modules before save.
The real template source is inspected; Fleet management account/binding/default
and platform Git settings are configured through the existing APIs. Catalog/API
setup alone is not reported as workload deployment acceptance.

Native and Score workload drafts were saved via Console before one Environment
Preview/Deploy for both workloads. The native workload declares all seven module
resources, with PostgreSQL default and HA distinct, and mounts the standalone PVC.
The Score workload shares the ordinary PostgreSQL. The Environment Deploy returned
SUCCEEDED for both workloads. Gateway execution proof selects the published Echo
Definition and records READY output. No new Gateway or cluster is created.

## Observed runtime evidence

- Eight long-running Pods are Ready: two web workloads, four single-instance
  databases/cache and two CNPG PostgreSQL instances. Seven PVCs are Bound.
- PostgreSQL ordinary/HA and MySQL pass authenticated SELECT 1 as the application
  user; MongoDB passes authenticated application-database ping; Redis passes ACL
  authenticated PING. Credentials are consumed privately, never logged.
- Native workload mounts the standalone resource PVC and writes/reads a marker.
  Both workload PostgreSQL init containers completed successfully.
- Both template-generated HTTPRoutes have expected hosts, listener, namespace,
  local Service/port and Accepted/ResolvedRefs. Existing shared Gateway UID is
  unchanged. No shared controller/operator/DNS/TLS change is performed.
- Real browser checks authenticate at the actual Tailscale Console URL, load the
  10-Type/11-Definition catalog and retained Application, and reach both real web
  URLs through the Gateway. Private screenshots show the product shell/catalog.
  Host-based tailnet access is verified; other device ACLs are not inferred.

**Metadata caveat:** after the second workload deployment, Active Resource and
Terraform instance records for MongoDB, MySQL, Redis and PostgreSQL HA are marked
UNREFERENCED while those objects remain physically Ready and declared by the
native workload. Namespace/ordinary PostgreSQL/mounted PVC stay READY. This
observation is retained rather than rewriting status, adding references merely
to hide it, or claiming every management-state check passed. Root cause and a
product fix are not established here. No automatic resource cleanup is run on
the retained sample. HA failover/backup/PITR, upgrade/migration and restart/data
persistence tests are not claimed by this initial-deployment verification.

## Empty bootstrap fixture and retained state

The initial catalog-free acceptance profile created an empty startup Application.
Its product deletion failed WORKLOAD_REMOVAL_FAILED before any Deployment,
Environment operation, workload, Terraform instance or configuration revision
existed. The failed receipt is retained. The new backend writer was stopped and
a private database backup made. A bounded owner transaction removed only that
empty fixture's two empty Deployment Sets, two Environments and Application row,
checking the absence of runtime/domain history and active claims/stores. No
constraint/trigger, Terraform state or real Application record was bypassed or
rewritten. This is a test-fixture metadata purge, not a successful product delete.
The backend now runs production/staging seed mode, which preserves the already
registered catalog and does not recreate the fixture. Actual workload resources
continue running through this Console maintenance.

Final browser/API checks confirm only the retained real test Application and the
exact catalog. Sample stack/forwards and all new resources remain up for user
review. Main SSO remains available. Repository branch remains
features/complete-resource-catalog pending acceptance; no main merge/tag is implied.
