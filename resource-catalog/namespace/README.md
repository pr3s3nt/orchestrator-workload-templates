# Namespace ứng dụng

Nhập [Type](namespace-type.yaml) và [Definition](namespace-definition.yaml) sau
cluster. Class default dùng module [namespace](../../terraform/namespace/main.tf).
Tên namespace do platform cấp qua context.env.namespace; provider bind trực tiếp
tới cluster default trong cùng Application/Environment. Database/PVC kế thừa
cluster qua namespace này. Module output name là namespace thực tế.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
