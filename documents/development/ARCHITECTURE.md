# Kiến trúc M2 và trạng thái kiểm chứng

Cập nhật ngày 29/10/2026. Xem [báo cáo M2](../reports/Capstone-Report-2-Architecture.md) và [biên bản kiểm chứng](../reports/M2-Verification-2026-10-29.md) để biết phần đã chạy/chưa chạy. Không xem code đã bổ sung là nghiệm thu toàn bộ M2.

## Các thành phần hiện có

| Thành phần | Trách nhiệm |
|---|---|
| `lib/app/` | Cấu hình demo/connected, navigator theo tài khoản, Riverpod composition root |
| `features/auth/` | Validate thông tin đăng nhập/đăng ký, Supabase adapter và form |
| `features/grammar/` | Kho, tìm/lọc, chi tiết, API/asset và cache; lỗi quyền không bị che bằng cache |
| `features/learning/domain/` | Note, UserProfile, LearningSummary, LearningStatus; SaveNote và UpdateLearning; repository interfaces |
| `features/learning/data/` | Ghi local + outbox transaction, CRUD cá nhân, push/pull với session owner và pending protection |
| `features/learning/presentation/` | Hồ sơ, lưu mẫu/trạng thái, controller và banner đồng bộ |
| `core/database/` | Drift schema version 2, migration v1 → v2 giữ dữ liệu cũ và code sinh |
| `supabase/` | Schema/RLS backend, seed 3 mẫu và pgTAP; SQL test mới phải chạy lại |

Domain chỉ phụ thuộc Dart. UI/controller gọi use case; data triển khai interface; app wire implementation. Demo dùng namespace riêng và không gửi outbox lên Supabase. Test widget dùng fake; repository/migration test dùng SQLite thật. Remote giả lập chỉ chứng minh thuật toán lỗi/race, không chứng minh Auth/API thật.

## Đồng bộ M2

- Bốn entity từ xa: profiles, notes, saved_grammar, progress. Local notes có tombstone; personal_records giữ payload cho ba loại còn lại.
- Outbox là các snapshot thao tác bất biến với sequence tăng dần. Push theo thứ tự, giữ thao tác nếu thất bại; upsert theo khóa ổn định. Ack chỉ xóa đúng sequence đã gửi.
- Worker lấy token của owner tại thời điểm tạo request; không lấy token của user khác. Kiểm tra session trước/sau await và dừng khi provider bị dispose.
- Pull theo owner, có phân trang; không đè entity/key còn pending local. Không dùng timestamp client để kết luận thứ tự xung đột đa thiết bị.
- Trigger khi mở kho, foreground, mỗi 30 giây khi banner còn được giữ và nút Đồng bộ. Không hứa tác vụ nền khi app bị đóng.
- Hard-delete từ admin và hợp nhất đa thiết bị chưa nghiệm thu. M3 chốt chính sách conflict/tombstone đầy đủ.

## Kiểm thử và tiếp tục

- `test/`: domain, SQLite, migration, retry/ack/session race, cache và widget.
- `test_connected/`: Auth/API/RLS qua SDK với Supabase local thật; chạy riêng, cấu hình thiếu là lỗi chứ không skip.
- `integration_test/`: luồng demo Android dùng asset/SQLite thật và luồng connected Android dùng Supabase local, Mailpit và mô phỏng ngắt API. Hai suite đạt trên Samsung A11; không thay thế Cloud UAT và thao tác bàn phím/mạng thật.
- CI chạy format/analyze/unit-widget/build APK, SQL và connected SDK. Chỉ dẫn kết quả run của commit thực tế.
- Phần còn phải nghiệm thu: email/đăng nhập Cloud bằng tài khoản người dùng, bàn phím và mạng thật, video 2–3 phút và mốc mã nguồn nộp. OCR/LLM/conflict đa thiết bị theo M3.

## Lịch sử kiểm chứng tại cloud ngày 22/10/2026


- Flutter 3.35.7 / Dart 3.9.2; Supabase CLI 2.121.0 được cài và chạy.
- `flutter analyze`: không có vấn đề; 12 test use case/repository/Drift/widget đạt.
- `flutter build bundle --debug --target-platform android-arm64 --dart-define-from-file=config/demo.example.json`: đạt. Đây là Dart/assets bundle, chưa phải APK đã cài trên thiết bị.
- Migration và seed đã chạy trên Supabase PostgreSQL local; 18 kiểm tra pgTAP RLS và `db lint` đạt. Hai chủ sở hữu dùng JWT claims dưới vai trò `authenticated`; đây là kiểm thử SQL, chưa phải luồng đăng nhập người dùng trên app.
- Auth container health check bị proxy cloud trả HTTP 403. Đã chạy phần database với `supabase start -x gotrue` để kiểm thử RLS độc lập; **lệnh này không khởi động Auth và không dùng để nghiệm thu connected mode**.
- Chưa build APK, chưa chạy emulator/điện thoại hoặc iOS, chưa chạy GitHub Actions tại thời điểm viết mục này. CI có cấu hình build APK; chỉ nhận kết quả sau khi workflow thực sự chạy.

Trên cloud ít dung lượng, CLI hỗ trợ `SUPABASE_USE_SLIM_IMAGES=true`. Ở môi trường này đã xác minh đường tải qua `SUPABASE_INTERNAL_IMAGE_REGISTRY=docker.io`; CLI chọn official slim images theo digest. Không bỏ checksum/TLS. Các tùy chọn cloud chỉ là cấu hình của tiến trình, không đổi mặc định máy cá nhân của thành viên.
