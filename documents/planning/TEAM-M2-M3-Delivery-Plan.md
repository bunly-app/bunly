# Bunly — Phân công hoàn tất M2 và triển khai M3

Ngày lập: 29/10/2026. Trạng thái: kế hoạch thực hiện, chưa phải bằng chứng hoàn thành tính năng.

## 1. Các quyết định đã thống nhất và giả định lập lịch

- M2 nộp trong ngày 29/10/2026; Hoàng phụ trách thực hiện, tích hợp và hoàn thiện báo cáo. Người dùng xác nhận sẽ bố trí đủ thời gian; chưa chốt giờ nộp cụ thể.
- M3 nộp tuần sau; ngày/giờ cụ thể cần điền theo lịch học phần, không suy từ hạn theo tuần trong template.
- Kế hoạch tuần tới tạm tính 5 giờ/người, tổng 15 giờ làm việc của con người. Đây là ngân sách điều phối agent, chạy thử, review và sửa lỗi; không phải cam kết toàn bộ phạm vi sẽ hoàn thành trong 15 giờ.
- Công cụ làm việc: Codex và Antigravity. Flutter đã chạy được, có Android thật và Docker. Supabase Auth chưa được xác minh trên môi trường của nhóm.
- Hiện trạng đầu vào là mã nguồn hiện có trong repository và bản xem trước M2; không có phần triển khai bổ sung ngoài repo được nhóm thông báo.
- Chuẩn nghiệm thu M2 giữ FR-01 đến FR-06 trong PRD. M3 ưu tiên OCR/AI, đồng bộ nâng cao, kiểm thử và hiệu năng. Yêu cầu chưa đạt phải giữ trạng thái chưa đạt, không tự bỏ khỏi phạm vi.
- Agent thực hiện phần lớn việc đọc mã, đề xuất, lập trình, tạo test và soạn tài liệu. Người phụ trách chịu trách nhiệm kiểm tra đầu ra, chạy trên thiết bị và chấp nhận bàn giao.

Tài liệu này chỉ mô tả trách nhiệm công việc, không ghi đánh giá cá nhân. Chưa tạo DOCX, sửa báo cáo nộp, chạy kiểm thử ứng dụng hoặc tạo tag trong tác vụ lập kế hoạch này.

## 2. Căn cứ và hiện trạng cần đối chiếu

Đọc trước khi giao việc: `AGENTS.md`, `PRD-M2-Architecture-Base.md`, `../development/GETTING_STARTED.md`, `../development/ARCHITECTURE.md`, `../roles/CLI-Environment-Maintainer.md`, báo cáo M1 và bản xem trước M2.

| Hạng mục | Đầu vào hiện có | Phần còn phải làm/kiểm chứng |
|---|---|---|
| Auth | Form, use case, Supabase adapter | Auth thật, xác nhận email, lỗi/khôi phục phiên, hồ sơ |
| Kho ngữ pháp | Danh sách/tìm/lọc/chi tiết, asset/API/cache | Connected trên thiết bị, cache/lỗi rõ ràng, nội dung biên tập |
| Học tập | Ghi chú local, transaction/outbox | Lưu/bỏ lưu, sửa/xóa, trạng thái và thống kê |
| Dữ liệu | Migration Supabase/RLS, Drift version 1 | Local schema/migration cho phần mới, worker push/pull |
| Chất lượng | Test và CI đã có trong repo | Chạy lại trên commit bàn giao, E2E, APK, Actions thực tế |
| M3 | Định hướng OCR/LLM trong M1 | Chưa có bằng chứng OCR/AI chạy thật trong các tài liệu đã đọc |

Các kết quả cũ trong bản xem trước M2 chỉ là lịch sử kiểm chứng. Dùng log mới để xác nhận bản nộp. Những số latency, accuracy, RAM, FPS trong template M3 là ví dụ, không sao chép thành số đo của Bunly.

## 3. Vai trò và nguyên tắc phối hợp

| Người | Trách nhiệm chính M2 | Trách nhiệm chính M3 | Review/hỗ trợ |
|---|---|---|---|
| Nguyễn Văn Hoàng | Toàn bộ luồng M2, tích hợp, kiểm chứng, báo cáo/video | Đồng bộ, Edge Function/LLM/hạn mức, tích hợp và bản phát hành | Review OCR/Flutter của Ánh; hỗ trợ môi trường, chốt hợp đồng |
| Đoàn Nhật Ánh | Nhận bàn giao baseline M2 khi có | OCR và luồng Flutter từ ảnh/dán câu đến kết quả; kiểm thử UI/OCR | Review đồng bộ/API của Hoàng, hỗ trợ migration và test khi có lỗi |
| Nguyễn Thị Ánh Vy | Nhận baseline nghiệp vụ khi có | Luồng/trạng thái UX, đặc tả nội dung, tập đánh giá và UAT/kịch bản demo | Kiểm tra trải nghiệm xuyên suốt, đối chiếu yêu cầu với bằng chứng |

