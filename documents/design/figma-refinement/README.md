# Bunly — Figma refinement checkpoint

Ngày 31/10/2026. **Chưa hoàn thành prototype.**

File: https://www.figma.com/design/mxdRi5kb1GYX6AyCLbGZ4D/Bunly?node-id=13-2

## Trạng thái đã xác nhận

- Plugin đã dùng tài khoản chủ sở hữu đúng. Session chỉnh sửa tạo thành công.
- Đã đọc cấu trúc 32 frame nguồn và nội dung 28 frame không trùng. Bốn frame trùng đã nhận diện qua cấu trúc; không coi là bốn màn khác.
- Đã xem screenshot nguồn: Hôm nay, Chi tiết ngữ pháp, Chọn phiên luyện tập, Đăng nhập.
- Trang nguồn được giữ nguyên nội dung, đổi tên thành `00 · Stitch — bản gốc`.
- Đã tạo `01 · Bunly — Prototype` (page 13:2) với **22 frame**, theo kết quả trả về từ các lệnh ghi Figma.
- Đã tạo `02 · Bunly — UI Kit` (page 13:3): 30 icon Lucide chính thức, 19 token ngữ nghĩa/kích thước, 11 primitive màu, 6 text style. Dùng lại Button và Navigation Bar của Material 3.
- Màn Hôm nay đã kiểm tra screenshot và sửa: badge bị cắt, nền tím còn sót trong Content của Material button, chiều cao nút và màu selected indicator. Screenshot sau sửa hiển thị đúng.
- **21 màn còn lại mới có bằng chứng cấu trúc, chưa kiểm tra ảnh.**
- **Chưa ghi bất kỳ prototype reaction nào.** 103 vị trí gắn tương tác trong STATE.json mới là dữ liệu chờ.
- Không sửa code Flutter, Supabase hoặc cấu hình tài khoản. Không commit.

## Chặn hiện tại

Sau batch ghi thứ hai, Figma trả về:
> You've reached the Figma MCP tool call limit on the Starter plan.

Lệnh whoami sau đó xác nhận tài khoản thuộc plan Starter. Không biết thời gian mở lại hạn mức; không tự nâng gói hoặc dùng tài khoản khác để lách giới hạn.

## Hướng giao diện đã áp dụng

390 × 844; nền #F7F9F6; surface trắng; primary #1F6840; Noto Sans cho tiếng Việt, Noto Sans JP cho câu Nhật. Dùng nguyên câu Nhật thay vì các ký tự/ruby rời gây vỡ layout. Nội dung cuộn trong viewport, header và bottom nav là các phần riêng. 4 root tab: Hôm nay / Tra cứu / Sổ học / Tiến độ. Detail/focus không có bottom nav. Button 48px, radius 12; card radius 16; padding màn 20.

Không đem thông số kỹ thuật, mã route hoặc giả định bảo mật vào nội dung sản phẩm. Không bịa nguồn sách/trang, phần trăm OCR hay kết quả dịch vụ. Dữ liệu thiết kế được ghi là minh họa. Không đánh đồng tự đánh giá, kết quả độc lập, gợi ý và nhận xét AI.

## Nội dung đã chuẩn hóa

- Home: ưu tiên mẫu đến hạn, sau đó quét câu, học tiếp.
- Capture/OCR: kiểm tra văn bản trước phân tích; không nhận định ngữ pháp ở bước OCR.
- Grammar: cấu trúc Vた + ことがある; câu và bản dịch liền mạch, không có nguồn giáo trình chưa xác minh.
- Progress: 12 mẫu N5 đã lưu, gồm 4 đã nắm + 5 đang học + 3 cần ôn; khớp với notebook 18 mục gồm 12 N5 + 6 N4.
- History/progress baseline: 32 quiz + 12 dịch + 4 voice = 48 bài; quiz 24/32 đúng lần đầu = 75%, 6 đúng sau hỗ trợ, 2 còn sai.
- Phiên 6 câu: 1 MCQ + 2 điền khuyết + 1 typing + 1 dịch + 1 voice. 4 câu chấm theo đáp án, 2 câu AI góp ý riêng.
- Cho phép cả に và へ trong 日本に/へ行ったことがあります.

