# Bunly — Prompt đồng bộ giao diện, điều hướng, Auth và Loading

Ngày: 31/10/2026. Project đã xem lại: https://stitch.withgoogle.com/projects/6411575233905174817

Tài liệu bổ sung cho [brief gốc](BUNLY-UI-IDEA-STITCH.md), [Voice & Practice](BUNLY-STITCH-EXTENSION-VOICE-PRACTICE.md) và [review vòng 2](BUNLY-STITCH-REVIEW-ROUND2.md). Đây là yêu cầu thiết kế, không xác nhận tính năng đã triển khai.

## 1. Kết quả kiểm tra lại

Đã mở lại viewer và đọc nội dung frame sau lượt chỉnh sửa mới. S33 đã đổi tiêu đề “Nói một câu”, bỏ lời hứa chấm phát âm và thu gọn thao tác lúc ghi; S34 có tiêu đề “Kiểm tra lời nói”; S35 đã có nhãn dựa trên văn bản xác nhận. MCQ, điền khuyết, dịch và tổng kết đã sửa một phần tiêu đề/CTA.

Vẫn quan sát được các điểm sau, dù phần trả lời của Stitch nói đã sửa:

- S11 vẫn mang tiêu đề Chi tiết ngữ pháp, 99% khớp, nguồn sách và nhãn N4.
- S38 vẫn mang tiêu đề Chi tiết ngữ pháp.
- S27 vẫn liệt kê 4 MCQ + 2 điền + 1 dịch + 1 voice nhưng nút bắt đầu ghi 6 câu, header 03/06.
- S20 vẫn dùng tổng 48 câu nhưng nhóm là 44 quiz + 12 viết/dịch + 4 voice.
- S06/S08/S12/S37 vẫn có mã route Sxx trong một số nút; logo/app bar giữa 4 tab chưa cùng một mẫu.
- S31 vẫn có lời gợi nhắc thể た hiện sẵn ngoài nút mở gợi ý.
- Chưa thấy frame Login/Signup, bộ spinner/loading/skeleton, Auth/cài đặt hoàn chỉnh trong danh mục canvas đang xem. Chưa kiểm chứng prototype chuyển màn xuyên suốt.

Vì vậy, prompt dưới yêu cầu **frame thật và biến thể thật** thay cho bản tự báo cáo hoàn thành. Không cần thiết kế lại concept.

## 2. Quyết định thống nhất trước khi gửi prompt

“Thanh điều hướng gốc/sidebar” được hiểu là cùng một hệ đích điều hướng, đổi hình thức theo không gian:

| Ngữ cảnh | Shell | Quy tắc |
|---|---|---|
| Mobile, màn cấp gốc | Top app bar + bottom navigation | 4 mục cố định: Hôm nay / Tra cứu / Sổ học / Tiến độ. Không hamburger/sidebar trùng 4 tab. |
| Tablet có đủ không gian | Navigation rail | Cùng 4 đích, nhãn rõ; không hiện đồng thời bottom nav. |
| Desktop nếu thiết kế bản rộng | Sidebar | Cùng 4 đích; tài khoản/cài đặt ở khu phụ. Đây là biến thể mở rộng, mobile vẫn ưu tiên. |
| Trang chi tiết và cài đặt | Detail shell | Back + tên màn; giữ ngữ cảnh nơi mở. Ẩn root navigation trên trang sâu của mobile. |
| Camera, ghi âm, làm bài | Focus shell | Đóng/thoát + tên tác vụ + tiến trình nếu có; không avatar/hamburger/bottom nav gây thoát nhầm. |
| Login/signup/reset/verification | Auth shell | Logo nhỏ, nội dung ngắn, form; không điều hướng 4 tab trước đăng nhập. |
| Khởi động/khôi phục phiên | Bootstrap shell | Logo ổn định và trạng thái đang kiểm tra; chưa hiện dữ liệu riêng trước xác định phiên. |

Component gốc: cùng logo Bunly, màu #1F6840, Noto Sans/Noto Sans JP, app bar, khoảng cách, icon family, nút, field, feedback và safe area. Active state của tab/rail/sidebar được xác định theo đích hiện tại; tuyệt đối không tạo màn trắng mới thay cho màn gốc đã có.

## 3. PROMPT A — Khóa design system và thanh điều hướng gốc

