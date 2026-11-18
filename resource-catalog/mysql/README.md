# MySQL trong namespace

Nhập [Type](mysql-type.yaml), thay image placeholder trong
[Definition](mysql-definition.yaml), rồi Kiểm tra và đăng ký. Class default,
module [mysql](../../terraform/mysql/main.tf). Image cần digest cố định và
entrypoint/client mysql tương thích; image_pull_secret_name là tên Secret đã có
trong namespace nếu cần. Module không có image mặc định.

Workload chỉ truyền database bắt buộc, username/storage tùy chọn. Username
fallback app, storage 10Gi. Không dùng params auth_secret_name/root_password_key/
user_password_key của contract cũ. Password và master_password do executor cấp;
module tạo Secret riêng và không công bố root password.

Module tạo một StatefulSet, headless Service và PVC. Type công bố password/uri
là secret, jdbcUrl không có credential. ClaimName/namespace và connection variants
là outputs tùy chọn; mẫu hiện tại map đầy đủ. Xem
[Type conflict và thứ tự nhập](../README.md#thứ-tự-nhập) trước khi dùng với Type
mysql cũ đã đăng ký trên installation.

Xem [hướng dẫn chung](../README.md) về prerequisites, pin nguồn, secrets và import.
