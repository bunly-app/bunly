# Bunly — Phân công hoàn thành baseline và bàn giao nhóm

Ngày: **09/11/2026**. Kế hoạch mới theo yêu cầu người dùng; lịch M2/M3 29/10 trong [kế hoạch cũ](TEAM-M2-M3-Delivery-Plan.md) là lịch sử, không dùng làm hạn hiện tại.

Đầu vào: [PRD tổng thể](PRD-BUNLY-Full-Function-Baseline.md), [ma trận hạ tầng](../development/INFRASTRUCTURE-SETUP-MATRIX.md), PRD M2 và development guide. Tác vụ này chỉ lập kế hoạch, chưa triển khai chức năng/deploy.

**Tiến độ A00 ngày 09/11/2026:** đã thực hiện [audit baseline](../reports/A00-Baseline-Audit-2026-11-09.md), sẵn sàng Ánh đối chiếu. Format/analyze/24 tests/codegen đạt; APK build lỗi cache Gradle, Docker chưa chạy, chưa có Android kết nối, Cloud INACTIVE. Chưa triển khai A01–A10 hoặc nghiệm thu G0. Phạm vi A02/A03 cụ thể được ghi trong báo cáo audit.

## 1. Cách phân công theo thế mạnh đã xác nhận

**Tiến độ tiếp 09/11 — [bàn giao A02/A03-01](../reports/A02-A03-01-Delivery-2026-11-09.md):** đã soạn contract và fixture B0 chờ review; đã sửa cache/logout boundary trong code, 30/30 tests đạt. A02 chưa có Ánh/Vy duyệt; A03-02/03, tích hợp thiết bị và các gói A04 trở đi chưa hoàn thành. Không dùng trạng thái này làm nghiệm thu baseline.

| Người | Vai trò | Giai đoạn Hoàng điều phối agent làm bản đầu | Sau khi có baseline |
|---|---|---|---|
| Văn Hoàng — leader, full stack, agent AI | Đầu mối sản phẩm, tích hợp và hạ tầng | Giao gói cho agent; duyệt phạm vi, quản lý config/Cloud/API/budget; ghép code; chạy build/E2E; cập nhật evidence | Quản lý release/CI, tích hợp PR, theo dõi lỗi/chỉ số, phát triển backend AI/quota |
| Ánh — full stack, chuyên môn kỹ thuật cao nhất | Reviewer kỹ thuật chính, xử lý phần khó | Review sớm contract/schema/sync/AI; không cần viết lại những phần agent đã làm đúng; chỉ rõ lỗi và kiểm tra sửa | Owner độ tin cậy offline/sync/conflict/migration; cải thiện OCR/AI adapter/performance, review kiến trúc chung |
| Vy — ý tưởng, thiết kế, nghiệp vụ người dùng | Owner trải nghiệm, nội dung và UAT | Chốt flow/Figma/states, duyệt nội dung và câu hỏi/tập eval; test app theo tiêu chí nghiệp vụ; ghi lỗi tái lập | Cải thiện thiết kế/accessibility/nội dung, mở rộng bài luyện/dịch/voice về nghiệp vụ, kiểm thử người dùng và hồ sơ bảo vệ |

Không dồn cho Ánh việc sửa toàn bộ code cuối đợt. Review tại điểm contract, khi hoàn thành lát xuyên suốt và trước release. Hoàng vẫn chịu trách nhiệm chất lượng phần agent được mình giao; agent không là người nghiệm thu cuối.

## 2. Bảng gói việc — thứ tự, owner, đầu ra và bàn giao

Các gói A được ưu tiên đủ chức năng trước; B là củng cố/tối ưu sau baseline. Ước lượng lịch chỉ lập sau khi có thời gian và thiết bị, không cam kết số ngày chưa xác nhận.