## Tiếp tục từ đâu

1. Đọc STATE.json và helpers.js. Dùng lại sessionId khi còn hợp lệ. Gọi whoami nếu có lỗi quyền/hạn mức. Không tạo trùng các màn đã có.
2. Dùng use_figma read-only kiểm tra page 13:2 và ID trong STATE; xem screenshot search, grammar, setup, translation. Chỉ sửa điều thực tế bị lỗi.
3. Hoàn thành các target chưa có: `profile`, `search-results`, `grammar-prohibition`, `grammar-obligation`, `errors`, `history`, `analysis-loading`, `draft-saved`, `learning-status`, `note-saved`, `session-source`, `voice-ready`, `mcq-hint`, `cloze-retry`, `cloze-2-feedback-wrong`, `translation-hint`, `translation-loading`.
4. Bổ sung translation-feedback/retry; voice-ready → recording → transcript-confirm → voice-loading → voice-feedback → retry/compare; summary; errors; history.
5. Bổ sung Auth: login, submitting, login-error, signup, confirm-email, forgot/sent/reset/success, onboarding; profile/settings/logout confirmation. Không dùng email thật hoặc password thật trong mockup.
6. Hoàn thiện loading: bootstrap và lỗi/try-again; AI loading và retry/cancel giữ draft; skeleton search/notebook/progress lần đầu; refresh khi có cache giữ dữ liệu. Trạng thái rỗng và lỗi tách biệt. Guide spinner kỹ thuật đặt UI Kit, không nằm trong root app.
7. Liên kết 103 action chờ cộng action màn mới bằng setReactionsAsync. Các callback onClick rõ đích; Back cần bảo toàn nguồn (BACK hoặc các detail variant tùy ngữ cảnh). Root tabs chuyển đúng và active tương ứng. Đang ghi không tự chấm âm thanh, transcript cần xác nhận trước AI.
8. Tạo flowStartingPoints: hành trình chính từ Home; Auth từ Login; Voice từ voice-ready; Loading từ bootstrap.
9. Kiểm tra mọi destination tồn tại, không link vào nguồn; mọi màn đạt viewport, không có glyph mất/overflow nội bộ, CTA chạm được; chạy xuyên luồng trong Presentation nếu công cụ cho phép. Screenshot kiểm tra toàn bộ nhóm.
10. Chỉ báo hoàn thành sau bằng chứng cấu trúc và ảnh sau sửa. Không coi syntax-check script là kiểm chứng canvas.

## Tệp trong checkpoint

- STATE.json: ID trang/màn/icon/token/style thật và 103 action đang chờ. Không phải nguồn dữ liệu ứng dụng.
- helpers.js: helper cho use_figma, đọc page 13:2 và dùng những component đã import. Đây là đoạn mã cần nối với một batch dựng màn; không chạy trực tiếp bằng Node hoặc import như plugin native.
- NEXT.md: hợp đồng hoàn thiện màn và tương tác.

## Lưu ý kỹ thuật

- Figma MCP API mở rộng có createAutoLayout, screenshot; các helper không phải plugin Figma native.
- Import Material đã trả về button Content màu tím riêng và nav height=12; phải override Content và sizing như helper. Không detach instance.
- Các script ghi trả createdNodeIds bao gồm node con; ID descendants trong instance có dạng I…; không suy đoán ID.
- Helpers dùng một page switch mỗi lệnh, load current font trước thay đổi text, alias token và text styles đã có.
- Khối next batch phải trả mapResult(); gộp screens/actions vào STATE ngay sau lệnh thành công.