- Mỗi gói có một người chịu trách nhiệm cuối; agent không thay vai trò nghiệm thu.
- Người triển khai cập nhật test và ghi bằng chứng cho phần mình làm. Không dồn toàn bộ test/tài liệu cho người khác cuối tuần.
- Hoàng và Ánh làm theo lát cắt chức năng, mỗi lát cắt đủ presentation/domain/data. Hợp đồng dùng chung được chốt trước khi code song song.
- Vy bàn giao theo buổi cố định: buổi đầu chốt luồng và dữ liệu đánh giá; buổi sau UAT và rà báo cáo/video. Các quyết định nhỏ dùng giả định đã ghi để tiếp tục, không chờ phản hồi liên tục.
- Nếu gói đang chặn người khác, bàn giao interface, fake và fixture trước; sau đó tiếp tục adapter thật. Fake không được ghi là tích hợp thật.

## 4. M2 hôm nay — Hoàng phụ trách

Thực hiện theo thứ tự dưới đây. Không yêu cầu làm lại base đã có. Với mỗi gói, agent phải đọc mã thực tế, liệt kê khoảng trống rồi chỉ bổ sung phần thiếu.

### M2-00 — Chụp baseline và kiểm tra môi trường

- Đầu vào: nhánh hiện tại, working tree, SDK pin, lockfile, Android, Docker.
- Việc: ghi SHA đầu vào; giữ nguyên các file local chưa theo dõi; xác nhận Flutter/Dart/Node/Supabase CLI, Docker daemon và thiết bị được nhận diện. Cài dependency theo lockfile khi cần.
- Đầu ra: bảng công cụ/kết quả và danh sách lỗi môi trường. Mở task sửa riêng nếu lỗi chặn.
- Đạt khi: xác định rõ lệnh nào chạy được; không coi việc đã cài Docker là daemon sẵn sàng.
- Bàn giao: baseline chung cho tất cả gói M2; thông tin cấu hình chỉ ghi tên biến và trạng thái, không ghi giá trị bí mật.

### M2-01 — Auth thật và hồ sơ (FR-01)

- Phạm vi: `lib/features/auth/`, `lib/app/`, schema/data hồ sơ khi cần.
- Khởi động Supabase local đầy đủ Auth. Kết nối Android thật theo hướng dẫn của repo, ưu tiên USB/adb reverse khi phù hợp; xác minh route mạng trước khi sửa nghiệp vụ.
- Chạy đăng ký, xử lý xác nhận email theo cấu hình local, đăng nhập, lỗi mật khẩu, đăng xuất, khôi phục phiên sau mở lại. Không dùng demo làm bằng chứng Auth.
- Bổ sung entity/interface/use case/repository/UI cho hồ sơ: tên hiển thị, N5/N4, mục tiêu, phút học/ngày; validation nhất quán với DB.
- Ghi/đọc hồ sơ đúng người, có tải/lỗi/thử lại; chốt hành vi khi người dùng chưa tạo hồ sơ và khi offline.
- Test: validation, repository thành công/lỗi, controller/widget; thiết bị thật với tài khoản A/B.
- Đạt khi: đăng nhập thật và mở lại hồ sơ đúng user; đổi user không thấy hồ sơ cũ. Có log/ảnh đã loại thông tin nhạy cảm.

### M2-02 — Kho ngữ pháp connected và bộ dữ liệu (FR-02)

- Phạm vi: `lib/features/grammar/`, asset và seed.
- Kiểm tra tải từ API, tìm mẫu/ý nghĩa, phối hợp lọc cấp độ và nhóm, chi tiết đủ công thức/cách dùng/ví dụ Nhật–Việt.
- Thể hiện tải/rỗng/lỗi/thử lại, nguồn cache và offline; lỗi quyền/xác thực không bị che thành tải mới thành công.
- Kiểm tra UUID liên kết giữa seed, asset, ví dụ và dữ liệu cá nhân. Không sinh lại ID tùy tiện làm hỏng tham chiếu.
- Ghi số mẫu N5/N4 thực tế được kiểm tra; dữ liệu do AI đề xuất phải có trạng thái chờ duyệt. Mục tiêu 80–120 mẫu của MVP vẫn được theo dõi riêng.
- Test: tổ hợp tìm/lọc, rỗng, remote lỗi có/không cache, mở chi tiết trên điện thoại.
- Đạt khi: đọc dữ liệu thật online, nội dung đã tải mở lại offline và UI mô tả đúng trạng thái.

### M2-03 — Học tập cá nhân và local schema (FR-03/FR-04)

