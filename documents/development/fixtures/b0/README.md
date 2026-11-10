# B0 — Bộ dữ liệu tích hợp chờ duyệt

Ngày 09/11/2026. Theo [contract v1](../../BASELINE-INTEGRATION-CONTRACTS.md).

| File | Nội dung | Trạng thái |
|---|---|---|
| `grammar.draft.json` | 12 mẫu, giữ nguyên 3 record asset và UUID; thêm 9 draft AI với ví dụ tự soạn | `pending_review`; chưa có reviewer/ngày duyệt |
| `questions.draft.json` | 24 câu: 1 MCQ + 1 cloze cho mỗi mẫu, version 1 | `pending_review`; MCQ distractor đơn giản phục vụ tích hợp, cần Vy nâng chất lượng trước dùng thật |
| `analysis.cases.json` | Success UTF-16 span với emoji, no-match, errors và duplicate processing | Contract fixture; không là kết quả model hoặc bằng chứng Auth/API thật |
| `sync.cases.json` | 4 case revision/tombstone/retry/conflict resolution, 1 case thứ tự attempt, 1 case cạnh tranh quota | Expected contract; chưa thực thi worker/server mới |

Các file này không có trong Flutter assets và không được seed lên database. Không tính chúng vào kho 80–120 mẫu đã hoàn thành. Chỉ import sau review và task có phạm vi rõ. Không thêm secret, email hoặc token thật vào fixture.

Kiểm tra cấu trúc và quan hệ bằng `python scripts/validate_b0_fixtures.py` từ gốc repo. Validator kiểm tra ID, giữ 3 record gốc, liên kết câu hỏi/đáp án và span UTF-16; **không xác nhận kiến thức tiếng Nhật hay chất lượng giảng dạy**.

Vy duyệt pattern/cấp độ/công thức/ý nghĩa/ví dụ/đáp án/distractor và nguồn sử dụng. Ánh review contract và loại lỗi; Hoàng tích hợp sau review. Khi cập nhật nội dung phải giữ ID/version đúng, không ghi reviewed_by thay thành viên chưa duyệt.
