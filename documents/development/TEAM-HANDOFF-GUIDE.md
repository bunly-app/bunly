# Hướng dẫn tiếp nhận & hoàn thiện code Bunly (dành cho thành viên nhóm)

Tài liệu này giúp thành viên trong nhóm **nắm nhanh app đang có gì**, **tự clone và chạy được code trên máy**, và biết rõ **cần làm tiếp những việc gì** (về dữ liệu, chức năng, dọn giao diện còn thô, đồng bộ, hạ tầng) để đưa app lên trạng thái hoàn chỉnh trước khi **Ánh hoàn thiện bộ báo cáo còn lại**.

> **Lưu ý nhanh về phân biệt 2 chế độ chạy:**
> - **Demo (ngoại tuyến):** Dùng dữ liệu đóng gói sẵn trong app + SQLite trên máy, **không gọi Supabase**, không cần đăng nhập thật.
> - **Connected (kết nối backend):** Kết nối Supabase (local Docker hoặc Cloud) để đăng nhập thật, gọi AI phân tích câu và đồng bộ dữ liệu giữa các thiết bị.
> Không dùng kết quả chạy Demo để kết luận tính năng Cloud/Sync đã hoạt động.

---

## 1. Ứng dụng hiện tại đã có gì?

### Các màn hình & luồng chính trong app
1. **Khởi động & Tài khoản (`features/auth/`):**
   - Màn khôi phục phiên an toàn khi mở app (tự giữ phiên đã đăng nhập nếu rớt mạng tạm thời).
   - Màn Đăng nhập / Tạo tài khoản / Quên mật khẩu / Đổi mật khẩu (ở chế độ Demo có phần xem trước giao diện Auth trong Hồ sơ).
2. **Thanh điều hướng 4 tab (`lib/app/app_shell.dart`):**
   - **Hôm nay (`today_screen.dart`):** Hiển thị lộ trình mục tiêu, danh sách mẫu đến hạn ôn (SRS), lối vào nhanh Quét/nhập câu và Luyện tập.
   - **Tra cứu (`grammar_screen.dart` & `grammar_detail_screen.dart`):** Tìm theo mẫu/ý nghĩa, lọc theo cấp độ N5/N4, 21 nhóm chủ đề và mẫu đã lưu; xem công thức, cách dùng, ví dụ, tự đánh giá trạng thái và viết ghi chú cá nhân.
   - **Sổ học (`notebook_screen.dart`):** Tập hợp các mẫu đã lưu và ghi chú của riêng từng tài khoản.
   - **Tiến độ (`progress_screen.dart`):** Đếm số mẫu theo trạng thái, thống kê tỉ lệ làm đúng trắc nghiệm/điền khuyết theo dữ liệu thật.
   - **Hồ sơ & Cài đặt (`profile_screen.dart`):** Đổi tên hiển thị, trình độ N5/N4, phút học/ngày, giao diện Sáng / Tối / Theo hệ thống, xem trạng thái tự đồng bộ + nút `Đồng bộ ngay` dự phòng và đăng xuất.
3. **Quét câu tiếng Nhật & Phân tích (`features/ocr/`, `features/analysis/`):**
   - Chụp/chọn ảnh qua thư viện (`image_picker`) và đọc chữ Nhật ngay trên thiết bị bằng **Google ML Kit** (`mlkit_ocr_repository.dart`) — hoạt động ngoại tuyến.
   - Cho sửa lại câu nhận dạng trước khi phân tích; ở bản Demo chỉ đối chiếu cục bộ với ví dụ trong kho, còn chế độ Connected gọi Edge Function `analyze-grammar`.
4. **Luyện tập & Lịch ôn SRS (`features/practice/`):**
   - Hỗ trợ làm **Trắc nghiệm (MCQ)** và **Điền khuyết (Cloze)**, chấm ngay trên máy, lưu từng lượt làm (`practice_attempts`) và tự lên lịch ôn ngắt quãng (`review_states`).
   - Có Sổ lỗi & Lịch sử bài làm (`practice_history_screen.dart`), cùng màn hình viết/dịch/nói dạng xem thử (`writing_practice_screen.dart`).

