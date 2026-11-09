# Bunly — Review bản Stitch public và prompt chỉnh sửa

Ngày đánh giá: 31/10/2026.

Project: https://stitch.withgoogle.com/projects/6411575233905174817

## 1. Phạm vi đã xem

Mở được viewer public không cần đăng nhập. Đã đọc nội dung frame qua giao diện viewer và quan sát canvas: component sheet, S06 Hôm nay, S07 Tra cứu, S08 Chi tiết, S12 Kết quả phân tích, S31 Dịch & góp ý, S34/S35 Voice, S37 Sổ lỗi. Viewer còn hiển thị `Generating Screen` và `Creating prototype…` tại thời điểm kiểm tra. Không suy ra các màn khác chưa xuất hiện là đã được tạo; chưa xác nhận prototype chạy đủ flow hoặc app thực thi chức năng.

Quyền viewer dùng để đánh giá. Các prompt dưới là nội dung để chủ project gửi trong Stitch; chưa gửi prompt hoặc chỉnh thiết kế trực tiếp trên project.

## 2. Nhận xét tổng thể

**Hướng hình ảnh đã phù hợp Bunly, nhưng chưa đủ để làm đặc tả triển khai trọn luồng.** Màu xanh, typography Nhật–Việt, vùng đánh dấu cấu trúc, câu nguồn và 4 tab có tính liên tục. Bài dịch đã có ba tiêu chí, chấp nhận hai cách dùng に/へ; Voice ghi rõ chưa chấm phát âm. Sổ lỗi có đường luyện lại, giúp nối phản hồi với hành động.

Vấn đề lớn nhất là các màn phản hồi đã được tạo trước khi có đủ bước nhập/xác nhận, một số màn dùng nhầm tiêu đề, và xuất hiện nội dung/số liệu có vẻ chắc chắn quá mức. Nên sửa nhóm này trước rồi mới sinh tiếp các màn; tránh tiếp tục nhân bản lỗi sang toàn bộ hệ thống.

## 3. Những điểm cần sửa theo mức ưu tiên

