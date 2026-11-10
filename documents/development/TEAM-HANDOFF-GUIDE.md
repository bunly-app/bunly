# Hướng dẫn tiếp nhận & hoàn thiện code Bunly (dành cho thành viên nhóm)

*Cập nhật theo trạng thái nhánh `dev` ngày **10/11/2026**.*

Tài liệu này giúp **Vy** và **Ánh** nắm nhanh **app và hạ tầng Cloud hiện đã chạy tới đâu**, **cách clone/chạy code hoặc cài APK test trên máy**, và **những đầu việc còn lại cần hoàn thiện** (dữ liệu, chức năng, dọn giao diện còn thô, đồng bộ xung đột, phát hành & báo cáo).

> **Lưu ý phân biệt 2 chế độ chạy:**
> - **Demo (ngoại tuyến):** Dùng dữ liệu đóng gói sẵn trong app + SQLite trên máy, **không gọi Supabase**, không cần đăng nhập thật.
> - **Connected (kết nối backend):** Kết nối Supabase (local Docker hoặc Cloud `bunly-dev`) để đăng nhập qua email thật, gọi AI phân tích câu và đồng bộ dữ liệu đa thiết bị.
> Không dùng kết quả chạy Demo hoặc test giả lập để kết luận tính năng Cloud/Sync đã nghiệm thu.

---

## 1. Ứng dụng & Hạ tầng hiện tại đang có gì?

### Các màn hình & luồng chính trong app
1. **Khởi động & Tài khoản (`features/auth/`):**
   - Màn khôi phục phiên an toàn khi mở app (giữ phiên đã đăng nhập khi mất mạng tạm thời).
   - Màn Đăng nhập / Tạo tài khoản / Xác nhận email / Quên mật khẩu / Đổi mật khẩu (hỗ trợ deep-link `bunly://auth-callback` trong `AndroidManifest.xml`; bản Demo có mục xem trước luồng Auth trong Hồ sơ).
2. **Thanh điều hướng 4 tab ([`lib/app/app_shell.dart`](../../lib/app/app_shell.dart)):**
   - **Hôm nay (`today_screen.dart`):** Lộ trình mục tiêu, danh sách mẫu đến hạn ôn (SRS), lối vào nhanh Quét ảnh/nhập câu và Luyện tập.
   - **Tra cứu (`grammar_screen.dart` & `grammar_detail_screen.dart`):** Tìm theo mẫu/ý nghĩa, lọc theo cấp độ N5/N4, 21 nhóm chủ đề và mẫu đã lưu; xem công thức, cách dùng, ví dụ, tự đánh giá trạng thái (`Chưa học`, `Đang học`, `Cần ôn`, `Đã nắm`) và viết/sửa/xóa ghi chú cá nhân.
   - **Sổ học (`notebook_screen.dart`):** Tập hợp các mẫu đã lưu và ghi chú riêng của từng tài khoản (lọc theo N5/N4/Có ghi chú).
   - **Tiến độ (`progress_screen.dart`):** Đếm số mẫu theo trạng thái, thống kê tỉ lệ làm đúng trắc nghiệm/điền khuyết theo dữ liệu thật, Sổ lỗi cần ôn và Lịch sử bài làm.
   - **Hồ sơ & Cài đặt (`profile_screen.dart`):** Đổi tên hiển thị, trình độ N5/N4, mục tiêu, phút học/ngày, giao diện Sáng / Tối / Theo hệ thống, xem trạng thái tự đồng bộ + nút `Đồng bộ ngay`, Đổi mật khẩu và Đăng xuất.
3. **Quét câu tiếng Nhật & Phân tích AI (`features/ocr/`, `features/analysis/`):**
   - Chụp/chọn ảnh (`image_picker`) và đọc chữ Nhật ngay trên máy bằng **Google ML Kit** (`mlkit_ocr_repository.dart`) — chạy ngoại tuyến hoàn toàn.
   - Cho sửa lại bản nháp trước khi xác nhận (kèm nút chèn nhanh dấu câu/trợ từ và chọn câu ví dụ mẫu); ở chế độ Demo chỉ đối chiếu ví dụ cục bộ trong kho, còn chế độ Connected hiển thị **hạn mức AI trong ngày**, gọi Edge Function `analyze-grammar` và tô highlight chính xác đoạn ngữ pháp khớp trong câu.