| Gói / phụ thuộc | Phạm vi | Thực hiện bản đầu | Reviewer / nghiệm thu | Đầu ra cụ thể / cổng |
|---|---|---|---|---|
| A00 / không | Chụp baseline, kiểm tra tool và Cloud INACTIVE; rà khoảng trống M2 | Hoàng + agent | Ánh đối chiếu | SHA + diff, bảng Ready/Blocked, thiết bị và config/mode; không bắt đầu bằng dựng app mới |
| A01 / A00 | Local connected, quyền team, hạ tầng Cloud đích, email/callback | Hoàng; Owner thực hiện thao tác tài khoản | Ánh kỹ thuật, Vy email flow | INF-01–10 đạt phần cần dùng; Cloud actions chỉ khi target/phạm vi được giao |
| A02 / A00 | Chốt contract dữ liệu/API/errors, màn trạng thái và bộ nội dung thử | Hoàng + agent soạn; Vy duyệt nghiệp vụ | Ánh duyệt contract/schema | Fixture OCR/AI, attempt/review/quota/version conflict; 12 mẫu cho B0; không tạo migration hosted trong gói planning |
| A03 / A02 | Hoàn thiện M2 và app shell theo Figma: auth/profile/kho/Sổ học/settings | Hoàng + agent | Ánh code, Vy UI/UAT | B-FR-01–04,13 trong phạm vi nhỏ chạy được; giữ DI/domain và namespace; không thay code bằng mockup |
| A04 / A02 | Camera/chọn ảnh/ML Kit Nhật/review/dán câu | Hoàng + agent | Ánh resource/lifecycle, Vy chữ và quyền | B-FR-05; OCR airplane mode thật; không có private API key cho OCR |
| A05 / A01,A02 | Function/LLM adapter/validation/quota/Free-Pro | Hoàng + agent | Ánh auth/transaction, Vy chất lượng gợi ý | B-FR-06,11; local tests + provider thật; key/budget là đầu vào Owner chuẩn bị |
| A06 / A02,A03 | Quiz/cloze/attempt/review engine/home/stats | Hoàng + agent | Ánh rules/data, Vy đáp án và luồng | B-FR-07–09; chấm offline, lịch deterministic, thống kê không bịa; migration/codegen/tests |
| A07 / A03,A06 | Đồng bộ toàn bộ entity, version/conflict/tombstone và account switch | Hoàng + agent; Ánh tham gia phần khó | Ánh reviewer chính; Vy case mất mạng | B-FR-12; offline restart, retry, hai máy, RLS. Không trì hoãn phần bảo toàn dữ liệu sang tối ưu |
| A08 / A03 | Nhắc học local và cấu hình giờ/quyền | Hoàng + agent | Ánh OS/lifecycle, Vy UAT | B-FR-10; báo đúng giờ, hủy đúng khi đổi giờ/logout; không cần FCM |
| A09 / bắt đầu A02, hoàn tất trước A10 | Kho 80–120 mẫu, câu hỏi và tập eval | Agent soạn draft; **Vy chịu trách nhiệm duyệt**; Hoàng import | Vy nội dung; Ánh schema/test dữ liệu | Nội dung hợp lệ và nguồn sử dụng; tối thiểu câu hỏi theo PRD; tập test tách khỏi prompt examples |
| A10 / A03–09 | Tích hợp, test, signed release, UAT và hồ sơ | Hoàng + agent, Vy kịch bản/báo cáo/video | Ánh kỹ thuật; Hoàng chấp nhận bản giao, Vy nghiệm thu luồng | B1: mọi FR/NFR có bằng chứng; signed APK/SHA/checksum, hướng dẫn, report/slides/video; giữ mục chưa xác minh |
| B01 / A10 | Tối ưu offline/sync/performance và OCR adapter | Ánh owner; Hoàng hỗ trợ CI/infra | Hoàng review; Vy regression UAT | Từng thay đổi có before/after measurement; không đổi âm thầm contract |
| B02 / A10 | Cải thiện model/prompt/retrieval/quota | Hoàng owner; agent hỗ trợ | Ánh kỹ thuật, Vy eval | Giảm lỗi/latency/cost trên cùng eval; chỉ cân nhắc fine-tune sau phân tích lỗi/dữ liệu |
| B03 / A10 | Cải thiện UI, nội dung và nghiên cứu E1 | Vy owner nghiệp vụ; Ánh/Hoàng code theo gói | Hoàng ưu tiên, Ánh review | Stories cho typing/dịch/voice/sổ lỗi; cần scope/contract/data trước khi code; không tự thêm dịch vụ trả phí |

**Các điểm nhóm cần tham gia ngay cả khi Hoàng làm bản đầu:** Ánh duyệt A02 trước thay schema/contract, Vy duyệt flow và 12 mẫu đầu; Hoàng có thể tự cho agent làm phần độc lập trong khi chờ review. Chưa review/duyệt thì ghi pending, không tự ghi Approved.

## 3. Năm cổng thực hiện, không thay mốc báo cáo môn học