```text
Trong project Bunly hiện tại, chuẩn hóa design system và app shell trước khi thêm Auth. Giữ concept sổ học xanh, typography Nhật–Việt và các frame nội dung đã có. Sửa trực tiếp, không sinh một bộ Bunly song song.

Tạo component sheet tên “Bunly — Shared UI & Navigation” gồm:
- Một logo/wordmark Bunly được dùng nhất quán; không trộn logo ảnh với 文 Bunly ぶんぽう ở màn khác.
- Token light/dark có vai trò: primary #1F6840, on-primary, background, surface, text chính/phụ, divider, outline, error, success; màu dark theo palette của brief gốc. Font Noto Sans/Noto Sans JP, type scale, spacing 4/8/12/16/24/32, lề mobile 20, nút/input radius 12, surface 16, vùng chạm 48dp.
- Các biến thể button (primary/secondary/text/destructive), input (default/focus/error/disabled), app bar, navigation, banner, snackbar, dialog, sheet, spinner và skeleton. Disabled/loading không đổi kích thước nút.

Khóa các shell:
1. Root mobile: app bar cùng một cấu trúc, logo Bunly trái và avatar phải, tên trang trong vùng nội dung. Bottom navigation 4 mục đúng thứ tự Hôm nay / Tra cứu / Sổ học / Tiến độ. Cùng icon và baseline, active có icon + chữ; không chỉ dựa màu. Chuyển tab giữ vị trí cuộn/query/filter của từng tab. Chạm lại tab đang active không tạo thêm route; nếu có hành vi về đầu trang thì thống nhất và ghi rõ.
2. Detail: back + tiêu đề đúng tác vụ, tối đa vài action cần thiết; không nhồi avatar vào mọi màn. Mở từ tab nào thì back về đúng danh sách và vị trí đó. Không tự về Hôm nay sau mỗi thao tác.
3. Focus: camera/OCR theo bước, ghi âm, quiz, dịch dùng đóng/thoát + tên tác vụ + tiến trình hợp lệ. Không bottom nav/side menu trong phiên. Setup chưa bắt đầu không có 03/06; tổng kết không còn tiến trình đang làm.
4. Auth: logo nhỏ + nội dung/form, không root nav.
5. Tablet/desktop: rail/sidebar là biến thể của cùng 4 đích. Không hiện sidebar và bottom nav cùng lúc. Không bắt tạo desktop cho mọi màn ở lượt này; chỉ một frame minh họa shell rộng và giữ mobile là chính.

Áp shared components lên S06, S07, S13, S20 trước, rồi S08/S12/S37/S38 và các màn học. Tên màn bằng tiếng Việt có dấu. Xóa toàn bộ chữ route “S16/S27”, “→ S08” khỏi UI; giữ ID/đích trong annotation ngoài frame. S11 tên “Kiểm tra văn bản”, S38 “Lịch sử bài làm”. Không nhầm chữ trên nút với liên kết hoạt động.

Đầu ra cần: component sheet, 4 root frame với active state tương ứng, một detail, một focus, một auth shell và một rail/sidebar mẫu. Liệt kê frame đã thực sự cập nhật. Không chỉ trả lời bằng báo cáo audit.
```

## 4. Hợp đồng chuyển màn