4. **Luyện tập & Lịch ôn SRS (`features/practice/`):**
   - Làm bài **Trắc nghiệm ngữ cảnh (MCQ)** và **Điền khuyết (Cloze)** (chọn nguồn theo SRS đến hạn, Điểm yếu từ Sổ lỗi, Theo từng mẫu hoặc Theo cấp độ N5/N4), chấm ngay trên máy, lưu từng lượt làm (`practice_attempts`) và cập nhật lịch ôn ngắt quãng (`review_states`).
   - Có Sổ lỗi cần ôn & Lịch sử bài làm (`practice_history_screen.dart`), cùng 2 màn `Dịch Việt → Nhật` / `Nói một câu` dạng thao tác thử cục bộ (`writing_practice_screen.dart`, chưa nối AI/micro).

### Cấu trúc code, Backend Cloud & CI hiện tại
- **Flutter App (`lib/`):** Tổ chức theo từng feature (`lib/features/<ten>/{domain,data,presentation}`). Toàn bộ dependency được nối tập trung tại [`lib/app/providers.dart`](../../lib/app/providers.dart).
- **Database cục bộ (SQLite via Drift):** Định nghĩa tại [`lib/core/database/app_database.dart`](../../lib/core/database/app_database.dart) (schema v3, 7 bảng: `cached_grammar`, `cached_questions`, `local_notes`, `sync_outbox`, `personal_records`, `local_practice_attempts`, `local_review_states`).
- **Backend Supabase (`supabase/`):**
  - `supabase/migrations/`: Đã có **5 file migration**, gồm bảng kho ngữ pháp, dữ liệu cá nhân kèm RLS tách từng user, bảng đề/bài làm/SRS, bảng đếm hạn mức AI (`quota`), hàm chống xung đột (`bunly_sync_personal_record`), và [`20261110111000_default_free_analysis_entitlement.sql`](../../supabase/migrations/20261110111000_default_free_analysis_entitlement.sql) tự động cấp **`5` lượt AI/ngày UTC** cho mọi tài khoản đăng ký mới.
  - `supabase/functions/analyze-grammar/`: Edge Function gọi **Gemini Free Tier** (`gemini-3.5-flash-lite` trong [`gemini-free.mjs`](../../supabase/functions/_shared/gemini-free.mjs)), nhận diện tối đa toàn bộ 90 UUID ngữ pháp N5/N4 (`BUNLY_APPROVED_GRAMMAR_IDS`), trừ hạn mức nguyên tử và hỗ trợ replay theo `request_id`.
- **Trạng thái Supabase Cloud (`bunly-dev`, ref `jbyxiihjqveqooenofsr`):**
  - **Đang hoạt động (Live):** Đã đẩy đủ 5 migrations và nạp đủ 90 mẫu / 168 ví dụ / 180 câu hỏi lên Cloud; đã deploy `analyze-grammar` với `gemini-3.5-flash-lite`; đã cấu hình **Custom SMTP (Gmail App Password)** và redirect `bunly://auth-callback`.
  - Đã kiểm chứng API end-to-end trên Cloud: đăng ký user test mới tự nhận `5` lượt/ngày (tài khoản test của Hoàng đặt `20` lượt/ngày), gọi `analyze-grammar` thật nhận diện đúng mẫu và không trừ trùng khi lặp `request_id`.
- **Build, CI & Phát hành APK (`.github/workflows/`):**
  - Workflow `checks.yml` và [`release-apk.yml`](../../.github/workflows/release-apk.yml) (đã hỗ trợ build cả `*-demo-offline.apk` và `*-connected-cloud.apk` khi repo có 2 secret `BUNLY_SUPABASE_URL`, `BUNLY_SUPABASE_ANON_KEY`).
  - Các tag đã tạo: `v0.1.0-demo.1`, `v0.1.0-demo.2`, `v0.1.0-cloud.1`. Lưu ý: `v0.1.0-cloud.1` trên GitHub Releases mới gắn được `demo-offline.apk` do CI chưa đọc thấy 2 secret Cloud ở lần chạy đầu (đang chờ rà lại mục *Actions -> Repository secrets* và chạy lại).
  - Bản `bunly-connected-cloud-release.apk` (`89.3 MB`, ký debug local) build từ máy dev đã cài và khởi động qua Wi-Fi/4G trên máy Android test (Samsung Galaxy A11). Chưa có keystore Release chính thức để ký phát hành rộng rãi.