| Cổng | Điều cần chứng minh | Chuyển tiếp |
|---|---|---|
| G0 — Nền sẵn sàng | A00–02; local stack/tool ổn, hiện trạng Cloud rõ, contract và task nhỏ có owner | Bắt đầu features; phần cloud chặn không ngăn domain/local/UI tiến hành |
| G1 — Một vòng học thật (B0) | 12 mẫu: ảnh → OCR offline → review → AI thật → mẫu → lưu → quiz → ngày ôn/thống kê | Còn quota/reminder/content/conflict thiếu vẫn gọi B0, chưa gọi đủ chức năng |
| G2 — Phủ đủ phạm vi | Các A03–09 xong toàn bộ, kho đạt số lượng, email và quota đúng, offline đa thiết bị có test | Dừng thêm tính năng, đóng lỗi tích hợp |
| G3 — Bản bàn giao B1 | A10 đạt: thiết bị thật, connected backend đã chỉ định, signed release, evidence/docs | Bàn giao nhóm, bắt đầu tối ưu có kiểm soát |
| G4 — Cải thiện / E1 | B01–03 theo lỗi/chỉ số và ưu tiên đã chốt | Nâng chất lượng hoặc mở phạm vi có tiêu chí mới |

## 4. Mẫu giao việc cho agent

Mỗi gói chia thành task vừa một mục đích, có các trường dưới đây. Đây là mẫu mô tả công việc, không phải lệnh triển khai toàn bộ ngay khi đọc file.

| Trường | Nội dung phải có |
|---|---|
| ID và mục tiêu | Ví dụ A04-02 / B-FR-05: sửa được OCR text trước xác nhận |
| Baseline | Branch/SHA, working tree diff đang có, phần cần giữ; không tạo worktree nếu user chưa yêu cầu |
| Tài liệu | AGENTS.md, PRD tổng thể + M2, guide, contract và Figma node liên quan |
| Phạm vi file | Feature cần sửa, test và docs; báo trước thay đổi `providers.dart`, schema, generated file, lockfiles |
| Hợp đồng | Input/output/errors, owner/session, offline, idempotency và version; fake và adapter thật cùng contract |
| Acceptance | Hành vi quan sát được, lỗi/edge case, visual/device check; chỉ rõ cần local/Cloud/provider thật |
| Kiểm chứng | Lệnh/kết quả/pass-fail/skipped, mode/backend/device và log đã lọc; không suy từ test fake |
| Bàn giao | File đổi, quyết định, bug còn lại, cách chạy, PR/SHA khi có; không commit credentials |

Đầu tiên kiểm tra feature có sẵn để chỉ bổ sung phần thiếu. Trên cùng checkout, không để nhiều phiên agent sửa đồng thời schema/DI/lockfile không điều phối. Không tự spawn nhiều agent chỉ vì file này có mẫu giao việc; Hoàng giao từng tác vụ theo nhu cầu.

## 5. Review, nghiệm thu và phân biệt trạng thái

Trạng thái: **Todo → Doing → Review → Verified → Integrated**. Blocked ghi lý do, người xử lý và việc độc lập còn làm được. Có source/fake/migration chưa có nghĩa Verified. Chỉ gán trạng thái sau kết quả thật.

| Khi bàn giao | Hoàng | Ánh | Vy |
|---|---|---|---|
| Feature code | Kiểm tra phạm vi, tích hợp, chạy checks | Review chiều phụ thuộc, lỗi dữ liệu/quyền, test có ý nghĩa | Kiểm tra flow, states, wording, nội dung |
| Backend/service | Chuẩn bị tài khoản/config/secret, target và chi phí; vận hành bản giao | Review RLS/API/idempotency/race/conflict | Kiểm tra hành vi email/quota/offline trên app |
| Release | Chốt SHA, build/sign, URL, evidence và danh sách tồn | Xác nhận kiểm tra kỹ thuật, giới hạn | UAT thiết bị, quay demo, đối chiếu báo cáo với chức năng thật |

Theo AGENTS.md, commit nhánh hiện tại dùng identity `Vcoch27 <hoangtungmy123@gmail.com>`; không rewrite commit hoặc thêm Codex co-author. Tác vụ soạn kế hoạch này chưa tạo commit. Các nhánh/PR của thành viên sau bàn giao tuân theo quy ước repo được thống nhất, không giả danh người khác.

## 6. Việc cần người sở hữu cung cấp khi bắt đầu tích hợp thật

Hoàng chốt deadline/thời gian nhóm, thiết bị Android và môi trường iOS hiện có; xác định hành động với project INACTIVE; chọn provider LLM/ngân sách, SMTP/sender/domain; cung cấp quyền qua tài khoản riêng. Agent có thể chuẩn bị code, example config, test và hướng dẫn trước. Những khoản cần mua, lời mời tài khoản hoặc deploy hosted không được tự suy là đã được cho phép từ yêu cầu lập kế hoạch này.
