# A05-01 — Biên kiểm tra contract phân tích (local)

Ngày 09/11/2026. Luồng môi trường/backend nhận phạm vi local từ runbook; không deploy hosted, không sửa Flutter hoặc schema chung.

## Đề xuất bàn giao trước khi triển khai

Giữ API v1 trong `BASELINE-INTEGRATION-CONTRACTS.md`: request chỉ gồm request_id/text/locale=vi; chuẩn hóa CRLF → LF rồi trim; 1–1000 Unicode code points, không quá 8 KiB UTF-8; fingerprint gồm text/locale/prompt version. Output chỉ nhận grammar_id trong tập ứng viên được server cung cấp và span UTF-16 hợp lệ. Không tự chọn provider/model/quota hay xem fixture là nội dung đã duyệt.

Lát này thêm module JavaScript thuần dùng được trong Deno/Node và test Node tích hợp fixture B0. Chưa thêm endpoint chạy được, DB ledger, Auth adapter hoặc model adapter. Luồng Flutter chưa phải đổi interface hoặc tích hợp module này. Không mở API mới hoặc đổi schema. Kết quả và giới hạn sẽ được cập nhật sau kiểm thử thực tế; đề xuất này không thay review của Ánh/Vy.

## Hiện thực và kiểm chứng

- `supabase/functions/_shared/analysis-contract.mjs`: request schema chặt, chuẩn hóa text, kiểm tra Unicode và đọc body dạng stream có trần 8192 byte; không tin Content-Length. Fingerprint SHA256 ổn định trên text/locale/prompt version; request UUID và owner là khóa ledger riêng, chưa có ledger ở lát này.
- Output validator dùng Set ID do server cung cấp; từ chối field không hỗ trợ, ID ngoài candidate và span sai substring hoặc cắt surrogate. Trả snapshot bất biến tách khỏi object model gốc. Không nhận quota/confidence từ model.
- `supabase/functions/tests/analysis-contract.test.mjs`: **14/14 đạt**, `node --test supabase/functions/tests/analysis-contract.test.mjs`, exit 0. Test có fixture B0, không dùng model thật; bao gồm stream UTF-8 tách từng byte, body vượt trần khai Content-Length sai, input 1000 emoji, field giả owner/model/quota, fingerprint đổi prompt/text và span UTF-16 cắt emoji.
- `node --check` hai module: exit 0. Không thêm dependency hoặc sửa npm lockfile. Module dùng Web APIs và ESM; chưa chạy Deno/Edge Runtime nên chưa xác nhận tương thích runtime Supabase thực tế.

Không có endpoint `analyze-grammar` có thể gọi trong lát này. Khi tích hợp, Auth đã xác minh phải chạy trước đọc body; candidate phải từ catalog được duyệt; output hợp lệ vẫn cần finalize ledger nguyên tử trước trả success. Module thuần này không thay Auth/RLS/quota, không ngăn vượt quota nếu một handler gọi sai thứ tự và không chứng minh AI hiểu ngữ pháp.

Đã đọc [changelog Supabase](https://supabase.com/changelog.md) và [hướng dẫn Function Auth](https://supabase.com/docs/guides/functions/auth) ngày 09/11/2026. Changelog có các thay đổi CLI v3/Flutter v3; repository tiếp tục giữ pin hiện tại. Không áp API mới vào wrapper cũ, không tắt verify_jwt hoặc đổi hosted config. Chưa chốt provider/model/key/ngân sách hoặc quota 5/20 đề xuất; các phần đó còn chờ quyết định khi tới tích hợp thật.