### Dữ liệu & Kiểm thử hiện tại
- Kho dữ liệu gồm **90 điểm ngữ pháp** (45 N5 + 45 N4, phủ 21 nhóm chủ đề) và **180 câu luyện tập** (90 MCQ + 90 Cloze) tại [`assets/data/grammar.json`](../../assets/data/grammar.json), [`assets/data/practice_questions.json`](../../assets/data/practice_questions.json) và [`supabase/seed.sql`](../../supabase/seed.sql).
- **Trạng thái quan trọng:** Bộ 90 mẫu và 180 câu hiện vẫn là **bản nháp do AI sinh (`AI-authored draft`)** — **chưa được kiểm duyệt chuyên môn tiếng Nhật** để chốt nội dung chính thức.
- **Kiểm tra tự động đã chạy đạt trên nền `dev` hiện tại (`10/11/2026`):** `validate_b0_fixtures.py` PASS, `dart format` & `flutter analyze` `0` lỗi, `flutter test --no-pub` `87/87` PASS, SQL `db lint` `0` lỗi, pgTAP `104/104` PASS, Edge unit tests `29/29` PASS, local Edge integration `1/1` PASS, `test_connected/m2_connected_test.dart` `3/3` PASS.
- **Chưa kiểm chứng đầy đủ:** UAT đa thiết bị thật (đồng bộ conflict 2 máy), bấm link deep-link thật trên điện thoại để nhảy vào `ResetPasswordScreen` khi app tắt hẳn, OCR camera thực tế ngoài đời, thông báo nhắc học (chưa cài) và toàn bộ nền tảng iOS.

---

## 2. Cách clone code và chạy trên máy thành viên

### Cần cài gì trên máy?
- **Nếu làm UI, dọn giao diện, duyệt/sửa dữ liệu JSON, sửa logic offline:** chỉ cần **Git** + **Flutter `3.35.7`** (đúng `.flutter-version`) + **Android SDK** + điện thoại Android hoặc máy ảo. *Không cần cài Docker.*
- **Nếu test APK Cloud có sẵn (UAT):** không cần cài môi trường dev, chỉ cần tải APK `*-connected-cloud.apk` (khi có bản phát hành mới từ GitHub Releases hoặc Hoàng gửi), cài lên Android, tự đăng ký tài khoản bằng email thật là có ngay 5 lượt AI/ngày.
- **Nếu làm Backend, Sync, Migration hoặc Edge Function:** cài thêm **Node.js (>= 22)** và **Docker Desktop** để chạy Supabase local trên máy mình.

> **Mẹo quan trọng cho máy Windows khi build Android:**
> Nếu máy có Android Studio đời mới (Java 21/25), Flutter có thể chọn nhầm JDK gây lỗi Gradle `25.0.2`. Khi build Android bị lỗi này, hãy tạm trỏ `flutter config --jdk-dir "<đường_dẫn_jdk_17>"` khi chạy và trả lại `flutter config --jdk-dir ""` sau đó (xem thêm ở [GETTING_STARTED.md](GETTING_STARTED.md)), không nâng bừa version Gradle/Flutter của repo.

### Các bước lấy code & tạo nhánh riêng
```sh
git clone https://github.com/bunly-app/bunly.git
cd bunly
git checkout dev
git pull origin dev
git checkout -b feat/ten-nhiem-vu-cua-ban
```
- Làm việc trên nhánh mới tách từ `dev`, xong mở Pull Request vào `dev` (không push thẳng lên `main`).
- **Tuyệt đối không commit** các file chứa thông tin riêng tư: `config/*.local.json`, `.env*` (trừ `.example`), file keystore hay API key cá nhân.

### Chạy ngay chế độ Demo (nhanh nhất)
```sh
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```

