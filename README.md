# Orchestrator workload templates

Nguồn phát hành chuẩn của workload templates và Terraform modules cho Console
Orchestrator (từ `v0.4.0`, issue pr3s3nt/poc#54). Bản gốc để phát triển và test
vẫn nằm trong repo `pr3s3nt/poc`; mỗi bản phát hành ở đây có tag riêng.
Template sinh Deployment, StatefulSet hoặc CronJob cùng Service, volumes và
các policy được workload khai báo. Không dùng Score và không chứa credential.

## Tham chiếu từ Console

1. Mở **Cấu hình tài nguyên → Tạo cấu hình**.
2. Chọn loại `workload`; driver là `Template`.
3. Nguồn Git: `https://github.com/pr3s3nt/orchestrator-workload-templates`.
4. Thư mục template: `templates/standard`.
5. Ref: `v0.4.0` hoặc commit chính xác muốn dùng.
6. Bấm **Kiểm tra template**, đặt ID/tên và điều kiện áp dụng rồi lưu.

Namespace lấy từ Resource Definition namespace của platform, ví dụ:

```text
${resources['k8s-namespace.default#environments.@app.@env'].outputs.name}
```

Repo cung cấp cả template workload và các module namespace/PostgreSQL/Redis.
Preview/Deploy thật vẫn cần Definition chọn cluster đích, cấu hình CD, Secret
Store và quyền truy cập tương ứng. Việc inspect/lưu Definition không provision
bất kỳ tài nguyên nào.

## Terraform modules

Dùng cùng URL Git ở trên, chọn nguồn **Git**, ref `v0.4.0` và thư mục:

| Resource Type | Thư mục module | Mục đích |
|---|---|---|
| `k8s-namespace` | `terraform/namespace` | Tạo namespace do platform quản lý |
| `postgres` | `terraform/postgres` | PostgreSQL StatefulSet, Service và storage |
| `redis` | `terraform/redis` | Redis StatefulSet, Service và storage |
| `mysql` | `terraform/mysql` | MySQL StatefulSet, Service và storage |
| `persistent-storage` | `terraform/persistent-storage` | PersistentVolumeClaim cho workload |

Chọn **Kiểm tra module**, cấu hình namespace/cluster references và ánh xạ
inputs/outputs theo metadata đã kiểm tra. Password do executor quản lý;
không đưa password hoặc kubeconfig vào repository hay biến literal.
Các module lấy từ repo `pr3s3nt/poc`; xem SOURCE.md để biết commit và đường dẫn gốc.

## Cấu trúc

```text
templates/standard/       # Template driver cho workload
terraform/namespace/     # Terraform: namespace
terraform/postgres/      # Terraform: PostgreSQL
terraform/redis/         # Terraform: Redis
terraform/mysql/         # Terraform: MySQL
terraform/persistent-storage/ # Terraform: PVC
```

- `templates/standard/bundle.yaml`: manifest source và workload presets.
- `templates/standard/defaults.yaml`: mặc định dùng khi render.
- `templates/standard/inputs.schema.json`: inputs của Definition.
- `templates/standard/resources/`: các manifest ban đầu.
- `templates/standard/patches/`: policy, runtime và controller patches.
- `templates/standard/normalize/`: chuẩn hóa workload intent.

Runtime files được lấy nguyên từ `pr3s3nt/poc`; xem SOURCE.md để biết commit.
Mỗi lần thay đổi template cần commit/tag mới và chọn revision mới trên Console;
Definition đã lưu không tự đổi pin khi `main` thay đổi.

## v0.3.0 — compatible security defaults

Generic presets are version 1.2.0: privileged=false without forcing UID, read-only
root filesystem, capability drops, seccomp or token automount. Explicit permitted
workload values win. The nginx-readonly image-specific preset is unchanged.
This is a compatibility-oriented default, not full Baseline enforcement.
Redis adds sensitive output `connection_string` for a single reference from the
Workload form; password bytes stay in secret delivery, never literal workload data.

## v0.4.0 — nguồn phát hành chuẩn (issue pr3s3nt/poc#54)

- `terraform/postgres`: thêm output `uri` (sensitive) và `jdbcUrl`.
- `terraform/redis`: thêm output `uri` (sensitive), giữ `connection_string`.
- Thêm `terraform/persistent-storage`.
- `templates/standard` trùng với `pr3s3nt/poc` tại commit ghi trong SOURCE.md.

## v0.4.1 — MySQL theo contract mới

`terraform/mysql` lấy từ `projects/platform-resources/terraform/mysql` của
`pr3s3nt/poc`: password do executor quản lý, có output `uri` (sensitive) và
`jdbcUrl`, kèm `terraform test`. Thay bản MySQL contract cũ trong `v0.4.0`.
Dùng `v0.4.1` cho mọi Definition mới.