- Phạm vi: `lib/features/learning/`, `lib/core/database/`, wiring `lib/app/providers.dart`.
- Bổ sung lưu/bỏ lưu mẫu, danh sách đã lưu; thao tác lặp không tạo trùng.
- Bổ sung sửa/xóa ghi chú; validation sau trim từ 1 đến 2000 ký tự; đúng ghi chú/đúng mẫu/đúng user. Dùng tombstone cho xóa chờ đồng bộ.
- Bổ sung bốn trạng thái mới/đang học/cần ôn/đã nắm; chốt quy tắc mặc định, chuyển trạng thái và mẫu chưa có progress.
- Thống kê lấy từ dữ liệu thật của user, không hardcode hoặc tự suy độ chính xác khi chưa có bài làm.
- Thiết kế local tables/migration từ Drift version 1, bảo toàn ghi chú và outbox cũ; tăng schema version, sinh lại code và test nâng cấp DB.
- Mọi ghi cá nhân trong connected mode phải đi cùng outbox trong transaction. Demo lưu namespace riêng, không tạo thao tác gửi remote.
- Test: trùng/lưu-bỏ lưu/sửa-xóa, khởi động lại DB, rollback, A/B isolation, migration có dữ liệu cũ, đếm trạng thái.
- Đạt khi: thao tác UI lưu bền sau tắt/mở app; lỗi không làm mất dữ liệu; số đếm khớp bản ghi.

### M2-04 — Đồng bộ cơ bản một thiết bị (FR-05)

- Phạm vi: lớp data/sync dùng chung và vòng đời session; chốt vị trí thư mục trước khi thêm.
- Chốt hợp đồng outbox: operation ID ổn định, owner/namespace, entity/key, thao tác/payload, revision cục bộ, thứ tự, số lần thử và lỗi; migration tương thích.
- Push theo thứ tự; upsert/idempotency phù hợp từng loại dữ liệu; chỉ xác nhận đúng operation sau remote success. Timeout sau server commit phải retry an toàn.
- Không để acknowledgment của thao tác cũ xóa thao tác mới hoặc ghi đè bản local mới hơn. Giữ pending khi lỗi mạng, hết phiên hoặc RLS từ chối.
- Pull và merge dữ liệu cá nhân với pending local; có tombstone, không làm sống lại bản đã xóa. Không gọi upload-only là hoàn chỉnh push/pull.
- Trigger khi có session hợp lệ, mở app hoặc người dùng thử lại; tránh nhiều worker cùng gửi. Dừng khi logout/đổi user, kiểm tra owner trước và sau await.
- UI phân biệt lưu trên máy/đang chờ/đã đồng bộ/lỗi và có retry. Không hứa chạy nền khi app bị đóng nếu chưa triển khai.
- Test: offline → ghi → restart → online, retry trùng, timeout sau commit, lỗi quyền, thao tác liên tiếp, chuyển user giữa request.
- Đạt khi: dữ liệu local và remote khớp sau reconnect trên cùng thiết bị, không mất thao tác và không gửi A bằng session B. Xung đột nhiều thiết bị tiếp tục ở M3.

### M2-05 — RLS, E2E và chất lượng (FR-06)

- Chạy local migrations/seed trong môi trường kiểm thử; chỉ reset DB local có thể bỏ dữ liệu sau khi kiểm tra dữ liệu cần giữ.
- Mở rộng SQL test cho toàn bộ bảng cá nhân được dùng: A đọc/ghi A; B không đọc/sửa/xóa A, không chèn/đổi owner thành A; client không ghi kho chung.
- Sau thử truy cập trái phép, kiểm tra dữ liệu A còn nguyên. Kiểm thử bằng vai trò authenticated, không dùng service-role làm bằng chứng.
- Trên Android thật: đăng nhập A → hồ sơ → tìm/lọc → chi tiết → lưu/ghi chú/trạng thái → mở lại → offline → reconnect → logout → B. Chạy cả lỗi mạng và hết phiên.
- Chạy bộ lệnh chất lượng ở mục 9; kiểm tra Actions thật của commit nếu có quyền truy cập. Có cấu hình workflow chưa chứng minh CI đã đạt.
- Đạt khi: đối chiếu từng FR với test/ảnh/log và giới hạn; ghi rõ manual E2E hay integration test tự động.

### M2-06 — Báo cáo, video và mốc mã nguồn

- Đầu vào: bằng chứng mới từ M2-00 đến M2-05. Không dùng mục tiêu làm kết quả.
- Hoàn thiện báo cáo 2 theo đúng ba mục template: Clean Architecture; schema/ERD và RLS; tiến độ lõi + liên kết mã/video.
- Chọn một ví dụ xuyên suốt SaveNote: UI → controller → use case → repository → transaction/outbox → remote; mô tả đúng phần đã triển khai tại commit nộp.
- ERD đối chiếu migration thật; local DB/outbox mô tả riêng. Ghi phiên bản SDK, thiết bị/OS, số nội dung, kết quả test, hạn chế và việc chuyển tiếp M3.
- Quay video 2–3 phút theo kịch bản có dữ liệu thật. Nếu có đoạn demo/fake phải ghi rõ; không để thông tin tài khoản/khóa xuất hiện trong video.
- Chốt SHA, build và kiểm tra artifact thuộc đúng SHA; bổ sung URL truy cập được. Tag `milestone-2` chỉ tạo khi đạt tiêu chí PRD; nếu chưa đạt, ghi branch/SHA nộp và phần còn thiếu.
- Đạt khi: người khác mở được tài liệu/link, hiểu cách chạy và đối chiếu tuyên bố với bằng chứng. Không ghi iOS đã chạy nếu chỉ kiểm chứng Android.

