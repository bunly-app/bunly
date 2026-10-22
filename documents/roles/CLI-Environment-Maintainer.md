# Vai trò: phụ trách CLI và môi trường phát triển

Vai trò dùng chung cho thành viên phụ trách công cụ hoặc trợ lý lập trình khi được giao việc về môi trường. Mục tiêu là để người mới clone repository có thể chạy demo, kết nối backend và thực hiện kiểm thử theo cùng một hướng dẫn. Vai trò không tự gán cho một thành viên cụ thể.

## Đầu vào cần đọc

- [Hướng dẫn thiết lập](../development/GETTING_STARTED.md).
- [PRD M2](../planning/PRD-M2-Architecture-Base.md) và `AGENTS.md` tại gốc repository.
- Phiên bản trong `.flutter-version`, `pubspec.lock`, `package.json` và `package-lock.json`.

## Trách nhiệm và đầu ra

| Trách nhiệm | Đầu ra phải kiểm chứng |
|---|---|
| Flutter/Dart, Node, Supabase CLI | Lệnh cài đặt theo từng hệ điều hành, phiên bản pin và lệnh kiểm tra |
| Supabase local | `config.toml`, migration, seed, lint/RLS test và vòng đời start/stop |
| Supabase hosted dành cho phát triển | Cách nhập cấu hình client; xác nhận project đích trước khi link/push migration |
| Cấu hình app | File mẫu không chứa thông tin bí mật; file local bị Git bỏ qua; giải thích địa chỉ emulator/thiết bị |
| CI và cloud | Tách check không cần dịch vụ với check cần Docker/thiết bị; ghi đúng phần chưa chạy |
| Thêm dịch vụ/CLI mới | Ghi mục đích, phiên bản, nơi cài, network, cấu hình, start/stop, readiness và cách gỡ |

## Quy trình thực hiện

1. Đọc trạng thái Git; kiểm tra công cụ, tài nguyên và Docker daemon trước khi cài. Không suy luận cloud luôn thiếu CLI.
2. Dùng demo để kiểm tra UI/domain độc lập backend; dùng connected để kiểm tra Supabase thật. Không đổi nhãn kết quả giữa hai chế độ.
3. Dùng công cụ pin trong repository (`npm ci`, `npm run supabase -- ...`); không cài Supabase CLI toàn cục bằng npm.
4. Thử thay đổi bằng local Supabase hoặc project kiểm thử đã được chỉ định. `db reset --local` xóa DB local, phải báo rõ trước khi dùng với dữ liệu của người khác.
5. Kiểm tra RLS qua vai trò authenticated và ít nhất hai chủ sở hữu; không lấy service-role làm bằng chứng cách ly.
6. Ghi lệnh đã chạy, kết quả, giới hạn và cách tái lập. Không đưa token/giá trị bí mật vào log, commit hoặc chat.
7. Cập nhật hướng dẫn và lockfile liên quan trong cùng thay đổi. Nếu công cụ mới cần cấu hình thì thêm file example và quy tắc ignore trước khi dùng.

## Cloud Codex

CLI có thể chạy trên cloud nếu có binary, quyền và kết nối mạng phù hợp. Supabase local cần Docker daemon, dung lượng tải image và khả năng mở kết nối giữa container. Android cần SDK và thiết bị/emulator; iOS cần macOS/Xcode. Có Flutter CLI không đồng nghĩa đã chạy được mọi nền tảng.

Khi một khả năng bị chặn, tiếp tục công việc độc lập: domain/widget test, migration review, tài liệu và demo. Ghi chính xác tác vụ bị chặn và phụ thuộc còn thiếu; không tắt TLS/checksum và không tự chuyển sang backend production để vượt lỗi.
