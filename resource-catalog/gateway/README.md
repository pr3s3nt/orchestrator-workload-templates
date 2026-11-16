# Existing Gateway và endpoint

Cần backend hỗ trợ issue `pr3s3nt/poc#84`. Bộ này đang trên nhánh thử,
chưa phát hành tag và chưa được nghiệm thu.

1. Nhập `gateway-type.yaml`, rồi sửa và nhập `gateway-definition.yaml`.
   Chọn cluster class thực tế, Gateway namespace/name/listener và domain đã có
   DNS/TLS phù hợp. Đăng ký chỉ lưu cấu hình; không tạo hoặc đổi Gateway.
2. Nhập Type và Definition trong `../endpoint/`. Endpoint tham chiếu Gateway
   resource, không khai báo lại cluster/domain/listener.
3. Inspect và chọn đúng commit template `templates/standard` có capability
   `endpoint-httproute-v1`. Template cũ không tự được nâng cấp khi Git thay đổi.
4. Workload khai báo Service và resource endpoint với `name`, `port` (tên cổng
   Service), `path` (mặc định `/`). Cả native workload và Score dùng cùng intent.
5. Preview/Deploy mới kiểm tra và triển khai. Platform giữ chỗ hostname/path;
   template sinh HTTPRoute trong namespace workload, CD giao route cùng Service.

Gateway/listener phải Ready, hỗ trợ HTTPRoute và cho phép namespace workload.
Gateway là hạ tầng dùng chung có sẵn; xóa ứng dụng chỉ dọn HTTPRoute và tài nguyên
ứng dụng thuộc ownership của platform, không xóa Gateway/Traefik/DNS/TLS.

Database in-cluster dùng namespace provider binding như mẫu MongoDB:

```yaml
variables:
  namespace: "${resources['k8s-namespace.default#environments.@app.@env'].outputs.name}"
provider_bindings:
  kubernetes:
    target: resource
    resource_ref: "k8s-namespace.default#environments.@app.@env"
```

Namespace Definition vẫn bind tới cluster. Không đổi Terraform module để thêm
credential/cluster variable vào database. Database cloud giữ Definition riêng.
