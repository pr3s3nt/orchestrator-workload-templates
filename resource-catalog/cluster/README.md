# Cluster có sẵn

Nhập [Type](cluster-type.yaml), thay Driver Account key trong [Definition](cluster-definition.yaml)
rồi Kiểm tra và đăng ký. Account phải là Internal/Kubernetes và READY trên Console
đích. Driver existing-cluster lấy identity/credential từ account; variables để trống.
Class default dùng chung; không tạo hoặc nhận ownership cluster.

Output name và cluster là metadata/target, không phải kubeconfig literal. Không
có module Terraform cho existing-cluster trong bộ này.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
