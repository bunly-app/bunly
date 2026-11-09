# Bunly — Hợp đồng tích hợp baseline v1

Ngày: 09/11/2026. Phạm vi **A02 + A03-01** theo [audit A00](../reports/A00-Baseline-Audit-2026-11-09.md) và [PRD tổng thể](../planning/PRD-BUNLY-Full-Function-Baseline.md). Đây là đặc tả kỹ thuật v1 để triển khai và review; **chưa được Ánh/Vy phê duyệt**, chưa áp schema mới hoặc deploy API.

## 1. Quy ước chung

| Quy ước | Contract |
|---|---|
| ID | UUID ổn định; client tạo ID thao tác/bài làm một lần, tái dùng khi retry. Không thay 3 grammar UUID hiện có. |
| User | Backend lấy user từ session đã xác minh; không tin user_id/entitlement do request tự khai. Local partition theo backend namespace + owner. |
| Thời gian | Timestamp ISO-8601 UTC; thời gian thiết bị chỉ là metadata/chỉ báo tạm cho phần đã quy định. Quota theo ngày UTC, hiển thị rõ khi reset. |
| Nội dung | `grammar_id` và `content_version` dẫn đến nội dung đã duyệt. Content draft/fixture không phải dữ liệu sẵn sàng cho người học. |
| Domain | Dart thuần, chứa entities/use cases/repository interfaces. Data adapter ánh xạ DTO, SDK và lỗi. Providers chọn implementation, presentation không import data implementation. |
| Fixture | [Thư mục B0](fixtures/b0/README.md) dành cho phát triển/test/review; không tự nạp vào app, seed hoặc model evaluation được tuyên bố đạt. |

## 2. Catalog và đăng xuất — hiện thực trong A03-01

### 2.1. Catalog có metadata theo từng lần tải

`GrammarRepository.load()` trả `GrammarCatalog(points, origin)`:

- `points`: danh sách không sửa cấu trúc được; origin đi cùng đúng snapshot load này.
- `origin = source`: tải từ nguồn được cấu hình. Demo là asset; connected là remote. Không coi `source` tự động đồng nghĩa Cloud đã được kiểm chứng.
- `origin = cache`: fallback SQLite khi tải nguồn thất bại và có cache trong đúng backend namespace.
- Lỗi Auth/quyền không được che bằng cache. Thành công trả rỗng phải xóa cache cũ; rỗng có `origin = source`.
- Kết quả cũ không bị đổi origin khi lần tải khác thành công/thất bại. Không dùng mutable `lastLoadFromCache` trên implementation làm state UI.

`SearchGrammar` trả catalog đã lọc và giữ origin; `catalogProvider` là `AsyncValue<GrammarCatalog>`, `filteredGrammarProvider` đưa danh sách đã lọc ra UI. Khi load đang pending/error, UI không hiển thị kết luận cache từ lần trước như kết quả hiện tại.

Thay đổi contract này yêu cầu cập nhật fake/unit/repository/widget tests và chỗ Android integration đọc `catalogProvider.future`. Không thay schema hoặc hợp đồng Supabase.

### 2.2. Đăng xuất

`GrammarScreen → SignOutController.submit → SignOut → AuthRepository.signOut`. Controller trả success boolean và giữ AsyncValue phục vụ loading/error. Bấm lặp trong lúc đang gửi không tạo thêm call. Lỗi giữ session/UI để retry; success để auth stream quyết định navigator. Controller chỉ ghi state nếu còn mounted; completion muộn sau navigation không ghi vào controller đã dispose.

Đăng xuất và đổi tài khoản vẫn phải làm navigator đóng route riêng; worker kiểm tra session/owner như nền hiện có. Chưa thay chính sách Supabase signOut scope hoặc xóa cache/outbox của user trong gói này.

## 3. OCR draft — A04

