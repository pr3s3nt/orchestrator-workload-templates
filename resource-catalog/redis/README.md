# Redis trong namespace

Nhập [Type](redis-type.yaml) và [Definition](redis-definition.yaml). Class default,
module [redis](../../terraform/redis/main.tf), một instance có ACL/password và PVC.
Username mặc định app, storage mặc định 1Gi; có thể truyền hai param này.
Default user bị tắt; password/tags do executor cấp. TLS output hiện là false.

Outputs password, uri và connection_string là secret; các chuỗi kết nối là
outputs tùy chọn trong Type nhưng mẫu Definition map đầy đủ. Không có module
Redis HA hoặc managed Redis trong catalog này.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