### Cấu trúc code & hạ tầng hiện tại (nhìn tổng quan)
- **Flutter App (`lib/`):** Tổ chức theo từng tính năng (`lib/features/<ten>/{domain,data,presentation}`). Toàn bộ dependency (repository, database, sync) được nối tập trung tại [`lib/app/providers.dart`](../../lib/app/providers.dart).
- **Database cục bộ trên máy (SQLite via Drift):** Định nghĩa tại [`lib/core/database/app_database.dart`](../../lib/core/database/app_database.dart) (schema v3, 7 bảng: `cached_grammar`, `cached_questions`, `local_notes`, `sync_outbox`, `personal_records`, `local_practice_attempts`, `local_review_states`).
- **Backend Supabase (`supabase/`):**
  - `supabase/migrations/`: 4 file SQL đã có đủ bảng kho ngữ pháp, dữ liệu cá nhân (kèm RLS tách theo từng user), bảng đề/bài làm/SRS, bảng đếm hạn mức AI (`quota`) và hàm hỗ trợ version chống xung đột (`bunly_sync_personal_record`).
  - `supabase/functions/analyze-grammar/`: Edge Function gọi **Gemini Free Tier** để nhận diện mẫu ngữ pháp trong câu, kiểm tra hạn mức lượt dùng từ phía server (API key giữ trên server, không đóng gói vào app Flutter).
- **Build & CI (`.github/workflows/`):**
  - Đã có workflow kiểm tra tự động (`checks.yml`) và workflow build + phát hành **GitHub Pre-release APK bản Demo** tự động khi gắn tag `v*` (`release-apk.yml`).
- **Trạng thái môi trường Cloud hiện tại:**
  - Môi trường local (Docker + Supabase CLI) chạy đầy đủ DB, Auth, mail thử local và test tự động.
  - Project Supabase Cloud chung (`bunly-dev`, ref `jbyxiihjqveqooenofsr`) hiện vẫn đang **INACTIVE**, chưa khôi phục để chạy UAT thật, chưa cấu hình SMTP gửi email ra ngoài và chưa phát hành keystore ký APK bản chính thức.

### Dữ liệu hiện tại đang như thế nào?
- Đã có **90 điểm ngữ pháp** (45 mẫu N5 + 45 mẫu N4, phủ 21 nhóm chủ đề) và **180 câu luyện tập** (90 trắc nghiệm + 90 điền khuyết) lưu ở:
  - [`assets/data/grammar.json`](../../assets/data/grammar.json) (app đọc ở chế độ Demo / cache offline)
  - [`assets/data/practice_questions.json`](../../assets/data/practice_questions.json) (tự nạp vào SQLite khi mở bản Demo)
  - [`supabase/seed.sql`](../../supabase/seed.sql) (nạp vào PostgreSQL khi dựng Supabase)
- **Trạng thái quan trọng:** Toàn bộ 90 mẫu và 180 câu này hiện là **bản nháp do AI sinh (`AI-authored draft`)** để app có dữ liệu thật chạy mượt từ đầu đến cuối — **chưa được kiểm duyệt chuyên môn tiếng Nhật** để chốt thành nội dung chính thức.

---

## 2. Cách clone code và tiếp tục làm bên máy thành viên

### Cần cài gì trên máy?
- **Nếu làm UI, dọn giao diện, sửa dữ liệu JSON, sửa logic app offline:** chỉ cần **Git** + **Flutter `3.35.7`** (đúng phiên bản ghi trong `.flutter-version`) + **Android SDK** (qua Android Studio) + điện thoại Android hoặc máy ảo. *Không cần cài Docker.*
- **Nếu làm Backend, Sync, Auth hoặc AI Edge Function:** cài thêm **Node.js (>= 22)** và **Docker Desktop** để chạy Supabase ngay trên máy mình.

