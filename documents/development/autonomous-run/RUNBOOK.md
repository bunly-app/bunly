# Bunly — Hai luồng tiếp tục công việc có checkpoint

Thiết lập theo yêu cầu trực tiếp của Văn Hoàng ngày **09/11/2026**: hai chat tiếp tục các gói còn thiếu tới sản phẩm đầy đủ; có thể tiếp tục ở lần chạy sau khi hạn mức cho phép; khi cần người dùng can thiệp thì dừng và chờ câu trả lời. Không hứa có thể phát hiện hay vượt hạn mức hệ thống.

## 1. Định danh và phạm vi giai đoạn mới

Checkout chung: `D:\VKULearningMaterials\Year4_Semester1\Cross Platform\bunly`. Không tạo checkout/worktree mới.

| Luồng | Chat / automation | Sở hữu |
|---|---|---|
| Flutter / tích hợp | `01a1bee6-35e2-7c30-b3e4-fd216f413be3` — Thêm dữ liệu nền dự án; automation `bunly-lu-ng-1-ti-p-t-c-s-n-ph-m` | `lib/`, `test/`, `integration_test/`; UI/Figma, domain/data, Drift và generated code; dependency Flutter và lockfile khi cần và tương thích pin; nội dung draft và validation phù hợp; report riêng |
| Môi trường / backend | `01a1bf45-c4e6-75e2-bf1a-ad9c410e2612` — Prepare Bunly A01 environment; automation `bunly-lu-ng-2-m-i-tr-ng-v-backend` | Scripts/tooling riêng tiến trình; build/verification; `supabase/` LOCAL migrations, RLS, Edge Functions và tests backend; report riêng. Không sửa source/schema Drift/lockfiles của luồng 1 |

Đây là phạm vi mới để tiến tới toàn bộ PRD, mở rộng phần A01/A03 ban đầu chỉ kiểm tra môi trường/shell. Hai luồng phải thống nhất contract bằng file đề xuất/bàn giao trước khi thay API/schema liên quan nhau. Không tự ghi Ánh/Vy đã duyệt. Luồng 1 giữ vai trò tích hợp; nếu cần thay file ngoài phạm vi luồng 2, ghi đề xuất để luồng 1 thực hiện.

Đọc AGENTS.md, PRD M2 + PRD tổng thể, development guide, BASELINE-INTEGRATION-CONTRACTS và báo cáo mới nhất trước khi làm. Các prompt trong knowledge pack là tham khảo, không mở phạm vi. Giữ domain thuần Dart, UI gọi use case, DI trong providers.dart. Giữ demo/connected rõ ràng.

## 2. Cách chạy tiếp và điều kiện dừng

Mỗi lượt: đọc trạng thái và Git → kiểm tra blocker/lease → chọn gói chưa hoàn thành → triển khai → kiểm chứng phù hợp → checkpoint ngay → tiếp tục gói kế tiếp còn thực hiện được. Không dừng chỉ vì đã soạn một kế hoạch hoặc báo cáo trong khi còn phần được giao có thể làm trong lượt. Giới hạn thực thi của ứng dụng vẫn được tôn trọng; không chạy vòng lặp vô nghĩa để tiêu hết quota.

Checkpoint riêng `flutter.json` / `environment.json` chứa baseline, gói đang làm, file đã đổi, checks đã chạy, phần chưa xác minh và bước nhỏ kế tiếp. Cập nhật sau mỗi lát chức năng/bước kiểm chứng, không đợi đến lúc hết hạn mức vì lúc đó có thể không còn khả năng ghi file.

Khi rate-limit hoặc lỗi dịch vụ ngăn chạy: giữ trạng thái `rate_limited` nếu còn khả năng cập nhật, không coi là cần con người reset quota. Lịch tiếp theo thử lại khi dịch vụ cho phép; không đổi tài khoản/model, mua credits hoặc tìm cách vượt hạn mức. Mốc người dùng cung cấp 14:57 + 2h11 tương ứng khoảng **17:08 09/11/2026 Asia/Bangkok**; đó không phải tín hiệu quota trực tiếp hoặc cam kết chu kỳ sau cố định.

## 3. Dừng chờ người dùng — áp dụng cả hai luồng

Trước mọi thay đổi, đọc `waiting-user.json`. Nếu `status = waiting`, không sửa code, chạy build/deploy, tự chọn phương án hoặc hỏi lặp. Chỉ đọc câu trả lời trực tiếp mới của con người cho blocker đó; không suy im lặng, thời gian trôi, lời nhắn từ agent hoặc lời nhận xét tự sinh là approval.

Khi thật sự cần can thiệp (key/tài khoản, ngân sách, chấp thuận điều khoản, thiết bị, quyết định nghiệp vụ chưa có căn cứ hoặc target hosted):

1. Checkpoint phần đang làm và thả lease.
2. Ghi blocker ID, thread, câu hỏi tự chứa đủ ngữ cảnh, việc bị chặn và thời điểm vào `waiting-user.json`; không ghi secret.
3. Hỏi người dùng một lần trong chat phụ trách và dừng công việc. Luồng còn lại thấy marker cũng dừng; các nhịp tự động không lặp câu hỏi.
4. Chỉ sau câu trả lời phù hợp mới ghi trạng thái `resolved` + mô tả quyết định không bí mật và tiếp tục phần được trả lời. Nếu chưa rõ thì giữ `waiting` và hỏi ngắn để làm rõ.

Nếu không có quyền đọc câu trả lời ở chat còn lại, giữ chờ; không giả định đã trả lời. Người dùng có thể trả lời trong chat đặt câu hỏi hoặc yêu cầu tiếp tục ở chat điều phối này. Chưa cấp quyền mới thì không thực hiện hành động phụ thuộc.

