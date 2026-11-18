# Resource Type và Definition catalog

Bộ mẫu cho các tài nguyên hiện có trong repo: **10 Types, 11 Definitions**, bao
phủ đủ 7 module Terraform. Đây là tài liệu cấu hình, không phải Kubernetes manifests
để kubectl apply. Đăng ký Definition chỉ lưu cấu hình; Preview/Deploy ứng dụng là
bước riêng. Các giá trị trong `<...>` phải được thay theo Console đích.

| Type | Definition YAML | Driver / nguồn | Class |
|---|---|---|---|
| k8s-cluster | [cluster](cluster/cluster-definition.yaml) | existing-cluster, Internal account có sẵn | default |
| k8s-namespace | [namespace](namespace/namespace-definition.yaml) | terraform/namespace | default |
| k8s-gateway | [gateway](gateway/gateway-definition.yaml) | Echo metadata cho Gateway có sẵn | default |
| endpoint | [endpoint](endpoint/endpoint-definition.yaml) | endpoint, tham chiếu Gateway | default |
| workload | [workload](workload/workload-definition.yaml) | templates/standard | default |
| postgres | [postgres](postgres/postgres-definition.yaml) | terraform/postgres | default |
| postgres | [postgres-ha](postgres/postgres-ha-definition.yaml) | terraform/postgres-ha, CNPG | ha |
| redis | [redis](redis/redis-definition.yaml) | terraform/redis | default |
| mysql | [mysql](mysql/mysql-definition.yaml) | terraform/mysql | default |
| mongodb | [mongodb](mongodb/mongodb-definition.yaml) | terraform/mongodb | default |
| persistent-storage | [persistent-storage](persistent-storage/persistent-storage-definition.yaml) | terraform/persistent-storage | default |

Mỗi thư mục có `*-type.yaml` để nhập trước Definition. PostgreSQL thường/HA dùng
chung một Type. Class thuộc từng Type, nên default của cluster và endpoint không
xung đột. Key Definition là ID độc lập với class; key MongoDB cũ được giữ lại để
không tạo thêm một family chỉ vì thay tên/criteria trong mẫu.

## Chuẩn bị trên Console đích

- Internal Driver Account cho cluster đã có, được kiểm tra và ở trạng thái READY.
  Thay key account trong [cluster Definition](cluster/cluster-definition.yaml).
  Credential/kubeconfig được lưu ở account, không đưa vào repo hoặc variables.
- StorageClass/provisioner phù hợp; `storage_class: ""` chọn mặc định của cluster.
- Thay image digest MySQL/MongoDB bằng image tương thích đã được chấp thuận.
  Nếu dùng imagePullSecret, Secret đó phải có sẵn trong namespace đích.
  PostgreSQL/Redis và HA dùng digest cố định từ module đã pin.
- Điền domain, scheme và Gateway namespace/name/listener thực tế trong Gateway
  Definition. Gateway/Traefik, DNS và TLS là hạ tầng có sẵn, bộ này không tạo chúng.
- Chỉ dùng PostgreSQL HA khi CNPG CRDs/operator đã sẵn sàng; xem [HA](postgres/README.md).

## Nguồn Git và template source

Các Terraform Definition dùng URL repo này, full commit
`b8e98a7f2d2239ab99de52b5dda7321653119dec`, path tương ứng trong `terraform/`.
Commit đó chứa tất cả module và template HTTPRoute cần dùng. Console thực hiện
Kiểm tra cấu hình để xác minh module và tạo source pin/digest; không tự điền IDs
hay hash lấy từ installation khác. Có thể chủ động chọn commit đã review khác,
rồi kiểm tra lại. Lưu/nâng main không tự đổi pin của Definition đang chạy.

