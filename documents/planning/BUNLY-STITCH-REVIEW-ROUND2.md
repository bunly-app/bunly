# Bunly — Đánh giá sau 4 prompt chỉnh sửa

Ngày: 31/10/2026. Project public: https://stitch.withgoogle.com/projects/6411575233905174817

## Kết luận

Bản mới đã tiến rõ từ vài màn trình bày sang một bộ giao diện học tập có đầu vào và kết quả. Có thể dùng làm cơ sở chọn màn để triển khai, nhưng chưa nên đóng băng toàn bộ như đặc tả hoàn chỉnh. Cần một lượt sửa có mục tiêu về tính nhất quán dữ liệu, trạng thái voice và các màn còn thiếu; không cần đổi concept hoặc sinh lại toàn bộ app.

Phạm vi đã đọc: 18 frame nội dung gồm S06, S07, S08, S11, S12, S13, S18, S20, S27, S28/S17, S29, S31 nhập, S31/S32 phản hồi, S33, S34 xác nhận, S34/S35 phản hồi và S37, S38; trong danh sách này S31 nhập/phản hồi và S34 xác nhận/phản hồi là các frame riêng. Có bảng component và một khối prototype. Chưa mở được prototype thành phiên chạy để xác minh chuyển màn; các kết luận flow dưới đây dựa trên frame/CTA, không phải test tương tác end-to-end.

## Đã cải thiện

| Hạng mục | Bằng chứng quan sát |
|---|---|
| Hôm nay | Đã đưa “6 mẫu đến hạn ôn” lên trước tác vụ quét/dán, phù hợp ưu tiên người quay lại. |
| Kết quả phân tích S12 | Tiêu đề đã đúng “Ngữ pháp trong câu”; bỏ “99%” tại màn này, dùng nguồn kho Bunly. |
| Chi tiết S08 | Đã sửa note quá tuyệt đối, đổi “3 câu thật” thành “3 ví dụ”, sửa cách gọi nattō. |
| Voice | Có S33 ghi âm, S34 xác nhận transcript với nút gửi, S35 góp ý; tiêu đề phản hồi đã đúng và mẫu hiển thị N5. |
| Dịch | Có editor riêng trước góp ý; phản hồi giữ ba tiêu chí và chấp nhận に/へ; đổi sang “gợi ý sửa giữ nguyên ý”. |
| Bài tập | Đã có chọn phiên, phản hồi MCQ, điền khuyết và tổng kết. |
| Dữ liệu học tập | Đã thêm Sổ học, lịch sử và Tiến độ; có ý thức tách tự đánh giá khỏi bài làm và AI khỏi quiz. |
| Sổ lỗi | Đã bỏ câu “tăng 70% trí nhớ”; bổ sung đơn vị đếm ở một số chỗ. |

## Cần sửa trước khi giao lập trình

### 1. Voice còn mâu thuẫn về chức năng

S33 vẫn ghi “Bước tiếp theo: Phân tích phát âm & độ chính xác (S34)” và nói đến “chấm điểm độ chuẩn xác”. S34 thực tế là xác nhận lời nói, S35 lại nói không chấm phát âm. Sửa S33 thành **“Tiếp theo: kiểm tra văn bản nhận dạng, rồi nhận góp ý ngữ pháp”**. Không trình bày khả năng chấm phát âm khi chưa đặc tả.

S33 đang ở trạng thái “Đang lắng nghe” nhưng đồng thời có nghe lại và đi tiếp. Cần tách rõ: chưa ghi → đang ghi (Dừng/Hủy) → đã dừng (Nghe lại/Ghi lại/Tiếp tục). Không phát lại bản ghi trong khi micro vẫn đang thu.

S35 vẫn có câu “sửa trước khi AI thẩm định” dù đang là màn kết quả. Đổi thành “Góp ý dựa trên văn bản bạn đã xác nhận”. Nếu sửa transcript, quay về S34 và đánh dấu kết quả cũ không còn áp dụng cho bản mới. Chưa thấy bằng chứng rõ cho cơ chế vô hiệu hóa này.

### 2. Số liệu và quy mô phiên chưa khớp

