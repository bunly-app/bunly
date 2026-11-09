# Bàn giao UI-first trên Samsung A11 — 09/11/2026

Đã đọc flutter.json và A03-UI-First-2026-11-09.md, nhận lease rồi build/cài trên **Samsung A11 SM-A115F thật, Android 12/API31**, màn 720×1560, giao diện dark theo hệ thống. Không sửa source Flutter, pubspec/lockfiles hoặc schema; không reset/uninstall/clear dữ liệu.

## Bản đã cài

- Working tree chưa commit trên HEAD `3ae5be9625edaa3a761253a4e578daa416a97322`; manifest **65 file** đầu vào không đổi suốt lượt build. Không coi đây là CI của HEAD thuần.
- APK cuối: `build/app/outputs/flutter-apk/app-debug.apk`, **172283456 byte**, SHA256 `3DA4A8DEEDAB8EB6CE2F3CAF3C7875180E86F26AC5128703A2689E2251849360`.
- `adb install -r` thành công; package readback lastUpdateTime **17:37:23**, version 0.1.0/code 1. App được để mở ở tab **Sổ học**. Vẫn là debug/demo, chưa phải release/connected/AI thật.
- Sổ học còn **1 mẫu đã lưu + 1 ghi chú**, đúng text cũ: `DEMO: Ghi chu luu tren dien thoai that.`. Nhật–Việt và ví dụ hiển thị được; không thêm/sửa/xóa ghi chú trong lượt này.

## Kiểm tra nhanh thực tế

| Màn | Quan sát trên A11 |
|---|---|
| Hôm nay | Header/mode pill, mục tiêu N5, CTA mở kho và card khám phá hiện được; không còn heading bị cắt như vị trí scroll của ảnh cũ |
| Tra cứu | Chip Tất cả/N5/N4 và nhóm cuộn ngang; N4 có 1 mẫu, N5 có 2 mẫu; đã trả về Tất cả |
| Sổ học | Tổng 1 mẫu/1 ghi chú; card có ví dụ Nhật–Việt và trích ghi chú cũ, nút chi tiết hiển thị |
| Tiến độ | Các ô 0 đã nắm/0 đang học/0 cần ôn/3 mới, 0/3 đã bắt đầu; ghi rõ tự đánh giá và bài luyện chưa có |

Không thấy crash, overflow hoặc chữ Nhật–Việt lỗi trong bốn màn ở cỡ chữ/mode hiện tại. Đây là quick manual check, không chạy lại toàn bộ unit/widget suite đã có trong bàn giao Flutter; chưa thử light mode, mọi cỡ chữ, mọi dialog/filter hoặc xác nhận khớp toàn bộ Figma. Nút nổi bốn ô xuất hiện cả lúc splash đen, là overlay ngoài nội dung Flutter; không ghi thành lỗi UI Bunly.

## Lỗi/quan sát cần bàn giao

1. **Mở nguội chậm:** sau install/force-stop, `am start -W` timeout khoảng 10.6 giây; log Android ghi `Displayed/Fully drawn ... +14s501ms`, màn đầu chụp sớm còn đen. Sau đó UI mới hiển thị và điều hướng được. Đây là quan sát trên debug/A11; chưa đo profile/release, chưa quy cho diff UI. Luồng Flutter nên rà bootstrap/splash khi phù hợp, không kết luận crash hoặc regression từ timeout ADB đơn lẻ.
2. **Build cache cũ — đã xử lý trong luồng môi trường:** lượt đầu báo success 57s nhưng compileFlutterBuildDebug UP-TO-DATE và APK vẫn cùng hash A03-02 cũ. Không dùng artifact đó làm bằng chứng UI mới. Đã ép riêng task Flutter (45s), thêm init script `scripts/a01-flutter-inputs.gradle` khai báo input lib/assets/pubspec/plugin metadata, và nối vào script A01 cho riêng tiến trình. Build cuối **29s, exit 0**, task packageDebug chạy; APK hash đổi và màn UI mới được xác minh bằng ảnh thật. Không sửa SDK/Gradle toàn máy, không xóa cache. Lỗi theo dõi depfile Windows là nhận định từ SDK source + quan sát cache, chưa phải báo cáo upstream được xác nhận.

Evidence: `build/ui-first-device-2026-11-09/` (Git ignore), gồm build.log, force-flutter.log, build-final.log/result, apk-final.json, install-final.log, launch-final.log, manifest và ảnh home-ready/lookup/notebook/progress/filter-n4/filter-n5/notebook-final.png. Log lọc E/flutter/FATAL theo PID trong cửa sổ kiểm tra không có dòng lỗi. Không chứa key/API config; chưa upload artifact.

API/quota tiếp tục để sau theo ưu tiên người dùng. Kết quả này xác nhận bản bốn tab mới đã có trên A11 và giữ được dữ liệu kiểm tra đã biết; không nghiệm thu toàn UI/PRD. Bàn giao luồng Flutter các quan sát trên, không sửa Flutter từ chat môi trường.