> **Mẹo quan trọng cho máy Windows khi build Android:**
> Nếu máy có cài Android Studio đời mới (kèm Java 21/25), Flutter có thể chọn nhầm JDK quá mới gây lỗi Gradle `25.0.2`. Khi build/chạy Android bị lỗi này, hãy dùng **JDK 17** cho riêng phiên dòng lệnh hoặc tạm trỏ `flutter config --jdk-dir "<đường_dẫn_jdk_17>"` khi chạy (xem thêm mục Windows ở [GETTING_STARTED.md](GETTING_STARTED.md)), không nâng cấp bừa version Gradle/Flutter của repo.

### Các bước lấy code & tạo nhánh riêng
```sh
git clone https://github.com/bunly-app/bunly.git
cd bunly
git checkout dev
git pull origin dev
git checkout -b feat/ten-nhiem-vu-cua-ban
```
- **Quy tắc Git ngắn gọn:**
  - Làm việc trên nhánh mới tách từ `dev`, xong mở Pull Request vào `dev` (không push thẳng lên `main`).
  - **Tuyệt đối không commit** các file cấu hình riêng tư: `config/*.local.json`, `.env*` (ngoại trừ file mẫu `.example`), keystore hay API key cá nhân.

### Chạy ngay chế độ Demo (nhanh nhất, chỉ mất 2 lệnh)
```sh
flutter pub get
flutter run --dart-define-from-file=config/demo.example.json
```
*(Nếu có nhiều thiết bị, xem mã thiết bị bằng `flutter devices` rồi thêm `-d <device-id>`.)*

### Chạy chế độ Connected local (khi cần code Đồng bộ / Đăng nhập / Backend AI)
1. Bật Docker Desktop, sau đó chạy trong thư mục dự án:
   ```sh
   npm ci
   npm run db:start
   npm run supabase -- status
   ```
   *(Lần đầu kéo image Docker sẽ hơi lâu; giữ lại `API URL` và `anon key` trong kết quả `status`.)*
2. Tạo file cấu hình local của riêng máy bạn (file `.local.json` đã được `.gitignore` bỏ qua tự động):
   ```sh
   cp config/connected.example.json config/development.local.json
   ```
   Mở `config/development.local.json` và điền:
   - `APP_MODE`: giữ nguyên `"connected"`
   - `SUPABASE_ANON_KEY`: dán `anon key` từ lệnh `status` ở trên
   - `SUPABASE_URL`: điền đúng theo thiết bị đang test:
     - **Máy ảo Android (Emulator):** `http://10.0.2.2:54321`
     - **Điện thoại Android cắm dây USB:** chạy `adb reverse tcp:54321 tcp:54321`, rồi điền `http://127.0.0.1:54321`
     - **iOS Simulator (macOS):** `http://127.0.0.1:54321`
3. *(Nếu test AI `analyze-grammar` local)* Copy [`config/functions.env.example`](../../config/functions.env.example) thành `.env.functions.local`, điền `GEMINI_API_KEY` (tài khoản Free Tier không bật billing), đặt `GEMINI_FREE_TIER_CONFIRMED=true` và phục vụ function theo CLI local.
4. Chạy app connected:
   ```sh
   flutter run --dart-define-from-file=config/development.local.json
   ```
5. Nếu bạn tự sửa database local bị rối và muốn làm sạch lại từ đầu theo `migrations` + `seed.sql`:
   ```sh
   npm run db:reset
   ```
   *(Chỉ chạy lệnh reset này trên máy local, **không bao giờ chạy lên Supabase Cloud chung**.)*

