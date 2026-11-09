# Công việc tiếp theo — chưa triển khai lên canvas

## Hoàn thiện feedback dịch và voice

- translation-loading: giữ nguyên đề và câu đã gửi; spinner “Đang đọc câu của bạn…”, không phần trăm/thời gian giả. Hủy → translation giữ nháp. Timeout → ai-error, Thử lại → loading, Quay về sửa → translation.
- translation-feedback: “Cần sửa thể động từ”. 3 phần: đúng ý (chưa diễn đạt trải nghiệm), ngữ pháp mục tiêu (行く → 行った), độ tự nhiên (ます phù hợp đồng nghiệp mới quen). Bản sửa nguyên câu 日本に行ったことがあります。; cách khác hợp lệ 日本へ行ったことがあります。; ghi rõ AI góp ý. Tự sửa → translation-retry; Lưu → note-saved; Tiếp tục câu 6 → voice-ready.
- translation-retry: câu đã sửa, có hành động gửi lại; ghi nhận làm lại, không cộng điểm độc lập.
- voice-ready: chưa ghi; tình huống “Kể rằng bạn đã từng leo núi Phú Sĩ”; gợi ý từ vựng 富士山 / 登る; nút Bắt đầu ghi, gõ thay thế. Không waveform/đồng hồ chạy trước xin phép.
- mic-permission: giải thích micro chỉ dùng khi thu âm; Cho phép → recording (mô phỏng), Không tiện nói → translation/gõ. Không coi Figma là quyền hệ điều hành thật.
- recording: Đang ghi, đồng hồ tĩnh ví dụ 00:04, nút Dừng và kiểm tra; Hủy → ready. Không playback cùng lúc ghi.
- transcript-confirm: playback bản ghi ví dụ và văn bản 富士山に登ることがあります。; sửa transcript trước gửi; gửi → voice-loading, ghi lại → ready.
- voice-loading: spinner, giữ transcript đã xác nhận; không chấm phát âm.
- voice-feedback: AI dựa trên văn bản đã xác nhận; 登る → 登った để nói trải nghiệm; câu sửa 富士山に登ったことがあります。; Nói lại → ready-retry; Sửa văn bản → transcript-confirm, kết quả cũ phải xem là hết hiệu lực.
- voice-compare: hiển thị transcript trước/sau và thay đổi ngữ pháp; không gọi transcript đúng là bằng chứng phát âm đúng. Đến summary.
- summary: 6 câu hoàn tất; 4 câu đáp án chuẩn + 2 câu AI. Kết quả cần gắn nhánh thực tế hoặc dùng nhãn phiên ví dụ; không để số liệu cố định giả vờ phản ánh mọi lựa chọn. Phương án ít chi phí: tổng kết định tính, từng câu là demo cố định có annotation ngoài UI, hoặc biến Figma lưu selected/hint/correct và điều kiện. CTA ôn lỗi, Home, history. Không gộp AI với điểm quiz.

## Màn phụ cho action đã được lưu