### Điểm dừng trước hạn nộp

Hoàng chủ động chốt giờ ngừng thêm tính năng để chạy lại, quay và nộp. Việc chưa đạt được đưa vào danh sách tồn đọng có ID, owner và ảnh hưởng M3. Nộp báo cáo đúng hiện trạng không đồng nghĩa nghiệm thu đủ FR-01–FR-06. Không trì hoãn toàn bộ báo cáo chỉ vì một gói bị chặn, cũng không đổi nhãn chưa chạy thành đã đạt.

## 5. Bàn giao từ M2 sang M3

Hoàng chuẩn bị một bản baseline ngắn, dùng chung cho hai thành viên và các agent:

- SHA/branch nộp M2, đường dẫn APK nếu có, hướng dẫn chạy, trạng thái demo/connected.
- Bảng FR-01–FR-06: đạt/chưa đạt/chưa chạy, link bằng chứng, bug và người tiếp nhận.
- Contract entity/repository/sync và schema version thực tế; các quyết định chưa chốt.
- Danh sách file dùng chung dễ xung đột và thứ tự tích hợp.
- Việc còn thiếu của M2 đi trước các tác vụ M3 phụ thuộc nó. Không giả định Auth/worker đã hoàn chỉnh chỉ vì M2 đã nộp.

## 6. M3 — Gói việc chi tiết tuần tới

### M3-00 — Chốt hợp đồng tích hợp và baseline (Hoàng; Ánh review)

- Rà tồn đọng M2, chọn lỗi chặn cần xử lý trước. Chốt model dữ liệu và các interface dùng chung bằng tài liệu/fixture nhỏ.
- Contract OCR: đầu vào ảnh, văn bản/đoạn nhận dạng, lỗi và metadata; không bịa confidence nếu SDK không cung cấp.
- Contract phân tích: câu đã xác nhận, request ID; kết quả gồm ID ngữ pháp hợp lệ và dữ liệu phục vụ hiển thị. Nếu có span, chốt đơn vị offset và cách kiểm tra chuỗi Unicode.
- Contract lỗi: chưa đăng nhập, offline, hết hạn mức, timeout, đầu ra không hợp lệ, không tìm thấy mẫu, dịch vụ không sẵn sàng; không để adapter trả lỗi không định dạng trực tiếp ra UI.
- Chốt vị trí `scanner`/`analysis` khi cần; không tạo lại feature learning/progress trùng hệ thống M2. Fake và adapter thật dùng cùng interface.
- Đạt khi: hai người viết được phần mình từ cùng fixture và không cần đoán field/status. Hoàng cập nhật providers sau khi ghép.

### M3-01 — Luồng UX và nội dung kiểm thử (Vy; Hoàng/Ánh hỗ trợ)

- Đầu buổi 1: chốt màn quét/chọn ảnh/dán câu → sửa văn bản → phân tích → kết quả → chi tiết → lưu. Bao gồm back/cancel và giữ nội dung đã sửa khi retry.
- Đặc tả trạng thái: quyền camera bị từ chối, ảnh không có chữ, ảnh khó đọc, OCR lỗi, model chưa sẵn sàng, offline, đang xử lý, AI lỗi/hết lượt, không có mẫu trong kho.
- Bàn giao flow, ghi chú màn hình/wireframe vừa đủ và câu chữ UI; không buộc lập trình chờ hoàn thiện toàn bộ thiết kế.
- Chuẩn bị tập ảnh/câu có ID, nguồn/quyền sử dụng, điều kiện chụp, transcript chuẩn và mẫu ngữ pháp đúng; chia nhóm rõ/mờ/nghiêng/nhiều dòng/không có mẫu phù hợp.
- Agent đề xuất dữ liệu và nhãn; người đủ khả năng tiếng Nhật kiểm tra nhãn. Nếu chưa có người kiểm tra, ghi nhãn chưa duyệt và chưa dùng để kết luận accuracy.
- Tách dữ liệu phát triển prompt và dữ liệu đánh giá giữ lại; không chỉnh prompt theo từng câu của tập đánh giá cuối.
- Đầu ra: đặc tả UX, bảng dữ liệu/nhãn, checklist UAT, nội dung demo. Số mẫu ghi thực tế; không ấn định tập nhỏ là đại diện cho mọi điều kiện.
- Đạt khi: Ánh dùng được đặc tả/ảnh để triển khai, Hoàng dùng được nhãn để đo; có trạng thái duyệt cho từng dòng.

### M3-02 — OCR và Flutter xuyên suốt (Ánh; Hoàng review, Vy UAT)