| Mức | Quan sát thực tế | Vì sao ảnh hưởng | Điều chỉnh yêu cầu |
|---|---|---|---|
| P0 | S34/S35 Voice hiển thị cả transcript chưa xác nhận, nút sửa văn bản và góp ý AI cùng lúc | Chưa rõ AI đã nhận xét câu nào; sửa transcript có thể để lại nhận xét cũ | Tách ghi âm → xác nhận transcript → góp ý. Sửa transcript làm mất hiệu lực nhận xét cũ cho tới khi gửi lại. |
| P0 | S31 và Voice có heading `Chi Tiết Tiến Độ`; S12 có heading `Chi Tiết Ngữ Pháp` | Người học không biết mình đang làm tác vụ nào; khó nối flow | S31 nhập: “Dịch Việt → Nhật”; phản hồi: “Góp ý bài dịch”; S34: “Kiểm tra lời nói”; S35: “Góp ý câu nói”; S12: “Ngữ pháp trong câu”. |
| P0 | S12 ghi “Độ khớp 99%”; S37 ghi ôn lỗi tăng “70% khả năng ghi nhớ bền vững” | Số liệu không có căn cứ trong thiết kế đang xem | Bỏ số; thay bằng thông điệp có thể kiểm chứng. Không thay bằng một số khác. |
| P0 | S12 tự ghi đối chiếu Minna no Nihongo Bài 19 và “Shinkanzen Master N5” | Nguồn nội dung chưa được xác thực; có thể gán nhầm tài liệu | Chỉ hiển thị nguồn gắn với bản ghi đã xác minh. Trong mockup dùng “Nội dung từ kho Bunly” và ghi chú dữ liệu minh họa. |
| P1 | Voice ghi cấp N4 cho mẫu 〜たことがある trong khi S08/S31 đang dùng N5 | Mâu thuẫn giữa các frame của cùng bản ghi | Dùng cùng metadata mẫu trong cả bộ. Cấp độ cần theo danh mục biên tập của Bunly; mockup hiện tại thống nhất N5. |
| P1 | S31 đang là bài làm đã có góp ý, không thấy editor nhập bản dịch và CTA gửi ở trạng thái ban đầu | Thiếu nửa đầu tác vụ | Tạo trạng thái nhập, đang đánh giá, nhận góp ý, tự sửa và thử lại; không mở lời giải ngay từ đầu. |
| P1 | Voice không có frame ghi âm trước màn transcript/phản hồi trong tập đã xem | Không thể đánh giá quyền micro, ghi lại và lỗi ASR | Bổ sung S33 và các ngoại lệ, giữ lối nhập tay. Không chấm phát âm từ transcript. |
| P1 | Chưa thấy MCQ, điền khuyết, typing, tổng kết phiên và chi tiết tiến độ trong tập đã xem | Danh sách tính năng luyện tập chưa thành luồng dùng được | Tạo S27–S30, trạng thái S17, S18, S36, S38–S40 theo nhóm có kiểm soát. |
| P1 | S08 có note “Không dùng mẫu này cho việc mới làm hôm qua hoặc tuần trước…” | Diễn đạt quy tắc quá tuyệt đối, dễ học sai | Không dùng thời điểm gần làm điều kiện cấm tuyệt đối. Đánh dấu note cá nhân không phải quy tắc kho; nội dung ví dụ cần biên tập kiểm tra. |
| P1 | S31 có “Bản sửa chuẩn xác nhất”; S37 có “Bản sửa chuẩn xác” | Gây cảm giác chỉ có một câu đúng dù nhiều cách diễn đạt hợp lệ | Dùng “Gợi ý sửa giữ nguyên ý”; phân biệt sửa bắt buộc và cách nói tự nhiên tùy ngữ cảnh. |
| P1 | S37 có “Sai 4 lần”, mô tả xuất hiện trong 3 bài, tỷ lệ 25% nhưng chưa giải thích đơn vị/mẫu số | Không biết đang đếm bài, lần thử hay lỗi; dễ làm sai mô hình tiến độ | Chốt đơn vị: số bài độc lập, số lần thử, khoảng thời gian. Chỉ dùng tỷ lệ khi có đúng/tổng; giữ góp ý AI riêng với quiz. |
| P1 | Hôm nay đặt khối quét lớn trước khối ôn được gắn “Ưu tiên 1” | Thứ tự hành động không khớp lời nhắc ưu tiên | Nếu đã có ôn đến hạn thì đặt phiên ôn là CTA chính, quét là tác vụ phụ rõ. Người mới chưa có lịch ôn thì ưu tiên quét/tra cứu. |
| P2 | Nhiều lớp xanh nhạt và khối card lồng; màn chi tiết/sổ lỗi dài | Các nội dung cạnh tranh tương tự nhau, khó quét nhanh | Surface đọc trung tính; xanh tập trung ở CTA, selection và đoạn câu. Dùng divider/heading thay card cho các mục liên tiếp. |
| P2 | “Tiến độ ghi chép & câu ví dụ 60%”, “Mục 42/120”, 42/58 mẫu, 18 bài xuất hiện rải rác | Mockup có thể bị hiểu thành dữ liệu sản phẩm thật, chỉ số chưa định nghĩa | Dùng một bộ dữ liệu minh họa nhất quán; bỏ phần trăm nếu không có tiêu chí hoàn thành. Hiển thị nhãn minh họa trong bản review/ghi chú thiết kế. |
| P2 | S12 có cả “Quay lại chỉnh câu” và “Sửa câu” cho cùng tác vụ | Trùng thao tác và chiếm không gian | Một back về nguồn, một action Sửa câu nếu có mục đích khác; nếu cùng đích chỉ giữ một. |
| P2 | S08 dịch nattō là “đậu nát”, ghi ví dụ là “3 câu thật”; S37 mô tả cấm đoán là “nhẹ nhàng” | Ngôn ngữ thiếu chính xác hoặc tự nhận nguồn gốc | Dùng “đậu nành lên men nattō”, “3 ví dụ”; mức cấm đoán xét ngữ cảnh, không gắn mặc định nhẹ nhàng. |
| P2 | S06 ghi `Thứ Tư, 29/10` nhưng bộ dữ liệu đang theo năm 2026 | Ngày minh họa chưa nhất quán; không cần hard-code thứ nếu không có năm | Dùng ngày động khi triển khai; mockup thống nhất “Hôm nay” hoặc một ngày mẫu được kiểm tra. |