| Trường / hành vi | Contract đích |
|---|---|
| Input | URI/path ảnh local do người dùng chọn/chụp; adapter kiểm tra ảnh đọc được, rotation và giới hạn tài nguyên trước OCR |
| Output | `draft_id`, `text`, `blocks[]` tùy khả năng engine, `engine`, `script=Japanese`; metadata engine không tự trở thành confidence |
| Review | Người dùng sửa text hoặc dán câu khác; mỗi lần xác nhận tạo snapshot text dùng cho request phân tích. Chưa xác nhận thì không upload. |
| Post-processing | Chuẩn hóa CRLF thành LF, trim đầu/cuối; không tự xóa khoảng trắng bên trong/đổi kanji/kana có thể đổi nghĩa. Offset của kết quả phân tích luôn tính trên text cuối đã xác nhận. |
| Lỗi local | `permission_denied`, `image_unreadable`, `model_unavailable`, `recognizer_failed`; ảnh không có chữ là empty state cho chụp lại/dán câu |
| Offline/lifecycle | OCR chạy khi Japanese model sẵn sàng; có test airplane mode. Không giữ xử lý nền/camera sau dispose, không tự gửi ảnh lên server. |

## 4. API phân tích — A05

Đề xuất endpoint `analyze-grammar` v1. Fixture JSON ở `analysis.cases.json`; đây là request/response mẫu, không phải Function đã chạy.

### 4.1. Request và validation

Request có đúng `request_id` UUID, `text`, `locale=vi`. User JWT nằm trong cơ chế Auth request, không nằm trong fixture hoặc JSON body. Từ chối field không hỗ trợ để tránh caller hiểu nhầm `user_id`, model hoặc quota do client điều khiển.

Giới hạn đề xuất v1: 1–1000 Unicode code points sau normalize/trim, tối đa 8 KiB UTF-8; không nhận ảnh/base64/document/audio. Khóa request gồm `(authenticated_user, request_id)` và fingerprint text/locale/prompt version. Cùng ID mà khác payload trả `request_conflict` (409), không tái dùng kết quả sai ngữ cảnh.

Server chọn ứng viên từ kho đã duyệt; prompt/LLM là thành phần không đáng tin. Output JSON phải qua schema và allowlist ID, không có ID ngoài candidate/catalog version; lỗi dữ liệu không được trả success. Dịch nghĩa/công thức/cách dùng chính vẫn lấy kho Bunly, không thay bằng lời LLM không kiểm soát.

### 4.2. Response

HTTP 200: `{request_id, matches: [{grammar_id, span?}], remaining_quota}`. `matches=[]` là no-match hợp lệ, có đường tìm thủ công. Không giả confidence nếu model/engine không có thước đo đã đánh giá.

Span gồm `start_utf16`, `end_utf16`, `text`, end-exclusive. Tính trên chính request text đã normalize, theo **UTF-16 code units** để khớp Dart/JS; server phải kiểm tra substring và không cắt giữa surrogate pair. Ví dụ emoji đầu câu trong fixture nhằm phát hiện nhầm offset code point với UTF-16. Span không khớp → invalid_output; bản đầu có thể bỏ span nếu chưa chứng minh được, không đánh dấu sai đoạn.

| Mã | HTTP / khả năng retry | UI |
|---|---|---|
| `invalid_input` | 400 / sửa input trước | Giữ editor, chỉ rõ input không hợp lệ |
| `unauthenticated` | 401 / cần đăng nhập | Giữ bản nháp phù hợp owner; không gửi lại bằng user khác |
| `request_conflict` | 409 / ID mới khi user xác nhận nội dung mới | Không áp kết quả của text cũ vào text mới |
| `quota_exceeded` | 429 / sau kỳ reset hoặc entitlement thay đổi | Hiện lượt còn lại/kỳ reset; không loop retry |
| `invalid_output` | 502 / không auto retry | Giữ text, cho tra thủ công hoặc user yêu cầu thử lại |
| `unavailable` | 503 / có thể retry với cùng ID | Không mất draft; bounded retry/backoff |
| `timeout` | 504 / có thể retry với cùng ID | Không khẳng định chưa có server commit; hỏi trạng thái request trước gọi mới |
| `processing` | 202 / retry trạng thái sau `retry_after_ms` | Đang xử lý, chống gửi mới vô hạn |
| `offline` | Lỗi client, không có HTTP response | Lưu draft local, không giả request đã được server nhận |