### Checklist tự kiểm tra trước khi đẩy code lên GitHub
```sh
# Chỉ chạy lệnh build_runner bên dưới nếu bạn có sửa bảng trong app_database.dart:
# dart run build_runner build --delete-conflicting-outputs

dart format --output=none --set-exit-if-changed lib test integration_test test_connected
flutter analyze --no-pub
flutter test --no-pub
```
Nếu có sửa SQL trong `supabase/`, bật Docker rồi chạy thêm: `npm run db:lint` và `npm run db:test`.

---

## 3. Danh sách nhiệm vụ cần làm để hoàn thiện sơ bộ ứng dụng

Mục này liệt kê **các phần việc cần code / sửa / dựng thật**, chia rõ theo từng mảng để các thành viên nhận làm trực tiếp (không phải chỉ đọc review).

### A. Hoàn thiện Dữ liệu (Nội dung thật, sạch lỗi)
- [ ] **Chuẩn hóa 90 mẫu ngữ pháp N5/N4** trong [`assets/data/grammar.json`](../../assets/data/grammar.json): rà soát lại công thức (`formula`), nghĩa tiếng Việt (`meaning_vi`), phần giải thích cách dùng và cặp ví dụ Nhật–Việt (tránh câu ví dụ lặp từ, sai sắc thái hoặc nhầm cấp độ N5/N4).
- [ ] **Chuẩn hóa 180 câu luyện tập** trong [`assets/data/practice_questions.json`](../../assets/data/practice_questions.json):
  - Với câu trắc nghiệm (`mcq`): kiểm tra 4 phương án nhiễu phải hợp lý, không có 2 đáp án đều đúng.
  - Với câu điền khuyết (`cloze`): bổ sung thêm các cách viết đúng tương đương vào mảng `accepted_answers` (ví dụ cả hiragana lẫn kanji phổ biến, thể ngắn/thể lịch sự nếu đề không khóa) để người dùng gõ tay không bị chấm sai oan.
  - Chạy lại [`scripts/generate_curriculum_data.py`](../../scripts/generate_curriculum_data.py) (hoặc đồng bộ tay) sao cho [`supabase/seed.sql`](../../supabase/seed.sql) khớp 100% ID và nội dung với file JSON trong `assets/data/`.
- [ ] **Chốt danh sách ID được AI phân tích (`BUNLY_APPROVED_GRAMMAR_IDS`):** Khi các mẫu đã sửa chuẩn, cập nhật danh sách UUID hợp lệ để Edge Function `analyze-grammar` nhận diện được hết kho ngữ pháp mới (thay vì danh sách rỗng mặc định).

### B. Hoàn thiện Chức năng còn thiếu hoặc mới chạy nửa vời
- [ ] **Thêm tính năng Nhắc học hằng ngày (Local Notification):**
  - Hiện app **chưa có** gói thông báo (`pubspec.yaml` chưa cài plugin nhắc lịch).
  - Việc cần làm: thêm plugin thông báo local tương thích Flutter 3.35.7, bổ sung công tắc Bật/Tắt + Chọn giờ học trong `ProfileScreen`, xin quyền thông báo OS hợp lý (từ chối quyền vẫn dùng app bình thường), bấm vào thông báo mở đúng tab **Hôm nay**, và tự hủy lịch nhắc khi người dùng **Đăng xuất**.
- [ ] **Hoàn thiện hoặc chốt lại chế độ Dịch Việt → Nhật & Nói một câu (`writing_practice_screen.dart`):**
  - Hiện màn hình này mới cho nhập chữ đối chiếu câu mẫu tĩnh và chưa lưu lịch sử vào DB.
  - Việc cần làm: nối phần Dịch Việt → Nhật sang endpoint góp ý AI (hoặc lưu lượt luyện tự đánh giá vào DB thật để `ProgressScreen` hiển thị số thật), còn phần **Nói một câu** nếu chưa tích hợp micro/thu âm (ASR) thì hoặc tích hợp gói speech-to-text tiếng Nhật + xin quyền micro thật, hoặc tạm ẩn khỏi bản phát hành để không gây hiểu nhầm tính năng giả.
