# Bunly

**Bunly** là dự án ứng dụng đa nền tảng giúp người Việt học và tra cứu ngữ pháp tiếng Nhật từ nội dung thực tế.

Ý tưởng cốt lõi: người học chụp hoặc tải ảnh, hay dán một câu tiếng Nhật; ứng dụng nhận dạng văn bản, phân tích cấu trúc ngữ pháp, giải thích bằng tiếng Việt và hỗ trợ lưu lại để luyện tập, ôn tập.

Nền ứng dụng M2 dùng **Flutter/Dart, Riverpod, Drift/SQLite và Supabase**. Bản triển khai M2 có tra cứu, hồ sơ, lưu mẫu, CRUD ghi chú, tiến độ và worker đồng bộ một thiết bị. Demo dùng asset/SQLite; connected dùng Auth/API. Trạng thái nghiệm thu được ghi riêng trong báo cáo và biên bản kiểm chứng.

```sh
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```

Dùng Flutter **3.35.7** theo `.flutter-version`; chọn thiết bị bằng `flutter devices`.

- [Thiết lập Flutter, CLI, Supabase local/hosted và kiểm thử](documents/development/GETTING_STARTED.md).
- [Nền kiến trúc hiện có, giới hạn và thứ tự phát triển tiếp](documents/development/ARCHITECTURE.md).
- [Vai trò phụ trách CLI và môi trường cho nhóm](documents/roles/CLI-Environment-Maintainer.md).
- [PRD để hoàn thiện M2](documents/planning/PRD-M2-Architecture-Base.md).
- [Báo cáo 2 cập nhật](documents/reports/Capstone-Report-2-Architecture.md).
- [Biên bản kiểm chứng M2](documents/reports/M2-Verification-2026-10-29.md).
- [Bản xem trước báo cáo 2](documents/reports/Capstone-Report-2-Architecture-Preview.md).

M2 chỉ được nghiệm thu sau khi các tiêu chí bắt buộc có bằng chứng; xem các mục còn thiếu trong biên bản kiểm chứng. Xem kết quả đã chạy và các mục chưa xác minh trong tài liệu kiến trúc trước khi ghi nhận tiến độ hoặc tạo tag mốc.
