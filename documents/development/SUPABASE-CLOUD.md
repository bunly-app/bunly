# Supabase Cloud phát triển — Bunly

**Snapshot trực tiếp 09/11/2026:** Supabase `list_projects` và `get_project` trả project `bunly-dev` (`jbyxiihjqveqooenofsr`) ở trạng thái **INACTIVE**. Chưa xác định nguyên nhân hoặc thực hiện restore; chưa chạy lại Auth/API/SQL/UAT. Các kết quả dưới đây thuộc hồ sơ thiết lập ngày 29/10, không chứng minh Cloud đang hoạt động hôm nay. Xem [ma trận hạ tầng và quy trình team](INFRASTRUCTURE-SETUP-MATRIX.md) để chuẩn bị hoạt động tiếp theo.

Thiết lập ngày 29/10/2026 cho môi trường phát triển, không phải production.

| Thuộc tính | Giá trị |
|---|---|
| Organization | Bunly |
| Project | bunly-dev |
| Project ref | jbyxiihjqveqooenofsr |
| Vùng | Singapore — ap-southeast-1 |
| Dashboard | https://supabase.com/dashboard/project/jbyxiihjqveqooenofsr |
| API URL | https://jbyxiihjqveqooenofsr.supabase.co |
| CLI trong repo | 2.121.0 |

## Đã thiết lập và kiểm tra

- Repo đã link đúng project ref trên. Không chạy `supabase init` lại.
- Migration `20261022000100_core_schema.sql` đã áp dụng; lịch sử local/remote khớp.
- Seed có 3 mẫu ngữ pháp và 3 ví dụ Nhật–Việt, không phải kho MVP 80–120 mẫu.
- Cả 6 bảng ứng dụng bật RLS; có 18 policy; `db lint --linked` không phát hiện lỗi schema.
- Auth health phản hồi; email/password signup được bật và vẫn yêu cầu xác nhận email.
- Truy cập kho ngữ pháp bằng client key khi chưa đăng nhập bị HTTP 401, đúng quyền hiện tại.
- Các kiểm tra trên xác minh thiết lập Cloud; không thay thế UAT đăng nhập/sync trên điện thoại bằng tài khoản thật.

## Cấu hình và chạy app

`config/development.local.json` chứa APP_MODE=connected, URL Cloud và anon client key. File này được Git ignore. Không đưa file cấu hình local vào commit hoặc log.

```sh
flutter run -d <device-id> --dart-define-from-file=config/development.local.json
```

APK connected được lưu ở `build/m2-artifacts/bunly-m2-connected-debug.apk` sau khi build thành công. APK demo được giữ riêng; dữ liệu demo dùng namespace khác dữ liệu tài khoản Cloud.

Bản connected đã build bằng Flutter 3.35.7 và cài/mở thành công trên Samsung A11 (SM-A115F). SHA256 APK: `35F92D919E7AF8554D0E9A123AC0A1D0C08C82EBEB234E8872D7539ECF5CB869`. Chưa tự đăng ký/đăng nhập thay người dùng; người dùng thực hiện bằng email của mình.

Luồng hiện tại: đăng ký bằng email được phép nhận thư, mở email xác nhận, quay lại Bunly và đăng nhập. Chưa thiết lập trang web/deep link để tự quay về app sau xác nhận.

SMTP tích hợp của Supabase chỉ phục vụ thử nghiệm: gửi tới email của thành viên organization và có hạn mức thấp. Email ngoài nhóm cần cấu hình SMTP riêng; không tắt xác nhận email chỉ để vượt hạn chế. Xem [tài liệu SMTP chính thức](https://supabase.com/docs/guides/auth/auth-smtp). Chưa gửi lời mời thành viên hoặc thiết lập SMTP bên ngoài trong tác vụ này.

## Quản trị và thay đổi tiếp theo

- Mật khẩu DB được sinh ngẫu nhiên, lưu mã hóa bằng Windows DPAPI tại `config/supabase-admin.local.json`, đã được Git ignore. Chỉ tài khoản Windows đã tạo file mới giải mã được; không chia sẻ file này với nhóm.
- Không có service-role key trong cấu hình app. Không in toàn bộ output `projects api-keys` ra chat hoặc báo cáo.
- Mọi lệnh migration tiếp theo phải kiểm tra project ref trước, chạy dry-run và kiểm chứng migration. Không chạy reset lên Cloud.
- Dùng CLI pin trong `node_modules/.bin/supabase` hoặc script npm của repo. Không nâng phiên bản tự động.
- Khi bàn giao cho thành viên, cấp quyền theo tài khoản riêng trong Dashboard; không chia sẻ access token/DB password. Việc gửi lời mời cần có email người nhận và chỉ dẫn của trưởng nhóm.

## Thành viên cùng phát triển

Mỗi thành viên dùng tài khoản Supabase của chính mình. Owner mở [Team settings của organization](https://supabase.com/dashboard/org/_/team), mời đúng email và chọn vai trò **Developer**. Lời mời có hiệu lực 24 giờ; người được mời phải chấp nhận rồi kiểm tra thấy project `bunly-dev` trong Dashboard. Quyền Developer làm việc với nội dung project nhưng không sửa project settings. Trên gói Free, quyền Read-Only và phân quyền theo từng project không có; Developer áp dụng cho toàn organization. Vì vậy chỉ giữ project phát triển trong organization này và không dùng Owner/Administrator cho công việc thường ngày.

Sau khi chấp nhận lời mời, mỗi người tự chạy `supabase login` bằng tài khoản riêng, `supabase projects list`, xác nhận ref `jbyxiihjqveqooenofsr`, rồi mới `supabase link --project-ref jbyxiihjqveqooenofsr` nếu cần quản lý migration. App chỉ cần URL HTTPS và anon client key trong `config/development.local.json` bị Git ignore; lấy client key từ Dashboard của project. Không chia sẻ `config/supabase-admin.local.json`, DB password, service-role/secret key hoặc access token. Migration đi qua Git và người phụ trách xác nhận project đích trước khi push lên Cloud.

Tài khoản Dashboard và tài khoản đăng nhập **trong app Bunly** là hai hệ thống riêng. Thành viên organization dùng cùng email có thể nhận thư xác nhận của SMTP thử nghiệm khi tự tạo tài khoản trong app. SMTP mặc định hiện giới hạn 2 thư/giờ và chưa phục vụ email ngoài team; muốn thử với người dùng khác phải cấu hình SMTP riêng.

Các kịch bản kiểm tra tiếp: [M2-TEST-HANDOFF.md](M2-TEST-HANDOFF.md).