Workload template có quy trình riêng: mở form cấu hình workload, chọn nguồn Git
repo này, cùng commit trên, path `templates/standard`, bấm **Kiểm tra template**.
Dùng source ID đã được chuẩn bị/đăng ký trên Console đích trong
`variables.template_source` của [workload Definition](workload/workload-definition.yaml).
Có thể hoàn tất form đó trực tiếp hoặc dùng ID trong YAML. Field này nhận ID,
không nhận URL hay object `{url, ref, path}`; không tự đoán ID từ commit.
`template_inputs: {}` hợp lệ với schema của source đang pin.

## Thứ tự nhập

1. Nhập các Type trước: cluster, namespace, gateway, endpoint, workload, postgres,
   redis, mysql, mongodb, persistent-storage. Chỉ nhập postgres Type một lần.
2. Thay placeholders, nhập cluster Definition, rồi namespace Definition.
3. Nhập Gateway, rồi Endpoint; cả hai dùng class default.
4. Chuẩn bị template source và nhập workload Definition.
5. Nhập các database/PVC Definitions cần dùng. PostgreSQL HA là tùy chọn riêng.
6. Mỗi Definition bấm Kiểm tra cấu hình, review pin/mapping/criteria rồi đăng ký.
   Sau đó Preview ứng dụng mới xác nhận lựa chọn và dependency thực tế.

Type/Definition import không ghi đè: cùng key tương đương là REUSED, khác schema/
cấu hình là CONFLICT. Với Definition đã tồn tại, dùng Sửa và review revision mới,
không tạo key khác chỉ để tránh conflict. Type không có chức năng sửa toàn bộ
schema trên Console hiện tại. Nếu Type hiện hữu không khớp, cần quyết định nâng
contract riêng; không xóa/reset Type hoặc installation để nhập bộ mẫu này.
Các mẫu không tự nâng schema, thay selection hay migrate dữ liệu đang chạy.

## Quan hệ giữa các cấu hình

- Database/PVC → `k8s-namespace.default#environments.@app.@env`.
  Cả variables.namespace và provider binding đều trỏ đúng namespace này.
- Namespace → `k8s-cluster.default#environments.@app.@env`.
  Namespace lấy tên do platform cấp qua `${context.env.namespace}`.
- Gateway → cluster default cùng Environment; Endpoint → Gateway default.
- Workload → namespace default; template sinh HTTPRoute từ endpoint intent.

Cluster/Gateway hiện có được tham chiếu bằng driver riêng. Endpoint do driver
endpoint cấp địa chỉ; workload do template render. Không có Terraform module giả
cho những phần này. Tất cả module hiện có trong repo đều là in-cluster; bộ này
không cung cấp RDS/managed database hoặc module tạo cloud cluster.

## Khai báo resource trong workload

Ví dụ đoạn resources của workload native hoặc Score (không phải file apply):

```yaml
resources:
  db:
    type: postgres
    class: default
    params:
      database: appdb
  cache:
    type: redis
    class: default
  data:
    type: persistent-storage
    class: default
    params:
      storage: 2Gi
  public:
    type: endpoint
    class: default
    params:
      name: my-app
      port: http
      path: /
```

Workload cần khai báo Service với cổng tên http khi dùng endpoint ở trên. Dùng
postgres class ha để chọn CNPG; MySQL/MongoDB cần database như postgres. Username/
storage là tùy chọn trong bộ Type này và nhận fallback từ Definition/module.
Password, master_password và tags do executor cấp, không phải workload params.
Outputs chứa credential (`password`, `uri`, `asyncUri`, `connection`,
`connection_string`) được đánh dấu secret; jdbcUrl không chứa credential.

HTTPRoute vẫn nằm trong [template](../templates/standard/resources/httproute.tpl),
không có Resource Definition riêng để provision HTTPRoute. Mỗi ứng dụng Preview/
Deploy qua cùng luồng sản phẩm; import YAML không chứng minh deploy/readiness,
failover hoặc dữ liệu được backup. PostgreSQL thường/Redis/MySQL/MongoDB là một
instance. Không coi thay class/module/image là thao tác migration dữ liệu.
