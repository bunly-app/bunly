# Biên bản kiểm chứng M2 — 29/10/2026

## Phiên bản và phạm vi

- Baseline: `d15909dec97da282c2643bbac93bac9babfc2b5b`.
- Commit chức năng: `6449a269b2944c5c6ccd64b467146c2071fee688`.
- Nhánh: `codex/complete-m2`; [draft PR #2](https://github.com/bunly-app/bunly/pull/2).
- Flutter 3.35.7, Dart 3.9.2, Riverpod 2.6.1, Drift 2.28.2, Supabase Flutter 2.10.3.
- Các chỉnh sửa báo cáo/hướng dẫn và integration test tiếp nối được ghi trong lịch sử PR. Không dùng SHA baseline như SHA triển khai mới.

## Kết quả đã đọc

| Kiểm tra | Môi trường/phương pháp | Kết quả |
|---|---|---|
| Dependency | flutter pub get --enforce-lockfile; npm ci | Đạt; bổ sung integration_test và cập nhật pubspec.lock bằng SDK pin |
| Codegen | build_runner; so SHA256 của app_database.g.dart trước/sau | Đạt, code sinh lại không đổi ở lần kiểm tra cuối |
| Format | dart format --output=none --set-exit-if-changed lib test integration_test test_connected | Đạt, 0 file đổi |
| Analyze | flutter analyze --no-pub | Đạt, No issues found |
| Unit/repository/widget | flutter test --no-pub --coverage trên Windows | 24/24 đạt: 21 domain/repository và 3 widget; coverage/lcov.info được sinh, chưa nhận ngưỡng coverage M3 |
| SQL/RLS mở rộng | Supabase PostgreSQL local trong GitHub Actions | 39/39 đạt; Result: PASS; db lint đạt |
| Connected SDK | Auth/API + SQLite push/pull/restart/edit/tombstone + hai user RLS trên GitHub Actions | 1/1 đạt; test dùng adapter Supabase thật |
| APK demo debug local | Gradle 8.12 wrapper bằng JDK 17, Flutter pin | BUILD SUCCESSFUL; file APK đã tạo, chưa suy ra E2E từ build |
| Android demo integration | Samsung A11 (SM-A115F), Android thật | 1/1 đạt; assets/SQLite thật |
| Auth/email/connected UI trên Android | Samsung A11 nối Supabase local | 1/1 đạt; Mailpit, offline gateway/reconnect, A/B; Cloud email thật còn chờ |
| Video M2 2–3 phút | Ghi hình và link khớp mã nguồn | Chưa quay |
| iOS | Xcode/thiết bị | Chưa chạy |

Nguồn SQL và connected SDK: [job database của run 40790854357](https://github.com/bunly-app/bunly/actions/runs/40790854357/job/123175421943), commit chức năng nêu trên. Log xác nhận `Files=1, Tests=39`, `Result: PASS`, và `1 test passed` ở bước connected. Setup tạo hai tài khoản đã xác nhận bằng admin local; chưa kiểm tra người dùng tự mở email xác nhận.

Các test remote giả lập kiểm chứng: mất mạng giữ queue; timeout sau remote commit retry không trùng; acknowledgment cũ không xóa thao tác mới; pull không ghi đè pending edit; session đổi giữa request ngừng gửi tiếp; không xóa note của user khác; transaction rollback và migration v1 giữ note/outbox. Chúng không thay thế kết quả Supabase thật.

[Run CI 40790854357](https://github.com/bunly-app/bunly/actions/runs/40790854357) đã hoàn tất thành công cả job flutter và database cho commit 6449a269b2944c5c6ccd64b467146c2071fee688. Job flutter xác nhận codegen không lệch Git, format, analyze, 24 test và build APK.

## APK và log local

- APK demo gốc: `build/m2-artifacts/bunly-m2-demo-debug.apk` (giữ riêng để test APK không ghi đè).
- Kích thước: 154213878 bytes.
- SHA256: `E0EF92D4CE5EFFAECF28AF1B8FCAD0AC61D102A896418AA5816895109FFEE7BC`.
- Chế độ: demo, phiên bản 0.1.0+1, debug. App dùng assets/SQLite; không có cấu hình hosted riêng và không chứng minh kết nối tài khoản.
- Log local: `build/m2-evidence/codegen.log`, `format.log`, `analyze.log`, `flutter-test.log`, `android-integration.log`.
- Thư mục build bị Git ignore; nhật ký công khai tái lập được lấy từ Actions/PR. Không đưa token hoặc cấu hình local vào báo cáo.

CI đã được bổ sung upload APK thành artifact `bunly-m2-demo-debug` ở lần workflow tiếp theo. Chỉ dùng link run có artifact thực tế sau khi bước upload đạt; chưa tạo release/tag nghiệm thu.

## Môi trường local và cách xử lý

- Flutter mặc định máy là 3.47.5. Đã chuẩn bị SDK 3.35.7 riêng tại D:/SDK/flutter-3.35.7; không thay pin trong repo hoặc nâng package để vượt lỗi.
- Docker Desktop ban đầu không khởi động do lỗi runtime socket dockerInference; engine pipe không sẵn sàng. Đã giữ bản sao thư mục runtime tại C:/Users/LENOVO/AppData/Local/Docker/run.bunly-backup-20261029063747, không xóa volume/VHDX hoặc factory reset. Trong phiên kiểm thử bổ sung cùng ngày, Docker hoạt động lại và toàn bộ SQL/connected Android đã chạy với Supabase local.
- Build Flutter chọn JDK Android Studio 25 không tương thích Gradle hiện tại; dùng wrapper với JAVA_HOME=JDK17 và GRADLE_USER_HOME cho riêng tiến trình. Kotlin có cảnh báo incremental cache khác ổ C/D và fallback; build cuối vẫn thành công.
- Khi chạy integration test, tạm chọn JDK17 qua Flutter config và gỡ lựa chọn sau lệnh bằng finally; không để thay đổi JDK toàn cục sau tác vụ.
- Samsung A11 đã kết nối và chạy cả demo lẫn connected integration. Máy ảo Bunly_M2 không lên trạng thái `device` trong lần thử lại; dữ liệu AVD cũ được giữ nguyên.

## Cổng nghiệm thu còn lại

1. Chạy checklist thao tác thủ công trên Android thật: Cloud signup/email, bàn phím Nhật, tắt Wi-Fi/data, force-stop, giao diện và nhiều thiết bị. Không suy các tình huống này từ mô phỏng ngắt API.
2. Hoàng tự quay video 2–3 phút; kiểm tra quyền truy cập link, bản app và SHA được quay.
3. Chốt báo cáo, branch/SHA/tag; chỉ tạo milestone-2 khi đủ FR-01–FR-06. Nếu nộp trước, giữ bảng thiếu bằng chứng đúng thực tế.

Kho hiện có 3 mẫu minh họa; mục tiêu nội dung MVP 80–120 mẫu chưa đạt. M3 tiếp tục OCR/AI, conflict đa thiết bị, benchmark và phần yêu cầu còn tồn đọng theo kế hoạch nhóm.

## Kiểm chứng bổ sung trên checkout hiện tại — 29/10/2026

Checkout tại commit `b2533fd` cùng các thay đổi tài liệu chưa commit. Docker Desktop hoạt động trong lần chạy này; nhận xét Docker không khởi động ở trên là tình trạng của phiên kiểm thử trước.

| Lệnh | Kết quả vừa chạy |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test integration_test test_connected` | 40 file, 0 file đổi |
| `flutter analyze --no-pub` | No issues found |
| `flutter test --no-pub` | 24/24 đạt |
| `supabase start` | Local stack khởi động, áp migration và seed |
| `supabase db lint --local --level warning --fail-on warning` | No schema errors found |
| `supabase test db` | 39/39 đạt, Result: PASS |
| `flutter test test_connected/m2_connected_test.dart --no-pub --dart-define-from-file=config/m2-test.local.json` | 1/1 đạt với hai tài khoản local được xác nhận sẵn; Auth/API, push/pull và RLS thật |
| `flutter test integration_test/m2_connected_test.dart -d R9JN409P9RJ --no-pub --dart-define-from-file=config/m2-test.local.json` | 1/1 đạt trên Samsung A11 với Supabase local: đăng ký/email, thao tác học tập, ngắt cổng API, outbox, kết nối lại, đồng bộ và cách ly A/B |
| `flutter test integration_test/m2_demo_test.dart -d R9JN409P9RJ --no-pub --dart-define-from-file=config/demo.example.json` | 1/1 đạt trên Samsung A11 với asset và SQLite thật |

Lần chạy connected SDK đầu dùng cấu hình dành cho kịch bản đăng ký mới nên tài khoản A chưa tồn tại, trả `invalid_credentials`. Đã tạo lại đúng hai tài khoản local đã xác nhận và chạy lại đạt. Đây là lỗi tiền điều kiện test, không phải bằng chứng app đăng nhập sai.

Lần chạy Android connected đầu dừng ở `HttpException` trong hàm `reachable()` của test khi cắt API; test mới bắt `SocketException` và timeout. Đã bắt thêm `HttpException`, chuẩn bị tài khoản thử mới rồi chạy lại toàn bộ và đạt. Email xác nhận được lấy từ Mailpit local, không dùng SMTP Cloud. Mô phỏng offline chỉ dừng gateway Supabase local, không thay thế kiểm thử tắt Wi-Fi/data thực tế. Bài test dùng Flutter test input và không kiểm chứng bàn phím thật. Sau mỗi lượt Android test, APK connected Cloud được cài lại trên điện thoại.

Project Cloud phát triển `bunly-dev` (`jbyxiihjqveqooenofsr`) đã áp migration và seed, có 6 bảng RLS cùng 18 policy; kiểm tra Cloud riêng ghi ở `../development/SUPABASE-CLOUD.md`. Chưa dùng tài khoản thật để chạy trọn luồng signup/email/sync trên Cloud. Lời mời thành viên Supabase Dashboard chưa được gửi; chủ project sẽ mời sau.
