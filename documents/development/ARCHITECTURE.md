# Nền kiến trúc đang có và cách tiếp tục M2

Đọc [thiết lập chạy app](GETTING_STARTED.md) trước. Tài liệu này mô tả base trên nhánh `feat/m2-architecture-base`, không phải tuyên bố M2 hoàn thành.

## Mã nguồn hiện tại

| Thành phần | Vị trí | Trách nhiệm |
|---|---|---|
| Bootstrap và cấu hình | `lib/main.dart`, `lib/app/config.dart` | Phân biệt demo/connected; cấu hình connected thiếu thì báo lỗi; release yêu cầu HTTPS |
| Composition root | `lib/app/providers.dart` | Riverpod lắp ghép repository, use case, controllers và session |
| Auth | `lib/features/auth/` | Interface và use case validate; adapter Supabase; form đăng nhập/đăng ký/xác nhận email |
| Grammar | `lib/features/grammar/` | Tìm/lọc trong domain; data lấy asset hoặc API và cache Drift; UI danh sách/chi tiết |
| Learning | `lib/features/learning/` | `SaveNote` kiểm tra nội dung; repository lưu local + outbox trong một transaction |
| Cơ sở dữ liệu local | `lib/core/database/` | Cache phân vùng theo backend; ghi chú/outbox theo backend và tài khoản; schema version 1 |
| Backend | `supabase/` | Sáu bảng, RLS, trigger hồ sơ/timestamp, ba mẫu seed và 18 kiểm tra pgTAP |

UI gọi use case hoặc repository interface qua DI; domain không import Flutter, Riverpod, Drift hay Supabase. `SearchGrammar` tải danh sách; `filterGrammar` xử lý truy vấn/cấp độ/nhóm trên danh sách đã tải, không gọi API mỗi lần gõ. Tài khoản thay đổi làm thay navigator để đóng trang ghi chú cũ.

Ghi chú connected hiện lưu trên thiết bị và tạo outbox. **Chưa có worker gửi/nhận ghi chú**; UI thông báo đúng giới hạn này. Demo không tạo outbox từ xa. Các bảng `saved_grammar`, `progress`, `profiles` đã có ở backend; chưa có đầy đủ use case/UI cho các chức năng đó.

## Cách thêm tính năng

1. Chốt entity, quy tắc nghiệp vụ và interface trong `domain`. Viết test cho quy tắc có thể sai trước khi ghép dịch vụ.
2. Thêm model/mapper, data source và implementation trong `data`; không để model Supabase/Drift đi lên UI.
3. Wire implementation ở `lib/app/providers.dart`. Dùng fake tại vị trí interface để kiểm thử widget.
4. Thêm controller/screen trong `presentation`; xử lý tải/rỗng/lỗi, lỗi lưu và vòng đời session.
5. Nếu đổi dữ liệu: migration Supabase + policy/test; migration Drift + code generation; chạy các kiểm tra liên quan.
6. Cập nhật tiến độ báo cáo bằng bằng chứng thật tại commit triển khai. Việc thêm folder hoặc interface chưa được tính là hoàn thành chức năng.

## Công việc tiếp theo theo thứ tự

| Thứ tự | Công việc | Điều kiện đạt |
|---|---|---|
| 1 | Chạy connected trên Android, hoàn thiện màn hình hồ sơ | Đăng ký/xác nhận/đăng nhập được; hồ sơ lưu và đọc lại đúng user |
| 2 | Hoàn thiện lưu/bỏ lưu mẫu và trạng thái học | Dữ liệu cục bộ có migration; thao tác lặp không trùng; số đếm lấy từ bản ghi thật |
| 3 | Sửa/xóa ghi chú và bổ sung tombstone | Không mất thao tác khi khởi động lại; ghi chú được phân vùng đúng tài khoản |
| 4 | Worker đồng bộ một thiết bị | Chỉ gửi bằng session chủ sở hữu; giữ outbox khi lỗi; retry idempotent; phản hồi cũ không ghi đè thay đổi mới |
| 5 | Nhận dữ liệu từ xa và giải thích trạng thái cache | Lần đầu tải được; offline đọc cache có thông báo; lỗi xác thực không bị báo thành đồng bộ thành công |
| 6 | Chạy E2E và quay video | FR-01 đến FR-06 đạt trên thiết bị; video 2–3 phút khớp tag/commit M2 |

OCR, LLM và xử lý xung đột nhiều thiết bị tiếp tục ở M3 theo PRD. Không tạo tag `milestone-2` trước khi bộ tiêu chí nghiệm thu đạt.

## Kiểm chứng tại cloud ngày 22/10/2026

- Flutter 3.35.7 / Dart 3.9.2; Supabase CLI 2.121.0 được cài và chạy.
- `flutter analyze`: không có vấn đề; 12 test use case/repository/Drift/widget đạt.
- `flutter build bundle --debug --target-platform android-arm64 --dart-define-from-file=config/demo.example.json`: đạt. Đây là Dart/assets bundle, chưa phải APK đã cài trên thiết bị.
- Migration và seed đã chạy trên Supabase PostgreSQL local; 18 kiểm tra pgTAP RLS và `db lint` đạt. Hai chủ sở hữu dùng JWT claims dưới vai trò `authenticated`; đây là kiểm thử SQL, chưa phải luồng đăng nhập người dùng trên app.
- Auth container health check bị proxy cloud trả HTTP 403. Đã chạy phần database với `supabase start -x gotrue` để kiểm thử RLS độc lập; **lệnh này không khởi động Auth và không dùng để nghiệm thu connected mode**.
- Chưa build APK, chưa chạy emulator/điện thoại hoặc iOS, chưa chạy GitHub Actions tại thời điểm viết mục này. CI có cấu hình build APK; chỉ nhận kết quả sau khi workflow thực sự chạy.

Trên cloud ít dung lượng, CLI hỗ trợ `SUPABASE_USE_SLIM_IMAGES=true`. Ở môi trường này đã xác minh đường tải qua `SUPABASE_INTERNAL_IMAGE_REGISTRY=docker.io`; CLI chọn official slim images theo digest. Không bỏ checksum/TLS. Các tùy chọn cloud chỉ là cấu hình của tiến trình, không đổi mặc định máy cá nhân của thành viên.
