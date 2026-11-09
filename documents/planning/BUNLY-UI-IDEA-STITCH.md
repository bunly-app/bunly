# Bunly — Ý tưởng giao diện và user flow đầu cuối cho Google Stitch

Ngày: 29/10/2026. Đây là định hướng thiết kế sản phẩm đích, không phải danh sách tính năng đã triển khai. Có thể dùng toàn bộ file làm brief, hoặc dùng prompt nền ở mục 8 kèm một nhóm màn hình ở mục 9.

**Bổ sung ngày 31/10/2026:** Người dùng mở rộng định hướng sang voice sửa ngữ pháp, MCQ/điền khuyết/typing, dịch Việt → Nhật có góp ý AI, tiến độ theo dạng bài và người học từ cơ bản tới nâng cao. Dùng [prompt bổ sung Voice & Practice](BUNLY-STITCH-EXTENSION-VOICE-PRACTICE.md) cùng file này; phạm vi mới trong file bổ sung thay cho giới hạn N5–N4 và phần bài dịch chỉ là mở rộng của brief ban đầu. Voice nhận xét ngữ pháp qua transcript; chấm phát âm vẫn chưa được đặc tả.

## 1. Sản phẩm phải giúp người dùng làm được gì?

**Bunly biến câu tiếng Nhật người học gặp trong đời sống thành kiến thức có thể hiểu, lưu, luyện và ôn lại.** Người dùng chính là người Việt học N5–N4, thường không biết tên cấu trúc để tra. Giao diện tiếng Việt; câu, công thức và ví dụ tiếng Nhật là nội dung chính.

Chu trình cốt lõi:

**Bắt gặp câu → lấy văn bản → xác nhận câu → nhận diện cấu trúc → đọc giải thích → lưu theo ngữ cảnh → luyện tập → ôn đến hạn → nhận ra tiến bộ.**

Ví dụ xuyên suốt thiết kế: người học chụp câu `日本へ行ったことがあります。`, sửa OCR nếu cần, thấy cụm `行ったことがあります` được đánh dấu, mở mẫu `〜たことがある` (Đã từng làm việc gì), lưu kèm câu gốc rồi luyện một câu liên quan. Khi đến hạn, mẫu xuất hiện ở Hôm nay.

Ba giá trị phải nhìn thấy trong UI:

- **Hiểu đúng ngữ cảnh:** luôn nối được mẫu ngữ pháp với đoạn câu đã phát hiện; phân biệt nội dung kho biên tập với gợi ý AI.
- **Học có tiếp nối:** sau khi hiểu có thể lưu hoặc luyện ngay; quay lại có việc cần ôn cụ thể.
- **Yên tâm về dữ liệu:** ghi chú lưu trên máy ngay, biết lúc nào còn chờ đồng bộ; mất mạng vẫn đọc nội dung đã tải.

Căn cứ: báo cáo M1, PRD M2, báo cáo M2 và theme Flutter hiện tại. MVP đích gồm đủ 9 nhóm: tài khoản/hồ sơ, kho ngữ pháp, học tập cá nhân, OCR, phát hiện ngữ pháp, luyện/ôn, lộ trình/thống kê, nhắc nhở, mô phỏng Free/Pro. Không thêm mạng xã hội, bảng xếp hạng, chatbot tổng quát, chấm phát âm, phân tích sách dài hoặc thanh toán thật vào thiết kế này.

## 2. Ý tưởng thẩm mỹ: “Sổ học ngữ pháp từ câu thật”

Gọn, rõ, có nhịp đọc như một công cụ học tập được biên tập cẩn thận. Bản sắc đến từ **câu tiếng Nhật được đánh dấu có ý nghĩa**, bố cục công thức–ví dụ–ghi chú và dấu lưu mẫu; không phụ thuộc tranh trang trí.

- Giữ nền tảng **Material 3**, màu xanh lá của Bunly hiện tại (`#1F6840`). Thiết kế mới là đề xuất phát triển từ theme này, chưa phải token đã có đầy đủ trong code.
- Nền sáng trung tính hơi xanh, bề mặt trắng, chữ đậm rõ. Dark mode dùng nền xanh đen và các lớp surface đủ phân biệt.
- Danh sách ngữ pháp là hàng nội dung có phân cấp và đường phân cách nhẹ; tránh mỗi dòng nằm trong một thẻ nổi lớn.
- Câu nguồn là điểm nhấn: chữ Nhật lớn vừa đủ, xuống dòng tự nhiên, vùng đánh dấu nền xanh nhạt và nhãn nối tới kết quả tương ứng.
- Mỗi màn có một hành động chính; trạng thái và hành động phụ đứng đúng thứ bậc.
- Giọng văn như người hướng dẫn học tập: cụ thể, ngắn, bình tĩnh. Ví dụ: “Ôn 6 mẫu đến hạn”, “Đã lưu trên thiết bị”, “Chưa tìm thấy mẫu phù hợp trong kho”.

### Những dấu hiệu AI slop phải tránh

