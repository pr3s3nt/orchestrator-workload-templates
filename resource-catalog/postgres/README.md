# PostgreSQL thường và HA

Nhập [Type postgres](postgres-type.yaml) một lần. Chọn
[Definition thường](postgres-definition.yaml) class default hoặc
[Definition HA](postgres-ha-definition.yaml) class ha; có thể đăng ký cả hai vì
criteria khác class. Cả hai dùng namespace provider binding và cùng contract
outputs. Database là workload param bắt buộc; username/storage có fallback.

- Bản thường: một PostgreSQL StatefulSet, Secret, Service và PVC; module postgres.
- HA: module postgres-ha tạo Secret và CNPG Cluster, mặc định hai instance. Cần
  CRDs/operator sẵn có, dùng image CNPG theo
  [module README](../../terraform/postgres-ha/README.md). Không cài operator từ
  Definition, không dùng stock PostgreSQL Alpine cho CNPG. Instance count thuộc
  policy của Definition, không phải param chung của Type postgres.
- CNPG quản lý Pods/PVC/Services con; trên một node không cung cấp khả năng chịu
  lỗi node. Module chưa cấu hình backup/PITR/pooler; có Ready wait tối đa 15 phút.

Password/URI/asyncUri là secret, jdbcUrl không có credential. URI/jdbcUrl/asyncUri
là outputs tùy chọn của Type để không bắt mọi Definition postgres phải xuất đủ
connection variants; cả hai mẫu hiện tại đều map đủ các output module có. Không
đổi default↔ha cho dữ liệu đang dùng như một thao tác cấu hình thông thường.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
