# BÁO CÁO MỐC 1 — ĐỀ XUẤT ĐỀ TÀI VÀ NGUYÊN MẪU GIAO DIỆN

**Học phần:** Phát triển ứng dụng di động đa nền tảng (9)<br>
**Giảng viên:** TS. Nguyễn Thanh Tuấn<br>
**Tên đề tài:** **Bunly — Ứng dụng học và tra cứu ngữ pháp tiếng Nhật từ nội dung thực tế**<br>
**Tên tiếng Anh:** **Bunly — Learn Japanese Grammar from Real-World Content**<br>
**Nhóm:** Bunly • **Học kỳ:** Học kỳ 1, năm học 2026–2027 • **Hạn nộp theo template:** Tuần 4<br>
**Repository GitHub:** [bunly-app/bunly](https://github.com/bunly-app/bunly)

| Vai trò | Họ và tên | Mã sinh viên |
|---|---|---|
| Trưởng nhóm | Nguyễn Văn Hoàng | 23IT088 |
| Thành viên | Nguyễn Thị Ánh Vy | 23IT323 |
| Thành viên | Đoàn Nhật Ánh | 23IT.B007 |

> Đây là đề xuất ở mốc 1. Các chức năng và chỉ tiêu đánh giá là mục tiêu dự kiến, chưa phải kết quả triển khai.

---

## 1. ĐỘNG LỰC VÀ BÀI TOÁN THỰC TẾ

### 1.1. Bối cảnh và vấn đề

Người Việt học tiếng Nhật thường gặp cấu trúc ngữ pháp trong ảnh chụp bài học, giáo trình hoặc nội dung trực tuyến. Khi chưa biết tên cấu trúc, họ khó nhập đúng từ khóa để tra cứu. Việc tìm giải thích, lưu ví dụ, luyện tập và ôn đúng thời điểm cũng thường bị tách giữa nhiều công cụ. Kết quả là kiến thức gặp trong đời sống chưa được chuyển thành tiến độ học tập có thể theo dõi.

Bunly giải quyết vấn đề bằng một quy trình liên tục: **chụp/tải ảnh hoặc dán câu tiếng Nhật → nhận dạng văn bản → xác nhận văn bản → phát hiện ngữ pháp → xem giải thích → lưu → luyện tập → ôn tập**. AI hỗ trợ tìm cấu trúc theo ngữ cảnh; kho ngữ pháp do nhóm biên tập là nguồn giải thích chính.

### 1.2. Người dùng mục tiêu

| Nhóm | Mục tiêu | Khó khăn |
|---|---|---|
| **Chính:** sinh viên/người tự học tiếng Nhật, khoảng 18–30 tuổi, mức N5–N4 | Hiểu nhanh câu gặp trong bài học; duy trì ôn tập hằng ngày | Không biết từ khóa để tra; ghi chú và tiến độ phân tán |
| **Phụ:** người ôn JLPT N4 | Nhận diện điểm yếu và chọn nội dung ôn phù hợp | Khó theo dõi lỗi lặp lại và lịch ôn |

**Tình huống điển hình:** Một sinh viên chụp câu `日本へ行ったことがあります。` trong tài liệu. Bunly nhận dạng chữ trên thiết bị và cho sửa nếu OCR sai. Ứng dụng gợi ý mẫu `〜たことがある`, mở giải thích tiếng Việt, rồi cho lưu mẫu và làm một câu luyện tập. Khi đến hạn ôn, mẫu này xuất hiện trong danh sách học hôm nay.

### 1.3. Mục tiêu và tiêu chí nghiệm thu dự kiến

1. Tìm, lọc và đọc mẫu ngữ pháp N5–N4 với công thức, ý nghĩa, cách dùng và ví dụ có bản dịch tiếng Việt.
2. Nhận văn bản qua ảnh hoặc thao tác dán, cho người dùng xác nhận kết quả OCR, rồi liên kết các mẫu phát hiện được tới kho nội dung.
3. Lưu ghi chú, tiến độ, bài làm và lịch ôn trên thiết bị trước; đồng bộ dữ liệu cá nhân lên đám mây khi có mạng.
4. Giao diện theo Material 3, có chế độ sáng/tối; mục tiêu cuộn và chuyển màn hình ở khoảng 60 fps trên thiết bị thử nghiệm phù hợp. Số liệu thực đo sẽ có ở mốc 3.
5. Xác thực tài khoản, áp dụng Row-Level Security (RLS) cho dữ liệu riêng và giữ khóa LLM API ở phía máy chủ.

---

## 2. PHẠM VI HỆ THỐNG VÀ ĐẶC TẢ CHỨC NĂNG

### 2.1. Phạm vi MVP

MVP tập trung vào **biến câu tiếng Nhật người học bắt gặp thành một mục học tập và ôn tập cá nhân**. Kho ban đầu dự kiến khoảng **80–120 mẫu N5–N4** được nhóm chọn lọc và kiểm tra; đây là mục tiêu nội dung, chưa phải số lượng đã hoàn thành.

| # | Nhóm tính năng | Chức năng cụ thể | Ưu tiên | Quy tắc nghiệp vụ và phạm vi |
|:---:|---|---|---|---|
| 1 | Tài khoản & hồ sơ | Đăng ký/đăng nhập email; lưu trình độ, mục tiêu và thời gian học/ngày | Bắt buộc | Supabase Auth; dữ liệu cá nhân gắn `user_id` và được bảo vệ bằng RLS. Google/Apple Sign-in là phần mở rộng. |
| 2 | Kho ngữ pháp | Danh sách, tìm kiếm, lọc theo cấp độ/nhóm, trang chi tiết | Bắt buộc | Có công thức, ý nghĩa, cách dùng và ví dụ. Nội dung đã tải đọc được offline. |
| 3 | Học tập cá nhân | Lưu mẫu, ghi chú, trạng thái mới/đang học/cần ôn/đã nắm | Bắt buộc | Ghi cục bộ ngay và đồng bộ khi có mạng. |
| 4 | AI trên thiết bị | Chụp/chọn ảnh, OCR tiếng Nhật, xem và sửa văn bản | Bắt buộc | Google ML Kit Text Recognition; nếu OCR sai, người dùng sửa hoặc dán câu thủ công. |
| 5 | Phát hiện ngữ pháp | Phân tích câu và gợi ý cấu trúc | Bắt buộc | LLM qua Supabase Edge Function khi online; chỉ hiển thị mẫu có trong kho. Khi offline, cho tìm thủ công. |
| 6 | Luyện tập & ôn tập | Trắc nghiệm, điền chỗ trống, lịch ôn theo kết quả | Bắt buộc | Bài cơ bản dựa trên nội dung đã biên tập; trả lời sai được ôn sớm hơn. |
| 7 | Lộ trình & thống kê | Chọn mục tiêu N5/N4, bài học hôm nay, số mẫu đã học và độ chính xác | Bắt buộc | Gợi ý dựa trên tiến độ và hạn ôn; chưa cần mô hình gợi ý riêng. |
| 8 | Nhắc nhở | Thông báo học/ôn trên thiết bị | Bắt buộc | Người dùng bật/tắt và chọn giờ. |
| 9 | Mô hình Free/Pro | Hiển thị hạn mức AI và mô phỏng quyền sử dụng | Bắt buộc | Backend kiểm tra lượt dùng; bản học phần chưa xử lý thanh toán thật. |

**Ngoài phạm vi MVP:** nhận diện giọng nói, chấm phát âm, tạo toàn bộ giáo trình bằng AI, phân tích tài liệu dài, thanh toán thật và phát hành thương mại. Bài dịch Việt → Nhật có nhận xét bằng AI là hướng mở rộng sau khi luồng chính ổn định.

### 2.2. Luồng chính và ngoại lệ

```text
Trang chủ → Chụp/chọn ảnh hoặc dán câu → OCR trên thiết bị
→ Người dùng xác nhận/sửa câu → Edge Function kiểm tra tài khoản và hạn mức
→ AI gợi ý mẫu → Ghép với kho ngữ pháp → Xem giải thích
→ Lưu/ghi chú → Làm bài luyện → Lên lịch ôn → Đồng bộ đám mây
```

Không có mạng thì người dùng vẫn đọc nội dung đã tải, ghi chú, luyện tập cơ bản và chạy OCR sau khi thành phần nhận dạng sẵn sàng. Bước LLM thông báo cần kết nối. Nếu AI không tìm thấy mẫu trong kho, ứng dụng giữ câu gốc và cho tìm thủ công, thay vì trình bày suy đoán như kết luận chắc chắn.

### 2.3. Giá trị kinh doanh

Mô hình đề xuất là **Free/Pro**. Kho ngữ pháp, ghi chú, tiến độ và bài luyện cơ bản thuộc Free. Phân tích AI có hạn mức; Pro có hạn mức cao hơn và có thể bổ sung thống kê/lộ trình nâng cao. Hạn mức và giá bán cần được thử nghiệm với người dùng, chưa cam kết ở mốc 1. Bản trình diễn học phần chỉ mô phỏng quyền truy cập và kiểm tra hạn mức phía máy chủ.

---

## 3. CÔNG NGHỆ VÀ KIẾN TRÚC BAN ĐẦU

| Thành phần | Lựa chọn dự kiến | Vai trò |
|---|---|---|
| Framework | **Flutter, Dart 3** | Một mã nguồn cho Android/iOS; UI Material 3, sáng/tối |
| State management | **Riverpod 2** | Trạng thái màn hình và tác vụ bất đồng bộ |
| Kiến trúc | **Clean Architecture theo tính năng** | Tách `presentation`, `domain`, `data` |
| Cơ sở dữ liệu cục bộ | **SQLite qua Drift** | Lưu nội dung đã tải, tiến độ, ghi chú và hàng đợi đồng bộ |
| Backend | **Supabase Auth, PostgreSQL, RLS, Edge Functions** | Tài khoản, dữ liệu đám mây, bảo mật và cổng gọi LLM |
| AI trên thiết bị | **Google ML Kit Text Recognition (Japanese)** | OCR ảnh ngay trên điện thoại |
| AI trực tuyến | **LLM API qua Edge Function** | Phân tích câu và chọn mẫu phù hợp; nhà cung cấp/model chọn sau thử nghiệm |

### 3.1. Phân lớp Clean Architecture

```text
Presentation: màn hình, widget, Riverpod provider
       ↓
Domain: GrammarPoint, Note, Progress, use case, repository interface
       ↓
Data: repository implementation, Drift, Supabase, ML Kit adapter,
      Edge Function client
```

Các tính năng dự kiến gồm `auth`, `grammar`, `scanner`, `progress`, `notes`, `practice`, `learning_path` và `statistics`. UI gọi use case; use case phụ thuộc repository interface; lớp data triển khai nguồn cục bộ và từ xa.

### 3.2. Offline-first và đồng bộ

- **Đọc:** nội dung ngữ pháp đã tải được truy vấn từ SQLite, không cần mạng cho mỗi lần mở trang.
- **Ghi:** ghi chú, tiến độ và bài làm được lưu cục bộ ngay, kèm trạng thái đồng bộ; thao tác chưa gửi được xếp hàng.
- **Kết nối lại:** hàng đợi được gửi theo thứ tự, dùng mã thao tác để hạn chế bản ghi trùng; ứng dụng sau đó tải thay đổi mới từ Supabase.
- **Xung đột:** bài làm là bản ghi riêng, không ghi đè; tiến độ được tính lại hoặc hợp nhất từ bài làm; ghi chú dùng quy tắc thời gian cập nhật do server xác nhận. Quy tắc chi tiết sẽ được kiểm thử ở mốc 2–3.
- **Giới hạn:** OCR trên thiết bị có thể chạy offline; phân tích LLM và kiểm tra hạn mức cần mạng.

### 3.3. Bảo mật và chất lượng AI

Flutter gửi câu đã xác nhận tới Edge Function cùng phiên đăng nhập. Function kiểm tra danh tính và hạn mức, lấy các mẫu ngữ pháp ứng viên, gọi LLM bằng khóa bí mật phía server, kiểm tra cấu trúc đầu ra và chỉ trả ID có trong kho. RLS giới hạn người dùng chỉ đọc/sửa ghi chú và tiến độ của chính họ. Gợi ý AI có thể sai; người dùng luôn xem được câu OCR và có đường tra cứu thủ công.

Ở mốc 3, nhóm dự kiến đo độ chính xác ký tự OCR, precision/recall phát hiện mẫu trên tập câu tự gán nhãn, thời gian phản hồi, tỉ lệ lỗi đồng bộ và tốc độ khung hình. Mốc 1 chưa có số liệu thực nghiệm.

---

## 4. NGUYÊN MẪU GIAO DIỆN

### 4.1. Điều hướng dự kiến

```text
Đăng nhập → Onboarding: trình độ, mục tiêu, thời gian/ngày → Trang chủ
  ├── Kho ngữ pháp → Tìm kiếm/Lọc → Chi tiết → Lưu/Ghi chú
  ├── Quét câu → Ảnh hoặc dán câu → Sửa OCR → Kết quả → Chi tiết
  ├── Luyện tập → Câu hỏi → Phản hồi → Lịch ôn
  └── Tiến độ → Thống kê → Cài đặt/Chủ đề sáng-tối
```

| Màn hình | Nội dung và tương tác cốt lõi |
|---|---|
| Trang chủ | Mục tiêu hôm nay, số mẫu đến hạn ôn, nút Quét câu |
| Kho ngữ pháp | Tìm kiếm, bộ lọc N5/N4, danh sách mở được trang chi tiết |
| Chi tiết mẫu | Công thức, giải thích tiếng Việt, ví dụ, lưu mẫu, ghi chú, bắt đầu luyện tập |
| Quét câu | Chọn camera/thư viện hoặc dán câu; sửa OCR trước khi gửi AI |
| Kết quả | Câu gốc, đoạn được đánh dấu, mẫu đề xuất, đường tìm thủ công |
| Luyện tập | Trắc nghiệm/điền chỗ trống, phản hồi, cập nhật lịch ôn |
| Tiến độ | Số mẫu đã học, độ chính xác, mẫu còn yếu |

Giao diện theo Material 3, có vùng chạm phù hợp màn hình di động, chữ tiếng Nhật rõ, hỗ trợ cỡ chữ hệ thống và dark mode. Các tác vụ mạng có trạng thái tải/lỗi/thử lại; trạng thái offline được thể hiện ở luồng quét và đồng bộ.

**Nguyên mẫu tương tác:** [Tệp prototype Bunly (HTML)](./Bunly-Wireframe-Prototype.html); tải tệp và mở cục bộ trong trình duyệt để tương tác. Prototype cho phép chuyển giữa các màn hình chính, mô phỏng OCR → kết quả → chi tiết → luyện tập, tìm trong kho và chuyển sáng/tối. Đây là mô phỏng luồng và dữ liệu mẫu; camera, OCR, AI và đồng bộ thật thuộc các mốc triển khai tiếp theo. Nếu học phần bắt buộc URL Figma, nhóm cần bổ sung bản Figma trước khi nộp.

---

## 5. KẾ HOẠCH BỐN MỐC VÀ RỦI RO

| Mốc | Hạn theo template | Kết quả dự kiến |
|---|---|---|
| **1 — Đề xuất & wireframe** | Tuần 4 | Bài toán, persona, MVP, stack, luồng chính và nguyên mẫu tương tác |
| **2 — Kiến trúc & tính năng lõi** | Tuần 8 | Flutter/Clean Architecture, xác thực, kho ngữ pháp, ghi chú/tiến độ, schema Supabase, RLS và dữ liệu cục bộ |
| **3 — AI, offline & kiểm thử** | Tuần 11 | OCR, phân tích ngữ pháp qua Edge Function, đồng bộ offline, bộ kiểm thử AI và đo hiệu năng |
| **4 — Báo cáo cuối & bảo vệ** | Tuần 13 | Luồng end-to-end, UX/dark mode, demo trên thiết bị, báo cáo, slide và video |

**Phân công đề xuất để nhóm xác nhận:** trưởng nhóm điều phối và tích hợp kiến trúc; hai thành viên chia công việc UI/kho ngữ pháp và backend/AI/kiểm thử theo năng lực thực tế. Đây chưa phải phân công đã được các thành viên xác nhận.

| Rủi ro | Hướng xử lý |
|---|---|
| OCR sai vì ảnh mờ/chữ nhỏ | Cho xem và sửa văn bản; hỗ trợ dán câu |
| LLM gợi ý sai hoặc bịa mẫu | Giới hạn vào kho đã biên tập; kiểm tra kết quả server; cho tra thủ công |
| Chi phí hoặc phản hồi AI chậm | Hạn mức ở backend, chỉ gửi văn bản cần thiết, cache câu trùng khi phù hợp |
| Mất mạng, xung đột nhiều thiết bị | Lưu local-first, hàng đợi và quy tắc hợp nhất theo loại dữ liệu |
| Vượt phạm vi học kỳ | Ưu tiên OCR → tra cứu → lưu → luyện tập; hoãn giọng nói và thanh toán thật |

---

## 6. TÀI LIỆU ĐẦU VÀO

- [Cuộc trò chuyện về ý tưởng và đặc tả ứng dụng học ngữ pháp tiếng Nhật](https://chatgpt.com/share/6ad8bef4-85c8-83ec-ad0d-f451c11dd200).
- [README dự án](../../README.md) mô tả Bunly và luồng học từ nội dung thực tế.
- [Repository GitHub của nhóm](https://github.com/bunly-app/bunly).
- Template bốn báo cáo của học phần trong thư mục `documents/reports`.