- Chọn package ML Kit Japanese tương thích SDK đang pin; kiểm tra yêu cầu Android/build/model và ghi quyết định trước khi thêm dependency.
- Camera/thư viện và dán câu; quyền truy cập, hủy thao tác, vòng đời widget, xoay ảnh, giải phóng tài nguyên. Không lưu ảnh lên server mặc định.
- Adapter OCR nằm lớp data; domain không import ML Kit. Kết quả hiện trong màn sửa để người dùng xác nhận trước khi gửi AI.
- Kiểm tra offline sau khi model sẵn sàng; nêu rõ hành vi lần đầu/model chưa tải. Offline OCR không đồng nghĩa LLM offline.
- Tích hợp contract phân tích từ M3-00; dựng fake trước nếu endpoint chưa xong, sau đó chạy với endpoint thật.
- Kết quả nối ID đến chi tiết kho; chỉ hiển thị mẫu hợp lệ, có đường tìm thủ công và trạng thái không tìm thấy. Loading/cancel/retry không gửi lặp ngoài ý muốn.
- Test: OCR adapter mapping/lỗi bằng fake, widget các trạng thái và Unicode; chạy ML Kit thật trên Android với tập ảnh của Vy. Không coi test fake là benchmark OCR.
- Đạt khi: ảnh thật → OCR → người dùng sửa → API thật → mẫu trong kho → lưu được; đường dán câu hoạt động khi không dùng ảnh.

### M3-03 — Edge Function, LLM và hạn mức (Hoàng; Ánh review)

- Chọn nhà cung cấp/model sau thử nghiệm, ghi model/version/config thực tế; khóa chỉ ở server. Đặc tả này không mặc định nhà cung cấp.
- Endpoint xác minh JWT/identity, validate và giới hạn độ dài input, truy vấn kho ứng viên rồi gọi LLM. Nội dung người dùng là dữ liệu, không phải lệnh thay chính sách server.
- Kiểm tra JSON schema, loại ID ngoài kho, trùng ID và span sai. Không tìm thấy thì trả trạng thái rõ; không biến gợi ý sai thành ngữ pháp đã xác minh.
- Chốt timeout, retry có giới hạn, lỗi và log đã loại nội dung/định danh không cần thiết. Không retry tùy tiện làm tính thêm lượt hoặc phát sinh nhiều request tính phí.
- Free/Pro: chốt đơn vị lượt, kỳ reset, khi nào trừ/hoàn lượt và xử lý request lặp. Kiểm tra/cập nhật quota nguyên tử phía server; client không tự cấp quyền Pro.
- RLS/quyền cho dữ liệu quota và cấu hình quyền; không mở bảng chung cho client ghi để tiện demo.
- Test JWT thiếu/sai, input lỗi, quota hết, request đồng thời/lặp, timeout, output sai schema, ID không tồn tại, no-match; chạy endpoint thật riêng với test mock.
- Đạt khi: endpoint bảo vệ được theo contract, Flutter gọi thật và UI giải thích lỗi/hạn mức; ghi rõ phần Free/Pro mới mô phỏng.
- Triển khai hosted chỉ sau khi Hoàng chỉ định rõ project đích. Nếu chưa có đích, dùng local; APK dùng local phải ghi điều kiện kết nối, không coi là bản dùng độc lập cho người ngoài.

### M3-04 — Xung đột và độ tin cậy đồng bộ (Hoàng; Ánh review)

- Hoàn tất tồn đọng worker M2 trước; mở rộng push/pull và kiểm thử hai thiết bị hoặc hai client lưu trữ độc lập cùng tài khoản.
- Chốt theo loại dữ liệu: ghi chú, lưu mẫu, progress; timestamp client không tự quyết định thứ tự. Server revision/timestamp và tie-break phải được mô tả, kiểm thử.
- Chốt hành vi ghi đồng thời, edit-vs-delete, tombstone, duplicate và thứ tự pull; nếu có thể mất một bản sửa theo chính sách, UI/tài liệu phải nói rõ.
- Kiểm tra pending local không bị pull ghi đè, crash giữa local commit/remote ack, timeout sau commit, hết phiên, account switch và retry nhiều lần.
- Không đồng bộ bài làm bằng ghi đè một bản ghi progress nếu đã bổ sung practice; bài làm cần ID ổn định và chiến lược append/deduplicate.
- Test unit/repository cho race và migration, RLS cho bảng mới; chạy kịch bản mạng thật. Ghi số thao tác thành công/lỗi/mất/trùng và điều kiện thử.
- Đạt khi: chính sách xung đột xác định được kết quả, thao tác không biến mất âm thầm; báo cáo mô tả đúng phạm vi đã thử.

### M3-05 — Đo chất lượng AI, coverage và hiệu năng (chia trách nhiệm)

