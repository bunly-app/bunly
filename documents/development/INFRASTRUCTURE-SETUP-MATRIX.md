# Bunly — Hạ tầng hiện tại và bảng thiết lập

Ngày rà soát: **09/11/2026**. Mục tiêu: hoàn thành bản cơ bản đủ chức năng theo M1, giữ kiến trúc M2, sau đó cải thiện theo dữ liệu kiểm thử. Đây là kế hoạch cấu hình, chưa phải biên bản triển khai mới.

Đi cùng [PRD tổng thể](../planning/PRD-BUNLY-Full-Function-Baseline.md) và [phân công](../planning/BASELINE-DELIVERY-OWNERSHIP.md). Công cụ và thao tác môi trường theo [GETTING_STARTED](GETTING_STARTED.md), [vai trò môi trường](../roles/CLI-Environment-Maintainer.md).

**Kết quả thực hiện A00 sau khi lập kế hoạch:** [audit 09/11/2026](../reports/A00-Baseline-Audit-2026-11-09.md) có kết quả mới về format/analyze/24 tests/codegen đạt và APK build lỗi cache Gradle; Docker/device/Cloud hiện chặn các kiểm tra tích hợp. Các mô tả chưa chạy trong tác vụ lập kế hoạch bên dưới là snapshot trước A00, không phải kết quả kiểm tra mới nhất.

## 1. Kết luận từ hiện trạng

**Không cần tạo lại ứng dụng hoặc thay backend.** Đã có nền Flutter + Riverpod + Drift + Supabase. Cần hoàn thiện tích hợp, bổ sung các tính năng chưa có và kiểm chứng toàn bộ luồng.

| Mức bằng chứng | Kết quả / giới hạn |
|---|---|
| Đọc mã tại checkout | HEAD `3ae5be9625edaa3a761253a4e578daa416a97322`; working tree có thay đổi chưa commit. Có auth, grammar, learning, schema Drift v2, worker sync và workflow CI. Đây là quan sát mã, chưa phải kết quả chạy hôm nay. |
| Cloud kiểm tra trực tiếp 09/11 | Supabase `list_projects` và `get_project` đều trả `bunly-dev`, ref `jbyxiihjqveqooenofsr`, Singapore, trạng thái **INACTIVE**. Chưa xác định nguyên nhân; chưa restore hoặc đổi cấu hình. Không coi Cloud sẵn sàng. |
| Lịch sử kiểm chứng 29/10 | [Biên bản M2](../reports/M2-Verification-2026-10-29.md) ghi format/analyze, 24 Flutter tests, 39 SQL tests, connected SDK và Android Samsung A11 đạt. Kết quả thuộc lần chạy/commit ghi trong biên bản; chưa chạy lại trong tác vụ lập kế hoạch này. |
| Cloud theo hồ sơ 29/10 | [SUPABASE-CLOUD](SUPABASE-CLOUD.md) ghi đã áp migration/seed, 6 bảng RLS, 18 policy, 3 mẫu và 3 ví dụ; chưa nghiệm thu signup/email/sync Cloud bằng người dùng thật. Chưa truy vấn lại bảng/policy do project hiện INACTIVE. |
| Chưa có trong mã được rà | Chưa có adapter OCR/camera, Edge Function, provider LLM, feature luyện tập/lịch ôn/nhắc nhở, quota Free/Pro; `pubspec.yaml` chưa có các gói tích hợp này. |
| Release | Gradle release hiện dùng debug signing; CI build APK debug/demo. Chưa có căn cứ coi đây là APK ký phát hành chính thức. |

Không chép giá trị cấu hình local hoặc khóa vào tài liệu. Không suy trạng thái runtime từ việc có file config.

## 2. Bảng hạ tầng và việc phải thiết lập

**Cổng G0:** cần trước khi sửa/tích hợp phần nền; **G1:** trước luồng OCR + AI thật; **G2:** trước hoàn tất chức năng; **G3:** trước bàn giao. Không cần cài mọi dịch vụ trước khi viết một feature độc lập.

