# Workload template

Nhập [Type](workload-type.yaml), chuẩn bị Git template theo
[hướng dẫn chung](../README.md#nguồn-git-và-template-source), rồi thay source ID
trong [Definition](workload-definition.yaml). Class default; namespace reference
đồng thời cung cấp placement cluster. Type không thêm params/output hạ tầng cho
workload; workload intent vẫn theo contract native/Score của sản phẩm.

Nguồn templates/standard ở commit được hướng dẫn có capability endpoint-httproute-v1.
Không dùng URL thay source ID, không đặt Terraform source/provider_bindings vào
template driver. Template input {} dùng các defaults trong schema đã pin.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