- Vy quản lý tập đánh giá/nhãn và bảng kết quả UAT; Ánh đo OCR/UI; Hoàng đo API/sync, tổng hợp coverage và phương pháp.
- OCR: lưu transcript chuẩn và dự đoán, quy tắc chuẩn hóa cố định; tính CER bằng edit distance/tổng ký tự chuẩn, báo số ảnh/ký tự và lỗi theo điều kiện. Nếu dùng accuracy suy từ CER phải ghi công thức/giới hạn.
- Phát hiện ngữ pháp: so tập ID dự đoán với nhãn, định nghĩa TP/FP/FN; báo precision/recall/F1, cách tổng hợp, no-match, dữ liệu chưa duyệt và giới hạn tập mẫu.
- Đo riêng OCR inference, gọi API/model và thời gian người dùng chờ toàn luồng; ghi warm-up, số lần đo, median/p95 khi đủ mẫu, thiết bị/model/mạng.
- RAM: đo baseline và peak theo cùng kịch bản. Frame: profile mode trên Android thật, ghi thao tác cuộn/chuyển màn và frame timing/jank; không dùng debug để khẳng định 60 FPS.
- Coverage: `flutter test --coverage`, ghi cách tính/phạm vi/exclusion và SHA. Mục tiêu template >=80% phải được đo; không bỏ file khó để làm đẹp kết quả, không viết test chỉ gọi code cho đủ số.
- Nếu kiểm thử Edge Function có toolchain riêng, ghi lệnh/runtime/test riêng; Flutter coverage không đo mã server.
- Đạt khi: số liệu tái lập từ dữ liệu/log thật, có mẫu số/phương pháp và hạn chế. Không có số đo thì ghi chưa đo.

### M3-06 — UAT, APK và báo cáo 3 (Hoàng tổng hợp; cả nhóm bàn giao)

- Vy chạy UAT theo kịch bản: ảnh tốt/xấu, sửa OCR, dán câu, AI không tìm thấy, offline, quota hết, lưu/đọc lại, đổi user. Ghi bước tái hiện, mong đợi/thực tế và mức ảnh hưởng.
- Ánh sửa lỗi Flutter/OCR; Hoàng sửa API/sync, ghép và chạy hồi quy luồng chính. Lỗi của module nào người đó chuẩn bị bằng chứng sửa và test phù hợp.
- APK có mode/cấu hình rõ, không chứa server secret, thử cài đúng artifact trên Android và ghi SHA/build/config. Có thể mở/cài APK chưa chứng minh backend ngoài mạng local truy cập được.
- Báo cáo 3 giữ ba phần template: AI và benchmark; offline/sync và conflict; test/coverage/performance + link APK nội bộ.
- Bàn giao code, migration, hướng dẫn, fixtures/nhãn, log đã lọc, benchmark, lỗi còn lại và link artifact truy cập được. Công bố release/hosted deploy cần đúng phạm vi người dùng đã giao.
- Đạt khi: báo cáo phản ánh artifact đã cài, các số liệu có nguồn; phần chưa đạt và rủi ro được ghi cụ thể.

## 7. Nhịp thực hiện và ngân sách thời gian M3

Các khoảng dưới đây là phân bổ dự kiến thời gian người làm việc với agent; điều chỉnh sau khi biết tồn đọng M2. Không dùng chúng như ước tính chắc chắn thời gian agent hoặc dịch vụ chạy.

| Người | Phân bổ 5 giờ dự kiến |
|---|---|
| Hoàng | 0,5h baseline/contract; 1,5h API/LLM/quota; 1h sync; 1h ghép/review; 1h benchmark/report/APK |
| Ánh | 0,5h contract/môi trường; 2h OCR/UI; 1h test/đo OCR; 1h review/hồi quy; 0,5h bàn giao |
| Vy | 1,5h UX/nghiệp vụ; 1,5h dữ liệu/nhãn; 1,5h UAT; 0,5h rà nội dung/demo |

| Chặng tương đối | Việc và cổng bàn giao |
|---|---|
| Sau nộp M2 | Hoàng công bố baseline/tồn đọng; không yêu cầu người khác tự suy hiện trạng |
| Đầu tuần M3 | M3-00 và buổi 1 Vy; có contract/fixture/flow để code song song |
| Giữa tuần | Ánh OCR/UI, Hoàng API/sync; ghép sớm một câu/ảnh xuyên suốt trước khi mở rộng |
| Trước hạn ít nhất một buổi | Buổi 2 Vy UAT; chạy benchmark/test trên baseline đã ghép; sửa lỗi chặn |
| Buổi chốt | Đóng thêm feature, chạy kiểm tra cuối, build/cài APK, đối chiếu và nộp báo cáo |

Nếu thiếu thời gian: giảm độ trau chuốt không ảnh hưởng luồng chính, hoãn biến thể/mở rộng ngoài phạm vi; ghi yêu cầu bắt buộc còn thiếu thành tồn đọng. Không giảm kiểm tra owner, giữ khóa server, dữ liệu bền hoặc tính trung thực của bằng chứng. Đề nghị thêm quỹ thời gian nếu tồn đọng bắt buộc vượt ngân sách, không cam kết agent sẽ tự xử lý hết.

## 8. Quy trình giao việc cho agent và review

### Prompt chung — ghép với một ID nhiệm vụ mỗi lần