- Không gradient tím/xanh neon, glow, kính mờ phủ mọi bề mặt, nền lưới công nghệ, icon tia sáng ở khắp nơi.
- Không hero khổng lồ “Unlock your potential”, slogan chung chung, carousel giới thiệu nhiều trang trước khi dùng app.
- Không biến Hôm nay thành dashboard gồm hàng loạt ô thống kê giống nhau. Thứ tự: việc nên làm → nội dung tiếp tục → thông tin hỗ trợ.
- Không mascot ngẫu nhiên, hoa anh đào, cổng torii hoặc mặt trời đỏ chỉ để thể hiện “Nhật Bản”.
- Không biến mọi thứ thành pill; chip chỉ cho bộ lọc/trạng thái ngắn. Không đặt một card trong nhiều card.
- Không thanh điều hướng nổi che nội dung, không nút quét quá lớn làm mất cân bằng cả app.
- Không số độ tin cậy AI kiểu “98%” nếu hệ thống chưa có xác suất được hiệu chuẩn; không hiển thị điểm thành thạo chỉ từ thao tác “Đã nắm”.
- Không fake testimonial, fake thành tích, số tăng trưởng, biểu đồ không có dữ liệu hoặc streak gây áp lực.
- Không lấy một bố cục đẹp rồi nhân bản cho camera, bài luyện và trang đọc. Mỗi loại tác vụ cần bố cục riêng nhưng cùng bộ thành phần.

## 3. Kiến trúc điều hướng

Đề xuất **4 tab cố định**: `Hôm nay` · `Tra cứu` · `Sổ học` · `Tiến độ`. Tài khoản/cài đặt mở từ avatar trên màn cấp cao nhất. Không dành riêng một tab cho AI, Pro hoặc Cài đặt.

| Tab | Câu hỏi người dùng | Nội dung chính |
|---|---|---|
| Hôm nay | Tôi nên làm gì tiếp? | Ôn đến hạn, phiên học theo mục tiêu, học tiếp; một nút “Quét hoặc dán câu” dễ thấy |
| Tra cứu | Mẫu này có nghĩa gì? | Tìm kiếm, lọc N5/N4/nhóm, kho ngữ pháp; lối vào quét/dán câu gần ô tìm kiếm |
| Sổ học | Tôi đã lưu gì và học đến đâu? | Mẫu đã lưu, các ghi chú gắn với mẫu, lọc trạng thái, lịch sử câu đã phân tích nếu người dùng đã chọn lưu |
| Tiến độ | Tôi đang tiến bộ ở điểm nào? | Lộ trình N5/N4, kết quả bài luyện, mẫu cần ôn, thay đổi mục tiêu |

Lưu ý về “Sổ học”: trạng thái học và việc lưu mẫu là hai thuộc tính độc lập. Bỏ lưu không xóa ghi chú hay kết quả học. Khi mở ghi chú, điều hướng về đúng mẫu và đúng ghi chú, không tạo một kho note bị tách khỏi ngữ cảnh.

Bottom navigation chỉ hiện ở 4 màn cấp cao nhất. Màn đọc sâu dùng back; camera, xác nhận văn bản và phiên luyện dùng luồng tập trung toàn màn hình. Quay lại giữ vị trí cuộn, từ khóa và bộ lọc. Từ kết quả quét mở chi tiết rồi back phải về đúng câu đã phân tích.

## 4. Danh sách màn hình cần thiết

Các ID là hợp đồng thiết kế để tham chiếu giữa các lượt tạo UI. “Có nền M2” nghĩa là đã có một phần luồng trong code; bố cục mới trong tài liệu này vẫn là đề xuất. Các màn đích khác cần triển khai tiếp, không dùng mockup làm bằng chứng chức năng đã xong.