Error response `{request_id, error: {code, retryable}}`; message UI do client ánh xạ, không hiển thị raw provider error/secrets. Timeout provider đề xuất 20 giây, client chờ 30 giây; đây là cấu hình đích cần đo, chưa phải kết quả latency.

### 4.3. Quota và idempotency

Entitlement chỉ server quản trị. Đề xuất Free 5/Pro demo 20 success/ngày UTC, cần Hoàng chốt trước adapter thật; không thu tiền. Quy trình:

1. Xác minh session, payload; tạo/fetch request ledger theo user + ID, kiểm tra fingerprint.
2. Reserve lượt nguyên tử nếu chưa có request và còn quota; không mở transaction DB trong khi chờ LLM.
3. Duplicate processing trả 202; duplicate succeeded trả lại cùng response và không trừ thêm. Quota còn lại trong response duplicate lấy từ ledger/account hiện tại, không làm UI tăng lượt vì response cũ.
4. Thành công hợp lệ, gồm no-match đã phân tích, finalize lượt một lần. Lỗi provider/invalid_output refund một lần; lưu trạng thái để retry không refund/trừ hai lần.
5. Request failed-retryable có thể claim attempt mới bằng compare-and-set cùng ID; không hai worker đồng thời. Reservation hết hạn không đủ để gọi LLM lần hai nếu worker cũ còn sống: cần lease/generation, finalize chỉ generation đang giữ; trace chi phí provider tách với quota người dùng.

Các case bắt buộc A05: hai request cuối quota cùng lúc, timeout sau commit, cùng ID khác text, provider thành công nhưng finalize lỗi, worker hết lease, refund lặp, user tự ghi entitlement, A đọc ledger B. Chưa có SQL/Function thực hiện các quy tắc này trong A02.

## 5. Attempts, lịch ôn và đồng bộ — A06/A07

| Entity | Khóa / contract đích |
|---|---|
| Question | UUID, `grammar_id`, `content_version`, type (`mcq`/`cloze`), prompt, đáp án và explanation đã duyệt. Client chỉ đọc kho; câu chấm local không phục vụ cấp Pro/quyền bảo mật. |
| Attempt | UUID client, owner, question/version, session UUID, answer, outcome, `attempted_at`, `server_received_at`, `retry_of?`. Immutable; retry transport cùng UUID không tạo lần làm mới; user làm lại thật tạo UUID mới và lineage. |
| Review event | Attempt được tính lịch chỉ là lần nộp đầu độc lập của question trong session; nộp lại sau xem đáp án không tăng bậc. Thiết kế uniqueness/eligibility server phải được kiểm thử trước A07. |
| Mutable record | Profile/note/saved/manual progress dùng `revision` server và `base_revision` từ client; update/delete có điều kiện, không blind upsert đa thiết bị. |
| Delete | Giữ tombstone có revision; stale edit không tự làm sống lại. Cần explicit khôi phục với current revision nếu nghiệp vụ cho phép. |

**Chấm:** MCQ so stable option ID khi schema chính thức chốt (fixture tạm dùng index trong content version bất biến); cloze bản đầu trim-only và danh sách đáp án chấp nhận do người duyệt cung cấp. Không tự bỏ dấu/kanji/kana. Không lưu raw câu trả lời vào log.

**Lịch ôn v1 cụ thể:** stage ban đầu -1; lần đầu đúng lên stage 0; stage 0..4 tương ứng 1/3/7/14/30 ngày. Đúng tăng stage tối đa 4; sai về stage 0. Due dựa trên ngày UTC của sự kiện đủ điều kiện + khoảng cách. Skip không đổi stage; self-assessed learning status tách khỏi correctness. Thuật toán có `algorithm_version=1`.