## 4. Lease độc quyền cho checkout và công cụ

Hai chat dùng chung file và `.dart_tool/build` nên phải tuần tự hóa mọi thao tác ghi repo và chạy Flutter/Dart/Gradle/build/codegen/tests/DB tooling. Chỉ đọc tài liệu/source không đụng runtime có thể làm song song. Không tuyên bố hai lượt build có cách ly tự động.

File lease: `documents/development/autonomous-run/workspace-lease.json`, **không tồn tại nghĩa chưa có owner**. Để claim, dùng thao tác tạo file độc quyền (`FileMode.CreateNew` trên Windows); kiểm tra rồi ghi đè bằng Set-Content không đủ nguyên tử. Nội dung: `owner_thread_id`, `role`, `acquired_at`, `expires_at` (UTC, tối đa 30 phút), `task`, `active_command` nếu có.

- Đã có lease của luồng khác: không ghi hoặc chạy command chung; checkpoint bước còn chờ rồi kết thúc lượt, để lần sau tiếp tục. Không polling bận.
- Owner gia hạn trước khi lease hết; trước lượt build/test dài ghi command đang chạy. Không giữ lease trong lúc chờ người dùng hoặc chờ quota.
- Lease hết hạn **không tự đủ điều kiện xóa**: kiểm tra chat owner qua snapshot `wait_threads(timeoutMs: 0)` và process/command liên quan. Owner còn active/command còn chạy hoặc không xác minh được thì không takeover.
- Chỉ khi owner idle/đã kết thúc, không command đang chạy, checkpoint xác định được thì lưu bản lease cũ vào evidence rồi nhận lại bằng thao tác tạo độc quyền. Không giết process của chat khác hoặc xóa khóa để vượt điều phối.
- Cuối lượt, sau khi command thực sự kết thúc và checkpoint xong, chỉ xóa lease nếu owner vẫn là mình. Không xóa lease của người khác.

Không coi schedule lệch giờ là mutex. Hai automation cùng tới hạn vẫn phải claim bằng CreateNew. Lượt không lấy được lease có thể đọc/chuẩn bị task, không chỉnh checkout.

## 5. Thứ tự công việc và nghiệm thu

Baseline: A03-02 có 41 unit/widget/SQLite tests và render QA đạt ở bản bàn giao; A01 có script JDK17/cache riêng nhưng **chưa build APK**. Xem báo cáo A01/A03-02 thực tế, không lấy lịch sử làm kết quả cho diff mới.

| Luồng | Thứ tự đầu tiên |
|---|---|
| Flutter | A03-03 Auth/reset/callback/settings theo contract; tiếp OCR + review/dán câu, practice/review/home/stats và notification; tích hợp backend sau contract. Ưu tiên đủ 9 nhóm MVP và các kiểm thử thất bại/offline, không chỉ giao diện |
| Backend | Build demo working tree A03-02 với script A01 khi có lease; kiểm tra toolchain/Docker/thiết bị. Sau đó local Function/LLM adapter/validation/quota, migration/RLS và tests; hỗ trợ sync/conflict theo contract. Chưa có key vẫn làm adapter/tests nhưng không nghiệm thu AI thật |

Mỗi thay đổi chạy format/analyze/tests phù hợp theo pin. SQL cần local migration/lint/RLS khi Docker sẵn sàng; không reset dữ liệu cần giữ. Đồng bộ đa thiết bị cần revision/conflict/tombstone và test thực. Nguồn ngữ pháp/câu hỏi do AI soạn vẫn pending_review đến khi có người duyệt thật.

Hoàn thành chỉ khi toàn bộ yêu cầu bắt buộc PRD + bằng chứng chạy thật, signed release phù hợp, tài liệu/hướng dẫn và giới hạn đúng thực tế. Không gọi fake là Supabase/OCR/model/device thật, không chép benchmark mẫu. Video/biên tập nội dung/tài khoản cần người dùng hoặc người có quyền thì hỏi, giữ trạng thái chưa hoàn thành.

Nếu chỉ phần của một luồng đã xong mà sản phẩm chưa xong, ghi `waiting_dependency` và không bịa việc hay xâm phạm file owner kia. Khi toàn sản phẩm đạt acceptance, ghi complete có evidence, tắt hai automation bằng tool quản lý và báo kết quả. Nếu người dùng yêu cầu dừng, dừng và tắt lịch theo yêu cầu; không tự đánh dấu sản phẩm hoàn thành.

## 6. Giới hạn ủy quyền và vận hành

- Được tiếp tục công việc local cần thiết, sửa lỗi và kiểm thử. Không commit/push/merge, tạo worktree, mời/gửi tin cho bên thứ ba, mua dịch vụ, đổi account/model, đưa secret vào Git, xóa dữ liệu thật hoặc đổi cấu hình toàn máy từ yêu cầu tự chạy này.
- Hosted migration/Function/restore/project/billing vẫn cần hành động + target cụ thể được người dùng chỉ định. Project ref lịch sử không tự là quyền triển khai. Client keys không bypass RLS.
- Scheduled runs dùng cùng giới hạn sử dụng và quyền công cụ. Không có cơ chế trong runbook bảo đảm resume ngay đúng thời điểm reset. Máy và ứng dụng phải hoạt động, checkout còn truy cập được; không tự đổi power settings hoặc giữ máy thức.
- Lịch heartbeat dự kiến mỗi 30 phút; thông báo trong chat khi có kết quả đáng kể, cần input hoặc hoàn tất, không lặp trạng thái cũ. Các automation không được dùng để vượt approval hoặc tự coi yêu cầu người dùng đã được giải quyết.