| ID | Màn hình | Bố cục/nội dung bắt buộc | Hành động chính và lối ra | Phạm vi |
|---|---|---|---|---|
| S01 | Chào và đăng nhập | Một câu giải thích giá trị, email, mật khẩu, hiện/ẩn mật khẩu; liên kết đăng ký và quên mật khẩu | Đăng nhập → Hôm nay hoặc thiết lập đầu tiên | Có nền M2 |
| S02 | Đăng ký | Email, mật khẩu, yêu cầu mật khẩu rõ, liên kết điều khoản/chính sách thực tế khi có | Tạo tài khoản → S03; quay lại đăng nhập | Có nền M2 |
| S03 | Chờ xác nhận email | Email đích, hướng dẫn mở thư và quay lại, gửi lại có thời gian chờ, sửa email | “Đến đăng nhập”; không báo xác nhận thành công khi chưa có bằng chứng | Đích; M2 có thông báo cơ bản |
| S04 | Khôi phục mật khẩu | Trạng thái nhập email → đã gửi → đặt mật khẩu từ liên kết hợp lệ; liên kết hết hạn có gửi lại | Gửi liên kết / Lưu mật khẩu mới → đăng nhập | Đích |
| S05 | Thiết lập học tập lần đầu | Một form ngắn: N5/N4, mục tiêu, thời gian/ngày; lựa chọn mặc định hợp lý, chỉnh sau được | “Bắt đầu học” → Hôm nay; không hỏi quyền camera/thông báo ở đây | Đích; M2 có form hồ sơ |
| S06 | Hôm nay | Dòng ngày và mục tiêu; khối chính “6 mẫu đến hạn ôn”; học tiếp; nút quét/dán; nội dung mới vừa đủ | Bắt đầu ôn; nếu chưa có lịch ôn thì chọn học mẫu đầu tiên | Đích |
| S07 | Kho ngữ pháp / tìm kiếm | Search luôn thấy, lọc cấp độ/nhóm, hàng mẫu gồm tên Nhật + nghĩa Việt + cấp độ + trạng thái | Mở S08; quét/dán câu từ cạnh search | Có nền M2 |
| S08 | Chi tiết ngữ pháp | Tên/cấp độ, ý nghĩa, công thức, cách dùng, ví dụ Nhật–Việt, lưu mẫu, trạng thái học, ghi chú; ngữ cảnh nguồn nếu có | “Luyện mẫu này”; lưu là thao tác phụ tại tiêu đề; back về đúng nguồn | Có nền M2; luyện là đích |
| S09 | Nhập câu từ nội dung thật | 3 lựa chọn rõ: Chụp ảnh, Chọn ảnh, Dán/nhập câu; hạn mức AI hiển thị nhẹ | Chọn nguồn → S10 hoặc S11; hủy về nơi bắt đầu | Đích |
| S10 | Chụp/chỉnh vùng ảnh | Camera hoặc ảnh chọn, khung crop, xoay/chụp lại; chỉ lấy đoạn ngắn cần học | “Dùng ảnh này” → OCR → S11; xin quyền camera đúng lúc | Đích |
| S11 | Xác nhận văn bản | Ảnh thu nhỏ nếu có, văn bản tiếng Nhật sửa được, chọn đoạn cần phân tích; giải thích chỉ câu đã xác nhận được gửi để phân tích | “Tìm ngữ pháp”; trở lại chỉnh ảnh hoặc nhập tay | Đích |
| S12 | Kết quả phân tích câu | Câu đã xác nhận, đoạn đánh dấu ↔ hàng mẫu tương ứng, nhãn “Gợi ý từ câu”; liên kết tới kho biên tập | Chọn mẫu → S08; “Sửa câu” → S11; kết quả rỗng vẫn có tìm thủ công | Đích |
| S13 | Sổ học | Bộ lọc Đã lưu/Có ghi chú và trạng thái; danh sách mẫu, trích ghi chú khi liên quan; số lượng lấy từ dữ liệu | Mở mẫu hoặc ghi chú; vào phiên ôn; bỏ lưu có thể hoàn tác | Đích; M2 có dữ liệu/lọc |
| S14 | Soạn/sửa ghi chú | Mẫu liên quan, câu nguồn nếu có, nội dung nhiều dòng, giới hạn 2.000 ký tự, nút lưu rõ | “Lưu ghi chú”; quay lại có cảnh báo nếu nội dung chưa lưu | Có nền M2; tách editor là đề xuất |
| S15 | Chuẩn bị phiên học/ôn | Số mẫu/câu, nguồn phiên: đến hạn/một mẫu/lộ trình; thời lượng là ước lượng nếu có cơ sở; không màn “bắt đầu” trùng lặp | “Bắt đầu”; Hôm nay có thể vào thẳng S16 nếu không cần lựa chọn | Đích |
| S16 | Câu luyện tập | Câu hỏi tiếng Nhật, chỉ dẫn Việt, lựa chọn hoặc ô điền, tiến trình `2/6`, thoát phiên | “Kiểm tra”; chưa chọn/nhập thì nút vô hiệu | Đích |
| S17 | Phản hồi đáp án | Giữ câu hỏi và đáp án của người học, đúng/sai có icon + chữ, lời giải biên tập, liên kết mẫu | “Câu tiếp theo”; không tự chuyển khi chưa đọc xong | Đích; là trạng thái của S16 |
| S18 | Kết thúc phiên | Đúng x/y, mẫu cần ôn, bước tiếp và lịch ôn; không biến điểm bài luyện thành năng lực JLPT | “Về Hôm nay” hoặc “Ôn các câu sai”; nếu thoát sớm ghi rõ phần đã làm | Đích |
| S19 | Danh sách ôn đến hạn | Nhóm đến hạn/học tiếp, mẫu và lý do xuất hiện; xem lịch tới dưới dạng danh sách ngày gọn | Bắt đầu ôn; thay số lượng phiên nếu có nhiều mẫu | Đích |
| S20 | Tiến độ và lộ trình | Số mẫu theo trạng thái, kết quả bài luyện theo khoảng thời gian, lộ trình N5/N4; liệt kê phần yếu có thể mở | Chọn nhóm cần ôn → S19/S08; chỉnh mục tiêu → S21 | Đích; M2 có thống kê trạng thái cơ bản |
| S21 | Hồ sơ và mục tiêu | Tên hiển thị, trình độ, mục tiêu, phút/ngày; không hỏi dữ liệu cá nhân dư thừa | Lưu thay đổi; mục tiêu đổi không xóa lịch sử | Có nền M2 |
| S22 | Cài đặt | Giao diện hệ thống/sáng/tối, nhắc học, dữ liệu/đồng bộ, tài khoản, hạn mức, trợ giúp | Mở cấu hình tương ứng; giữ cấu trúc danh sách đơn giản | Đích |
| S23 | Nhắc học | Bật/tắt, giờ, ngày lặp; mô tả thông báo thật; trạng thái quyền hệ điều hành | Lưu; khi bị từ chối có đường mở cài đặt hệ thống | Đích |
| S24 | Dữ liệu và đồng bộ | Lần thành công gần nhất, thao tác đang chờ, nội dung đã tải, lỗi có thể xử lý | “Đồng bộ lại”; giải thích dữ liệu nào vẫn dùng được offline | Đích; M2 có banner/nút cơ bản |
| S25 | Free/Pro và hạn mức | Phần dùng được, lượt AI còn lại, kỳ làm mới do hệ thống cung cấp, so sánh quyền ngắn | “Tiếp tục với Free”; mô phỏng Pro ghi rõ bản học phần, không tạo checkout thanh toán | Đích |
| S26 | Tài khoản / riêng tư / trợ giúp | Email tài khoản, đăng xuất, quản lý dữ liệu cá nhân, phản hồi lỗi, mô tả dữ liệu ảnh/câu gửi lên | Đăng xuất có xử lý pending; xóa tài khoản cần xác nhận và trạng thái thực thi | Đích; M2 có đăng xuất |

