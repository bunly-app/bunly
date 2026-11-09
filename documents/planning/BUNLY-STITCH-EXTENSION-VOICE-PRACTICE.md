# Bunly — Prompt bổ sung Voice, bài tập đa dạng và tiến độ

Ngày: 31/10/2026. Dùng để bổ sung vào project Google Stitch đã tạo từ [brief giao diện gốc](BUNLY-UI-IDEA-STITCH.md). Đây là thiết kế sản phẩm đích, chưa phải tính năng đã triển khai.

## 1. Cập nhật định hướng sản phẩm

Bunly giúp người Việt **hiểu và sử dụng được ngữ pháp tiếng Nhật từ nội dung thực tế**, đi từ nhận diện sang chủ động đặt câu, nói và dịch. Đối tượng là sinh viên và người tự học từ cơ bản đến nâng cao, đặc biệt người học JLPT hoặc gặp tiếng Nhật trong giáo trình, tài liệu, manga và website.

Chu trình mở rộng:

**Gặp câu → hiểu ngữ pháp → lưu ngữ cảnh → luyện nhận biết → tự viết/dịch/nói → nhận phản hồi → sửa và thử lại → ôn theo điểm yếu → theo dõi tiến bộ.**

Yêu cầu mới của người dùng mở rộng brief cũ: bổ sung voice để sửa ngữ pháp, MCQ, điền khuyết, typing, dịch Việt → Nhật và định hướng N5–N1. N5–N4 vẫn là nền nội dung ban đầu; không hiển thị N3–N1 như kho đã sẵn sàng nếu chưa có nội dung. Voice ở đây tập trung vào **câu nói và ngữ pháp qua văn bản nhận dạng**, chưa đồng nghĩa đã có hệ thống chấm phát âm.

Giữ 4 tab `Hôm nay · Tra cứu · Sổ học · Tiến độ`. Bài luyện mở từ Hôm nay, Chi tiết mẫu, kết quả phân tích, Sổ học và nhóm điểm yếu trong Tiến độ. Không thêm một tab cho mỗi loại bài, không biến Bunly thành chatbot tổng quát.

## 2. Cách bổ sung vào các màn hiện tại

| Màn đã có | Bổ sung cụ thể |
|---|---|
| S06 — Hôm nay | Giữ việc ôn đến hạn ở vị trí ưu tiên; thêm một lựa chọn “Luyện viết & nói” bên dưới. Đề xuất một nhiệm vụ cụ thể như “Đặt câu với 〜たことがある”, không xếp 5 nút loại bài cạnh tranh nhau. |
| S08 — Chi tiết mẫu | CTA “Luyện tập mẫu này” mở lựa chọn dạng bài khi cần. Ví dụ có thể nghe nếu audio thực sự tồn tại. Khu “Tự đặt câu” dẫn tới typing tự do hoặc nói một câu có dùng mẫu. |
| S12 — Kết quả phân tích | Sau khi mở mẫu, có thể luyện từ chính ngữ cảnh đã xác nhận; chọn bài phù hợp nội dung, không hứa tự sinh bài đúng từ mọi ảnh. |
| S13 — Sổ học | Thêm vùng “Câu đã sửa” và liên kết tới lịch sử bài làm; một câu có bản gốc, bản sửa, mẫu mục tiêu và lần thử. Không mặc định lưu mọi bản ghi âm. |
| S15 — Chuẩn bị phiên | Chọn nguồn bài và các dạng có sẵn; hiển thị loại bài cần AI/mạng hoặc micro. Phiên ôn mặc định được đề xuất sẵn để vào học nhanh. |
| S16–S17 — Câu hỏi/phản hồi | Dùng chung shell tiến trình và nút kiểm tra; thay component trả lời theo loại bài. Không ép MCQ, typing, dịch và voice vào cùng một layout cứng. |
| S18 — Tổng kết | Tách kết quả bài có đáp án xác định và nhận xét AI cho câu mở; hiển thị mẫu cần luyện lại và nút vào phiên tiếp theo. |
| S20 — Tiến độ | Thêm kết quả theo dạng bài, lỗi lặp lại, lịch sử thử lại; phân biệt tự đánh giá, điểm quiz và nhận xét AI. |
| S21 — Mục tiêu | Định hướng N5–N1; cấp chưa có nội dung ghi “Chưa có nội dung”, vẫn cho sửa mục tiêu sau. Không có bài kiểm tra đầu vào thì không tự kết luận trình độ thực. |
| S24/S25/S26 | Phản ánh kết quả AI đang chờ, hạn mức cho voice/dịch nếu backend quy định, quyền micro và lựa chọn lưu/xóa âm thanh. Không bịa chính sách hoặc quota riêng cho mỗi dạng bài. |

