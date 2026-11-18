# Persistent storage/PVC

Nhập [Type](persistent-storage-type.yaml) và
[Definition](persistent-storage-definition.yaml). Class default, module
[persistent-storage](../../terraform/persistent-storage/main.tf). Workload có
param storage tùy chọn (fallback 2Gi). StorageClass và access_mode thuộc policy
của Definition; mặc định chọn StorageClass cluster và ReadWriteOnce.

Variables.namespace và provider binding cùng tham chiếu namespace default.
Executor cấp tags/instance identity; module tạo một PVC, không tạo database hay
StorageClass. Outputs claimName và namespace dùng cho workload mount/placement.
Module không đợi PVC Bound trong apply vì StorageClass có thể dùng delayed binding.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