Các nhận xét nội dung Nhật ở đây chỉ ra điểm cần sửa trong brief/biên tập; không thay thế bước chuyên môn rà soát toàn bộ kho bài học.

## 4. PROMPT 1 — Sửa bộ màn hiện có trước khi mở rộng

```text
Review và chỉnh đúng các frame Bunly đang có trên canvas, giữ palette xanh, font Noto Sans/Noto Sans JP, 4 tab, sentence block và component sheet. Không tạo một phiên bản app khác hoặc duplicate các màn cùng nhiệm vụ. Trước khi sửa hãy liệt kê frame đích và sau khi sửa liệt kê frame đã cập nhật.

1. Sửa tiêu đề sai: S12 là “Ngữ pháp trong câu”; S31 nhập là “Dịch Việt → Nhật”, phản hồi là “Góp ý bài dịch”; S34 là “Kiểm tra lời nói”; S35 là “Góp ý câu nói”. Không dùng “Chi tiết tiến độ” cho voice/dịch. Cùng mẫu 〜たことがある dùng cùng metadata N5 như S08/S31 hiện tại.
2. Xóa “Độ khớp 99%”, số tăng 70% khả năng ghi nhớ, nguồn giáo trình chưa được cung cấp/xác minh. Không thay bằng số/nguồn mới tự tạo. Dùng “Gợi ý từ câu — bạn có thể kiểm tra lại”, “Nội dung từ kho Bunly” và “Ôn lại các mẫu thường sai” theo đúng ngữ cảnh.
3. Thay “Bản sửa chuẩn xác nhất” bằng “Gợi ý sửa giữ nguyên ý”. Giữ nhiều cách diễn đạt hợp lệ. Phân biệt lỗi ngữ pháp với lựa chọn văn phong. Không coi câu thân mật hoặc câu đúng khác đáp án mẫu là sai.
4. S08 không trình bày note cá nhân “không dùng mẫu này cho hôm qua/tuần trước” như quy tắc chuẩn. Dùng note minh họa trung tính: “So sánh cách kể một việc cụ thể với cách nói về trải nghiệm”. Dịch nattō là “đậu nành lên men nattō”, dùng “3 ví dụ” thay “3 câu thật” khi không có xuất xứ. Không tự gán “cấm đoán nhẹ nhàng”.
5. S37 thống nhất đơn vị đếm bài độc lập/lần thử/lỗi và khoảng thời gian; mọi tỷ lệ có mẫu số. Không gộp nhận xét AI thành tỷ lệ quiz. Bỏ phần trăm ghi chép 60% nếu chưa có định nghĩa. Toàn bộ số liệu mockup dùng một dataset minh họa nhất quán, không coi là dữ liệu Bunly hiện tại.
6. Hôm nay có bài đến hạn thì ưu tiên CTA ôn; quét/dán vẫn dễ tìm nhưng không chiếm khối lớn hơn việc ưu tiên. Người mới chưa có bài ôn có layout empty riêng ưu tiên quét/tra cứu.
7. Giảm card lồng card và nhiều lớp xanh. Nền đọc trung tính, màu xanh tập trung ở CTA/selection/đoạn Nhật được nhấn. Giữ body dễ đọc, vùng chạm 48dp, tiếng Nhật xuống dòng tự nhiên. Chuẩn hóa viết hoa tiêu đề theo câu, không Title Case mọi từ.
8. Gộp nút sửa câu trùng chức năng ở S12. Giữ query, bản nháp, câu nguồn và nơi quay về. Các liên kết và CTA ghi rõ frame đích thay vì chỉ dùng # nếu chưa nối được prototype.

Đầu ra: sửa các frame hiện hữu, kèm note ngắn các chỉnh sửa; không tự thêm tính năng hoặc đổi navigation. Chưa gọi là flow hoàn chỉnh nếu mới có màn kết quả mà thiếu màn nhập/xác nhận.
```