- S27: MCQ 4 + điền 2 + dịch 1 + voice 1 = **8 câu**, nhưng CTA/quy mô phiên ghi **6 câu**. Setup đã có tiến trình `03/06` dù chưa bắt đầu.
- S20: tổng **48 câu**, nhưng nhóm quiz **44**, viết/dịch **12**, voice **4** cộng thành **60**. S38 lại dùng **32 + 12 + 4 = 48**.
- S18: “4/5 (80%)” gồm một câu đúng lần đầu và ba câu đúng sau gợi ý. Đã ghi chú sự hỗ trợ là tốt, nhưng không nên đặt 80% như độ chính xác độc lập của người học. Tách đúng lần đầu và hoàn thành sau hỗ trợ.
- S37: “4 lỗi trong 12 bài” nhưng tỷ lệ “1/4 (25% trong 12 bài)” chưa rõ bốn lần đo thuộc tập nào. Dùng đúng/tổng của các câu cùng mẫu, cùng khoảng thời gian; bỏ phần trăm nếu chưa định nghĩa.
- S07 tổng N5/N4 là 100 mẫu, S20 kho N5 lại 120 mẫu. Cần chốt tổng kho, phần đã tải và cấp độ; nếu khác phạm vi phải ghi nhãn.

Chốt **một bảng dữ liệu minh họa** trước khi sửa UI rồi dùng lại trên mọi frame. Số liệu đẹp không quan trọng bằng việc đếm đúng và biết đang đếm gì.

### 3. Lỗi cũ đã chuyển sang màn mới

S11 mới vẫn có “99% khớp”, nguồn Minna Bài 19 và nhãn N4 cho mẫu đang là N5 ở các màn khác. S29 còn nguồn Minna. S13 thêm nguồn sách/trang chưa được cung cấp. Không thể coi lỗi nguồn/chỉ số đã xử lý toàn project chỉ vì S12 đã sửa.

Xóa số tin cậy không có dữ liệu, chỉ dùng nguồn có bản ghi được xác minh. Với mockup dùng “Ảnh người dùng chọn — dữ liệu minh họa”. S11 đang hiện công thức/ngữ pháp trước bước phân tích: nếu đây chỉ là OCR thì để gợi ý ngữ pháp sang S12, hoặc phải đặc tả nguồn nhận diện trước đó. Không ngầm thêm một bước AI chưa được xác nhận.

### 4. Tiêu đề và ghi chú kỹ thuật đang lọt vào giao diện người dùng

- S11 và S38 vẫn có tiêu đề “Chi Tiết Ngữ Pháp”.
- S33/S34/S31 nhập dùng “Focused Practice Session”.
- MCQ có header `Dien Tu Mau Cau`; điền khuyết lại `Dich Cau Nhat Viet`; tổng kết ghi N4 và `03/06` dù đã kết thúc phiên N5.
- Nhiều CTA hiện `→ S16`, `S13`, `S16/S27` ngay trên nút. ID route phải ở annotation của frame, không nằm trong nhãn sản phẩm.
- Logo/header S13/S20 dùng `文 Bunly ぶんぽう`, khác bộ Bunly/avatar trước đó. Chốt một biến thể app bar cấp cao nhất để tái dùng.

Các lỗi này làm app trông như nhiều màn sinh riêng được ghép lại. Sửa chúng sẽ cải thiện cảm giác đồng bộ nhiều hơn thêm hiệu ứng/trang trí.

### 5. Một số bước vẫn chưa thấy trong bộ frame

Chưa thấy S30 typing độc lập, S36 so sánh lần thử, S39 chi tiết tiến độ, S40 mục tiêu; đầu vào MCQ chưa chọn đáp án cũng chưa rõ vì frame đang ở phản hồi khóa. Chưa thấy editor ghi chú riêng, camera/chọn ảnh hoàn chỉnh, Auth/hồ sơ/cài đặt, các biến thể lỗi AI/micro/offline/hết lượt, dark mode và bàn phím/font lớn. Cần tạo hoặc xác định trạng thái trong frame hiện có; không bắt buộc mọi trạng thái phải là route riêng.

Avatar không thay thế các màn tài khoản. Danh sách flow trong phần trả lời của Stitch là lời mô tả, không chứng minh các frame hoặc tương tác đã có.

### 6. Nội dung bài luyện còn tiết lộ đáp án và hứa quá mức

S31 editor đã nhắc dùng thể た ngay trước khi người học tự mở gợi ý. Nếu đó là bài đo khả năng tự làm, chuyển gợi ý sang thao tác chủ động và ghi nhận việc dùng. Phần nói “đuôi câu です/だ” là ví dụ không phù hợp để dùng chung cho mọi câu động từ; bỏ quy tắc tổng quát này hoặc thay bằng ví dụ được biên tập đúng bài.

S38 gắn “Đúng lần đầu” với “Nắm chắc”; một câu đúng chưa đủ kết luận thành thạo. Dùng “Trả lời đúng”, giữ mức nắm vững riêng. Những hứa hẹn như lưu tối đa 100 bài, mọi ảnh/bản nháp đều chỉ ở thiết bị phải do nghiệp vụ và triển khai xác nhận, không để thiết kế tự quyết.

