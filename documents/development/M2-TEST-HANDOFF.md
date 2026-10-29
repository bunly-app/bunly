# M2 — Bàn giao kiểm thử bổ sung cho nhóm

Ngày: 29/10/2026. Video do Hoàng tự quay; ghi hình không phải điều kiện để bộ test tự động đạt. Không đánh dấu một dòng đã đạt nếu chưa tự chạy và lưu bằng chứng.

## 1. Bộ kiểm thử tự động

| Bộ | Lệnh/phạm vi | Bằng chứng |
|---|---|---|
| Unit/repository/widget | `flutter test`; validation, SQLite transaction/rollback, migration v1→v2, CRUD, owner/session, retry và stale ack/pull | 24 test đạt; xem biên bản kiểm chứng và Actions của SHA đang review |
| SQL/RLS | `npm run db:lint`, `npm run db:test` trên local stack | 39 SQL test đạt ở các run đã ghi nhận |
| SDK connected | `flutter test test_connected/m2_connected_test.dart --dart-define-from-file=config/m2-test.local.json` | Auth/API thật, DB reopen, push/pull, sửa/xóa, hai tài khoản; chạy riêng với user thử |
| Android demo | `flutter test integration_test/m2_demo_test.dart -d <device-id> --dart-define-from-file=config/demo.example.json` | Assets/SQLite thật; hồ sơ, lưu mẫu, trạng thái, tạo/sửa note; đã đạt trên emulator Android 15 |
| Android connected | Workflow `M2 connected Android` | Bản mở rộng có đăng ký/email local, cache khi API ngắt, ghi local/outbox, kết nối lại và A/B; đọc kết quả run mới trước khi nhận đạt |

Ghi rõ SHA/run URL. Bộ 24 test mặc định không tự chạy suite SDK/Android. Test nhập văn bản dùng Flutter test input để tránh IME ghi đè thao tác tự động; SQLite, plugin Android và Supabase adapter vẫn chạy thật. Vì vậy bàn phím thật còn thuộc kiểm thử thủ công.

Kịch bản outage trong CI tạm dừng **cổng API Supabase local 35 giây**, giữ database, rồi khởi động lại. Đây là mô phỏng backend không truy cập được; không chứng minh mọi hành vi chuyển Wi-Fi/4G hoặc chế độ máy bay. Server điều khiển chỉ bind loopback trên runner và yêu cầu token test; không triển khai lên hosted.

## 2. Checklist cần bạn trong nhóm chạy thêm

Người kiểm thử dùng Android thật và backend phát triển được nhóm chỉ định. Dùng hai tài khoản A/B dành riêng cho kiểm thử. Không gửi token, mật khẩu hoặc service-role key trong ảnh/log/issue.