| Điểm vào | Thành công | Back/thoát và ngoại lệ |
|---|---|---|
| Mở app | Kiểm tra phiên → root cũ hoặc Hôm nay; chưa đăng nhập → S01 | Không thoáng hiện màn login trước khi khôi phục phiên xong; kiểm tra chậm/lỗi mạng không tự xóa dữ liệu hay kết luận phiên vô hiệu. |
| S01 đăng nhập | Có phiên hợp lệ → S05 nếu chưa thiết lập, nếu đã có → đích được phép hoặc Hôm nay | Sai input giữ email; không gửi trùng; hết loading trở lại trạng thái thao tác được. |
| S02 đăng ký | Chờ xác nhận → S03; chỉ vào vùng riêng khi có phiên hợp lệ | Không đăng ký xong là tự nhận đã đăng nhập nếu Auth còn yêu cầu xác nhận email. |
| S03 xác nhận | Liên kết hợp lệ → đăng nhập hoặc tiếp tục theo trạng thái phiên | Có gửi lại/sửa email/đăng nhập; link hết hạn có khôi phục. Chưa cấu hình deep link thì hướng dẫn quay lại app, không mô phỏng như đã triển khai. |
| Forgot/reset | Gửi yêu cầu → trạng thái trung tính; link hợp lệ → đặt mật khẩu → login | Link lỗi/hết hạn gửi lại; không tiết lộ email có tồn tại; xác thực reset không trở thành lối vào app tùy tiện. |
| Chuyển root tab | Đi đúng S06/S07/S13/S20 | Giữ từng tab; không reset app hoặc push vô hạn cùng một màn. |
| Root → chi tiết → note | Giữ mẫu/câu nguồn, lưu xong trở lại đúng chi tiết | Có bản nháp thì hỏi trước khi bỏ; lưu/bỏ lưu không đẩy người học sang tab khác ngoài ý muốn. |
| Bắt đầu luyện | Tạo một phiên, shell hiển thị đúng câu i/n | Mở lại trang lý thuyết từ giải thích rồi back tiếp tục bài, không tính thêm lần nộp hoặc làm lộ đáp án trước nộp. |
| Ghi âm/AI | Xác nhận input → xử lý → kết quả đúng lần gửi | Thoát ghi phải dừng micro. Hủy/chuyển màn không làm response cũ gắn vào câu mới. |
| Phiên hết hạn lúc soạn | Giữ bản nháp đúng chủ sở hữu → đăng nhập lại → khôi phục nếu còn phù hợp | Đổi user không lộ bản nháp của user trước; không tự gửi câu/ghi âm sau khi login nếu chưa có hành động xác nhận. |
| Đăng xuất | Xử lý pending → S01, đóng đường back tới vùng riêng | Không cho back về tài khoản trước; local data của chủ cũ không hiện trong tài khoản mới. |

Các quy tắc là đặc tả hành vi đích; prototype có thể mô phỏng, nhưng ghi rõ các phần không có backend thật.

## 5. PROMPT B — Thiết kế Login, Signup và luồng Auth đầy đủ

```text
Tạo nhóm Auth cho Bunly theo shared UI vừa chốt, cùng màu, font, button, field và giọng văn. Thiết kế mobile trước; một câu giá trị ngắn “Hiểu câu Nhật, luyện để dùng được”. Không hero marketing, mascot, gradient, social login chưa được hỗ trợ hoặc bắt nhập thông tin thừa. Dùng email/password làm luồng chính; không hiển thị nút Google/Apple như tính năng đã tích hợp.

Tạo các frame và trạng thái:

S01 — Đăng nhập: logo Bunly, email label rõ, mật khẩu có hiện/ẩn, quên mật khẩu, CTA Đăng nhập, liên kết Tạo tài khoản. Có trạng thái rỗng/focus/validation lỗi/sai thông tin/email chưa xác nhận/mất kết nối/đang gửi. Khi gửi, nút có spinner và chữ “Đang đăng nhập…”, giữ kích thước và không nhận tap trùng. Giữ email khi lỗi; lỗi cụ thể và có hướng khắc phục. Không show toast success rồi để ở nguyên login.

S02 — Đăng ký: email, mật khẩu, xác nhận mật khẩu; yêu cầu mật khẩu hiển thị theo chính sách Auth thực tế, không tự bịa quy tắc. Có hiện/ẩn và hỗ trợ autofill/password manager; cho dán mật khẩu. Tránh dùng placeholder thay label. CTA Tạo tài khoản, liên kết Đã có tài khoản? Đăng nhập. Nếu có liên kết điều khoản/chính sách thì chỉ dùng nội dung đã có, không tự tạo tuyên bố pháp lý. Loading không cho gửi trùng. Server yêu cầu xác nhận thì đến S03, chưa vào Hôm nay.

S03 — Xác nhận email: email đích từ form, hướng dẫn mở thư, quay lại app và đăng nhập. Có Gửi lại có cooldown do server, Sửa email và Đến đăng nhập; các biến thể chưa gửi/gửi lại đang chờ/đã gửi/lỗi/hết hạn. Không tự đếm thời gian hoặc báo đã xác nhận nếu chưa có kết quả. Có frame liên kết xác nhận thành công; nếu deep link chưa triển khai thì ghi trong annotation đây là đích thiết kế và giữ luồng quay lại app thủ công.

S04a — Quên mật khẩu: email và CTA Gửi liên kết; sau gửi dùng thông điệp trung tính không tiết lộ email tồn tại. S04b — Đặt mật khẩu mới: chỉ từ link reset hợp lệ, mật khẩu mới/xác nhận, CTA Lưu mật khẩu; có link hết hạn/không hợp lệ và Gửi lại. S04c — Thành công: hành động Đăng nhập, không truy cập tài khoản chỉ vì mở một URL.

S05 — Thiết lập học tập sau đăng nhập lần đầu: một form gọn gồm tên hiển thị nếu cần, cấp mục tiêu, phút/ngày và mục tiêu học. N5/N4 là nội dung ban đầu; cấp mở rộng chưa có nội dung ghi rõ. Không xin camera/micro/thông báo ở đây. Lưu → Hôm nay; người đã thiết lập không bị hỏi lại mỗi lần login.

Luồng đầu cuối: mở app kiểm tra phiên → login hoặc đích hợp lệ; đăng ký → chờ email → xác nhận → login → thiết lập nếu cần → Hôm nay. Forgot → gửi → link hợp lệ → đặt mật khẩu → login. Đăng nhập lại khi hết phiên giữ đích dự định và bản nháp đúng chủ sở hữu; không khôi phục draft của tài khoản khác hoặc tự nộp bài chưa xác nhận.

Auth không có bottom nav/sidebar. Form cuộn được khi bàn phím mở, CTA không bị che; label/error đọc được ở 360dp và cỡ chữ lớn. Chuẩn hóa cùng một auth shell thay vì mỗi màn một style. Tạo ít nhất một auth frame dark và frame bàn phím mở. Các email là địa chỉ minh họa, không dùng thông tin cá nhân thật.

Đầu ra: frame Auth thật, các biến thể loading/error/success, đường chuyển màn và annotation back. Không chỉ đặt icon avatar trên app bar rồi coi Auth đã hoàn thành.
```