| ID / cổng | Thành phần / lựa chọn | Hiện tại | Phải thiết lập / cấu hình | Điều kiện sẵn sàng | Chịu trách nhiệm → review |
|---|---|---|---|---|---|
| INF-01 / G0 | Flutter/Dart, Android, Node, CLI | Flutter pin 3.35.7; Riverpod 2.6.1; Drift 2.28.2; Supabase Flutter 2.10.3; CLI 2.121.0 | Dùng SDK pin và lockfile; JDK 17 cho build theo hướng dẫn Windows; kiểm tra Android SDK, Docker daemon, thiết bị; ghi phiên bản | Clone/cài theo lockfile, demo chạy; checklist môi trường có kết quả thật | Hoàng → Ánh |
| INF-02 / G0 | GitHub và quyền làm team | Repo và 2 workflow có sẵn | Quyền riêng từng người; PR nhỏ, review trước merge; một người tích hợp schema/DI/lockfiles; không chia sẻ GitHub token | Thành viên clone, tạo branch/PR, thấy CI; không sửa identity của nhánh hiện tại | Hoàng → Ánh |
| INF-03 / G0 | Supabase local riêng mỗi người | `supabase/config.toml`, migration, seed, SQL tests đã có | Docker + CLI pin; start đầy đủ Auth/DB/mail local; cấu hình URL đúng emulator/USB/LAN; không init lại | Đọc seed, signup qua mail local, A/B RLS và connected SDK đạt | Hoàng dựng chuẩn, Ánh tái lập |
| INF-04 / G0 | Supabase Cloud dùng chung để tích hợp | `bunly-dev` **INACTIVE**, xác nhận trực tiếp | Hoàng kiểm tra Dashboard/nguyên nhân; chọn thời điểm và hành động restore với target rõ; khi hoạt động kiểm tra migration history, grants/RLS, Auth, seed, API | API/Auth thật phản hồi; bảng và quyền khớp repo; Android connected chạy A/B | Hoàng → Ánh |
| INF-05 / G0 | Phân quyền Dashboard | Hồ sơ cũ ghi chưa gửi lời mời; hôm nay chưa kiểm tra membership | Hoàng Owner quản trị; Ánh Developer nếu cần backend; Vy chỉ cần app/Figma/GitHub theo nhiệm vụ. Mời qua tài khoản riêng, kiểm tra phạm vi quyền của plan hiện dùng | Người cần quản trị thấy đúng project; mỗi người có app test account riêng | Hoàng; từng người xác nhận |
| INF-06 / G0 | Cấu hình client | Có `demo.example.json`, `connected.example.json`; `*.local.json` bị ignore | Mỗi người tự tạo file local: `APP_MODE`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` (tên hiện có, nhận client key phù hợp). Ghi rõ local hay Cloud và tài khoản test | Connected không fallback demo; namespace/cache tách theo backend và user | Hoàng → Ánh |
| INF-07 / G0 | PostgreSQL, RLS, migrations | 6 bảng M2; 1 migration nguồn | Giữ migration đã áp; thêm migration mới cho feature mới; kiểm tra quyền Data API và RLS; seed ID ổn định; review thứ tự migration | Dựng DB local từ Git, lint/SQL A-B tests đạt; schema remote được đối chiếu sau khi active | Hoàng → Ánh |
| INF-08 / G0–G2 | Drift + đồng bộ | 4 bảng local, schema v2, outbox tuần tự, push/pull một thiết bị | Mở rộng practice/review; transaction dữ liệu + outbox; migration có test; chốt conflict/version/tombstone cho nhiều thiết bị | Offline ghi → restart → reconnect không mất/trùng; hai máy sửa có kết quả giải thích được | Hoàng → Ánh |
| INF-09 / G1 | Email Auth + SMTP | Local có mail inbox; Cloud theo hồ sơ dùng SMTP mặc định | Chốt sender, SMTP provider và domain nếu thử ngoài team; tài khoản/email xác minh của người sở hữu; cài SMTP credentials phía Supabase; thử xác nhận và reset password | Email thử đến được người dùng dự kiến; lỗi hết hạn/rate limit rõ | Hoàng cấu hình; Vy UAT |
| INF-10 / G1 | Callback/deep link Auth | Chưa có theo hồ sơ; local redirect list rỗng | Chốt URI callback dev/release, allowlist Supabase, Android/iOS handler; test mở email lúc app đóng/mở. Ưu tiên đường dẫn quay về app | Xác nhận/reset quay đúng màn, callback không làm lộ token | Hoàng → Ánh; Vy UAT |
| INF-11 / G1 | OCR Nhật trên thiết bị: ML Kit | Chưa tích hợp | Chọn Flutter adapter tương thích SDK pin; Japanese recognizer/model; ưu tiên bundled để thử offline ngay; kiểm tra min SDK, quyền camera/thư viện, vòng đời recognizer | Ảnh thật → chữ sửa được; airplane mode OCR vẫn chạy; giải phóng tài nguyên | Hoàng + agent → Ánh |
| INF-12 / G1 | Supabase Edge Function + LLM API | Chưa có source Function trong repo | Function `analyze-grammar`; xác thực user; server chọn ứng viên kho; kiểm tra JSON/ID; timeout; adapter provider; secrets server; môi trường local rồi Cloud đích đã được chỉ định | Test function và một request model thật; client không chứa private key; offline thông báo đúng | Hoàng + agent → Ánh |
| INF-13 / G1 | Provider LLM + chi phí | Chưa chọn model/tài khoản/ngân sách | So sánh provider/model trên cùng tập câu Nhật–Việt; Hoàng chốt tài khoản, ngân sách và model ID; ghi model/prompt version; thiết lập giới hạn request/output, quota và theo dõi chi phí | Báo cáo đánh giá, một kết nối thật, giới hạn server hoạt động; không dùng mock để nghiệm thu | Hoàng quyết định; Ánh kỹ thuật; Vy nội dung |
| INF-14 / G1 | Hạn mức / Free-Pro | Chưa có | Ledger request + entitlement phía server; hạn mức theo user/ngày; chống gọi đồng thời/retry trùng; app chỉ đọc quyền của mình | Hai request cạnh tranh không vượt quota; retry cùng ID không trừ thêm; user không tự nâng Pro | Hoàng → Ánh |
| INF-15 / G1–G2 | Kho ngữ pháp và bài tập | Asset hiện có 3 mẫu | Chọn nguồn có quyền sử dụng; biên tập 80–120 N5/N4; bộ câu hỏi có đáp án/giải thích; quy trình draft → duyệt → seed; cùng ID local/remote | Vy duyệt nội dung, kiểm tra số lượng/quan hệ/đáp án; import local trước khi phát hành nội dung Cloud | Vy duyệt; agent soạn; Hoàng tích hợp |
| INF-16 / G2 | Thông báo local | Chưa có | Chọn plugin tương thích pin, quyền OS và timezone; giờ học, bật/tắt, hủy/đặt lại lịch; hành vi đổi user | Nhắc đúng giờ trên máy thật; từ chối quyền vẫn học được; không nhắc cho user đã logout | Hoàng + agent → Ánh; Vy UAT |
| INF-17 / G0–G3 | Figma và theme | User cung cấp file Figma; app có light/dark nền | Vy chốt luồng/màn/state; Hoàng/agent đọc đúng node trước khi triển khai; 4 tab Hôm nay/Tra cứu/Sổ học/Tiến độ; kiểm tra responsive, chữ Nhật và bàn phím | Mỗi CTA có đường đi và trạng thái thật; UI review trên Android, không nghiệm thu bằng ảnh thiết kế | Vy → Hoàng, Ánh |
| INF-18 / G3 | CI, kiểm thử tích hợp, evidence | Có format/analyze/tests/codegen/debug build, local SQL/SDK; workflow Android riêng | Thêm tests OCR/parser/Function/quota/practice/conflict; chạy workflow trên SHA giao; lưu báo cáo đo và UAT đã lọc secrets | Kiểm tra bắt buộc đạt trên bản giao; điều chưa chạy ghi rõ | Hoàng → Ánh; Vy UAT |
| INF-19 / G3 | Android signed release + phân phối | Release config đang ký debug | Chốt application ID/version, keystore riêng, lưu khóa ngoài Git và backup riêng; signing config/CI secrets; HTTPS backend; build và cài APK release | Artifact SHA/checksum, chứng chỉ release đúng, chạy đủ luồng trên thiết bị thật | Hoàng → Ánh |
| INF-20 / G3 | iOS | Có scaffold, chưa có bằng chứng build hiện tại | Xác nhận Mac/Xcode/iPhone và khả năng ký; cấu hình OCR/quyền/callback; build/test nếu có; hỏi GV phạm vi khi thiếu phần cứng | Chỉ ghi đạt iOS khi có log build và chạy; chưa có thiết bị giữ trạng thái chưa xác minh | Hoàng điều phối; Ánh triển khai nếu đủ môi trường |
| INF-21 / G3 | Log và xử lý lỗi | Có tests; chưa thấy SDK crash reporting | Trước hết dùng log có mã request, lỗi đã lọc email/token/câu riêng tư; ghi cách lấy log trên máy. Sentry/Crashlytics là nâng cao sau baseline | Tái lập lỗi bằng request ID mà không ghi nội dung nhạy cảm | Hoàng → Ánh |

## 3. Supabase làm team như thế nào?

**Mỗi người có Supabase local riêng; nhóm dùng một `bunly-dev` làm nơi tích hợp.** Không cần tạo một project Cloud cho mỗi thành viên. Hướng này là đề xuất phù hợp nhóm ba người và [quy trình môi trường của Supabase](https://supabase.com/docs/guides/deployment/managing-environments).

| Môi trường | Ai dùng / dữ liệu | Thay đổi được phép theo kế hoạch |
|---|---|---|
| Demo | Agent/UI test; asset và SQLite riêng | Không gọi backend; chỉ chứng minh luồng demo |
| Local connected | Hoàng/Ánh trên máy riêng, tài khoản giả và mail local | Thử migrations, RLS, Function và lỗi mạng; reset chỉ local khi đã giữ dữ liệu cần thiết |
| Cloud dev | Nhóm UAT/tích hợp, tài khoản test theo người | Hoàng là đầu mối áp bản đã review; schema/seed có phiên bản trong Git; mọi thao tác hosted phải có target và phạm vi được giao rõ |
| Bản bàn giao | APK release trỏ backend ổn định đã chốt | Có thể dùng dev cho demo học phần và ghi đúng là dev; staging/production riêng là bước sau, không giả vờ đã có môi trường production |

**Dashboard account khác app account.** Được mời vào organization không tự tạo tài khoản Auth trong Bunly. Người thử app không cần được cấp quyền quản trị DB. [Access control](https://supabase.com/docs/guides/platform/access-control) phải được kiểm tra theo plan đang dùng trước khi mời; không chia sẻ tài khoản Owner.

Quy trình schema: task/contract → migration mới → local lint/RLS/connected tests → Ánh review → Hoàng tích hợp → kiểm tra target và migration dự kiến → áp lên Cloud khi đã được giao target/phạm vi → kiểm tra lại bằng client/user thật. Không sửa SQL trực tiếp trên Cloud rồi bỏ quên migration. Không dùng reset Cloud.

SMTP mặc định không phù hợp thử rộng ngoài team; Supabase nêu hạn chế người nhận khi chưa cấu hình SMTP riêng. Chọn dịch vụ SMTP sau khi kiểm tra domain, quyền gửi và chi phí; tài liệu này chưa chọn hay đăng ký nhà cung cấp. [Nguồn SMTP](https://supabase.com/docs/guides/auth/auth-smtp).

## 4. AI, API và các dịch vụ bên thứ ba

| Quyết định đề xuất cho bản đầu | Lý do và phần thiết lập |
|---|---|
| ML Kit Japanese OCR trên thiết bị | Đáp ứng phần on-device AI; OCR không cần private cloud key. Phải chọn cách cung cấp model và thử offline trên máy; bundled/unbundled có hành vi tải khác nhau. [Nguồn ML Kit](https://developers.google.com/ml-kit/vision/text-recognition/v2/android). |
| LLM API gọi qua Edge Function | Giữ private key ở server; đổi model qua adapter; tập trung quota/validation. [Function secrets](https://supabase.com/docs/guides/functions/secrets), [Function auth](https://supabase.com/docs/guides/functions/auth). |
| Prompt + lấy ứng viên từ kho trước | Với 80–120 mẫu, bắt đầu truy vấn/rules đơn giản hoặc gửi tập ứng viên có giới hạn phù hợp context/cost; đo độ phủ ứng viên. LLM chọn ID có thật, giải thích gốc lấy từ kho. Chưa cần vector database/embedding riêng. |
| Chưa fine-tune trong baseline | Chưa có tập gán nhãn và số đo lỗi để biện minh chi phí huấn luyện. Sau baseline phân loại lỗi OCR/retrieval/prompt/model; chỉ cân nhắc fine-tune khi lỗi lặp lại còn tồn tại và có dữ liệu được phép dùng, tập train/validation/test tách biệt. Fine-tune không thay thế RLS, kho kiến thức hay on-device OCR. |
| Provider/model chốt sau thử nghiệm nhỏ | API thương mại hoặc nhà cung cấp tương đương đều phải qua cùng contract/eval. Không tự cam kết model, giá hoặc ngân sách; API key/ngân sách thực là điều kiện trước nghiệm thu AI online. |

Các lựa chọn này là định hướng kỹ thuật cho Bunly, không phải tất cả đều là yêu cầu nguyên văn của môn học.

| Dịch vụ / hạ tầng thêm | Mức cần thiết |
|---|---|
| Supabase, GitHub Actions, Figma | Tiếp tục dùng nền hiện có; kiểm tra quyền và giới hạn hiện hành |
| Một LLM provider | Cần để hoàn thành phân tích online đã cam kết M1 |
| SMTP riêng + sender/domain được xác minh | Cần khi onboarding người thử ngoài phạm vi SMTP mặc định; chưa cần khi chỉ kiểm thử local |
| ML Kit, plugin ảnh/camera, local notifications | Thư viện trên app; kiểm tra phiên bản tương thích và khai báo quyền, không tự đồng nghĩa cần một server riêng |
| Supabase Storage | Chưa cần trong baseline: OCR xử lý ảnh local, chỉ gửi câu đã xác nhận. Nếu sau này lưu ảnh/avatar/audio mới thiết kế bucket, quyền owner, vòng đời và xóa dữ liệu |
| Firebase/FCM, VPS, Redis, vector DB, Kubernetes | Chưa có nhu cầu bắt buộc cho luồng baseline; nhắc giờ học dùng local notification; backend dùng Supabase. Chỉ thêm sau khi có vấn đề cụ thể và phép đo |
| Sentry/Crashlytics, store accounts, analytics | Sau baseline theo nhu cầu; signed APK và video thật vẫn phải có trước bàn giao học phần |
| ASR/ghi âm cho voice | Có trong tài liệu mở rộng UI; nằm ở đợt E1 sau baseline M1. Cần chọn on-device/cloud, tiếng Nhật, consent, lưu/xóa audio và đo thực; không mặc định STT offline hoặc chấm phát âm |

## 5. Cấu hình cần chuẩn bị và nơi giữ

Các tên biến LLM/quota dưới đây là **đề xuất contract**, chưa được ứng dụng đọc ở hiện tại.

| Nơi | Thông tin | Ai quản lý |
|---|---|---|
| `.flutter-version`, lockfiles, example config trong Git | Phiên bản, tên biến và giá trị mẫu không bí mật | Hoàng tích hợp, Ánh review |
| `config/*.local.json` ngoài Git | Mode, backend URL, client key; test credentials chỉ ở file test riêng | Từng người tự tạo; không chia sẻ file admin DPAPI |
| Local Function env ngoài Git / hosted Function secrets | `LLM_PROVIDER`, `LLM_MODEL`, private `LLM_API_KEY`, timeout và giới hạn request | Hoàng, theo provider chốt; server secrets không đóng gói vào Flutter |
| DB server | Entitlement/quota dùng thực, request ledger, migration history | Hoàng triển khai, Ánh review quyền/transaction |
| Supabase Auth settings | SMTP host/port/user/password, sender, redirect allowlist | Hoàng/Owner; Vy kiểm tra luồng email |
| Kho khóa riêng / CI secret store | Android keystore/password, token deploy nếu sau này dùng CI deploy | Hoàng giữ và backup; không in log hoặc commit |

## 6. Những việc chưa được thực hiện trong tác vụ này

Chưa restore Cloud, mời thành viên, cấu hình SMTP, mua dịch vụ, tạo API key, deploy Function/migration, hoặc sửa code. Chưa chạy lại Flutter/SQL/Android tests. Đã đọc cấu hình/mã và kiểm tra metadata Cloud trực tiếp. Cấu hình mới chỉ được đánh dấu Ready khi có kết quả kiểm tra ở bảng trên.

Đã đối chiếu tài liệu Supabase ngày 09/11/2026: [changelog](https://supabase.com/changelog), [Data API exposure](https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically). Khi thêm bảng phải kiểm tra grants/API lẫn RLS; tiếp tục dùng CLI **2.121.0** pin trong repo, không sao chép lệnh CLI mới mà chưa xem `--help`. Thay đổi SDK/CLI cần tác vụ tương thích riêng.