```text
Bạn đang làm Bunly. Thực hiện gói [ID] trong documents/planning/TEAM-M2-M3-Delivery-Plan.md.
Đọc AGENTS.md, PRD M2, GETTING_STARTED, ARCHITECTURE và mã/test liên quan trước khi sửa.
Mục tiêu/đầu ra của gói: [chép mục tương ứng]. Owner: [tên]. Reviewer: [tên].
Baseline: [SHA/branch]. Việc phụ thuộc đã đạt: [ID + bằng chứng].
Phạm vi file dự kiến: [paths]. Các file chung đang có người sửa: [paths/người].
Đầu tiên đối chiếu mã thật với yêu cầu, giữ phần đã đúng; ghi giả định và quyết định cần chốt.
Nếu thiếu adapter/endpoint, dùng interface + fake có nhãn để tiến bộ độc lập; không báo tích hợp thật.
Domain Dart thuần, presentation gọi use case, data triển khai interface, DI tại app/providers.dart.
Giữ Riverpod/Drift/Supabase và SDK đang pin; không tự thêm Freezed/Dartz/go_router hoặc đổi kiến trúc.
Schema mới cần migration bảo toàn dữ liệu + code generation + test nâng cấp.
Không sửa file local của người khác, không đưa secret vào log/commit, không tự deploy hosted.
Thực hiện test cho hành vi/rủi ro thay đổi; chạy lệnh kiểm chứng phù hợp và đọc kết quả.
Bàn giao: file đổi, hành vi, test/lệnh/exit code, bằng chứng, giới hạn, bug và việc tiếp theo.
Không claim hoàn tất nếu chưa đối chiếu từng tiêu chí; chưa chạy thì ghi chưa chạy.
```

### Prompt review chéo

```text
Review gói [ID] tại [SHA/diff] với baseline [SHA]. Đọc tiêu chí trong kế hoạch và mã thực tế.
Tập trung lỗi người dùng gặp, mất/trùng dữ liệu, session/owner, retry/race, migration,
contract API, giả/fake lẫn thật và bằng chứng còn thiếu. Chỉ ra file/vị trí và tình huống tái hiện.
Đối chiếu log được giao; chạy kiểm tra độc lập phù hợp nếu môi trường cho phép.
Kết quả: lỗi chặn, lỗi cần sửa, tiêu chí đạt/chưa đạt/chưa kiểm chứng. Không duyệt chỉ vì agent báo pass.
```

### Tránh xung đột và hỗ trợ nhau

- Mỗi người có branch riêng theo gói, mặc định tiền tố `codex/`; agent không tự tạo worktree khi chưa được yêu cầu.
- Trước khi chia việc kiểm tra workflow có chạy nhánh mới không: hiện push filter chỉ gồm main/feat, còn pull_request có check. Dùng PR để được kiểm tra hoặc sửa filter có chủ đích và review; không nhận có CI nếu chưa có run.
- Hoàng điều phối `lib/app/providers.dart`, local schema/generated file, lockfile và migrations dùng chung. Ai cần đổi báo qua task/contract trước khi sửa; không giữ hai bản schema khác nhau rồi ghép cuối.
- Đổi interface phải cập nhật fixture, fake, adapter, người gọi và test; báo người phụ thuộc trước khi ghép. Không sửa API response âm thầm.
- Agent bàn giao phần độc lập trước khi đổi việc. Khi chuyển Codex/Antigravity, gửi SHA, trạng thái working tree, quyết định, lệnh kiểm tra và bước tiếp; không để agent mới đoán từ lịch sử chat.
- Mỗi PR/gói ghi Problem → Behavior → Verification → Limits; gói đang thiếu kiểm chứng chưa được đánh dấu Verified.

## 9. Lệnh kiểm chứng và bằng chứng

Chạy từ gốc repo bằng SDK pin. Đây là hướng dẫn cho tác vụ triển khai; các lệnh Flutter/DB dưới đây chưa được chạy trong tác vụ soạn kế hoạch.

```powershell
git status --short --branch
git rev-parse HEAD
flutter --version
flutter devices
docker info
npm ci
flutter pub get --enforce-lockfile
```