**Thứ tự đa thiết bị v1:** server gán `server_received_at` bất biến ở lần insert attempt đầu; order `(server_received_at, attempt_id)` tăng dần, không dùng clock client để quyết định thứ tự hay revision. Due server tính từ ngày UTC nhận sự kiện; replay trên mọi thiết bị giống nhau. `attempted_at` giữ để hiển thị, clock tương lai lệch >5 phút gắn cờ, không đổi thứ tự canonical. Offline client tính lịch tạm theo giờ local và ghi nhãn chưa đồng bộ; khi sync có thể đổi lịch theo receipt server. Đây là lựa chọn baseline đơn giản, đánh đổi việc offline lâu có thể dời ngày ôn; UI phải giải thích và test, không gọi đó là lịch học chính xác tuyệt đối theo ngày làm offline.

**Lưu bền:** transaction gồm thay đổi local + outbox; ack chỉ xóa đúng sequence/op đã gửi. Pull không ghi đè pending local. Attempts merge theo UUID; dữ liệu mutable stale nhận 409/conflict record để so sánh, không bỏ local change hoặc tự chọn thắng theo đồng hồ máy. Retry sau server commit trả ack cũ, không tăng revision/đếm bài lần hai.

| Case | Kết quả phải có khi triển khai |
|---|---|
| Máy A và B sửa note từ revision 3 | A cập nhật thành 4; B gửi base 3 nhận conflict; giữ bản B; nếu user chọn B thì gửi update base 4, thành 5 |
| A xóa note, B đang offline sửa | Tombstone revision mới không bị stale edit làm sống lại; B xem conflict, user quyết định theo nghiệp vụ |
| Request thành công nhưng client timeout | Cùng operation UUID retry → cùng ack/revision; không sinh attempt hoặc trừ quota lần hai |
| Hai máy có bài làm riêng | Union attempt ID; tính lại review theo thứ tự canonical; không ghi đè aggregate bằng snapshot máy cũ |
| User đổi giữa request | Worker cũ ngừng gửi tiếp/merge; response thuộc A không cập nhật UI hoặc queue B; pending A giữ partition A |
| Hai máy chọn trùng một câu trong cùng session | Eligibility unique session+question trên owner, tie-break deterministic; retry không giả thêm bài đầu độc lập |

Các rule mới chưa có trong worker M2 đang dùng upsert một thiết bị. Giữ giới hạn M2 tới A07, không nhận contract là code đã hoàn thành.

## 6. Map trạng thái UI và CTA

| Luồng | Trạng thái / CTA |
|---|---|
| Catalog | loading → list/empty/error-retry; cache notice chỉ từ catalog result hiện tại; filter không gọi SDK |
| Auth | submitting khóa nút, confirmation-required về inbox hướng dẫn; logout-error vẫn còn session và retry; success đóng routes cũ |
| OCR | idle → chọn ảnh/quyền → processing → empty/error hoặc editable draft → user confirm; không confirm không gọi AI |
| Analysis | offline/draft, processing, success/no-match, quota/reset, timeout/retry, invalid-output/tra thủ công; back giữ draft theo owner |
| Practice | question → submitting → feedback → next → summary; không lộ đáp án trước nộp; skip/try-again không tính như lần đầu đúng |
| Sync | local pending → syncing → synced/failed; conflict có bản local/server, chọn bản; không nút chết hoặc số liệu giả |

## 7. Bàn giao và trạng thái review

- A02-01/02: đã viết contract/fixture để Ánh review; chưa dựng migrations, Function, attempts/review engine.
- A02-03: 12 mẫu/24 câu draft tách khỏi asset/seed; cần Vy duyệt cấp độ, tiếng Nhật, đáp án, chất lượng distractor và quyền sử dụng. 3 record đầu được copy nguyên từ asset; không suy chúng đã được review độc lập hôm nay.
- A03-01: thay typed catalog + SignOut được ghi bằng source/tests và báo cáo kiểm chứng riêng; chưa hoàn thành app shell A03-02 hoặc reset/callback/theme settings A03-03.
- Các giá trị quota/timeout/order là quyết định triển khai v1 có thể review, chưa phải thông số hệ thống đã cấu hình. Thay contract cần tăng version/đổi fixture/test tương ứng, không sửa API âm thầm.