## 3. Các dạng bài và thiết kế tương tác

| Dạng | Mục tiêu | Input và hành động | Phản hồi đúng loại |
|---|---|---|---|
| MCQ | Nhận biết ý nghĩa/cấu trúc phù hợp ngữ cảnh | Một câu và một đáp án đúng trong các lựa chọn; chọn → Kiểm tra | Đáp án người học, đáp án đúng, giải thích vì sao đúng và vì sao lựa chọn sai không phù hợp. Khóa đáp án sau nộp. |
| Điền khuyết | Gọi lại trợ từ/cách chia/cấu trúc | Làm nổi bật chỗ trống; có thể nhập hoặc chọn từ ngân hàng, ghi rõ biến thể bài | Chấp nhận các đáp án hợp lệ do nội dung quy định; giải thích lỗi vị trí cụ thể. Không biến mọi bài thành MCQ trá hình. |
| Typing có đáp án | Tự viết từ/cụm/câu theo yêu cầu xác định | Bàn phím tiếng Nhật, câu gợi ý và trường nhập; chỉ kiểm tra khi bấm | So sánh theo các đáp án được chấp nhận, xử lý khoảng trắng/dấu câu hợp lý; không đánh sai chỉ vì một cách viết tương đương. |
| Typing tự đặt câu | Dùng mẫu trong ý định của người học | Mẫu mục tiêu + tình huống hoặc ý định; trường soạn nhiều dòng | AI phân tích đúng ý, cấu trúc mục tiêu, lỗi ngữ pháp và cách nói tự nhiên. Không áp chấm exact-match. |
| Dịch Việt → Nhật | Diễn đạt ý và dùng ngữ pháp phù hợp | Câu Việt, ngữ cảnh/người nghe, yêu cầu mẫu nếu bài bắt buộc; câu trả lời Nhật | Ba tiêu chí riêng: truyền đạt ý, ngữ pháp mục tiêu, độ tự nhiên. Có nhiều bản dịch đúng; một câu mẫu không phải đáp án duy nhất. |
| Voice — tự nói/đặt câu | Thực hành tạo câu bằng lời nói và sửa ngữ pháp | Đề bài hoặc mẫu → ghi âm → nghe lại → xác nhận transcript → gửi nhận xét | Sửa câu dựa trên văn bản người học đã xác nhận, kèm lý do. Lỗi nhận dạng giọng nói được xử lý trước khi đánh giá. |

Không cần thêm bài nghe/thi JLPT đầy đủ chỉ vì có nút audio. Những chức năng đó cần yêu cầu riêng. Phiên ôn có thể trộn dạng bài đã có nội dung, ưu tiên mẫu sai hoặc đến hạn; không ép mọi mẫu phải có đủ mọi dạng.

## 4. Danh sách frame bổ sung cho Stitch

Dùng ID mới S27–S40, giữ ID cũ cho các màn được mở rộng. Các trạng thái của cùng tác vụ có thể nằm trong cùng nhóm frame.