## 6. Phân biệt Spinner, Loading screen và Skeleton

| Kiểu | Dùng ở đâu | Không nên làm |
|---|---|---|
| Spinner cục bộ | Đăng nhập, gửi form, gửi lại email, lưu cài đặt, thử đồng bộ | Không chặn toàn app khi chỉ một nút đang gửi; không thay label nút bằng icon không có nghĩa. |
| Loading screen | Khởi tạo app/khôi phục phiên khi chưa có shell nội dung; tác vụ tập trung cần một vùng riêng | Không thêm loading giả cho mỗi lần đổi tab; không quay về splash vì refresh nhỏ. |
| Skeleton screen | Tải lần đầu danh sách kho/Sổ học/tiến độ chưa có cache | Không skeleton hóa nội dung đã có; không dùng skeleton cho lỗi/không có dữ liệu; không tạo số liệu giả. |
| Refresh có dữ liệu | Giữ nội dung hiện có và trạng thái cập nhật nhỏ | Không xóa danh sách, reset cuộn hoặc làm người học mất thao tác. |
| Tiến trình theo bước | OCR/nhận dạng/AI khi có các bước thực sự biết | Không bịa %/thời gian còn lại; spinner không phải bằng chứng server đang chạy mọi bước. |

ID đề xuất: S00a (khởi tạo), S00b (khôi phục phiên chậm/lỗi); L01 (spinner trong component), L02 (loading OCR/AI), L03 (skeleton kho), L04 (skeleton Sổ học), L05 (skeleton Tiến độ), L06 (refresh có dữ liệu). Lxx là frame/component state, không phải các màn bắt người dùng đi qua trong happy path.

## 7. PROMPT C — Spinner và Loading screen theo tác vụ