**Không tạo màn riêng cho mọi popup.** Bộ lọc tìm kiếm là bottom sheet; đổi trạng thái học là menu/sheet; chọn nguồn ảnh có thể là sheet S09; xóa ghi chú là dialog; gửi lại email là trạng thái S03; tải/lỗi/rỗng là biến thể của màn đang dùng. S17 là trạng thái bài luyện, không ép người học mở một route mới sau mỗi câu.

Lịch sử phân tích là một vùng tùy chọn trong Sổ học: chỉ chứa các câu người dùng đã chọn lưu, mở lại S12. Không mặc định lưu mọi ảnh/câu đã phân tích. Trang giải thích chính sách hoặc trợ giúp có thể dùng cùng một template nội dung trong S26.

## 5. User flow tối ưu

### F01 — Người mới vào học

S01 → S02 → S03 → đăng nhập S01 → S05 → S06. S05 là một bước gọn; không trình chiếu nhiều trang. Hôm nay lần đầu chưa có thống kê: giải thích “Bắt đầu bằng một câu bạn đang gặp” và hai lối vào quét/dán hoặc kho N5. Quyền camera và thông báo chỉ hỏi khi dùng tính năng liên quan. Lần sau đăng nhập có phiên hợp lệ thì vào thẳng nội dung.

### F02 — Chụp câu để hiểu và học (luồng đặc trưng)

S06 “Quét hoặc dán câu” → S09 → chụp/chọn ảnh S10 → OCR → xác nhận/sửa S11 → phân tích → S12 → chạm một mẫu → S08 → lưu kèm câu nguồn → luyện ngay S16 → phản hồi S17 → tổng kết S18 → Hôm nay. Nếu chỉ muốn hiểu, đọc S08 rồi back về S12, không bắt lưu/luyện.

Dán câu đi từ S09 thẳng S11, bỏ bước ảnh/OCR. Có thể sửa câu ngay tại kết quả mà không phải quét lại. Lưu mẫu giữ ngữ cảnh đã chọn; người dùng quyết định có lưu câu gốc hay không. Chỉ gửi phân tích khi bấm xác nhận; không tự gọi AI mỗi lần gõ.

### F03 — Tra cứu nhanh, không dùng AI

Tab Tra cứu S07 → gõ `たこと` hoặc “đã từng” → chọn mẫu S08 → đọc ví dụ → lưu/ghi chú nếu muốn. Giữ search và vị trí danh sách khi back. Lọc phối hợp N5/N4 + nhóm; số kết quả và “Xóa bộ lọc” phải rõ. Không ép đi qua trang chủ hoặc nhập câu vào chatbot.

### F04 — Quay lại để ôn

Mở app hoặc nhắc học → Hôm nay S06 / danh sách đến hạn S19 → bắt đầu S16 → trả lời → S17 → lặp → S18 → Hôm nay cập nhật phần đã làm. Nếu chỉ có một phiên rõ ràng, bỏ S15. Trả lời sai có giải thích và đưa mẫu vào lịch ôn phù hợp; không chỉ đổi màu đáp án rồi cho qua.

### F05 — Ghi chú và tiếp tục sau

S08 → thêm/sửa S14 → Lưu → trở lại đúng vị trí S08. Lưu trên máy xong hiển thị “Đã lưu trên thiết bị”; nếu chưa gửi thì có trạng thái chờ đồng bộ nhẹ. Sổ học → chọn trích ghi chú → mở đúng mẫu/ghi chú. Xóa note cần xác nhận; bỏ lưu mẫu chỉ cần hoàn tác và giữ note.

### F06 — Mất mạng và nối lại