| ID | Tên | Nội dung và CTA |
|---|---|---|
| S27 | Trung tâm luyện tập / chọn phiên | Nguồn: đến hạn, mẫu đang đọc, điểm yếu, tự chọn. Danh sách dạng bài có mô tả ngắn và nhãn sẵn sàng/cần mạng; CTA “Bắt đầu phiên”. Chỉ hiện bước này khi người học cần lựa chọn. |
| S28 | MCQ | Câu hỏi, ngữ cảnh, đáp án có vùng chạm lớn, tiến trình; CTA “Kiểm tra”. Biến thể phản hồi cùng màn. |
| S29 | Điền khuyết | Câu Nhật với vị trí trống rõ, trường nhập hoặc ngân hàng từ; CTA “Kiểm tra”; có trạng thái nhiều đáp án hợp lệ. |
| S30 | Typing | Biến thể trả lời xác định và biến thể tự đặt câu có nhãn phân biệt; nút gửi, bản nháp, bàn phím; không gửi trong lúc IME đang compose. |
| S31 | Dịch Việt → Nhật | Câu Việt, ngữ cảnh, mẫu mục tiêu nếu có; editor Nhật, gợi ý có thể mở chủ động; CTA “Nhận góp ý”. Gợi ý trước khi nộp phải được ghi nhận khi tổng kết. |
| S32 | Phản hồi câu viết/bài dịch | Bản gốc, 3 tiêu chí, lỗi được đánh dấu, bản sửa tối thiểu, cách nói tự nhiên tùy chọn; CTA “Tự sửa và thử lại”; nút lưu câu sửa là phụ. |
| S33 | Nói một câu | Mẫu/tình huống, bắt đầu/đang ghi/tạm dừng hoặc dừng/nghe lại/ghi lại; thời lượng thật và trạng thái micro. CTA sau ghi âm: “Kiểm tra văn bản nhận dạng”. |
| S34 | Xác nhận lời nói | Transcript sửa được, nghe lại bản ghi nếu còn lưu, nhãn câu do máy nhận dạng; CTA “Gửi để góp ý ngữ pháp”. Nếu sửa transcript, đánh dấu nhận xét dựa trên bản đã sửa. |
| S35 | Góp ý câu nói | Câu đã xác nhận, đoạn lỗi, bản sửa giữ ý, lý do tiếng Việt, cách nói tự nhiên; CTA “Nói lại”; lựa chọn “Tôi muốn nói ý khác” để bổ sung ý định. |
| S36 | So sánh lần thử | Câu lần đầu/lần mới, lỗi đã khắc phục/còn tồn tại; không dùng bảng điểm tiến bộ giả. CTA “Lưu và tiếp tục”; có thể mở chi tiết từng lần. |
| S37 | Sổ lỗi cần ôn | Nhóm theo cấu trúc, trợ từ, cách chia, thiếu ý, văn phong; số lần theo dữ liệu thực; chạm xem ví dụ của chính người học; CTA “Luyện lại nhóm này”. |
| S38 | Lịch sử bài làm | Lọc thời gian, dạng bài, mẫu, có/không hỗ trợ; hàng bài có kết quả và trạng thái AI đang chờ/lỗi; mở chi tiết, không tự xóa lần làm cũ khi thử lại. |
| S39 | Tiến độ luyện tập chi tiết | Mở từ S20: quiz đúng/tổng, mẫu đã luyện, kết quả từng dạng, lỗi lặp lại và so sánh khoảng thời gian có dữ liệu. Mỗi chỉ số dẫn được tới bài làm minh chứng. |
| S40 | Mục tiêu và đề xuất luyện tiếp | N5–N1 theo nội dung sẵn có, thời gian/ngày, ưu tiên nhận biết/viết/dịch/nói; việc tiếp theo cụ thể và lý do đề xuất. Không tạo giáo trình nâng cao trống. |

Bottom sheet dùng chung: chọn dạng bài, giải thích tiêu chí đánh giá, quyền micro bị từ chối, hết lượt AI, xin thoát khi có bản nháp, xác nhận xóa bản ghi. Không biến các sheet thành tab điều hướng mới.

## 5. User flow mới

### V1 — Luyện nói và sửa ngữ pháp

S08 “Tự đặt câu” hoặc Hôm nay “Luyện viết & nói” → S27 nếu cần chọn dạng → S33 → ghi âm → dừng → S34 → nghe/đọc/sửa transcript → gửi → S35 → tự sửa/nói lại → S33/S34 → S36 → lưu câu đã chọn → tổng kết S18 → lịch ôn.

Không bật ghi âm khi vừa vào màn. Xin quyền micro sau khi bấm ghi. Có thể nhập câu thay thế khi từ chối quyền hoặc không tiện nói. Chỉ phân tích sau xác nhận, không gửi lặp mỗi đoạn âm thanh. Nếu ASR không nghe được thì chưa chấm ngữ pháp; nếu nhận sai thì cho sửa trước. Đánh giá transcript đã sửa không được trình bày là bằng chứng người học đã nói đúng câu đó.

### V2 — Dịch và học từ phản hồi