| ID | Các bước cần chạy | Điều kiện đạt | Trạng thái ban đầu |
|---|---|---|---|
| M2-MANUAL-01 | Đăng ký email mới, mở email xác nhận, đăng nhập; thử sai mật khẩu/email chưa xác nhận | Phản hồi dễ hiểu, không vào trang riêng khi chưa có phiên hợp lệ | Chưa chạy trên điện thoại thật |
| M2-MANUAL-02 | Đăng nhập A → đóng app/force-stop → mở lại; lặp sau khi để app nền lâu | Khôi phục phiên hợp lệ, không nhấp nháy nội dung tài khoản khác; hết phiên có phản hồi phù hợp | Chưa chạy trên điện thoại thật |
| M2-MANUAL-03 | Hồ sơ: tên/mục tiêu, N5/N4, phút học 1/1440; thử 0, 1441, rỗng, chuỗi không phải số | Lưu/đọc lại đúng; input lỗi không được lưu; đổi tài khoản không lẫn hồ sơ | Chưa chạy |
| M2-MANUAL-04 | Tìm/lọc đồng thời; tìm tiếng Nhật/Việt; tìm không có kết quả; đổi bộ lọc nhanh | Kết quả và trạng thái rỗng đúng, không treo hoặc lỗi layout | Chưa chạy |
| M2-MANUAL-05 | Dùng bàn phím Gboard/IME Nhật thật; tạo/sửa/hủy/xóa ghi chú, emoji, nhiều dòng, ghi chú dài | Không bị ghi đè nội dung khi focus/scroll; đúng note ID; lỗi lưu không xóa nội dung đang soạn | Chưa chạy |
| M2-MANUAL-06 | Lưu/bỏ lưu lặp; chuyển đủ 4 trạng thái; lọc đã lưu; mở lại app | Không trùng; số đếm khớp các mẫu trong catalog đang tải; dữ liệu bền | Chưa chạy |
| M2-MANUAL-07 | Online tải kho → bật máy bay/tắt Wi-Fi và data → force-stop/mở app → đọc chi tiết và ghi chú | Nội dung đã tải vẫn đọc được; thay đổi cá nhân lưu trên máy, không báo đã sync giả | Chưa chạy mạng thiết bị thật |
| M2-MANUAL-08 | Offline tạo/sửa/xóa liên tiếp → reconnect → Đồng bộ → bấm lại; đối chiếu Supabase | Không mất/trùng; tombstone đúng; pending hết sau thành công; API lỗi còn giữ queue | Chưa chạy mạng thiết bị thật |
| M2-MANUAL-09 | A có pending → logout → B → mở các trang riêng; đổi phiên khi request đang gửi | B không thấy note/hồ sơ/progress của A; queue A không gửi bằng phiên B; vào lại A vẫn xử lý được queue | Chưa chạy trên điện thoại thật |
| M2-MANUAL-10 | Màn nhỏ, font hệ thống lớn, dark mode; mở bàn phím, xoay màn hình và back nhanh | Không overflow, nút thao tác chạm được, chữ Nhật rõ, không callback lên màn đã đóng | Chưa chạy |
| M2-MANUAL-11 | Hai thiết bị sửa cùng note hoặc edit-vs-delete | Ghi lại kết quả/rủi ro; **chưa nhận hỗ trợ hợp nhất xung đột nhiều thiết bị ở M2** | Theo dõi cho M3 |

Không cần tất cả thành viên chạy mọi case. Hoàng chuẩn bị cấu hình/test account và hỗ trợ sync/Auth; Ánh kiểm tra luồng kỹ thuật, dữ liệu và tái hiện lỗi; Vy kiểm tra luồng người dùng, câu chữ, bàn phím và giao diện. Mỗi case chỉ có một người chịu trách nhiệm ghi kết quả trước khi người khác review.

## 3. Mẫu ghi kết quả

```text
Case ID:
Người chạy / ngày giờ:
Branch / SHA / APK hash:
Model / Android / keyboard / mode demo hoặc connected:
Backend thử nghiệm (tên môi trường, không ghi key):
Tiền điều kiện và dữ liệu:
Các bước:
Mong đợi:
Thực tế: PASS / FAIL / BLOCKED / CHƯA CHẠY
Ảnh/video/log đã loại dữ liệu nhạy cảm:
Bug / mức ảnh hưởng / người tiếp nhận:
```

Lỗi mất dữ liệu, lẫn tài khoản, queue bị xóa khi chưa gửi, app crash hoặc false-success đồng bộ phải được xử lý trước khi nghiệm thu. Lỗi UX ghi rõ bước tái hiện và ảnh, tránh nhận xét chung chung.

## 4. Giới hạn phải giữ trong báo cáo

- Kho hiện có 3 mẫu minh họa; chưa đạt mục tiêu nội dung MVP 80–120 mẫu.
- Chưa kiểm chứng iOS, mọi loại mạng, app bị hệ điều hành kill giữa request, hoặc conflict đa thiết bị.
- Worker M2 chạy khi app/màn kho còn hoạt động, khi foreground và khi người dùng bấm Đồng bộ; không hứa tác vụ nền sau khi app bị đóng.
- Bài làm/accuracy/lịch ôn, OCR/LLM và hạn mức AI thuộc phần phát triển tiếp; số liệu template M3 không phải kết quả thực đo.
- Hoàng bổ sung video 2–3 phút và link sau khi tự quay; không dùng demo asset để minh họa một thao tác Supabase thật mà không ghi rõ mode.

Nguồn trạng thái mới nhất: [biên bản kiểm chứng](../reports/M2-Verification-2026-10-29.md) và [báo cáo M2](../reports/Capstone-Report-2-Architecture.md).