### Chạy chế độ Connected (Local Docker hoặc Cloud dùng chung)
- **Cách 1 — Trỏ tới Supabase Cloud dùng chung (`bunly-dev`) không cần Docker:**
  1. Copy mẫu config: `cp config/connected.example.json config/development.local.json`
  2. Điền `SUPABASE_URL` (HTTPS của `bunly-dev`) và `SUPABASE_ANON_KEY` (khóa client publishable/anon do Hoàng cung cấp riêng cho nhóm) vào `config/development.local.json`.
  3. Chạy `flutter run --dart-define-from-file=config/development.local.json` *(không bao giờ chạy lệnh `db reset` lên Cloud)*.
- **Cách 2 — Chạy Supabase Local trên Docker riêng (khuyên dùng khi sửa SQL/Sync/Edge Function):**
  1. Bật Docker Desktop và chạy:
     ```sh
     npm ci
     npm run db:start
     npm run supabase -- status
     ```
  2. Điền `SUPABASE_ANON_KEY` và `SUPABASE_URL` vào `config/development.local.json`:
     - **Android Emulator:** `http://10.0.2.2:54321`
     - **Android cắm USB:** chạy `adb reverse tcp:54321 tcp:54321`, dùng `http://127.0.0.1:54321`
     - **iOS Simulator (macOS):** `http://127.0.0.1:54321`
  3. *(Nếu test AI `analyze-grammar` local)* Copy [`config/functions.env.example`](../../config/functions.env.example) thành `.env.functions.local`, điền `GEMINI_API_KEY` Free Tier và chạy CLI cục bộ.
  4. **Lưu ý CLI trên Windows:** Khi gọi lệnh Supabase CLI có nhiều cờ như `--env-file`, `--project-ref`, `--workdir`, hãy gọi trực tiếp binary `.\node_modules\.bin\supabase.cmd ...` (hoặc `./node_modules/.bin/supabase ...` trên macOS/Linux) thay vì `npm run supabase -- ...` để tránh `npm` nuốt tên cờ.
  5. Khi cần làm sạch DB local trên máy mình: `npm run db:reset` *(chỉ dùng cho local, cấm chạy lên Cloud)*.

### Checklist tự kiểm tra trước khi đẩy code lên GitHub
```sh
python scripts/validate_b0_fixtures.py
# Chỉ chạy build_runner nếu có sửa bảng trong app_database.dart:
# dart run build_runner build --delete-conflicting-outputs

dart format --output=none --set-exit-if-changed lib test integration_test test_connected
flutter analyze --no-pub
flutter test --no-pub
```
Nếu có sửa SQL hoặc Edge Function trong `supabase/`: bật Docker rồi chạy thêm `npm run db:lint`, `npm run db:test` và `node --test supabase/functions/tests/*.test.mjs`.

---

## 3. Danh sách nhiệm vụ cần làm để hoàn thiện ứng dụng

Phân công tổng thể theo [`BASELINE-DELIVERY-OWNERSHIP.md`](../planning/BASELINE-DELIVERY-OWNERSHIP.md): **Hoàng** (hạ tầng, Cloud, AI/quota, CI/release), **Ánh** (review kỹ thuật, sync conflict, kiến trúc/hiệu năng), **Vy** (UI/UAT, trải nghiệm, duyệt nội dung Nhật–Việt).

### A. Hoàn thiện & Duyệt Dữ liệu (Vy chủ trì nội dung, Hoàng hỗ trợ import)
- [ ] **Duyệt & chuẩn hóa 90 mẫu ngữ pháp N5/N4** trong [`assets/data/grammar.json`](../../assets/data/grammar.json): rà soát công thức, `meaning_vi`, cách dùng và ví dụ Nhật–Việt (tránh câu lặp từ, sai sắc thái hoặc lệch cấp độ N5/N4) để bỏ trạng thái `AI-authored draft`.
- [ ] **Duyệt & chuẩn hóa 180 câu luyện tập** trong [`assets/data/practice_questions.json`](../../assets/data/practice_questions.json):
  - Với câu trắc nghiệm (`mcq`): kiểm tra 4 phương án nhiễu hợp lý, chỉ có 1 đáp án đúng.
  - Với câu điền khuyết (`cloze`): bổ sung các cách viết hợp lệ tương đương vào `accepted_answers` (hiragana/kanji phổ biến, thể ngắn/lịch sự nếu phù hợp) để tránh chấm sai oan.
  - Chạy lại [`scripts/generate_curriculum_data.py`](../../scripts/generate_curriculum_data.py) (hoặc đồng bộ tay) để [`supabase/seed.sql`](../../supabase/seed.sql) khớp 100% ID với JSON, rồi cập nhật lên `bunly-dev` (nếu có thêm UUID mẫu mới ngoài 90 UUID hiện tại thì cập nhật thêm `BUNLY_APPROVED_GRAMMAR_IDS`).