```text
Thiết kế bộ trạng thái loading của Bunly dựa trên shared components. Mục tiêu là nói rõ app đang làm gì và giữ người học kiểm soát, không thêm thời gian chờ hoặc animation trang trí.

S00a — App đang khởi tạo/khôi phục phiên: logo Bunly nhỏ, nền theo theme, một spinner vừa phải và câu “Đang mở Bunly…” hoặc “Đang kiểm tra phiên đăng nhập…”. Không số %, quote carousel, quảng cáo hay đếm giây giả. Chưa biết user thì không hiện nội dung riêng rồi mới redirect.
S00b — Kiểm tra phiên lâu/lỗi: thay vì spinner vô hạn, có thông báo kiểm tra kết nối và Thử lại, hướng quay lại đăng nhập khi phù hợp. Lỗi mạng không tự xóa session/local data hoặc kết luận tài khoản hết hạn. Chỉ cho đọc dữ liệu cục bộ khi đã xác định đúng chủ sở hữu và được phép; đây là logic cần triển khai, không fake bằng redirect.

L01 — Spinner trong button: giữ chiều rộng/chiều cao và chữ hành động “Đang đăng nhập…”, “Đang tạo tài khoản…”, “Đang gửi…”, “Đang lưu…”. Không tap trùng. Các điều khiển không liên quan vẫn dùng được nếu tác vụ cho phép; hoàn tất trở lại bình thường hoặc chuyển đúng đích; lỗi giữ input. Spinner nhỏ trong nút, không phủ màn.

L02 — Processing tập trung cho OCR/nhận dạng lời nói/góp ý AI: giữ ảnh/câu/bài vừa nộp và header tác vụ. Hiển thị trạng thái thực có thể biết, ví dụ “Đang nhận dạng văn bản” hoặc “Đang chuẩn bị góp ý”. Đừng giả hoạt động từng tiêu chí hay phần trăm. Có trạng thái đang chờ, xử lý lâu, lỗi/timeout/hết lượt; cho rời màn hoặc hủy khi có hỗ trợ, ghi rõ hủy trên giao diện không nhất thiết hủy tác vụ server. Lần gửi cũ không được ghi đè câu mới. Nút Thử lại không tạo hai bài/lượt dùng trùng; ghi chú đây là yêu cầu nghiệp vụ.

Không bịa retry tự động, quota hoặc thời gian hứa hẹn. Nếu backend không cung cấp tiến trình, dùng indeterminate và nội dung có ích. Không lấy trạng thái “đang phân tích AI” làm “đang đồng bộ”: tách hai việc. Khi nhận kết quả thì thể hiện góp ý đúng bản nộp; khi chỉ lưu local thì dùng “Đã lưu trên thiết bị”.

Tạo component spinner light/dark, biến thể button/inline/vùng xử lý, reduced-motion và nhãn trợ năng. Loading được thông báo có nghĩa cho trình đọc màn hình, không đọc lại mỗi vòng quay; không dùng chớp sáng. Thiết kế trạng thái thành công/lỗi sau chờ để không bị dead-end. Không áp spinner fullscreen cho mọi lần chuyển tab hay lưu note.
```

## 8. PROMPT D — Skeleton screen và cập nhật có cache

```text
Tạo skeleton component và biến thể cho Bunly bằng chính layout thật đã có. Không tạo màn loading khác style.

L03/S07 — Kho tải lần đầu chưa có cache: giữ app bar, search, chỗ bộ lọc và bottom navigation ổn định. Vùng danh sách có 5–6 grammar-row skeleton với hai dòng tiêu đề Nhật/nghĩa Việt và metadata. Không đặt chữ ngẫu nhiên, tên mẫu hoặc count giả vào skeleton. Filter chưa có dữ liệu không phản hồi như đã lọc thành công.
L04/S13 — Sổ học: giữ root shell; skeleton đúng số vùng của một mục có câu/ghi chú, không quá nhiều lớp thẻ. Loading tài khoản mới không được thoáng hiện dữ liệu user cũ. Kết thúc loading có dữ liệu hoặc empty state thật với CTA mở kho; lỗi có thử lại, không dùng empty để che lỗi.
L05/S20 — Tiến độ: placeholder cho nhóm tổng hợp và hàng nội dung; không giả 0%, biểu đồ tăng trưởng hoặc số mẫu. Dữ liệu từng vùng sẵn sàng độc lập thì tải theo vùng; không chờ phần chậm nhất để hiện mọi thứ. Khi chưa có bài làm hiển thị “Chưa có kết quả luyện tập”, khác với lỗi tải.
L06 — Refresh có dữ liệu: giữ nguyên grammar rows/câu/note/thống kê và vị trí cuộn; hiển thị indicator nhỏ ở vùng cập nhật. Offline có cache thì hiện cache + nhãn phù hợp, không skeleton vô hạn. Không có cache và mất mạng thì có thông báo/Thử lại. Không ghi “đã đồng bộ” chỉ vì indicator đã dừng.

Skeleton có kích thước gần với content cuối để tránh nhảy layout; nền trung tính và tương phản vừa phải. Không shimmer mạnh khắp màn, reduced-motion dùng placeholder tĩnh. Dùng một tín hiệu loading chính cho mỗi vùng, không vừa skeleton vừa spinner fullscreen. Có annotation trạng thái đang tải, có dữ liệu, rỗng, lỗi, offline-cache và refresh.

Thể hiện trước/sau bằng cặp frame cùng layout. Áp light/dark và một biến thể 360dp; giữ nav, safe area và cỡ chữ thống nhất. Đầu ra gồm component skeleton dùng lại và 4 ví dụ theo đúng các màn hiện có, không tạo route Lxx cho người học bấm qua.
```