Đang đọc → mất mạng → tiếp tục nội dung cache + nhãn “Nội dung đã tải”. Ghi chú/trạng thái vẫn lưu trên máy; UI nói đang chờ gửi. OCR chỉ dùng offline khi thành phần nhận dạng đã sẵn sàng. Phân tích AI cần mạng: giữ văn bản, cho tìm thủ công hoặc thử lại sau. Có mạng → worker thử gửi khi app hoạt động → S24 phản ánh kết quả thật. Không hứa đồng bộ nền khi ứng dụng đã đóng.

### F07 — Hạn mức AI

S11 bấm phân tích → backend báo hết lượt → sheet giải thích lượt và kỳ làm mới → tiếp tục tra cứu thủ công hoặc xem S25. Giữ nguyên câu đã nhập và cho quay lại; nội dung kho, ghi chú và luyện cơ bản vẫn dùng được. Không khóa toàn bộ app vì hết lượt AI, không tạo vòng mời nâng cấp.

### F08 — Cấu hình nhắc học và quyền thiết bị

S06 sau một phiên học, gợi ý nhỏ “Nhắc tôi ôn” → S23 → chọn giờ/ngày → xin quyền thông báo → lưu. Nếu từ chối, vẫn dùng app bình thường, S23 giải thích cách bật lại. Camera bị từ chối ở S10 thì quay về chọn ảnh hoặc nhập câu, không kẹt ở màn đen.

### F09 — Đổi tài khoản an toàn

S26 → đăng xuất → nếu còn dữ liệu chờ gửi, nêu rõ số thao tác và lựa chọn đồng bộ trước hoặc đăng xuất nhưng giữ trên thiết bị → S01. Phiên tiếp theo chỉ hiển thị dữ liệu đúng tài khoản. Nếu phiên hết hạn khi đang soạn, giữ bản nháp thuộc đúng tài khoản và đưa người dùng về bước đăng nhập phù hợp.

## 6. Một hệ thống giao diện cho toàn bộ sản phẩm

### 6.1. Token đề xuất (khóa từ lượt thiết kế đầu)

| Vai trò | Light | Dark | Cách dùng |
|---|---|---|---|
| Primary | `#1F6840` | `#93D5AA` | CTA, selected, liên kết chính |
| On primary | `#FFFFFF` | `#08371D` | Chữ/icon trên nút primary |
| Primary container | `#D5EEDB` | `#214D33` | Đoạn câu được chọn, bề mặt nhấn nhẹ |
| Background | `#F7F9F6` | `#101712` | Nền toàn màn |
| Surface | `#FFFFFF` | `#18221B` | Sheet, editor, khối nội dung cần tách |
| Surface secondary | `#EDF2EC` | `#243027` | Nhóm nội dung phụ, trường nhập |
| Text chính | `#17251C` | `#E4EBE3` | Nội dung đọc |
| Text phụ | `#4D6153` | `#B4C5B7` | Chú thích, metadata |
| Outline | `#748478` | `#819486` | Viền input và ranh giới có chức năng |
| Divider | `#DEE6DD` | `#344639` | Phân cách nhẹ |
| Error | `#B3261E` | `#FFB4AB` | Lỗi nhập/liên quan thao tác; luôn có chữ |

Đây là palette thiết kế khởi điểm, cần kiểm tra contrast trên bản dựng. Màu lỗi/cảnh báo là màu ngữ nghĩa, không dùng để trang trí. Bốn trạng thái học dùng **nhãn + icon**; màu chỉ hỗ trợ. Dữ liệu chưa đồng bộ không dùng màu đỏ nếu chưa có lỗi thật.

- Chữ Việt: Noto Sans; chữ Nhật: Noto Sans JP cùng hệ Noto. Trọng lượng 400/500/600/700; không phối một font trang trí để tạo khác biệt giả.
- Thang chữ: tiêu đề màn 24/32, tiêu đề mục 20/28, nội dung 16/24, metadata 14/20. Câu Nhật nổi bật 22/34; ví dụ Nhật 18/30. Không tăng letter-spacing chữ Nhật hoặc ép câu thành một dòng.
- Lưới khoảng cách: 4, 8, 12, 16, 24, 32; lề mobile 20, màn hẹp 16. Cùng một mức cho cùng loại thành phần.
- Bo góc: input/nút 12, khối nội dung 16, sheet 24 phía trên. Full pill dành cho chip nhỏ hoặc thành phần Material phù hợp; không dùng cho mọi container.
- Icon Material Symbols Rounded, một kiểu stroke; selected có thể filled cùng family. Icon có nhãn hoặc tooltip khi nghĩa chưa rõ.
- Vùng chạm tối thiểu 48dp. Bố cục chịu được font hệ thống lớn, bàn phím mở, câu Nhật dài và màn 360dp; không cắt CTA dưới safe area.
- Motion vừa đủ: chuyển trạng thái/route khoảng 150–250ms; tôn trọng giảm chuyển động; không confetti và animation lặp trên màn đọc.

### 6.2. Bộ component dùng chung