## 5. PROMPT 2 — Hoàn thiện luồng Voice và Dịch còn thiếu bước

```text
Tiếp tục trong project Bunly hiện tại sau khi đã sửa tiêu đề và component. Hoàn thiện hai chuỗi sau, dùng lại các frame kết quả đã có:

A. Voice: S33 “Nói một câu” → S34 “Kiểm tra lời nói” → S35 “Góp ý câu nói” → nói lại → S36 so sánh lần thử → S18 tổng kết.
S33 có đề bài/mẫu mục tiêu, ghi chủ động, đang ghi, dừng, nghe lại, ghi lại và nhập tay thay thế. Xin micro khi bấm ghi, không tự thu âm. S34 chỉ có transcript sửa được, nghe lại và CTA “Gửi để góp ý”; chưa hiện nhận xét AI trước khi xác nhận. S35 chỉ nhận xét bản đã xác nhận, ghi rõ nếu transcript đã được sửa. Khi sửa transcript sau đánh giá, nhận xét cũ được đánh dấu không còn áp dụng cho bản mới; gửi lại mới có nhận xét mới. Không chấm phát âm/accent/độ trôi chảy từ văn bản. Có lỗi quyền micro, im lặng, ASR sai, offline và AI lỗi; giữ bản nháp.

B. Dịch: S31 trạng thái đề bài + editor Nhật chưa nộp → đang đánh giá → S32 góp ý → tự sửa → S36 so sánh → S18.
Dùng bài “Tôi đã từng đi Nhật”, mẫu 〜たことがある. Phản hồi ba tiêu chí đúng ý/ngữ pháp mục tiêu/tự nhiên. Chấp nhận 日本に行ったことがあります và 日本へ行ったことがあります. Với 日本に行くことがあります, giải thích khác nghĩa theo ngữ cảnh rồi đề xuất sửa giữ ý, không chỉ tô đỏ và chấm điểm. Có câu đúng nhưng chưa dùng mẫu yêu cầu, nhiều bản dịch hợp lệ, câu mơ hồ cần ngữ cảnh, gợi ý đã dùng và lỗi AI/hết lượt. Không tự ghi đè câu đang soạn bằng bản AI.

Giữ một shell tiến trình/thoát phiên và một hệ sentence/feedback. Không dùng bottom navigation trong lúc ghi âm/làm bài. Nối CTA tới frame đích hoặc ghi rõ liên kết dự kiến; tránh gộp ba trạng thái thời gian khác nhau vào một màn tĩnh.
```

## 6. PROMPT 3 — Bổ sung Quiz, Typing và tiến độ có bằng chứng

