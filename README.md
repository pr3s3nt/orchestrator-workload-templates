# Orchestrator workload templates

Repository mẫu để kiểm tra nguồn Git của Resource Definition trong Orchestrator.
Template sinh Deployment, StatefulSet hoặc CronJob cùng Service, volumes và
các policy được workload khai báo. Không dùng Score và không chứa credential.

## Tham chiếu từ Console

1. Mở **Cấu hình tài nguyên → Tạo cấu hình**.
2. Chọn loại `workload`; driver là `Template`.
3. Nguồn Git: `https://github.com/pr3s3nt/orchestrator-workload-templates`.
4. Thư mục template: `templates/standard`.
5. Ref: `v0.1.0` hoặc commit chính xác muốn kiểm tra.
6. Bấm **Kiểm tra template**, đặt ID/tên và điều kiện áp dụng rồi lưu.

Namespace lấy từ Resource Definition namespace của platform, ví dụ:

```text
${resources['k8s-namespace.default#environments.@app.@env'].outputs.name}
```

Repo này chỉ cung cấp template workload. Preview/Deploy thật còn cần các
Definition hạ tầng và cấu hình CD tương ứng trong môi trường.

## Cấu trúc

- `templates/standard/bundle.yaml`: manifest source và workload presets.
- `templates/standard/defaults.yaml`: mặc định dùng khi render.
- `templates/standard/inputs.schema.json`: inputs của Definition.
- `templates/standard/resources/`: các manifest ban đầu.
- `templates/standard/patches/`: policy, runtime và controller patches.
- `templates/standard/normalize/`: chuẩn hóa workload intent.

Runtime files được lấy nguyên từ `pr3s3nt/poc`; xem SOURCE.md để biết commit.
Mỗi lần thay đổi template cần commit/tag mới và chọn revision mới trên Console;
Definition đã lưu không tự đổi pin khi `main` thay đổi.