## 9. PROMPT E — Nối điều hướng, kiểm tra logic và khóa tính nhất quán

```text
Nối các frame Bunly hiện có với Auth và loading mới theo một sơ đồ điều hướng duy nhất. Giữ nguyên 4 đích root S06 Hôm nay / S07 Tra cứu / S13 Sổ học / S20 Tiến độ; mobile bottom nav, tablet rail, desktop sidebar chỉ là các biến thể của cùng đích. Đặt annotation route ngoài UI; mọi CTA có một đích rõ, không còn S16/S27 mơ hồ trên nút.

Các hành trình cần thể hiện:
- Bootstrap kiểm tra phiên → S01 nếu chưa đăng nhập, hoặc S05 lần đầu/Hôm nay khi hợp lệ. Loading chậm/lỗi có hồi phục.
- S01 ↔ S02 → S03 → đăng nhập → S05 nếu cần → Hôm nay. S01 → S04 quên mật khẩu → thông báo gửi → link reset hợp lệ → đổi mật khẩu → đăng nhập.
- Chuyển 4 tab giữ state; mở chi tiết từ Tra cứu/Sổ học/kết quả quét rồi Back về đúng nơi, query và vị trí. Avatar mở hồ sơ/cài đặt thật, không chỉ icon không có đích.
- Chi tiết → soạn note → lưu local → chi tiết; nếu pending thì nhãn chờ gửi. Thoát có bản nháp cần lựa chọn. Bỏ lưu không xóa note.
- Hôm nay/Chi tiết → chọn phiên khi cần → làm bài → phản hồi → tiếp theo → tổng kết → ôn lỗi/lịch sử/root. Nếu mở lý thuyết giữa phiên, Back trở lại bài đang làm, không tạo lần nộp mới.
- Nói → dừng ghi → xác nhận transcript → loading góp ý → kết quả → sửa/nói lại. Dịch → gửi → loading → góp ý → tự sửa. Chỉnh input làm nhận xét cũ không áp dụng cho bản mới; không có response cũ ghi đè.
- Phiên hết hạn/đăng xuất: giữ bản nháp đúng chủ sở hữu, đăng nhập lại an toàn, đóng đường back vào nội dung riêng khi đã logout; đổi user không lộ dữ liệu trước.

Rà lỗi còn tồn tại trên frame: S11 vẫn có 99%, tên Chi tiết ngữ pháp và N4; S38 sai tên; S27 tổng dạng bài là 8 nhưng CTA là 6; S20 48 tổng nhưng nhóm cộng 60; nhiều nút S06/S08/S12/S37 còn mã Sxx; logo root chưa thống nhất. Phải sửa frame, không chỉ tuyên bố đã sửa trong lời trả lời. Chốt dataset minh họa trước khi chỉnh số liệu và đối chiếu tổng giữa phiên/lịch sử/tiến độ.

Kiểm tra thêm: form keyboard mở, IME Nhật đang compose, nút bị disable/loading, micro/AI lỗi, cache offline, skeleton chỉ lần đầu, root nav active đúng, Back/Close không lẫn, một primary CTA, cỡ chữ lớn và dark. Không tự gọi mockup là backend thật. Chưa có màn typing/so sánh hoặc ngoại lệ thì giữ danh sách thiếu rõ ràng.

Đầu ra: sơ đồ frame/transition, các frame cập nhật, bảng CTA → đích → Back/hồi phục. Nếu có prototype, nối và kiểm tra các đường chính; nếu không, nói rõ mới là đặc tả chuyển màn. Không lấy dòng annotation “→ Sxx” làm bằng chứng prototype đã hoạt động.
```

## 10. Thứ tự gửi và tiêu chí nghiệm thu

Gửi A trước để khóa shell/component; B tạo Auth; C tạo spinner/loading; D tạo skeleton; E nối và rà logic. Nếu mỗi lượt cần chia nhỏ, yêu cầu tạo frame theo nhóm thay vì trả một bài tự đánh giá. Gửi kèm frame/component chuẩn đang dùng để tránh lệch style.

Một bản đủ bàn giao phải có: cùng một root nav, Auth đủ đầu vào–chờ–lỗi–thành công, spinner đúng vùng thao tác, loading có lối hồi phục, skeleton khớp layout cuối, back/close giữ đúng ngữ cảnh và quyền riêng tư. Màn prototype đẹp chưa thay thế kiểm tra chức năng Flutter/Supabase khi triển khai.