Chọn bài dịch S31 → đọc ngữ cảnh/mẫu mục tiêu → tự dịch → Nhận góp ý → S32 → xem thiếu ý/lỗi mẫu/cách diễn đạt → tự sửa và gửi lại → S36 → lưu hoặc tiếp tục bài khác → S18. Cho mở gợi ý theo yêu cầu; lưu việc đã dùng gợi ý. Không thay câu đang soạn bằng bản AI nếu người học chưa chọn áp dụng.

### V3 — Quiz và ôn có mục đích

Hôm nay “Ôn đến hạn” → vào thẳng câu đầu S28/S29/S30 khi không cần setup → Kiểm tra → phản hồi giữ nguyên câu hỏi → Câu tiếp theo → S18 → nhóm sai S37 → phiên luyện lại. Không hiển thị lời giải trước khi nộp. Làm lại có đáp án vừa xem không tính như lần trả lời độc lập đầu tiên.

### V4 — Học từ lỗi lặp lại

Tiến độ S20 → S39 → nhóm “Cách chia trước 〜たことがある” → S37 → xem các lần sai → mở S08 để đọc lại → luyện đúng nhóm đó → S36/S18 → cập nhật tiến độ. Lịch sử cũ vẫn giữ để thấy quá trình sửa.

### V5 — Từ nội dung thực tế tới bài luyện

Quét/dán câu → xác nhận → S12 → S08 → chọn loại luyện → bài gắn cấu trúc/ngữ cảnh đó → phản hồi → lưu/ôn. Nếu chưa có bài biên tập phù hợp, thông báo rõ và cho tự đặt câu để nhận góp ý; nội dung AI tạo phải có nhãn và cơ chế kiểm tra, không giả thành câu hỏi biên tập đã được kiểm chứng.

Với manga hoặc lời thoại, nhận xét phải xét văn nói, rút gọn và quan hệ người nói/người nghe. Không sửa mọi câu thân mật thành văn lịch sự rồi gọi bản gốc là sai ngữ pháp.

## 6. Hợp đồng phản hồi AI để thiết kế đúng

### Ba tiêu chí cho bài dịch

| Tiêu chí | Cần giải thích | Cách thể hiện |
|---|---|---|
| Truyền đạt đúng ý | Chủ thể, hành động, thời gian, phủ định, sắc thái và thông tin quan trọng | “Đủ ý”, “Thiếu một phần ý”, “Khác ý”, hoặc “Chưa đủ ngữ cảnh”; dẫn đúng đoạn liên quan. |
| Ngữ pháp mục tiêu | Có dùng mẫu được yêu cầu không, dạng kết hợp/cách chia/trợ từ có đúng không | “Dùng đúng”, “Cần sửa”, “Chưa dùng mẫu yêu cầu”; phân biệt câu đúng nhưng chưa đạt mục tiêu bài. |
| Độ tự nhiên | Cách chọn từ, kết hợp từ, mức lịch sự và văn phong theo ngữ cảnh | “Phù hợp ngữ cảnh”, “Có cách diễn đạt tự nhiên hơn”, hoặc “Cần thêm ngữ cảnh”. Không gắn mọi cải thiện tự nhiên thành lỗi bắt buộc. |

Mỗi góp ý có: đoạn gốc → loại vấn đề → giải thích tiếng Việt → sửa tối thiểu → bản tự nhiên hơn nếu hữu ích. Không chỉ đưa điểm và một câu “cố gắng thêm”. Chưa có rubric số được kiểm chứng thì dùng nhãn mô tả; không tự tạo điểm 92/100 hoặc confidence 99%.

**Ví dụ minh họa xuyên suốt:**

- Đề: “Tôi đã từng đi Nhật.” Mẫu mục tiêu: `〜たことがある`.
- Câu người học: `日本に行くことがあります。`
- Góp ý: câu hiện tại có thể diễn đạt “Có lúc tôi đi Nhật”; nếu muốn nói trải nghiệm đã từng thì dùng thể た trước `ことがあります`.
- Sửa giữ ý: `日本に行ったことがあります。`
- Cũng chấp nhận `日本へ行ったことがあります。`; không đánh sai chỉ vì khác trợ từ với câu mẫu.
- Không hứa rằng mọi bài chỉ có một cách dịch đúng; khi câu Việt mơ hồ, hỏi ý định hoặc nêu cách hiểu trước khi nhận xét.

