# Thiết lập và chạy Bunly

Đọc [PRD M2](../planning/PRD-M2-Architecture-Base.md) để biết phạm vi và tiêu chí nghiệm thu. Nền ứng dụng có hai chế độ: **demo** dùng dữ liệu mẫu và cơ sở dữ liệu cục bộ; **connected** dùng Supabase Auth/API cùng cơ sở dữ liệu cục bộ. Các dịch vụ chưa được kết nối phải ghi rõ trong tiến độ M2.

## 1. Công cụ

| Công cụ | Phiên bản/cách lấy | Kiểm tra |
|---|---|---|
| Flutter | `3.35.7` trong `.flutter-version`; cài theo [Flutter SDK](https://docs.flutter.dev/install) | `flutter --version`, `flutter doctor -v` |
| Dart | Đi cùng Flutter SDK; không cài bản riêng | `dart --version` |
| Node.js | 22 trở lên; dùng cho công cụ repository | `node --version` |
| Supabase CLI | Pin trong `package-lock.json`, cài bằng `npm ci` | `npm run supabase -- --version` |
| Docker | Docker Desktop trên macOS/Windows hoặc Docker Engine trên Linux; cần cho Supabase local | `docker info` |
| Thiết bị | Android SDK + emulator/điện thoại; iOS cần macOS/Xcode | `flutter devices` |

Node/Supabase/Docker không cần cho việc chạy demo Flutter. Trên Windows, dùng Git Bash hoặc WSL cho các script Bash; Docker Desktop phải bật integration nếu chạy trong WSL. Không commit cấu hình có đường dẫn riêng của máy.

## 2. Clone và chạy demo

```sh
git clone https://github.com/bunly-app/bunly.git
cd bunly
git switch feat/m2-architecture-base
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```

Chọn thiết bị từ `flutter devices` và thêm `-d <device-id>` khi cần. Demo chạy không cần tài khoản Supabase. Ghi chú/trạng thái demo lưu cục bộ, phân biệt với tài khoản backend. Không dùng demo để nghiệm thu xác thực/RLS/đồng bộ từ xa.

## 3. Supabase local

```sh
npm ci
npm run doctor
npm run db:start
```

Lần đầu tải nhiều Docker images. `supabase/config.toml` đã có trong repository; không chạy lại `supabase init`. CLI phải báo các dịch vụ sẵn sàng trước khi nối app. Để xem URL và client key trên máy của bạn, dùng `npm run supabase -- status`; không gửi toàn bộ output vào chat vì có thông tin nhạy cảm của môi trường local.

```sh
cp config/connected.example.json config/development.local.json
```

Sửa `SUPABASE_URL` và `SUPABASE_ANON_KEY` trong file local. Chỉ dùng anon/publishable key dành cho client; không dùng `service_role`, secret key hoặc access token. Giá trị Dart define được đóng gói vào app, không phải kho bí mật. `APP_MODE` phải là `connected`.

| Nơi app chạy | Supabase local URL thường dùng |
|---|---|
| Android emulator chuẩn | `http://10.0.2.2:54321` |
| iOS simulator cùng máy Mac | `http://127.0.0.1:54321` |
| Android qua USB và `adb reverse tcp:54321 tcp:54321` | `http://127.0.0.1:54321` |
| Điện thoại qua Wi-Fi | Địa chỉ LAN của máy chạy Docker; kiểm tra firewall, chỉ dùng mạng phát triển tin cậy |

HTTP local chỉ dùng trong debug. Android/iOS release giữ yêu cầu HTTPS; dùng URL HTTPS của project hosted khi build bản chia sẻ.

```sh
flutter run --dart-define-from-file=config/development.local.json
npm run db:lint
npm run db:test
npm run db:stop
```

Khi cần dựng lại dữ liệu kiểm thử từ migration và seed:

```sh
npm run db:reset
```

**Lệnh reset xóa dữ liệu Supabase local của project này.** Sao lưu dữ liệu cần giữ trước khi chạy. Migrations và seed có version trong Git; không chỉnh database qua Dashboard rồi bỏ quên migration.

## 4. Supabase hosted dành cho phát triển

Nếu không có Docker, vẫn có thể dùng demo hoặc kết nối một project Supabase phát triển riêng. Điền URL HTTPS và client key vào file `.local.json`. Đăng nhập Supabase CLI phục vụ quản trị chỉ cần khi quản lý project/migration; app không cần access token CLI.

Người phụ trách backend phải xác nhận project đích trước khi chạy `supabase link` hoặc `db push`. Không có script tự động đẩy migration hosted trong base. Migration và seed hiện tại phải được kiểm thử local trước; không chạy reset lên project dùng chung hoặc production.

## 5. Code generation và kiểm thử

```sh
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=config/demo.example.json
```

Commit file Drift `*.g.dart` đã sinh để thành viên mới mở dự án thuận tiện. Khi đổi schema, tăng schema version và viết migration trước khi dùng dữ liệu cũ. Unit/widget/Drift test không cần Supabase; SQL/RLS test cần local stack. App integration/E2E và thiết bị thật được ghi riêng trong báo cáo, không suy từ unit test.

## 6. Mở rộng công cụ và xử lý lỗi

- Làm theo [vai trò CLI/môi trường](../roles/CLI-Environment-Maintainer.md) khi bổ sung dịch vụ hoặc thay phiên bản.
- Lỗi tải Flutter/pub/image: kiểm tra proxy/allowlist, chứng chỉ và dung lượng. Giữ nguyên TLS và checksum; không dùng mirror không xác minh.
- Lỗi `connection refused`: kiểm tra dịch vụ sẵn sàng và địa chỉ theo thiết bị; localhost trên điện thoại không phải máy chạy Docker.
- Lỗi xác nhận email: kiểm tra cấu hình Auth của local/project phát triển và hộp thư kiểm thử; không tự tắt xác nhận trên project dùng chung.
- Trong cloud Codex, dùng checkout hiện có. Có thể chạy CLI nếu môi trường đáp ứng yêu cầu; kiểm tra Docker/SDK/mạng trước. Cloud Linux không build iOS.
- Nếu home directory của cloud chỉ đọc, cấu hình các thư mục ghi được ngoài checkout bằng `SUPABASE_HOME`, `PUB_CACHE`, `XDG_CONFIG_HOME` và `ANALYZER_STATE_LOCATION_OVERRIDE`. Ví dụ `SUPABASE_HOME=/workspace/.cache/supabase npm run supabase -- --version`; không đổi biến `HOME` và không đưa cache vào Git.
- Cấu hình không được commit: `config/*.local.json`, `.env*` (trừ example), token CLI và khóa quản trị. Khi chia sẻ lỗi, chỉ ghi tên biến và trạng thái hiện diện.

Xem [kiến trúc hiện tại và kết quả kiểm chứng](ARCHITECTURE.md) để phân biệt chức năng của base với mục tiêu M2. Ghi chú connected hiện lưu local và xếp outbox; worker đồng bộ, hồ sơ, lưu mẫu và tiến độ còn phải triển khai.