- [ ] **Hoàn thiện luồng Quên mật khẩu & Deep-link quay về app:**
  - `AndroidManifest.xml` đã khai báo schema `bunly://auth-callback`, nhưng cần test thực tế việc bấm link từ email xác nhận đăng ký / đặt lại mật khẩu để app tự mở đúng màn `ResetPasswordScreen` (nếu thiếu handler nhận link lúc app đang tắt hẳn thì bổ sung cấu hình deep-link callback).
- [ ] **Test trọn vòng OCR + AI trên máy Android thật:**
  - Cài bản Connected lên điện thoại thật: thử từ chối quyền Camera/Thư viện ảnh (xem thông báo lỗi có rõ ràng không), thử chụp ảnh chữ Nhật ngoài đời (tắt mạng test OCR local, bật mạng test gọi Gemini thật), kiểm tra bộ đếm giới hạn lượt dùng AI (`quota`).

### C. Dọn "UI Slop" (Phần giao diện còn lộ bản nháp / chữ mô phỏng)
- [ ] **Xóa bỏ các nhãn & khối UI mô phỏng ("hàng trưng bày chưa chạy"):**
  - Ở `ProgressScreen` (`lib/features/learning/presentation/progress_screen.dart`): xử lý 2 dòng đang ghi `"Chưa nối"` (*Viết câu & Dịch thuật*, *Voice phản xạ ngữ cảnh*) — nối dữ liệu thật hoặc ẩn đi nếu chưa triển khai.
  - Ở `PracticeHistoryScreen` (`lib/features/practice/presentation/practice_history_screen.dart`): bỏ nút xem mẫu giả `showSample` / card `"Minh họa UI"`, chỉ hiển thị empty state gọn khi người dùng chưa làm bài nào.
  - Ở `WritingPracticeScreen` (`lib/features/practice/presentation/writing_practice_screen.dart`): bỏ khung sóng âm mô phỏng (`_VoiceWaveformPreview`) nếu chưa nối micro thật; tinh gọn banner chú thích để người dùng không bị rối.
- [ ] **Sửa lỗi cắt chữ & tối ưu màn hình nhỏ theo Figma (`39hHCJ2CmxZNbe5NAUd6sA`):**
  - Chỉnh lại AppBar ở `WritingPracticeScreen` để tiêu đề `"Dịch Việt → Nhật"` không bị dấu `...` trên màn hình hẹp khi đặt cạnh badge bên phải.
  - Kiểm tra lại toàn bộ app ở 2 chế độ **Sáng / Tối**, cỡ chữ hệ thống to (`1.3x–1.5x`) và khi mở **bàn phím tiếng Nhật (Gboard)** trên máy thật để chắc chắn không bị che nút Lưu / nút Nộp bài.

### D. Nâng cấp cơ chế Đồng bộ (Chống ghi đè khi dùng 2 thiết bị)
- [ ] **Nối logic phát hiện xung đột (Conflict) từ DB lên giao diện Flutter:**
  - *Hiện trạng:* Database Supabase đã tạo sẵn hàm `bunly_sync_personal_record` + bảng `record_revisions`, và Drift v3 cũng đã tạo sẵn cột `serverRevision`, `operationId`, `conflictPayload`, nhưng code trong [`learning_sync.dart`](../../lib/features/learning/data/learning_sync.dart) hiện vẫn chỉ gọi `upsert` thẳng nên nếu dùng 2 máy cùng sửa 1 ghi chú lúc mất mạng rồi bật lại, máy đồng bộ sau sẽ âm thầm ghi đè máy trước.
  - *Việc cần làm:* Sửa `SupabaseLearningRemote` gọi RPC `bunly_sync_personal_record` thay vì `upsert` thô; khi server trả về `'status': 'conflict'`, lưu bản server vào `conflictPayload` và hiện hộp thoại đơn giản cho người dùng chọn **Giữ bản trên máy** hoặc **Dùng bản trên máy chủ**.