Voice dùng cùng cấu trúc góp ý nhưng có bước xác nhận lời nói. Nếu người học nói tự do mà thiếu ý định, chỉ ra những lỗi có căn cứ và hỏi thêm khi cần; không tự gán một nghĩa rồi sửa theo nghĩa đó. Không suy ra phát âm, accent, độ trôi chảy hay năng lực nghe từ transcript.

## 7. Theo dõi tiến độ có ích và có căn cứ

S20 tóm tắt ít chỉ số; S39 là drill-down, S38 là bằng chứng. Giữ thao tác “luyện tiếp” gần chỉ số; không biến màn thành dashboard dày đặc.

- **Hoạt động:** số câu đã làm, số ngày học, thời gian phiên nếu đo được, số mẫu đã luyện. Không đánh đồng thời gian mở app với thời gian học hiệu quả.
- **Quiz xác định:** đúng/tổng, theo dạng bài và mẫu; cho biết khoảng thời gian và cách tính lần đầu/thử lại. Không cộng tất cả lần làm lại để tô đẹp tỷ lệ.
- **Câu mở:** thống kê các nhận xét theo tiêu chí, số lỗi mục tiêu đã sửa và số lần chưa được đánh giá; nhãn “Góp ý AI”. Không gộp thành điểm chính xác khách quan chung với MCQ.
- **Mức ghi nhớ:** trạng thái tự chọn Mới/Đang học/Cần ôn/Đã nắm vẫn riêng với lịch ôn và kết quả bài làm. Đổi trạng thái không tự tạo bài làm đạt.
- **Viết/dịch/nói:** có kết quả riêng theo dạng, không suy ra kỹ năng nói tốt chỉ vì transcript được người học sửa đẹp. Bài dùng gợi ý và bản transcript đã chỉnh có nhãn trong lịch sử.
- **Lỗi lặp lại:** mẫu/trợ từ/cách chia nào xuất hiện nhiều lần, ví dụ thật, lần gần nhất và bài đề xuất. Một lỗi chỉ sửa trên cùng câu chưa đủ kết luận đã thành thạo mẫu.
- **JLPT:** cho biết đã luyện bao nhiêu mẫu trong kho của cấp đó và phần còn thiếu. Không dự đoán điểm thi hoặc tuyên bố “đạt N2” từ vài bài luyện.
- **Dữ liệu ít:** hiện “Chưa đủ bài để so sánh”, CTA làm một phiên ngắn. Không radar chart, heatmap hoặc đường tăng trưởng trang trí từ dữ liệu giả.

## 8. Trạng thái và ràng buộc cần thể hiện

| Khu vực | Trạng thái bắt buộc | Hành vi giữ trải nghiệm |
|---|---|---|
| Micro | Chưa cấp quyền, bị từ chối, đang ghi, dừng, nghe lại, không có âm thanh, bị gián đoạn | Có dấu hiệu ghi thật, ghi lại/xóa/chuyển nhập tay; không tự thu âm nền. |
| Nhận dạng lời nói | Đang xử lý, không nhận ra, không phải tiếng Nhật, transcript cần kiểm tra | Giữ bản ghi nếu người dùng còn giữ; sửa văn bản hoặc thử lại. Không mặc định mọi thiết bị đều ASR offline. |
| AI | Đang chờ, xử lý, timeout, lỗi, hết lượt, kết quả chưa đủ căn cứ | Giữ câu/bản nháp, thử lại có chủ đích; chưa có kết quả thì không tính bài đạt. Không trừ lượt lặp trên UI theo phỏng đoán. |
| Bàn phím Nhật | IME đang compose, hoàn tất nhập, bàn phím che nút, câu dài | Không submit khi Enter đang xác nhận ký tự; editor cuộn được, CTA tiếp cận được. |
| Kết quả | Đúng có nhiều cách nói, sai mẫu nhưng câu hợp lệ, mơ hồ, không đồng ý nhận xét | Có giải thích và “Báo góp ý chưa phù hợp”; không biến phản đối của người dùng thành tự chấm đạt. |
| Offline/sync | Bài biên tập đã tải dùng offline; chấm AI cần mạng; bản nháp/pending còn trên máy | Giữ nội dung, đánh dấu chưa nhận góp ý; không hứa AI hoặc ASR offline khi chưa có hỗ trợ. |
| Riêng tư | Ghi âm có chủ đích, chọn giữ/xóa, giải thích dữ liệu gửi đi | Quy định lưu/xóa và thời hạn chỉ được khẳng định khi đã có chính sách/triển khai; ghi chú thiết kế không giả thành cam kết vận hành. |