```text
Giữ đúng bộ UI Bunly đã chốt; tạo các nhóm còn thiếu, không tạo thêm tab:

S27 chọn phiên theo đến hạn/mẫu đang đọc/điểm yếu; S28 MCQ; S29 điền khuyết; S30 typing; S17 phản hồi tại chỗ; S18 tổng kết; S38 lịch sử bài làm; S39 chi tiết tiến độ; S40 mục tiêu và việc nên luyện tiếp. Dùng S37 sổ lỗi hiện có làm lối vào luyện lại. Nếu số lượng frame lớn, tạo nhóm câu hỏi/tổng kết trước, lịch sử/tiến độ ở lượt sau và ghi rõ phần chưa tạo.

MCQ có lựa chọn, khóa sau nộp, giải thích. Điền khuyết làm rõ chỗ trống và biến thể input. Typing có đáp án xác định khác typing tự đặt câu: đáp án xác định chấp nhận cách viết hợp lệ, câu mở dùng góp ý AI có nhãn. Không gửi khi bàn phím Nhật đang compose. Phản hồi giữ nguyên câu hỏi và câu người học trả lời, nút tiếp theo rõ; tổng kết nối về mẫu sai/ôn tiếp.

Tiến độ hiển thị đúng/tổng của quiz và lần đầu/thử lại/dùng gợi ý; nhận xét AI tách riêng, transcript đã chỉnh có nhãn. Số mẫu tự chọn “Đã nắm” không được coi là số bài đạt. Mọi chỉ số mở được lịch sử/bài làm minh chứng. Ít dữ liệu thì nói chưa đủ dữ liệu; không radar chart, điểm năng lực JLPT hoặc phần trăm chung tự tạo. N3–N1 chỉ hiện nội dung sẵn có, không tạo curriculum giả.

Flow phải nối được: Hôm nay → phiên ôn → câu → phản hồi → tổng kết → sổ lỗi → luyện lại → lịch sử/tiến độ. Tạo trạng thái chưa trả lời, sai/đúng, thoát có bản nháp, offline và chưa có bài phù hợp. Bài biên tập tải sẵn có thể dùng offline, nhận xét AI cần mạng. Dùng lại light/dark tokens, button, input, status và typography của canvas.
```

## 7. PROMPT 4 — Audit và nối flow toàn bộ project

```text
Audit project Bunly sau các lượt bổ sung. Lập danh sách frame đã có theo ID; chỉ nhận một flow hoàn chỉnh khi đủ bước đầu vào, xác nhận, xử lý, kết quả, thử lại/lưu và lối thoát. Giữ các frame hoàn chỉnh, sửa hoặc bổ sung đúng khoảng trống; không sinh thêm bộ thiết kế song song.

Kiểm tra 5 flow: quét/dán → sửa OCR → kết quả → chi tiết → luyện; tra cứu → chi tiết → ghi chú → Sổ học; voice → xác nhận transcript → góp ý → nói lại; dịch → góp ý ba tiêu chí → thử lại; ôn đến hạn → quiz → tổng kết → sổ lỗi → tiến độ. Nếu camera/OCR/Sổ học/tiến độ chưa có frame, ghi rõ và tạo nhóm thiếu theo brief đã cung cấp. Bổ sung Auth/hồ sơ/cài đặt theo brief gốc khi cần, không coi nút avatar là đã có tài khoản hoàn chỉnh.

Soát tên màn, metadata N5/N4, số liệu minh họa, trạng thái active của 4 tab, CTA, đường back, input/bản nháp, trạng thái sync, quyền micro/camera, lỗi/hết lượt và màn ít dữ liệu. Voice/dịch không mang tiêu đề tiến độ. Không nguồn/chỉ số AI tự bịa. Ngày hiển thị thống nhất.

Tạo dark cho các loại màn tiêu biểu, biến thể 360dp, font lớn và bàn phím Nhật mở. Không ép toàn bộ trang dài vào một viewport làm chữ nhỏ. Đầu ra là danh mục flow đã nối, frame bổ sung/sửa và các chỗ chỉ là mô phỏng. Nếu có prototype đang tạo dở, không tuyên bố hoàn thành trước khi các đường tương tác được kiểm tra.
```

## 8. Cách dùng các prompt

Gửi prompt 1 để sửa nền trước; sau đó prompt 2 cho Voice/Dịch, prompt 3 cho bài tập/tiến độ, cuối cùng prompt 4 để soát toàn project. Nếu bộ màn thay đổi sau lúc review, dùng các quan sát ở mục 3 như checklist và chỉ sửa vấn đề còn tồn tại. Các prompt bổ sung tính năng đầy đủ nằm ở [Voice & Practice](BUNLY-STITCH-EXTENSION-VOICE-PRACTICE.md).