| Component | Các biến thể phải thống nhất |
|---|---|
| Top app bar | Cấp cao nhất: tên màn + avatar; cấp sâu: back + tên ngắn + tối đa vài action có ích |
| Bottom navigation | 4 nhãn cố định, cùng thứ tự/icon trên mọi màn cấp cao nhất |
| Button | Primary filled, secondary outlined, tertiary text, destructive; normal/loading/disabled/focus |
| Text field | Label luôn rõ, helper/error, multiline, password, bàn phím phù hợp; giữ input khi lỗi |
| Grammar row | Tên Nhật, nghĩa Việt, cấp độ, trạng thái, dấu lưu; selected/đã lưu/có note |
| Sentence block | Câu Nhật, vùng đánh dấu có thể chạm, bản dịch nếu có; OCR chưa xác nhận/đã xác nhận |
| Example block | Câu Nhật, bản dịch Việt, cấu trúc được nhấn; cùng cách căn trên chi tiết và phản hồi luyện |
| Learning status | Mới / Đang học / Cần ôn / Đã nắm; cùng icon, thứ tự và cách diễn đạt |
| Sync indicator | Đã lưu trên máy / Đang chờ / Đang đồng bộ / Lỗi; tránh banner chiếm màn thường trực |
| Feedback | Inline lỗi form; snackbar cho thao tác ngắn; banner cho lỗi ảnh hưởng tác vụ; dialog cho xác nhận có hậu quả |
| Empty state | Một lời giải thích gắn ngữ cảnh + một hành động cụ thể; không minh họa lớn và CTA vô nghĩa |
| Practice answer | Chưa chọn/chọn/đã khóa/đúng/sai; đúng sai có chữ, icon, không chỉ màu |

### 6.3. Quy tắc nội dung và tin cậy

- “Kho ngữ pháp” là nội dung đã biên tập. “Gợi ý từ câu” là bước nhận diện AI; không gắn nhãn AI lên mọi đoạn giải thích của kho.
- Chạm một vùng đánh dấu phải làm nổi bật đúng hàng mẫu và ngược lại; nếu nhiều cấu trúc chồng nhau, chọn một mẫu tại một thời điểm.
- Không có mẫu trong kho: giữ câu gốc, nói rõ chưa tìm được, cho sửa câu/tìm thủ công. Không tự tạo bài giải thích ngoài kho để lấp màn trống.
- OCR là bản nháp sửa được. Nếu chưa có chỉ số độ tin cậy thật, chỉ nhắc người dùng kiểm tra văn bản thay vì đánh dấu lỗi đoán mò.
- Số liệu tiến độ phải có đơn vị/mẫu số. “Đã nắm” do người học chọn khác với “Đúng 8/10 câu đã làm”. Chưa làm bài thì hiển thị chưa có dữ liệu.
- Mẫu mockup có thể dùng dữ liệu minh họa nhất quán: phiên ôn 6 mẫu, hoàn thành 4/6, kết quả 4/6; phải đánh dấu là kịch bản thiết kế, không phải số đo hiện tại của Bunly.
- Không hiển thị tên bảng database, outbox, RLS, Edge Function hoặc service key trong UI người dùng.
- Chỉ đưa ảnh/câu lên dịch vụ theo luồng đã giải thích. Quyền xóa dữ liệu và các hứa hẹn lưu trữ chỉ hiển thị khi backend hỗ trợ; thiết kế trạng thái chờ/lỗi thực thi.

## 7. Ma trận trạng thái cần thiết kế

| Khu vực | Các trạng thái cần có | Hướng thoát/hồi phục |
|---|---|---|
| Auth | Sai thông tin, email chưa xác nhận, gửi lại có cooldown, phiên hết hạn, link hết hạn | Sửa input/gửi lại/đăng nhập; không lộ email có tồn tại qua thông báo reset |
| Kho/Sổ học | Loading, có dữ liệu, không kết quả tìm, chưa lưu gì, cache offline, lỗi tải không có cache | Xóa lọc, mở kho, thử lại; phân biệt rỗng với lỗi |
| OCR | Quyền từ chối, ảnh mờ/không có chữ Nhật, đang xử lý, model chưa sẵn sàng offline | Chụp lại/chọn ảnh khác/nhập tay; giữ ảnh để chỉnh |
| AI | Đang phân tích, thành công, một phần/không có mẫu trong kho, mất mạng, timeout, hết lượt | Giữ câu, sửa câu, thử lại hoặc tìm thủ công; không thông báo đã hoàn tất khi lỗi |
| Ghi chú/sync | Đang soạn, lưu local thành công, pending, sync thành công, lỗi, phiên hết hạn | Giữ nội dung, thử lại đúng tài khoản; xóa có xác nhận |
| Luyện/ôn | Chưa trả lời, trả lời, phản hồi, kết thúc, thoát sớm, không có câu phù hợp | Tiếp tục, xem mẫu hoặc về Hôm nay; không tạo câu bịa để lấp phiên |
| Tiến độ | Chưa có bài làm, có dữ liệu ít, đủ dữ liệu, hết bài đến hạn | Học mẫu đầu/tiếp tục lộ trình; không biểu đồ giả |
| Cài đặt | Quyền thông báo bị từ chối, đổi theme, logout còn pending, xóa dữ liệu đang xử lý/lỗi | Mở cài đặt hệ thống, hủy, thử lại; nội dung xác nhận cụ thể |