## Nhận xét về hình thức

Nên giữ hướng sổ học xanh hiện có. Phần cần tập trung là nhịp đọc và component: tiêu đề màn, app bar, nhãn CTA, sentence block, thứ bậc phản hồi và ít lớp card hơn. Các frame mới vẫn thiên về đoạn giải thích dài; nên mở phần “Vì sao” theo nhu cầu sau kết luận ngắn, để hành động sửa/thử lại dễ thấy. Chưa kết luận contrast, cỡ chữ 360dp, dark mode hoặc khả năng chạm từ một canvas thu nhỏ; cần kiểm tra ở kích thước thiết bị khi có bản chạy.

## Prompt sửa vòng cuối có mục tiêu

```text
Sửa trực tiếp bộ frame Bunly hiện tại. Không tạo lại concept, không nhân bản màn đã đúng và không chỉ trả lời một bản báo cáo audit. Ưu tiên cập nhật frame thật theo danh sách sau, rồi liệt kê frame sửa và phần chưa làm:

1. Chuẩn hóa tiêu đề: S11 “Kiểm tra văn bản”, S38 “Lịch sử bài làm”, S33 “Nói một câu”, S34 “Kiểm tra lời nói”, S31 nhập “Dịch Việt → Nhật”, S28 “Trắc nghiệm”, S29 “Điền khuyết”, S18 “Kết quả phiên học”. Tiếng Việt có dấu. Xóa ID Sxx/route và mũi tên chỉ route khỏi chữ trên CTA, chuyển chúng ra annotation ngoài frame. Setup không có số câu đang làm; tổng kết không giữ 03/06.
2. S33 bỏ mọi lời hứa chấm phát âm/độ chuẩn xác; tách trước ghi/đang ghi/đã dừng. Đang ghi chỉ có Dừng/Hủy, đã dừng mới Nghe lại/Ghi lại/Tiếp tục. S34 xác nhận transcript trước gửi. S35 ghi “Góp ý dựa trên văn bản bạn đã xác nhận”; chỉnh transcript phải về S34 và kết quả cũ không còn áp dụng cho câu mới.
3. Quét toàn bộ frame, đặc biệt S11/S29/S13, để bỏ 99% khớp và nguồn sách/trang không được cung cấp. Metadata mẫu 〜たことがある thống nhất N5 trong dataset minh họa. S11 chỉ xác nhận OCR, không tự hiện kết luận ngữ pháp trước bước phân tích.
4. Chốt một dataset minh họa dùng chung. Phiên S27 tổng câu phải bằng tổng từng dạng, rồi khớp shell và S18. Tổng bài trên S20 bằng tổng nhóm và khớp S38; tách đúng lần đầu/đúng sau gợi ý/sai/AI chưa đánh giá. S37 mọi tỷ lệ có đúng/tổng cùng phạm vi; nếu chưa có định nghĩa thì bỏ phần trăm. Tổng kho N5/N4 và số đã tải phải có phạm vi rõ. Không gộp AI với độ chính xác quiz, không dùng một câu đúng để gắn “Nắm chắc”.
5. S31 nhập không hiện sẵn gợi ý thể た nếu chưa yêu cầu; gợi ý chủ động có nhãn đã dùng. Xóa diễn giải chung “です/だ” cho mọi câu, chỉ chấp nhận biến thể được nội dung bài xác định. Giữ bản nháp, nhiều bản dịch hợp lệ và góp ý ba tiêu chí.
6. Bổ sung phần còn thiếu theo nhóm: S30 typing có đáp án và tự đặt câu; S36 so sánh lần đầu/lần sửa; MCQ trước khi chọn/nộp. Sau đó các trạng thái lỗi micro, nhận dạng sai, AI timeout/hết lượt, offline và ít dữ liệu. Xác nhận các frame S39/S40, ghi chú, camera, tài khoản/cài đặt đã có hay chưa; thiếu thì ghi rõ, không gọi toàn bộ sản phẩm hoàn chỉnh.
7. Dùng một app bar/logo cho 4 tab; không trộn Văn Bunly với logo khác. Giữ palette/font/spacing, giảm đoạn văn dài bằng kết luận ngắn + phần “Vì sao” có thể mở. Tạo biến thể dark, 360dp, bàn phím Nhật mở cho loại màn đại diện và kiểm tra CTA không bị che.

Chỉ đánh dấu “đã sửa/đã có” khi frame hoặc trạng thái thực sự xuất hiện. Prototype phải kiểm tra thao tác được; annotation → Sxx không tương đương liên kết chạy được. Kết quả mong muốn là các frame cập nhật, dataset minh họa dùng chung và danh sách khoảng trống còn lại.
```

