# Chỉ đạo mới nhất: sửa bản Stitch gốc

Ngày 31/10/2026. Người dùng yêu cầu sửa trực tiếp page `00 · Stitch — bản gốc` (0:1), giữ phong cách Stitch hiện có và nối màn để Present. Không tiếp tục dựng bản thay thế trên page 13:2.

## Trạng thái thực tế

- Đã thử lại use_figma: vẫn lỗi Starter MCP call limit.
- whoami vẫn đúng chủ sở hữu. Đây là hạn mức, không phải lỗi quyền.
- Có thể điều khiển tab Bunly Figma đang mở trong Chrome qua giao diện Windows.
- Đã tìm Scripter của Rasmus trên Figma Community (42.9k users), mở trang thông tin; chưa bấm Run hoặc Save.
- Scripter chưa nằm trong danh sách plugin gần đây. Trước khi chạy lần đầu cần xử lý xác nhận theo computer-use confirmations.
- Chưa thay đổi UI hoặc prototype trên bản Stitch gốc trong lượt này.

## Cách tiếp tục

1. Sau khi có xác nhận chạy Scripter, mở plugin từ trang thông tin hiện tại, không tự nâng gói Figma.
2. Chạy source-audit.js bằng native Plugin API để đọc layout/hierarchy đang có; không dùng helper MCP có createAutoLayout/screenshot trong native plugin.
3. Sửa tại chỗ, tải font trước khi đổi text. Giữ hình ảnh và bố cục Stitch, xử lý vùng mất chữ và line break bất thường.
4. Đưa annotation kỹ thuật ra khỏi màn sử dụng; không xóa nội dung không liên quan.
5. Thống nhất 4 tab Home/Search/Notebook/Progress, cùng logo, Noto Sans/Noto Sans JP, icon22–24 và vùng chạm48, button radius12.
6. Sửa các lỗi đã có bằng chứng: title OCR/history sai; route Sxx trong button; phiên6 so với8 câu; 48 so với60 tổng bài; điểm sau gợi ý bị gọi độc lập; ngữ pháp N5/N4 không nhất quán; nguồn sách và OCR99% chưa xác minh; login đồng thời nút thường/loading; signup lộ mật khẩu giả; thông số backend và bảo mật thừa.
7. Tách câu hỏi/feedback và trạng thái thu âm/chờ/hoàn tất để tương tác không gây hiểu nhầm. Có thể dùng các frame trùng của quiz để tạo before/after.
8. Nối navigation và back theo đúng nguồn. Thêm frame thiếu trong cùng page gốc khi cần cho ghi chú, xác nhận email, nhập tay, lỗi và trạng thái tải.
9. Root viewport390x844, giữ content cuộn và header/nav cố định sau kiểm tra native hierarchy. Tránh resize mù làm hỏng Auto Layout.
10. Tạo flow Home, Auth, Voice; chạy Present kiểm tra đường đi và screenshot sau sửa trước báo hoàn tất.

## Đích flow chính hiện có

| Flow | Node nguồn → đích |
|---|---|
| 4 root tab | Home 9:2 · Search 9:378 · Notebook 9:3337 · Progress 9:3853 |
| Câu thật | Home → OCR 9:3200 → Analysis 9:234 → Grammar 9:579 → Notebook |
| Ôn tập | Home/Grammar → Setup 9:1871 → MCQ 9:2265 → Cloze 9:2105 → Translation 9:1606 → Translation feedback 9:810 → Voice 9:1438 → Transcript 9:1729 → Voice feedback 9:971 → Summary 9:2405 |
| Lịch sử/lỗi | Progress/Summary → Errors 9:1159 / History 9:3665 → đúng feedback |
| Auth | Bootstrap 9:4265 → Login 9:4115 ↔ Signup 9:4177; thêm xác nhận email, không signup thẳng Home |
| Loading | Bootstrap timeout 9:4323 · AI/OCR loading 9:4614 · Search skeleton 9:4745 · Notebook skeleton 9:4857 · Progress skeleton 9:5046 · Cache 9:5184 |

Các ID trên đã được đọc từ file nhưng cần kiểm tra tồn tại trước ghi. Không coi bảng này là connection đã tạo.