Mỗi nhóm thiết kế tối thiểu một happy path và các ngoại lệ trực tiếp của nó. Không cần tạo 26 bản dark ngay; chốt component trước rồi áp dark vào các loại màn tiêu biểu.

## 8. Prompt nền dùng trực tiếp trong Google Stitch

Sao chép đoạn dưới kèm các hàng màn hình và flow cần tạo ở mục 4–5. Nếu đính kèm cả file, yêu cầu dùng file làm đặc tả, tạo theo từng nhóm ở mục 9 và giữ cùng hệ thống thiết kế.

```text
Thiết kế giao diện mobile app Bunly cho người Việt học ngữ pháp tiếng Nhật N5–N4. Ngôn ngữ UI là tiếng Việt, nội dung học có tiếng Nhật và bản dịch Việt. Sản phẩm giúp biến một câu người học gặp thành kiến thức đã hiểu, lưu, luyện và ôn lại: chụp/chọn ảnh hoặc dán câu → xác nhận/sửa văn bản → gợi ý cấu trúc có trong kho → đọc giải thích biên tập → lưu kèm ngữ cảnh → luyện tập → ôn đến hạn → theo dõi tiến bộ.

Định hướng hình ảnh: “sổ học ngữ pháp từ câu thật”. Material 3 có bản sắc, bình tĩnh, dễ đọc, nội dung Nhật là tâm điểm. Giữ primary #1F6840, nền #F7F9F6, surface trắng, text #17251C; dark mode dùng nền #101712 và primary #93D5AA. Font Noto Sans cho tiếng Việt và Noto Sans JP cho tiếng Nhật. Khoảng cách theo 4/8/12/16/24/32, lề 20, bo nút/input 12, khối nội dung 16. Icon Material Symbols Rounded. Vùng chạm 48dp; hỗ trợ font lớn, câu Nhật dài, bàn phím và safe area. Các token và component dùng lại xuyên suốt mọi màn hình.

Điều hướng 4 tab, đúng thứ tự và nhãn: Hôm nay, Tra cứu, Sổ học, Tiến độ. Avatar mở tài khoản/cài đặt. Quét/dán câu là tác vụ dễ thấy trên Hôm nay và cạnh search Tra cứu, không phải tab AI/chatbot. Bottom nav chỉ hiện ở màn cấp cao nhất. Camera, xác nhận câu và phiên luyện là luồng tập trung. Back giữ câu, query, filter, vị trí đọc và điểm vào trước đó.

Hãy tạo các màn hình theo ID trong brief kèm theo. Mỗi màn có một CTA chính và lối ra rõ. Hôm nay ưu tiên việc học đến hạn thay vì nhiều ô thống kê. Kho dùng danh sách hàng nội dung, tránh card lồng card. Kết quả phân tích hiển thị câu gốc với vùng đánh dấu liên kết tới mẫu trong kho. Chi tiết có công thức, giải thích Việt, ví dụ Nhật–Việt, lưu, ghi chú và luyện. Bài luyện giữ câu hỏi khi hiện phản hồi và giải thích. Progress phân biệt trạng thái tự đánh giá với kết quả bài làm.

Dùng câu xuyên suốt 日本へ行ったことがあります。 và mẫu 〜たことがある — Đã từng làm việc gì. Dữ liệu minh họa nhất quán giữa màn; số liệu mockup là ví dụ thiết kế. Nguồn kho biên tập và gợi ý AI phải được phân biệt. AI không có kết quả thì giữ câu và cho tìm thủ công. Không hiển thị confidence % bịa, không chatbot tổng quát, không tường nâng cấp chặn nội dung cơ bản. Free/Pro của bản học phần là mô phỏng, không thiết kế thanh toán thật.

Thiết kế trạng thái loading/empty/error/offline/pending và success cho tác vụ tương ứng. Lưu local thành công không được ghi “Đã đồng bộ” khi chưa gửi máy chủ. Camera bị từ chối có nhập tay/chọn ảnh. Mất mạng giữ câu và ghi chú, nội dung cache vẫn đọc được. Xin quyền đúng lúc dùng.

Tránh AI slop: không gradient tím/neon, glassmorphism, glow, bento dashboard, mascot ngẫu nhiên, hoa anh đào trang trí, slogan rỗng, thanh nav nổi hoặc hàng loạt chip/thẻ giống nhau. Bản sắc đến từ typography Nhật–Việt, câu đánh dấu, công thức, ví dụ và các thao tác học cụ thể.

Đầu ra mong muốn: các frame mobile cùng kích thước tham chiếu 390×844, nội dung cuộn tự nhiên, một bộ component/token chung và mô tả ngắn các chuyển màn. Kiểm tra thêm bố cục hẹp 360dp. Nếu có khả năng tạo prototype, nối các điểm chạm theo flow; nếu không, ghi rõ màn đích cho từng CTA. Không tự bỏ màn/ngoại lệ và không tự thêm tính năng ngoài brief. Lượt sau tiếp tục dùng cùng màu, font, spacing, component và navigation đã chốt.
```