Khi thay schema/generator:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Kiểm tra code sau thay đổi; sửa format nếu check phát hiện sai rồi chạy lại:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage
```

Nếu đã thêm `integration_test/`, đưa thư mục vào format check và chạy test trên device ID thật. Chỉ dùng lệnh sau khi suite đã tồn tại và cấu hình kiểm thử đã được chuẩn bị:

```powershell
flutter test integration_test -d <device-id> --dart-define-from-file=config/development.local.json
```

Đối với SQL/RLS dùng local stack đầy đủ Auth cho E2E:

```powershell
npm run db:start
npm run db:lint
npm run db:test
```

Khi cần chứng minh tái tạo schema, dùng `npm run db:reset` theo điều kiện bảo toàn dữ liệu local trong hướng dẫn. Không dùng stack bỏ Auth để nghiệm thu đăng nhập.

Build demo chỉ kiểm chứng demo. Connected build/cài và profile phải dùng file local phù hợp với backend đã chỉ định:

```powershell
flutter build apk --debug --dart-define-from-file=config/demo.example.json
flutter build apk --debug --dart-define-from-file=config/development.local.json
flutter run --profile -d <device-id> --dart-define-from-file=config/development.local.json
```

Không sao chép nguyên output Supabase status hoặc log có token vào báo cáo. Lưu bằng chứng đã lọc theo gói: lệnh, thời điểm, SHA, môi trường, mode, số pass/fail/skipped, lỗi và cách tái lập. Không gán toàn bộ log từ working tree chưa commit cho một SHA; chốt commit rồi chạy kiểm tra cuối hoặc ghi rõ diff đi kèm.

## 10. Theo dõi tiến độ và tiêu chuẩn bàn giao

Trạng thái dùng chung: Todo → In progress → Ready for review → Changes requested/Verified → Integrated. Blocked ghi lý do và phần vẫn làm được. Bảng dưới đây là khởi tạo kế hoạch, không xác nhận các phần code cũ chưa tồn tại.

| ID | Owner | Phụ thuộc chính | Trạng thái khởi tạo |
|---|---|---|---|
| M2-00 | Hoàng | Công cụ/checkout | Todo |
| M2-01 | Hoàng | M2-00, Auth local | Todo |
| M2-02 | Hoàng | M2-00; M2-01 để nghiệm thu connected | Todo |
| M2-03 | Hoàng | Contract dữ liệu; M2-01/02 để ghép | Todo |
| M2-04 | Hoàng | M2-01/03 | Todo |
| M2-05 | Hoàng | M2-01 đến 04 | Todo |
| M2-06 | Hoàng | Bằng chứng các gói M2 | Todo |
| M3-00 | Hoàng | Baseline/tồn đọng M2 | Todo |
| M3-01 | Vy | Baseline sản phẩm | Todo |
| M3-02 | Ánh | M3-00; flow đầu tiên M3-01 | Todo |
| M3-03 | Hoàng | M3-00, Auth/kho dữ liệu | Todo |
| M3-04 | Hoàng | Worker M2, contract sync | Todo |
| M3-05 | Hoàng/Ánh/Vy theo phần | Tập nhãn duyệt + build tích hợp | Todo |
| M3-06 | Hoàng, cả nhóm bàn giao | M3-02 đến 05 và tồn đọng chặn | Todo |

Mỗi lần cập nhật một task ghi: người phụ trách, trạng thái, baseline/commit/PR, file sửa, tiêu chí đã đạt, kiểm chứng chưa chạy, lỗi còn lại, người đang chờ và bước tiếp. Phần có nhiều người ở bảng chỉ là gói tổng hợp; trách nhiệm từng đầu ra đã tách trong M3-05/06.

### Snapshot triển khai ngày 29/10/2026

Code M2 đã được bổ sung trong PR #2, commit chức năng 6449a26. CI đã đạt 24 test Flutter, 39 SQL/RLS, 1 connected SDK test và build APK. Bảng Todo phía trên là trạng thái khởi tạo; nghiệm thu cuối vẫn chờ Android connected và video. Xem `../reports/M2-Verification-2026-10-29.md` cho trạng thái cập nhật và bằng chứng thay vì suy từ kế hoạch.

## 11. Bao phủ yêu cầu MVP và việc không được bỏ quên

| Yêu cầu M1 | Phụ trách/đường đi | Cách giữ phạm vi |
|---|---|---|
| Auth/hồ sơ | Hoàng M2-01 | Bù lỗi trước API M3 |
| Kho ngữ pháp | Hoàng M2-02; Vy hỗ trợ nội dung M3-01 | Theo dõi mục tiêu 80–120 mẫu và chất lượng duyệt riêng |
| Lưu/ghi chú/tiến độ | Hoàng M2-03/04 | Dữ liệu thật + offline + owner |
| OCR | Ánh M3-02 | Ảnh thật và model Japanese |
| Phát hiện ngữ pháp | Hoàng M3-03, Ánh ghép UI | Kho hợp lệ + quota + fallback |
| Luyện tập/lịch ôn | Hoàng điều phối; Vy đặc tả; Ánh hỗ trợ UI | Chưa giao vào ngân sách M3 lõi; giữ backlog bắt buộc, chốt lịch riêng sau baseline M2 |
| Lộ trình/thống kê | Thống kê trạng thái M2-03; phần dựa bài làm theo practice | Không bịa accuracy hoặc lịch ôn khi chưa có dữ liệu |
| Nhắc nhở | Vy chốt nghiệp vụ; Ánh dự kiến triển khai | Backlog bắt buộc trước nghiệm thu MVP cuối; không tự đánh dấu đã có |
| Free/Pro | Hoàng M3-03; Vy duyệt UX; Ánh ghép | Hạn mức server + mô phỏng quyền; không thanh toán thật |
| UX/dark mode/accessibility | Vy UAT, Ánh sửa, Hoàng hỗ trợ | Kiểm tra chữ Nhật/cỡ chữ, trạng thái lỗi, bàn phím, vùng chạm và sáng/tối |

Các phần practice/lịch ôn, lộ trình hoàn chỉnh, nhắc nhở và kho nội dung chưa đủ không biến thành tùy chọn. Sau M2 cần chốt deadline/gói riêng; nếu giảng viên yêu cầu chúng ở M3 thì bổ sung quỹ giờ hoặc điều chỉnh lịch cùng nhóm, không tự nhận đủ trong ngân sách hiện tại.