Khi thoát hoặc đổi tài khoản, bản nháp/lịch sử/bản ghi thuộc đúng người. Không tự phát audio khi mở màn. Nút nghe mẫu chỉ hiện khi có nguồn audio; có trạng thái tải/lỗi. Lịch ôn và cách điều chỉnh theo kết quả cần được đặc tả nghiệp vụ, không để Stitch tự đặt thuật toán.

## 9. PROMPT BỔ SUNG CHÍNH — dán vào project Stitch hiện tại

```text
Hãy mở rộng project giao diện Bunly đang có trên canvas, giữ nguyên hệ thống thiết kế và các màn đã tạo. Dùng bộ component sheet, Material 3, màu xanh Bunly, typography Noto Sans/Noto Sans JP, các hàng mẫu ngữ pháp, cách đánh dấu câu Nhật và 4 tab Hôm nay / Tra cứu / Sổ học / Tiến độ làm chuẩn. Không thiết kế một app mới, không thêm tab AI/Voice riêng, không nhân bản Hôm nay/Tra cứu/Chi tiết thành các phiên bản khác nhau.

Cập nhật định hướng: Bunly dành cho sinh viên và người Việt tự học tiếng Nhật từ cơ bản tới nâng cao, học JLPT hoặc thường gặp tiếng Nhật trong giáo trình, tài liệu, manga, website và nội dung thực tế. Luồng xuyên suốt là gặp câu → hiểu ngữ pháp → lưu ngữ cảnh → luyện nhận biết → tự viết/dịch/nói → nhận góp ý → sửa và thử lại → ôn theo điểm yếu → theo dõi tiến bộ. N5–N4 là nền đầu tiên; N3–N1 chỉ hiển thị nội dung thực sự sẵn có hoặc ghi rõ chưa có nội dung.

Bổ sung luyện tập gồm MCQ, điền khuyết, typing có đáp án, tự đặt câu bằng typing, dịch Việt → Nhật, và nói một câu để nhận góp ý ngữ pháp. Lối vào nằm ở Hôm nay, Chi tiết mẫu, Sổ học và nhóm điểm yếu trong Tiến độ. Một phiên ôn rõ ràng được vào trực tiếp, không ép chọn lại nhiều màn. Từ Chi tiết, nút Luyện tập mẫu này cho chọn những dạng bài có nội dung phù hợp.

Các dạng bài dùng chung shell tiến trình, CTA Kiểm tra/Nhận góp ý, back/thoát và phản hồi; input thay đổi đúng tác vụ. MCQ dùng lựa chọn; điền khuyết có chỗ trống; typing có bàn phím Nhật; bài dịch có câu Việt + ngữ cảnh + mẫu mục tiêu nếu bắt buộc. Giữ bản nháp khi lỗi hoặc thoát. Không submit trong lúc IME đang compose. Bài có đáp án xác định chấp nhận các đáp án tương đương hợp lệ, câu mở không chấm exact-match.

Với bài dịch, AI góp ý riêng ba tiêu chí: truyền đạt đúng ý, dùng đúng ngữ pháp mục tiêu và độ tự nhiên theo ngữ cảnh. Mỗi góp ý phải chỉ đoạn gốc, lý do tiếng Việt, sửa tối thiểu giữ ý, và một cách nói tự nhiên hơn nếu cần. Phân biệt lỗi ngữ pháp bắt buộc với gợi ý văn phong. Một câu mẫu không phải bản dịch đúng duy nhất. Dùng nhãn mô tả, không bịa điểm 92/100 hoặc xác suất 99%. Cho tự sửa/thử lại, so sánh lần thử, lưu câu sửa, báo góp ý chưa phù hợp.

Luồng voice: người học chủ động bấm ghi → dừng → nghe lại → đọc/sửa transcript → xác nhận gửi → nhận góp ý ngữ pháp → nói lại. Hiển thị quyền micro, trạng thái ghi và thời lượng thật. Không thu âm tự động. Phân biệt lỗi nhận dạng giọng nói với lỗi ngữ pháp; chưa nhận được transcript thì chưa đánh giá. Khi transcript đã được sửa, ghi rõ đánh giá dựa trên bản sửa. Không chấm phát âm/accent/độ trôi chảy từ văn bản. Người học có thể nhập tay thay thế hoặc bổ sung ý định muốn nói.

Dùng ví dụ nhất quán: đề “Tôi đã từng đi Nhật”, mẫu 〜たことがある; người học viết/nói 日本に行くことがあります。 Giải thích câu này có thể mang nghĩa “Có lúc tôi đi Nhật”; để diễn đạt trải nghiệm đã từng, dùng 日本に行ったことがあります。 Cũng chấp nhận 日本へ行ったことがあります。 Không đánh sai vì khác một câu mẫu hợp lệ. Với manga/văn nói, xét quan hệ người nói và mức lịch sự, không sửa mọi câu thành văn trang trọng.

Mở rộng Tiến độ với tỷ lệ đúng/tổng của quiz, kết quả theo dạng bài, số mẫu đã luyện, lỗi lặp lại, lịch sử bài làm và đề xuất luyện tiếp. Tách lần làm đầu/thử lại/dùng gợi ý, tách góp ý AI của câu mở khỏi điểm quiz và trạng thái tự đánh giá. Không suy ra năng lực nói từ transcript đã sửa, không dự đoán điểm JLPT. Ít dữ liệu thì hiện chưa đủ dữ liệu và hành động học tiếp; không tạo radar chart hoặc biểu đồ trang trí.

Thêm các frame: S27 chọn phiên; S28 MCQ; S29 điền khuyết; S30 typing; S31 dịch Việt–Nhật; S32 phản hồi câu viết/dịch; S33 ghi âm câu nói; S34 xác nhận transcript; S35 góp ý câu nói; S36 so sánh lần thử; S37 sổ lỗi; S38 lịch sử bài làm; S39 chi tiết tiến độ; S40 mục tiêu/đề xuất. S17 là phản hồi trong shell bài luyện, S18 tổng kết phiên dùng chung. Giữ ID/tên màn, không tạo hai bộ màn cùng nhiệm vụ. Nếu tạo từng nhóm, liệt kê nhóm đã tạo và nhóm còn lại.

Tạo happy path cùng các trạng thái trực tiếp: chưa trả lời, đúng/sai, nhiều đáp án hợp lệ, micro bị từ chối, không nghe được, transcript sai, mất mạng, AI timeout/hết lượt, chưa đủ dữ liệu, bản nháp chưa gửi. Bài biên tập đã tải có thể học offline; nhận xét AI cần mạng. Giữ input và cho thử lại/tìm hiểu mẫu thay vì dead-end. Chỉ ghi “đã đồng bộ” khi thành công; quyền lưu/xóa audio là lựa chọn có giải thích, không tự tạo cam kết lưu trữ.

Giữ mobile 390×844 tham chiếu, kiểm tra 360dp, font lớn, safe area, bàn phím Nhật và light/dark. Dùng lại button, field, sentence block, feedback, status và navigation hiện có; bổ sung component trả lời, ghi âm, rubric và so sánh lần thử. Không thêm gradient neon, glassmorphism, mascot, dashboard bento, confetti, bảng xếp hạng hoặc màn chat tổng quát. Giảm lớp card/nền xanh lồng nhau; tăng vùng đọc trung tính và phân cấp chữ.

Soát lại các frame hiện có: bỏ nhãn “Độ khớp 99%” nếu không có số đo thật, bỏ trích giáo trình cụ thể khi không có nguồn, không trình bày ảnh/âm thanh hỏng như thành phần đã sẵn sàng. Dữ liệu ví dụ phải nhất quán và là dữ liệu minh họa. Thiết kế các tính năng tương lai không có nghĩa ứng dụng đã triển khai chúng.

Đầu ra cần là các frame có tên/ID, component dùng chung, mô tả CTA và đường chuyển màn, cùng các biến thể lỗi quan trọng. Nếu có prototype thì nối flow; nếu không, ghi rõ màn đích. Ưu tiên luồng học hoàn chỉnh và khả năng sử dụng, không chỉ tạo một collage các màn đẹp.
```