## 9. Thứ tự tạo UI và prompt theo lượt

Đây là cách chia brief để kiểm soát chất lượng; không giả định công cụ sẽ tự nhớ mọi quyết định. Ở mỗi lượt hãy kèm prompt nền, bảng token và frame chuẩn đã được chấp nhận nếu công cụ hỗ trợ tham chiếu.

| Lượt | Màn cần tạo | Prompt bổ sung để sao chép sau prompt nền |
|---|---|---|
| A — Chốt ngôn ngữ thiết kế | Component sheet + S06, S07, S08 | “Tạo bộ nền trước: button/input/chip/grammar row/sentence/example/status/navigation. Thiết kế Hôm nay, Tra cứu và Chi tiết trên cùng bộ này. Chứng minh chúng là ba loại bố cục khác nhau nhưng cùng một app. Tạo thêm S08 dark và S07 empty/offline. Chưa mở rộng sang màn khác khi nền chưa nhất quán.” |
| B — Luồng khác biệt | S09–S12 + S08 từ câu nguồn | “Giữ nguyên bộ nền lượt A. Thiết kế F02 với hai lối chụp ảnh và dán câu. Thể hiện crop, OCR sửa được, câu xác nhận, các đoạn đánh dấu và mẫu tương ứng. Có lỗi OCR, camera bị từ chối, không có mẫu, mất mạng và hết lượt. Kết quả phải dẫn tới trang Chi tiết đã có, không thiết kế lại nó.” |
| C — Học và quay lại | S13–S20 | “Tiếp tục cùng design system. Thiết kế F04–F05: Sổ học, editor note, đến hạn, câu luyện trắc nghiệm/điền, phản hồi và tổng kết, Tiến độ. Phân biệt lưu mẫu và trạng thái học. Feedback giữ ngữ cảnh câu hỏi; đưa mẫu sai về danh sách ôn. Tạo cả trạng thái chưa có bài làm và đã ôn hết, không dùng biểu đồ giả.” |
| D — Tài khoản và thiết lập | S01–S05, S21–S26 | “Thiết kế đăng nhập/đăng ký/xác nhận/khôi phục mật khẩu/thiết lập lần đầu và các trang hồ sơ, cài đặt, nhắc học, sync, hạn mức, riêng tư. Form cùng component đã chốt. Onboarding một form gọn. Chỉ xin quyền lúc liên quan, giữ pending khi logout, Free/Pro mô phỏng không checkout. Lỗi Auth và link hết hạn có lối hồi phục.” |
| E — Soát toàn hệ thống | Các frame đã tạo + biến thể | “Rà soát mọi frame theo ID và flow. Giữ chính xác tên tab, palette, type scale, margin, radius, icon, CTA, cách viết trạng thái. Áp dark lên Hôm nay, kết quả câu, Chi tiết, bài luyện, form và sheet. Kiểm tra chữ lớn, màn 360dp và bàn phím. Bổ sung frame ngoại lệ còn thiếu thay vì thêm đồ trang trí.” |

## 10. Tiêu chí chọn bản thiết kế để triển khai

- Người mới nhìn Hôm nay biết bắt đầu từ đâu; người quay lại biết ôn gì; người chỉ muốn tra mở được search ngay.
- Luồng chụp/dán luôn có xác nhận văn bản và đường tra thủ công; không làm mất câu khi lỗi hoặc hết lượt.
- Từ câu nguồn → mẫu → luyện → ôn là một chuỗi liền mạch; không buộc đi vòng về trang chủ giữa các bước.
- Mẫu, ví dụ và note có thứ bậc đọc rõ; tiếng Nhật đúng glyph, không cắt, không chen Latin font làm lệch dòng.
- Mỗi hành động có trạng thái phản hồi, back/cancel và cơ chế bảo vệ bản nháp phù hợp.
- Cả 4 tab cùng một hệ thống; dark mode thay vai trò màu đúng, không chỉ đảo màu ảnh chụp.
- Bao phủ cả 9 nhóm MVP, nhưng frame tương lai không bị gọi là chức năng đã triển khai. OCR/AI/practice/reminder/Free–Pro vẫn cần code và kiểm chứng riêng.
- Không đặt chỉ tiêu kho 80–120 mẫu hoặc số liệu mockup thành số liệu sản phẩm hiện tại; M2 hiện chỉ có 3 mẫu minh họa.
- Bản giao phải có màn thành công và ngoại lệ, component sheet, thứ tự điều hướng và nhãn màn; một bộ ảnh đẹp rời rạc chưa đủ làm đặc tả triển khai.

Tài liệu nguồn trong repo: [M1](../reports/Capstone-Report-1-Proposal.md), [PRD M2](PRD-M2-Architecture-Base.md), [M2](../reports/Capstone-Report-2-Architecture.md), [kiến trúc hiện tại](../development/ARCHITECTURE.md). Quyết định UX/token ở file này là đề xuất thiết kế mới; nhóm có thể chỉnh sau khi thử luồng với người dùng.
