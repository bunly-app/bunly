# Bunly

**Bunly** là dự án ứng dụng đa nền tảng giúp người Việt học và tra cứu ngữ pháp tiếng Nhật từ nội dung thực tế.

Ý tưởng cốt lõi: người học chụp hoặc tải ảnh, hay dán một câu tiếng Nhật; ứng dụng nhận dạng văn bản, phân tích cấu trúc ngữ pháp, giải thích bằng tiếng Việt và hỗ trợ lưu lại để luyện tập, ôn tập.

Nền ứng dụng M2 dùng **Flutter/Dart, Riverpod, Drift/SQLite và Supabase**. Base có demo tra cứu ngữ pháp và lưu ghi chú cục bộ; chế độ connected có adapter Auth/API. Hồ sơ, lưu mẫu, tiến độ và worker đồng bộ tiếp tục theo kế hoạch M2.

```sh
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```

Dùng Flutter **3.35.7** theo `.flutter-version`; chọn thiết bị bằng `flutter devices`.

- [Thiết lập Flutter, CLI, Supabase local/hosted và kiểm thử](documents/development/GETTING_STARTED.md).
- [Nền kiến trúc hiện có, giới hạn và thứ tự phát triển tiếp](documents/development/ARCHITECTURE.md).
- [Vai trò phụ trách CLI và môi trường cho nhóm](documents/roles/CLI-Environment-Maintainer.md).
- [PRD để hoàn thiện M2](documents/planning/PRD-M2-Architecture-Base.md).
- [Bản xem trước báo cáo 2](documents/reports/Capstone-Report-2-Architecture-Preview.md).

Base chưa đạt nghiệm thu toàn bộ M2. Xem kết quả đã chạy và các mục chưa xác minh trong tài liệu kiến trúc trước khi ghi nhận tiến độ hoặc tạo tag mốc.