## 10. Prompt tạo theo lượt khi cần giới hạn số màn

Dùng prompt chính làm ngữ cảnh; sau đó gửi từng đoạn dưới. Đính kèm frame đã chốt nếu cần để giữ bộ component nhất quán.

### Lượt 1 — Quiz, điền khuyết, typing

```text
Tiếp tục đúng design system Bunly trên canvas. Chỉ làm nhóm S27–S30 và trạng thái S17/S18 dùng chung: chọn phiên, MCQ, điền khuyết, typing có đáp án và typing tự đặt câu. Phân biệt input và cách đánh giá từng loại; phản hồi giữ câu hỏi, chỉ lỗi cụ thể và giải thích. Có trạng thái chưa chọn/đang nhập/đã nộp/đúng/sai, màn bàn phím Nhật mở, thoát khi có bản nháp. Nối từ S08 Luyện tập mẫu này → chọn dạng nếu cần → bài → phản hồi → tổng kết. Không tạo lại 4 tab hoặc thay font/màu đang có.
```

### Lượt 2 — Dịch Việt → Nhật và sửa câu

```text
Dùng lại shell luyện tập và sentence block đã chốt. Tạo S31, S32, S36: dịch Việt → Nhật, phản hồi ba tiêu chí đúng ý / ngữ pháp mục tiêu / tự nhiên, và so sánh lần thử. Dùng ví dụ “Tôi đã từng đi Nhật” với 〜たことがある. Hiển thị câu gốc, đoạn cần sửa, lý do, sửa tối thiểu và cách nói tự nhiên tùy chọn. CTA chính là tự sửa/thử lại; áp dụng gợi ý cần hành động chủ động. Tạo thêm trường hợp câu đúng nhưng chưa dùng mẫu yêu cầu, câu có nhiều cách dịch đúng, AI lỗi/hết lượt và bản nháp được giữ. Không dùng điểm số tự bịa hoặc một đáp án duy nhất.
```