### B. Hoàn thiện Chức năng còn thiếu & Chốt UAT trên máy thật
- [ ] **Thêm tính năng Nhắc học hằng ngày (Local Notification):**
  - Hiện [`pubspec.yaml`](../../pubspec.yaml) chưa có gói thông báo. Cần thêm plugin local notification tương thích Flutter `3.35.7`, bổ sung Bật/Tắt + Chọn giờ học trong `ProfileScreen`, xin quyền OS hợp lý (từ chối quyền vẫn học bình thường), bấm thông báo mở đúng tab **Hôm nay**, và tự hủy lịch khi **Đăng xuất**.
- [ ] **Chốt dứt điểm 2 màn `Dịch Việt → Nhật` & `Nói một câu` (`writing_practice_screen.dart`):**
  - Hiện chỉ là màn thao tác thử cục bộ (`[Chưa kết nối AI]` / `[Chưa thu âm]`), chưa lưu lịch sử vào DB. Nhóm cần quyết định: nối góp ý AI / ghi nhận lịch sử thật (và gắn speech-to-text thật cho phần Nói) **hoặc tạm ẩn khỏi màn chọn bài luyện** trước khi bàn giao để không còn tính năng giả.
- [ ] **UAT trọn vẹn Deep-link Auth & OCR trên Android thật:**
  - Test bấm link xác nhận đăng ký và link **Quên mật khẩu** trong Gmail trên điện thoại (cả lúc app đang mở lẫn tắt hẳn) để chắc chắn `bunly://auth-callback` mở đúng `ResetPasswordScreen`.
  - Test từ chối quyền Camera/Thư viện ảnh, quét chữ Nhật ngoài đời khi bật chế độ Máy bay (OCR ML Kit) rồi bật Wi-Fi/4G gọi Gemini (`analyze-grammar`), xác nhận bộ đếm quota `5` lượt/ngày trừ đúng và không trừ trùng.

### C. Dọn "UI Slop" (Giao diện còn chữ nháp / hiển thị thử)
- [ ] **Xóa bỏ các khối UI mô phỏng / chữ chưa hoàn thiện:**
  - Ở `ProgressScreen` (`lib/features/learning/presentation/progress_screen.dart`): xử lý 2 dòng đang ghi `"Chưa nối"` (*Viết câu & Dịch thuật*, *Voice phản xạ ngữ cảnh*) — nối dữ liệu thật hoặc ẩn đi nếu chưa triển khai.
  - Ở `PracticeHistoryScreen` (`lib/features/practice/presentation/practice_history_screen.dart`): bỏ biến/nút xem mẫu giả `showSample` / card `"Minh họa UI"`, chỉ giữ empty state gọn.
  - Ở `WritingPracticeScreen` (`lib/features/practice/presentation/writing_practice_screen.dart`): bỏ `_VoiceWaveformPreview` nếu chưa có thu âm thật; tinh gọn banner chú thích; sửa AppBar để tiêu đề `"Dịch Việt → Nhật"` không bị cắt dấu `...` trên màn hình hẹp.
- [ ] **Rà Responsive & Figma (`39hHCJ2CmxZNbe5NAUd6sA`):** Kiểm tra toàn bộ app ở 2 chế độ Sáng/Tối, cỡ chữ to (`1.3x–1.5x`) và khi bật bàn phím tiếng Nhật (Gboard) để không bị che nút Lưu / Nộp bài.