- [ ] **Kiểm tra lại độ ổn định đồng bộ thực tế:** Test case mất mạng hoàn toàn trên máy thật -> sửa ghi chú + làm 1 bài quiz -> thoát hẳn app -> mở lại app -> bật mạng xem thanh trạng thái tự đồng bộ ở đầu màn hình có chạy sạch hàng đợi `sync_outbox` không.

### E. Nâng cấp Hạ tầng & Chuẩn bị phát hành bản thật
- [ ] **Mở lại & chuẩn hóa Supabase Cloud (`bunly-dev`):**
  - Vào Dashboard khôi phục project `bunly-dev` (hiện đang `INACTIVE`).
  - Đối chiếu lại schema trên Cloud, đẩy đủ 4 file migrations + `seed.sql` mới nhất, thiết lập Redirect URL `bunly://auth-callback`, deploy Edge Function `analyze-grammar` kèm secret `GEMINI_API_KEY`.
- [ ] **Cấu hình SMTP gửi email thật:** Kết nối nhà cung cấp SMTP (ví dụ Resend/Brevo miễn phí hoặc SMTP riêng của nhóm) vào Supabase Auth để email xác nhận tài khoản và reset mật khẩu gửi được tới email bất kỳ của giảng viên/người dùng test (không bị giới hạn email mặc định của Supabase).
- [ ] **Thiết lập Keystore ký APK Release & Build bản Connected:**
  - Tạo 1 file keystore Android release riêng (cất ở nơi an toàn, **không push vào Git**), đưa thông tin ký lên GitHub Actions Secrets, cập nhật [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts) và [`.github/workflows/release-apk.yml`](../../.github/workflows/release-apk.yml) để xuất được APK bản **Connected (HTTPS trỏ tới `bunly-dev`)** phát hành cho người dùng cuối cài thẳng.
- [ ] **Chốt kiểm chứng trên máy thật (iOS nếu có Mac/iPhone):** Chạy lại đủ bộ kiểm tra E2E (`integration_test/m2_demo_test.dart`, `integration_test/m2_connected_test.dart`) trên thiết bị Android thật sau khi hoàn thiện các mục trên.

---

## 4. Bàn giao cho Ánh hoàn thiện báo cáo sau khi code xong

Sau khi các đầu việc **A → E** ở trên đã chạy ổn định trên app thật và backend Cloud thật, **Ánh** sẽ chốt phần rà soát cuối và hoàn thiện các báo cáo còn lại:
1. **Lấy bằng chứng thực tế:** Quay video demo 2–3 phút trên điện thoại thật (từ Đăng ký/Email thật → Quét ảnh OCR → Phân tích AI thật → Lưu mẫu/ghi chú → Làm bài tập & SRS → Đồng bộ giữa 2 thiết bị), kèm ảnh chụp màn hình và SHA-256 của file APK phát hành cuối cùng.
2. **Hoàn thiện bộ báo cáo trong [`documents/reports/`](../reports/):**
   - Cập nhật [`Capstone-Report-2-Architecture.md`](../reports/Capstone-Report-2-Architecture.md) & [`M2-Verification-2026-10-29.md`](../reports/M2-Verification-2026-10-29.md) (ghi rõ kết quả đã chạy thật so với những phần chưa làm như iOS nếu nhóm không có máy Mac/iPhone).
   - Viết hoàn chỉnh [`Capstone-Report-3-AI-Testing.md`](../reports/Capstone-Report-3-AI-Testing.md) (kết quả đánh giá AI/OCR thực tế, độ chính xác phát hiện mẫu trên tập câu test, chi phí/quota Free Tier).
   - Hoàn tất [`Capstone-Report-4-Final-Defense.md`](../reports/Capstone-Report-4-Final-Defense.md) & slide bảo vệ từ khung mẫu sẵn có.