### Lượt 3 — Voice sửa ngữ pháp

```text
Giữ UI Bunly hiện tại. Tạo chuỗi S33 → S34 → S35 → nói lại → S36: chủ động ghi âm một câu theo mẫu, dừng/nghe lại, xác nhận hoặc sửa transcript, nhận góp ý ngữ pháp, thử lại. Lỗi ASR và lỗi ngữ pháp phải khác nhau. Hiển thị lời nhận dạng chưa xác nhận, bản người học sửa, thời lượng/ghi âm thật và quyền micro. Nếu không tiện nói, có nhập tay. Tạo trạng thái micro từ chối, không có tiếng, nhận sai, bị gián đoạn, AI chậm/lỗi và offline. Không chấm phát âm hay suy ra năng lực nói từ transcript, không biến luồng thành chatbot không có điểm kết thúc.
```

### Lượt 4 — Tiến độ, sổ lỗi và lịch sử

```text
Mở rộng S20, S13, S18; tạo S37–S40 cùng hệ thống UI đã có. Người học xem quiz đúng/tổng, kết quả từng dạng bài, mẫu đã luyện, nhóm lỗi lặp lại và lịch sử từng lần. Tách tự đánh giá / điểm quiz / góp ý AI; tách làm lần đầu / thử lại / dùng gợi ý / transcript đã sửa. Chạm chỉ số mở được bài làm liên quan và luyện lại nhóm yếu. Cấp N3–N1 chưa có nội dung phải ghi rõ, không giả dữ liệu. Có trạng thái ít dữ liệu và hết bài ôn. Hôm nay chỉ thêm một việc tiếp theo hữu ích; không nhồi toàn bộ số liệu lên trang chủ.
```

## 11. Checklist nhận bản thiết kế

- Có đủ MCQ, điền khuyết, typing, dịch và voice với input/phản hồi phù hợp từng loại.
- Có đường từ câu thật hoặc mẫu ngữ pháp tới bài luyện, từ lỗi tới ôn lại, từ tiến độ về bài làm.
- Voice có xác nhận transcript trước góp ý, đường nhập tay và quyền micro; không gộp ASR với ngữ pháp.
- Bài dịch có ba tiêu chí và nhiều đáp án hợp lệ; gợi ý giữ ý và văn phong ngữ cảnh.
- Lần thử lại được so sánh với lần trước; lời giải đã xem/gợi ý đã dùng không làm đẹp điểm giả.
- Có AI lỗi, hết lượt, offline, bản nháp, dữ liệu ít; không có màn cụt.
- Typography Nhật–Việt, 4 tab, màu, spacing, button và dark mode đồng bộ với bản gốc.
- Có phân biệt tính năng tương lai và kết quả triển khai; tài liệu M1/M2 chưa tự thay phạm vi theo mockup mới.