### D. Nâng cấp cơ chế Đồng bộ đa thiết bị (Ánh chủ trì review/triển khai)
- [ ] **Nối logic phát hiện xung đột (Conflict) từ DB lên Flutter:**
  - *Hiện trạng:* DB Supabase đã có sẵn hàm `bunly_sync_personal_record` + `record_revisions`, và Drift v3 đã có cột `serverRevision`, `operationId`, `conflictPayload`, nhưng [`learning_sync.dart`](../../lib/features/learning/data/learning_sync.dart) hiện vẫn chỉ gọi `upsert` thẳng (nếu 2 máy cùng sửa 1 ghi chú lúc mất mạng, máy đồng bộ sau sẽ ghi đè máy trước).
  - *Việc cần làm:* Sửa `SupabaseLearningRemote` gọi RPC `bunly_sync_personal_record`; khi server trả `'status': 'conflict'`, lưu bản server vào `conflictPayload` và hiện hộp thoại cho người dùng chọn **Giữ bản trên máy** hoặc **Dùng bản trên máy chủ**.
- [ ] **UAT đồng bộ mất mạng & 2 thiết bị:** Tắt mạng sửa ghi chú + làm quiz -> thoát hẳn app -> mở lại + bật mạng kiểm tra hàng đợi `sync_outbox` chạy sạch -> đăng nhập cùng tài khoản trên máy thứ 2 để xác nhận dữ liệu khớp.

### E. Hoàn tất Hạ tầng CI & Phát hành APK chính thức (Hoàng chính, Ánh review)
- [x] Khôi phục Cloud `bunly-dev`, đẩy 5 migrations + seed 90 mẫu/180 câu, cấu hình Gmail Custom SMTP + deep-link redirect, deploy `analyze-grammar` dùng `gemini-3.5-flash-lite`, tự động cấp 5 lượt AI/ngày khi đăng ký *(đã kiểm chứng ngày 10/11/2026)*.
- [ ] **Hoàn tất gắn `*-connected-cloud.apk` lên GitHub Releases:** Rà lại 2 secret `BUNLY_SUPABASE_URL` và `BUNLY_SUPABASE_ANON_KEY` trong mục **Actions -> Repository secrets** trên GitHub rồi chạy lại release `v0.1.0-cloud.*` để cả nhóm tải trực tiếp file APK kết nối Cloud từ tab Releases.
- [ ] **Tạo Keystore Release Android cố định:** Thay chữ ký `debug` ở [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts) bằng keystore release riêng (lưu khóa ngoài Git + GitHub Secrets) để mọi bản cập nhật APK từ CI đều cài đè được mà không xung đột chữ ký.
- [ ] **Kiểm chứng tổng thể trước bàn giao:** Chạy `integration_test/m2_demo_test.dart`, bộ UAT connected trên Android thật (và ghi rõ phạm vi iOS nếu nhóm chưa có Mac/iPhone).

---

## 4. Bàn giao chốt kiểm chứng & Hoàn thiện bộ báo cáo

Sau khi các đầu việc **A → E** ở trên hoàn tất và UAT ổn định trên thiết bị thật, nhóm chốt lại bộ bằng chứng và hoàn thiện báo cáo trong [`documents/reports/`](../reports/):
1. **Bằng chứng thực tế (Vy & Hoàng thu thập, Ánh đối chiếu):** Video demo 2–3 phút trên điện thoại thật (Đăng ký/Email thật → Quét ảnh OCR → Phân tích AI thật → Lưu mẫu/ghi chú → Luyện tập & SRS → Đồng bộ 2 thiết bị), ảnh chụp màn hình và SHA-256 của file APK phát hành cuối cùng.
2. **Hoàn thiện bộ báo cáo (Ánh chủ trì kỹ thuật, Vy đối chiếu nội dung & UAT):**
   - Cập nhật [`Capstone-Report-2-Architecture.md`](../reports/Capstone-Report-2-Architecture.md) & [`M2-Verification-2026-10-29.md`](../reports/M2-Verification-2026-10-29.md) (ghi đúng kết quả đã chạy thật và giữ nguyên mục chưa xác minh như iOS nếu thiếu phần cứng).
   - Viết hoàn chỉnh [`Capstone-Report-3-AI-Testing.md`](../reports/Capstone-Report-3-AI-Testing.md) (kết quả test `gemini-3.5-flash-lite` + ML Kit OCR trên tập câu kiểm thử thực tế, độ chính xác, giới hạn Free Tier).
   - Hoàn tất [`Capstone-Report-4-Final-Defense.md`](../reports/Capstone-Report-4-Final-Defense.md) & slide bảo vệ cuối kỳ.
