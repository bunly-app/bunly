# Bunly

**Bunly** là dự án ứng dụng đa nền tảng giúp người Việt học và tra cứu ngữ pháp tiếng Nhật từ nội dung thực tế.

Ý tưởng cốt lõi: người học chụp hoặc tải ảnh, hay dán một câu tiếng Nhật; ứng dụng nhận dạng văn bản, phân tích cấu trúc ngữ pháp, giải thích bằng tiếng Việt và hỗ trợ lưu lại để luyện tập, ôn tập.

Nền ứng dụng M2 dùng **Flutter/Dart, Riverpod, Drift/SQLite và Supabase**. Bản triển khai M2 có tra cứu, hồ sơ, lưu mẫu, CRUD ghi chú, tiến độ và worker đồng bộ một thiết bị. Demo dùng asset/SQLite; connected dùng Auth/API. Trạng thái nghiệm thu được ghi riêng trong báo cáo và biên bản kiểm chứng.

```sh
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```

Dùng Flutter **3.35.7** theo `.flutter-version`; chọn thiết bị bằng `flutter devices`.

- [PRD tổng thể: bản cơ bản đầy đủ chức năng và tiêu chí nghiệm thu](documents/planning/PRD-BUNLY-Full-Function-Baseline.md).
- [Bảng hạ tầng hiện tại, dịch vụ và cấu hình cần thiết lập](documents/development/INFRASTRUCTURE-SETUP-MATRIX.md).
- [Phân công Hoàng / Ánh / Vy, giao việc agent và bàn giao baseline](documents/planning/BASELINE-DELIVERY-OWNERSHIP.md).
- [Kết quả rà baseline A00 ngày 09/11/2026 và phạm vi A02/A03 tiếp theo](documents/reports/A00-Baseline-Audit-2026-11-09.md).
- [Contract tích hợp v1 và fixture B0 chờ duyệt](documents/development/BASELINE-INTEGRATION-CONTRACTS.md).
- [Bàn giao A02/A03-01: code, kiểm chứng và cách chia hai chat](documents/reports/A02-A03-01-Delivery-2026-11-09.md).
- [Thiết kế Figma của dự án Bunly](https://www.figma.com/design/39hHCJ2CmxZNbe5NAUd6sA/Bunly?node-id=0-1). Liên kết do người dùng cung cấp ngày 09/11/2026, dùng làm nguồn tham chiếu giao diện.
- [Dữ liệu nền môn học: kiến thức Week 09–13, rubric và checklist capstone](CROSS_PLATFORM_CAPSTONE_KNOWLEDGE_PACK.md). Tài liệu tham khảo để lập kế hoạch và đối chiếu yêu cầu; không phải bằng chứng nghiệm thu Bunly. Các prompt mẫu không tự động mở rộng phạm vi công việc.
- [Thiết lập Flutter, CLI, Supabase local/hosted và kiểm thử](documents/development/GETTING_STARTED.md).
- [Nền kiến trúc hiện có, giới hạn và thứ tự phát triển tiếp](documents/development/ARCHITECTURE.md).
- [Vai trò phụ trách CLI và môi trường cho nhóm](documents/roles/CLI-Environment-Maintainer.md).
- [PRD để hoàn thiện M2](documents/planning/PRD-M2-Architecture-Base.md).
- [Báo cáo 2 cập nhật](documents/reports/Capstone-Report-2-Architecture.md).
- [Danh mục đủ 5 template báo cáo gốc](documents/reports/templates/README.md).
- [Biên bản kiểm chứng M2](documents/reports/M2-Verification-2026-10-29.md).
- [Bản xem trước báo cáo 2](documents/reports/Capstone-Report-2-Architecture-Preview.md).

M2 chỉ được nghiệm thu sau khi các tiêu chí bắt buộc có bằng chứng; xem các mục còn thiếu trong biên bản kiểm chứng. Xem kết quả đã chạy và các mục chưa xác minh trong tài liệu kiến trúc trước khi ghi nhận tiến độ hoặc tạo tag mốc.
