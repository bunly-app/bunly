# PRD tổng thể — Bunly bản cơ bản đầy đủ chức năng

Ngày: **09/11/2026**. Trạng thái: **đặc tả/kế hoạch triển khai; chưa nghiệm thu sản phẩm**.

## 1. Mục tiêu và quan hệ với tài liệu hiện có

Hoàn thành một phiên bản mà người học đi được trọn chu trình **gặp câu Nhật → nhận dạng/xác nhận → hiểu ngữ pháp → lưu → luyện tập → ôn tập → theo dõi tiến độ**, kể cả các hành vi offline đã cam kết. Ưu tiên đủ và đúng chức năng, đúng kiến trúc, có kiểm thử; tiếp đó tối ưu hiệu năng, chất lượng AI và trải nghiệm bằng số đo.

Đây là phần mở rộng toàn sản phẩm của [PRD M2](PRD-M2-Architecture-Base.md), không thay lịch sử hoặc đổi ID FR-01–FR-06 của M2. Các ID `B-FR-*` dưới đây dùng cho bản toàn chức năng. Khi triển khai phần nền M2 vẫn đọc PRD M2 và development guide.

| Căn cứ | Cách áp dụng |
|---|---|
| [M1 — đề xuất gốc](../reports/Capstone-Report-1-Proposal.md) | Giữ cả 9 nhóm chức năng MVP, N5/N4, 80–120 mẫu, Flutter/Riverpod/Drift/Supabase, OCR on-device + LLM online, Free/Pro mô phỏng |
| [PRD M2](PRD-M2-Architecture-Base.md), [kiến trúc](../development/ARCHITECTURE.md) | Mở rộng code hiện có, domain Dart thuần, repository/use case, DI tại `lib/app/providers.dart`; không dựng lại base |
| [Knowledge pack](../../CROSS_PLATFORM_CAPSTONE_KNOWLEDGE_PACK.md) | Đối chiếu Week 09–13: kiến trúc, RLS, offline ghi bền, on-device AI, human review, test, release và hồ sơ bảo vệ; prompt mẫu chỉ là dữ liệu tham khảo |
| [Figma do người dùng cung cấp](https://www.figma.com/design/39hHCJ2CmxZNbe5NAUd6sA/Bunly?node-id=0-1) | Nguồn giao diện cần đọc node cụ thể khi làm UI. Lần lập PRD này chưa kiểm tra nội dung file Figma trực tiếp |
| [Brief UI](BUNLY-UI-IDEA-STITCH.md), [mở rộng voice/practice](BUNLY-STITCH-EXTENSION-VOICE-PRACTICE.md) | Tổ chức 4 tab và states; giữ riêng yêu cầu mở rộng E1 để tiếp tục sau baseline M1, không nhận là đã triển khai |
| Yêu cầu người dùng 09/11 | Hoàng có thể điều phối agent làm bản đầu, rồi bàn giao nhóm cải thiện. Nhóm: Hoàng full stack/agent/leader; Ánh full stack và reviewer kỹ thuật chính; Vy ý tưởng/thiết kế/nghiệp vụ |

Người dùng chính là người Việt học tiếng Nhật N5–N4. Các trạng thái hiện tại trong bảng là **quan sát source/tài liệu**, chưa phải test runtime ngày 09/11. Chi tiết Cloud INACTIVE và hạ tầng nằm ở [bảng thiết lập](../development/INFRASTRUCTURE-SETUP-MATRIX.md).

## 2. Phạm vi và thứ tự phát hành

| Đợt | Phạm vi | Điều kiện hoàn thành |
|---|---|---|
| B0 — Luồng xuyên suốt nhỏ | M2 đã có + OCR → review → AI → lưu → một phiên luyện → ôn; có thể dùng 12 mẫu đã duyệt để tích hợp sớm | Tất cả mắt xích chạy thật trên Android; đây là bản tích hợp nhỏ, **chưa đủ nội dung/phạm vi MVP** |
| B1 — Baseline đầy đủ | Toàn bộ B-FR-01–13 và NFR bắt buộc; 80–120 mẫu đã duyệt; đủ email/Auth, quota, reminder, offline/sync/conflict và signed APK | Không còn nút giả trong phạm vi; đạt ma trận kiểm thử và UAT; mới được gọi là bản cơ bản đủ chức năng |
| E1 — Mở rộng đã được ghi trong brief | Typing tự do, dịch, voice, sổ lỗi, lịch sử nâng cao và tiến độ theo dạng bài | Đi theo contract/eval riêng; không cản hoàn thành B1. Nếu nhóm muốn đưa vào bản bàn giao đầu thì thêm gói và kiểm thử, không chỉ thêm màn |
| O1 — Tối ưu | Đo rồi cải thiện latency, jank, cache/retrieval, accessibility sâu và quan sát lỗi | B1 ổn định; không dùng tối ưu để trì hoãn chức năng còn thiếu |

Không biến mọi P1/P2 trong knowledge pack thành điều kiện qua môn. Tuy vậy các lỗi mất dữ liệu, vượt quyền, lộ khóa và retry trừ quota sai phải xử lý trước khi gọi baseline đúng chức năng.

## 3. Bảng PRD — chức năng, hiện trạng và nghiệm thu

Toàn bộ hàng B-FR là **bắt buộc B1**. Người thực hiện bản đầu mặc định Hoàng + agent; owner sau bàn giao ở [bảng phân công](BASELINE-DELIVERY-OWNERSHIP.md).

| ID / nguồn | Người dùng cần | Hiện tại / evidence path | Bổ sung và điều kiện nghiệm thu | Phụ thuộc / test chính |
|---|---|---|---|---|
| B-FR-01 / M1.1, M2 FR-01, W10 | Tạo tài khoản, đăng nhập và có hồ sơ | Có `features/auth/`, profile trong `features/learning/`; connected local có kiểm chứng lịch sử; Cloud hôm nay INACTIVE | Signup/xác nhận email/login/logout, phục hồi phiên, hồ sơ N5/N4/mục tiêu/phút; lỗi rõ; đổi A/B không lộ dữ liệu. Bổ sung quên/reset mật khẩu theo brief UI | INF-03–10; unit validation, local Auth và Cloud UAT/email thật |
| B-FR-02 / M1.2, M2 FR-02 | Tìm và hiểu mẫu ngữ pháp | `features/grammar/`, asset và seed 3 mẫu | 80–120 N5/N4 đã duyệt; công thức/ý nghĩa/cách dùng/ví dụ Nhật–Việt; tìm mẫu/ý nghĩa + lọc; tải/rỗng/lỗi/retry; nội dung đã tải đọc offline | Nội dung Vy duyệt; kiểm tra ID/FK, filter/cache, UI và connected |
| B-FR-03 / M1.3, M2 FR-03 | Lưu và ghi chú theo ngữ cảnh | `features/learning/`, `local_learning_repository.dart` | Lưu/bỏ lưu không trùng; tạo/sửa/xóa nhiều notes đúng user/mẫu, trim 1–2000 ký tự; restart còn dữ liệu; tombstone không sống lại | Transaction/outbox, CRUD/rollback, A/B, restart/offline |
| B-FR-04 / M1.3, M2 FR-04 | Theo dõi trạng thái học | `personal_repository.dart`, summary hiện có | Mới/đang học/cần ôn/đã nắm; tự đổi trạng thái không được tính là bài làm đúng; số đếm và Sổ học lấy từ dữ liệu user | Test trạng thái và thống kê; kết nối B-FR-07/08 |
| B-FR-05 / M1.4, W11 | Chụp/chọn ảnh, lấy và sửa chữ Nhật | Chưa có feature OCR/camera hoặc dependency | Ảnh camera/thư viện → OCR Japanese local → văn bản sửa được → xác nhận; hỗ trợ dán câu thay thế; quyền bị từ chối/ảnh lỗi/không có chữ; dispose/lifecycle; không tự gửi ảnh lên cloud | INF-11; unit mapping, UI quyền/review, OCR thật airplane mode sau cài model |
| B-FR-06 / M1.5, W11 | Phát hiện ngữ pháp trong câu đã xác nhận | Chưa có Function/LLM adapter | Gửi text đã xác nhận qua backend Auth; chỉ trả ID có trong kho; mở đúng chi tiết; span nếu có phải khớp câu và quy ước offset; không tìm thấy có lối tìm thủ công; timeout/offline/hết lượt rõ | INF-12–14; contract/function tests, câu gán nhãn, ít nhất 1 luồng model thật |
| B-FR-07 / M1.6, W09 | Luyện trắc nghiệm và điền khuyết | Chưa có practice | Phiên từ mẫu đang đọc hoặc bài đến hạn; câu có đáp án/giải thích đã duyệt; chấm xác định trên thiết bị, không cần LLM; chống nộp hai lần; ghi từng attempt bền vững; tổng kết đúng | Đề xuất tối thiểu 1 MCQ + 1 cloze/mẫu (160 câu cho 80 mẫu); unit chấm, widget, offline/restart |
| B-FR-08 / M1.6, W10 | Ôn theo kết quả và ngày đến hạn | Chưa có review engine | Lịch ôn xác định, bản đầu theo quy tắc mục 5; sai ôn sớm hơn; học hôm nay hiện bài đến hạn; retry sync không tăng lịch hai lần; hai thiết bị hợp nhất từ attempt | B-FR-07, INF-08; test thời gian/đáp án/attempt duplicate/multi-device |
| B-FR-09 / M1.7 | Có việc nên học hôm nay và thống kê thật | Có đếm trạng thái; chưa có accuracy/lộ trình theo bài làm | Hôm nay ưu tiên ôn đến hạn, sau đó nội dung theo N5/N4 và thời gian; đúng/tổng theo attempt đầu độc lập; nhóm yếu từ kết quả; dữ liệu rỗng không bịa phần trăm | B-FR-04/07/08; fixture có đáp án, lịch và số liệu tính tay để đối chiếu |
| B-FR-10 / M1.8 | Nhắc học theo giờ mình chọn | Chưa có | Bật/tắt/chọn giờ; quyền OS, timezone, hủy/đặt lại khi sửa; chạm thông báo về Hôm nay; logout không giữ nhắc cá nhân cũ | INF-16; notification thật trên Android, từ chối quyền/đổi giờ/logout |
| B-FR-11 / M1.9 | Biết hạn mức AI và Free/Pro mô phỏng | Chưa có backend quota | Entitlement do server quản lý; UI xem số lượt còn lại; request đồng thời không vượt quota; retry cùng ID không trừ lại; Free hết lượt bị chặn; Pro test cấp bằng công cụ quản trị | INF-14; test cạnh tranh, retry và user tự nâng quyền bị từ chối; không thu tiền |
| B-FR-12 / M2 FR-05/06, W10 | Ghi offline và đồng bộ an toàn | Drift v2 + outbox + worker; hiện giới hạn một thiết bị | Ghi cá nhân/bài làm local + outbox trong cùng transaction; restart; push idempotent/pull; dừng khi đổi user; version/conflict và tombstone đa thiết bị; trạng thái pending/syncing/synced/failed và retry rõ | INF-07/08; SQL RLS A/B, network cut, timeout sau commit, 2 máy sửa cùng note |
| B-FR-13 / W13, brief UI | Luồng rõ và giao diện hoàn chỉnh | App hiện auth → kho; light/dark nền, chưa đủ app shell đích | 4 tab Hôm nay/Tra cứu/Sổ học/Tiến độ; profile/settings; deep flow giữ ngữ cảnh; loading/empty/error/success, quyền, quota, đồng bộ; theme hệ thống và lựa chọn sáng/tối; phóng chữ/IME không vỡ | Figma node review khi làm; widget/nav tests + visual UAT trên Android thật |

### Yêu cầu mở rộng E1 được giữ lại

| ID | Yêu cầu từ brief mở rộng | Điều kiện trước khi làm / nghiệm thu |
|---|---|---|
| E-FR-01 | Typing có đáp án và tự đặt câu | Tách exact-match có biến thể hợp lệ với nhận xét câu mở; IME compose không tự submit; bản nháp/attempt riêng |
| E-FR-02 | Dịch Việt → Nhật và phản hồi | Có ngữ cảnh/ý định; đánh giá ý nghĩa, ngữ pháp mục tiêu, tự nhiên riêng; nhiều cách dịch đúng; xem nhận xét rồi thử lại có lineage |
| E-FR-03 | Voice → xác nhận transcript → góp ý ngữ pháp | Chốt adapter ASR Nhật và permission/privacy; sửa transcript trước AI; phân biệt lỗi ASR và lỗi ngữ pháp; không tuyên bố chấm phát âm; không mặc định lưu audio |
| E-FR-04 | Sổ lỗi, lịch sử, so sánh lần thử | Schema attempt/error có nguồn; đếm được từ bản ghi thật; lỗi AI và quiz tách; không dùng điểm tiến bộ giả |
| E-FR-05 | Mục tiêu N3–N1 | Chỉ mở cấp có nội dung được biên tập và test; baseline N5/N4 giữ nguyên; không sinh kho rỗng để trưng giao diện |

Đây là định hướng thứ tự theo mục tiêu hoàn thành M1 trước. Các chức năng E1 có trong tài liệu dự án nhưng chưa được chuyển thành cam kết lịch/ngân sách của bản đầu trong lần lập kế hoạch này.

## 4. Kiến trúc, mô hình dữ liệu và hợp đồng tích hợp

Giữ chiều phụ thuộc **presentation → domain ← data**. Use case không biết Flutter/SDK; adapter ML Kit, Supabase, notification, LLM client nằm ở data/hạ tầng. Wire implementation trong `lib/app/providers.dart`. Giữ `learning` hiện có; thêm `scanner`, `analysis`, `practice`, `review` khi có lát chức năng thật; không nhân đôi notes/progress.

| Dữ liệu | Hiện có | Thiết kế bổ sung đề xuất, chưa phải migration đã áp |
|---|---|---|
| Kho dùng chung | `grammar_points`, `grammar_examples` | Question bank có `id`, `grammar_id`, type, prompt, đáp án hợp lệ, explanation, content version; client chỉ đọc |
| Cá nhân | `profiles`, `saved_grammar`, `notes`, `progress` | Bảo toàn ID và ý nghĩa trạng thái tự đánh giá; revision server cho records mutable, cập nhật có điều kiện; giữ tombstone |
| Bài làm | Chưa có | `practice_attempts`: UUID client, user, question/content version, session, câu trả lời, kết quả, attempted time, server receipt và lineage; insert idempotent; chỉ owner đọc/ghi; không dùng điểm quiz này để cấp quyền Pro |
| Lịch ôn | Chưa có | `review_state`/bảng tương đương: user + grammar, stage/due, algorithm version; dẫn xuất lại từ attempts duy nhất; quy tắc thứ tự nhất quán mục 5 |
| AI/quota | Chưa có | Request ledger unique(user, request_id), status/reservation, usage period, model/prompt version; entitlements chỉ server quản trị; user đọc số dùng của mình, không tự ghi lượt/quyền |
| Local DB | Drift v2, 4 tables | Thêm cache question/attempt/review/settings phù hợp, migration giữ dữ liệu; outbox chứa entity/key/version/op đủ retry; regenerate Drift khi schema đổi |

Không mặc định cần lưu ảnh, audio hoặc toàn bộ câu phân tích lên server. Chỉ lưu text riêng tư khi chức năng cần và người dùng chọn; log dùng request ID, không text/token.

| Contract | Hướng triển khai baseline |
|---|---|
| OCR | Input ảnh local → text/blocks + lỗi; confidence chỉ dùng nếu engine thực sự cung cấp và có ý nghĩa; không tự tạo phần trăm |
| `analyze-grammar` (đề xuất) | Request: `request_id`, `text`, `locale`; user lấy từ session đã xác minh. Server chọn ứng viên từ kho. Response có `request_id`, `matches[]` với `grammar_id`, span tùy chọn đã validate và quota còn lại; giải thích chính từ kho |
| Lỗi AI | Kiểu lỗi có mã: unauthenticated, offline, quota_exceeded, invalid_input, timeout, unavailable, invalid_output; không tìm thấy mẫu là kết quả hợp lệ riêng |
| Quota | Đề xuất Free 5, Pro test 20 phân tích thành công/ngày UTC, lưu chính sách server. Đây là thông số đề xuất, không phải mức đã cấu hình hay quy định môn học; Hoàng chốt trước G1. Reserve nguyên tử, finalize/refund theo kết quả; lỗi provider không tính lượt; retry cùng ID không phát sinh lần tính mới |
| Sync mutable | `base_revision` → server update có điều kiện → revision mới; stale trả conflict, giữ bản local để người dùng chọn; không âm thầm ghi đè ghi chú hoặc làm sống lại tombstone |

Retry request đang processing trả trạng thái đang xử lý, không gọi model lần hai ngay. Worker/transaction phải xử lý reservation hết hạn; không giữ transaction DB trong suốt thời gian chờ LLM. Model response phải qua JSON/schema validation và allowlist ID; invalid output không được hiển thị như kết quả đúng. Chọn model sau eval, chưa fine-tune baseline.

## 5. Quy tắc nghiệp vụ bản đầu cần triển khai

Các quy tắc sau là đề xuất cụ thể để agent không tự đoán; Ánh review trước khi đổi schema, Vy duyệt trải nghiệm/nội dung.

1. **Luyện tập:** một attempt UUID cho mỗi lần nộp; bấm lại/retry không sinh thêm. Cloze chuẩn hóa khoảng trắng và dấu câu được nội dung cho phép, không tự bỏ mọi khác biệt có thể đổi nghĩa. Quiz dùng đáp án đã biên tập, không cần AI online để chấm.
2. **Ôn tập:** thang khoảng cách đề xuất 1/3/7/14/30 ngày; sai về bậc đầu và đến hạn ngày kế tiếp; đúng tăng một bậc, tối đa 30 ngày. Mẫu mới chưa làm được đưa vào hàng học mới. Mỗi câu hỏi chỉ lần nộp đầu độc lập trong một phiên tác động lịch; retry sau xem đáp án không được tính như chứng minh mới.
3. **Hai máy:** merge attempts theo UUID, giữ các lần làm độc lập. [Contract v1](../development/BASELINE-INTEGRATION-CONTRACTS.md) cụ thể hóa thứ tự canonical `(server_received_at, attempt_id)` và ngày UTC server nhận để tính lịch; giờ thực hiện từ client chỉ là metadata. Lịch local offline là tạm, có thể dời sau sync; UI phải ghi rõ đánh đổi này. Không dùng client timestamp làm LWW cho ghi chú. Notes/profile/saved/progress mutable dùng revision/conflict; bản xóa có tombstone. Đây là thiết kế A02 chờ review, chưa phải worker đa thiết bị đã chạy.
4. **Thống kê:** hiển thị đúng/tổng lần đầu độc lập, loại câu bỏ qua khỏi mẫu số và báo số bỏ qua riêng; thử lại tách riêng. Khi chưa có attempt, hiển thị chưa có dữ liệu. Tự đánh giá trạng thái và nhận xét AI không cộng vào accuracy quiz.
5. **Offline:** đã cache được xem/luyện/lưu; ảnh OCR chạy khi model sẵn sàng; LLM cần mạng và không tự gửi bản nháp khi có mạng lại nếu user chưa xác nhận. Khi đổi tài khoản dừng worker cũ, không hiện/gửi dữ liệu A bằng session B.
6. **Nội dung:** agent có thể soạn nháp, Vy duyệt đúng mẫu/cấp độ/ví dụ/đáp án và quyền sử dụng; Ánh/Hoàng kiểm tra ID/schema. Chưa duyệt không được tính vào 80–120 mẫu hoàn thành.

## 6. Phi chức năng và điều kiện chất lượng

| ID / nguồn | Bắt buộc trước bàn giao B1 |
|---|---|
| B-NFR-01 / W09 | Các feature quan trọng đủ domain/data/presentation; UI gọi use case, domain Dart thuần; test được bằng fake, composition root rõ |
| B-NFR-02 / W10 | RLS mọi bảng exposed; kiểm tra grants/API và owner; A/B không đọc/sửa/xóa/chèn đổi owner; không có LLM/service-role/signing private key trong client/Git/log |
| B-NFR-03 / W11 | OCR offline trên thiết bị thật, human review trước gửi/lưu; có post-processing chuẩn hóa input; báo cáo latency OCR riêng LLM; không bịa confidence/accuracy |
| B-NFR-04 / W09–13 | Format/analyze/unit/widget, connected SDK/SQL local, Function tests và ít nhất 1 E2E xuyên suốt; UI manual trên điện thoại; kết quả/giới hạn gắn SHA và mode |
| B-NFR-05 / W13 | Light/dark, loading/empty/error/retry, responsive và chữ phóng to; profile/release kiểm tra jank; mục tiêu 60fps chỉ ghi đạt sau đo |
| B-NFR-06 / W12 | APK release ký bằng cấu hình release thật, cài được, HTTPS backend; version/SHA/checksum/hướng dẫn; không nhận APK debug là signed release hoàn thành |
| B-NFR-07 / W12–13 | Final report PDF 25–40 trang, slides PDF 10–12 trang, binary release, repo sạch và video 3–5 phút 1080p máy thật theo knowledge pack; xác nhận thời lượng bảo vệ và yêu cầu iOS với GV |

Các con số ví dụ trong template report 3 chưa phải số đo Bunly. Rubric 30/25/20/15/10 dùng để ưu tiên công việc, không phải điểm đã đạt.

## 7. Bộ kiểm chứng và định nghĩa hoàn thành

| Luồng | Bằng chứng bắt buộc |
|---|---|
| UAT-01 | Cloud email signup → xác nhận → login → hồ sơ → restart → logout → tài khoản B; test quyền bằng request thật |
| UAT-02 | Tìm/lọc → chi tiết → lưu/note → sửa/xóa → restart offline → online sync; thử timeout sau commit và retry không trùng |
| UAT-03 | Ảnh thật → OCR khi airplane mode → sửa text → online AI thật → mẫu hợp lệ → lưu → luyện → ngày ôn và thống kê đổi đúng |
| UAT-04 | Phiên quiz offline, force-stop/restart giữ kết quả → reconnect → máy thứ hai thấy dữ liệu; hai máy sửa một note có conflict rõ |
| UAT-05 | AI hết lượt/lỗi output/timeout và notification denied/đổi giờ; user không tự nâng Pro; UI giữ bản nháp khi lỗi |
| UAT-06 | APK release + dark/light + cỡ chữ lớn + bàn phím Nhật + back navigation; quay demo trên máy thật |

Đề xuất tập đánh giá ban đầu do Vy duyệt: ít nhất 30 ảnh Nhật đủ điều kiện rõ/mờ/xoay để đo OCR CER; 50 câu có nhãn ID ngữ pháp, gồm ít nhất 10 câu không có mẫu trong kho; tách ví dụ dùng chỉnh prompt khỏi tập đánh giá cuối. Đo OCR/LLM p50/p95, số mẫu, thiết bị/mode/điều kiện, precision/recall và lỗi. Đây là quy mô đề xuất, không phải chỉ tiêu giảng viên; ngưỡng chất lượng phải chốt sau pilot, trước nghiệm thu AI, chưa có số đo hiện tại.

Một gói chỉ hoàn thành khi đúng tiêu chí, test liên quan đạt, UI có kiểm tra thiết bị nếu có, và tài liệu/bằng chứng đúng commit. Hoàn thành B1 yêu cầu **tất cả B-FR và B-NFR bắt buộc**; thiếu dịch vụ thật hoặc nội dung duyệt vẫn ghi partial/blocked ở đúng hàng. Fake giúp phát triển độc lập nhưng không thay bằng chứng integrated.

## 8. Ngoài phạm vi baseline và thông tin còn thiếu

Baseline chưa làm thanh toán thật, fine-tune/custom model training, chatbot tổng quát, chấm phát âm, hệ thống quản trị web riêng hoặc store production. Voice/dịch/N3–N1 theo E1 không bị xóa khỏi hướng phát triển.

Chưa có xác nhận mới về hạn nộp/ngày cần bản B1, số giờ nhóm, thiết bị hiện sẵn (Samsung A11 chỉ là bằng chứng lịch sử), Mac/iPhone, ngân sách/provider LLM và SMTP/domain. Lịch triển khai vì vậy tính theo gói/cổng trong [kế hoạch phân công](BASELINE-DELIVERY-OWNERSHIP.md), không gán ngày nộp tự suy từ lịch cũ 29/10. Công việc domain/UI/local không phụ thuộc thông tin còn thiếu vẫn có thể tiến hành khi được giao triển khai.
