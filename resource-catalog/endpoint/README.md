# Endpoint qua Gateway

Nhập [Type](endpoint-type.yaml), rồi [Definition](endpoint-definition.yaml) sau
Gateway. Class default, reference k8s-gateway.default trong Environment. Workload
truyền name, tên cổng Service qua port, và path tùy chọn. Driver cấp hostname/URL;
[template HTTPRoute](../../templates/standard/resources/httproute.tpl) tạo route.
Không tạo Gateway/DNS/TLS trong Endpoint Definition.

Xem [hướng dẫn chung](../README.md) và [Gateway](../gateway/README.md).