- profile: tên/email giả, mục tiêu, Cài đặt, trợ giúp; Logout → xác nhận → login.
- search-results: kết quả lọc たこと; clear → search; no-result riêng với “Thử từ khóa khác”, không nhầm lỗi.
- grammar-prohibition / grammar-obligation: dùng lại cấu trúc grammar nhưng nội dung và CTA đúng mẫu, không chuyển nhầm về trải nghiệm. Nếu phiên chỉ có trải nghiệm thì ghi rõ cấu trúc luyện mẫu minh họa hoặc tạo setup theo mẫu.
- note-saved: xác nhận local “Đã lưu trên thiết bị”, Xem sổ → notebook, Tiếp tục → BACK nguồn. Không báo Supabase đã sync.
- draft-saved: “Đã lưu bản nháp trên thiết bị”, Quay về bài đang làm; dùng BACK để tránh mất ngữ cảnh dịch/paste.
- learning-status: 4 mục Mới / Đang học / Cần ôn / Đã nắm, tách khỏi điểm; selected state thật, lưu → grammar variant phù hợp.
- session-source: chọn Đến hạn / Mẫu đang học / Sổ lỗi / Cấp độ. Nếu đổi nguồn, state setup cần cập nhật nội dung, không chỉ link vòng.
- mcq-hint: “Để nói trải nghiệm, dùng Vた + ことがある”; sau hint quay lại câu và đánh dấu đã dùng gợi ý; không tính độc lập.
- cloze-retry: giải thích không dùng thể từ điển/て trong vị trí này; thử lại hoặc tiếp câu3. Không link tới “Đúng lần đầu”.
- cloze-2-feedback-wrong: で không hợp đích đến của 行く; に và へ đều được; câu tiếp4.
- translation-hint: gợi ý thể た mở chủ động; sau mở phải ghi nhận có hỗ trợ.
- errors: mẫu sai, câu trước/sửa, lý do và luyện lại; không tỷ lệ thiếu mẫu số. Dùng dữ liệu minh họa định tính; không coi mọi khác biệt phong cách là lỗi.
- history: 48 mục baseline (32 quiz +12 dịch +4voice), kết quả lần đầu/hỗ trợ/AI riêng; item tap đúng loại feedback và có Back về history.

## Auth

- login: một nút Đăng nhập, email/password, hiện/ẩn, quên mật khẩu, signup.
- submitting riêng; disabled button với spinner giữ cùng kích thước; không hiển thị cạnh nút thường.
- login-error: lỗi cụ thể, giữ email; password masked; retry.
- signup: email/password/confirmation; không chép plaintext password trên frame; chính sách chưa xác minh không tự khẳng định.
- confirm-email: email minh họa, gửi lại, sửa email, login. Không vào Home trước xác nhận. Confirmation success riêng.
- forgot → reset-sent (trung tính) → reset-password từ link hợp lệ → reset-success → login.
- onboarding: cấp N5/N4, thời lượng 5/10/15 phút; Save → Home. Các cấp chưa có nội dung ghi rõ.
- session/bootstrap: logo + một spinner; timeout có retry/login; không tự hiển thị private data khi danh tính chưa rõ.

## Loading, empty và offline

- search-loading, notebook-loading, progress-loading: skeleton cùng kích thước/layout với trạng thái có dữ liệu; các khối xám là chủ ý, không đặt tiêu đề hoặc dữ liệu giả.
- offline-cached: dữ liệu cũ hiện nguyên, “Đang xem bản đã lưu”; refresh nhỏ không thay cả body; retry → root tương ứng. Không báo đồng bộ thành công.
- notebook-empty: “Chưa có mẫu đã lưu”, CTA mở search; khác notebook-error.
- notebook-error: thông báo tải lỗi, retry; không xóa dữ liệu.
- L01 spinner guide đặt UI Kit: nút thường/loading/disabled/error, kích thước48, cùng label alignment; annotation kỹ thuật ngoài sản phẩm.

## Prototype acceptance

- Một trang prototype; 4 flowStartingPoints: Home / Auth / Voice / Loading. Giữ Source và UI Kit ngoài luồng sử dụng.
- Root nav 4 mục đúng đích/active, không có avatar trên Focus, không bottom nav trên Detail/Auth.
- Quyết định back theo nơi vào, không hardcode search khi detail được mở từ notebook/quiz/history.
- Có đường thoát giữ nháp cho voice, translation và capture.
- Tất cả nút nhìn như có thể chạm phải có reaction có nghĩa hoặc trạng thái disabled có lý do. Không để nút fake.
- Dữ liệu tổng kết phải phản ánh nhánh được chọn hoặc minh bạch là kịch bản demo; Figma không thực thi OCR/ASR/Auth/AI/Supabase.
- Chạy kiểm tra graph: destination tồn tại, mọi màn luồng chính có đường tới và đường ra; không nối nhầm Source.
- Visual QA: toàn bộ frame mới; cắt screenshot cả vùng cuộn nếu cần; kiểm tra mất chữ Nhật, màu tím mặc định Material, badge cao10px, nút tràn, content bị bottomnav che.

