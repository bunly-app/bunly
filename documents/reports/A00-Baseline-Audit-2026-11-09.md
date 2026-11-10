# A00 — Rà baseline và khả năng triển khai Bunly

Ngày kiểm tra: **09/11/2026**, múi giờ Asia/Bangkok. Phạm vi được thực hiện: A00 theo [phân công baseline](../planning/BASELINE-DELIVERY-OWNERSHIP.md). Không triển khai chức năng mới, sửa dependency, tạo worktree, commit, deploy hoặc thay đổi Supabase hosted.

## 1. Kết luận và baseline

Có thể tiếp tục A02 và chuẩn bị phần A03 chạy local. Kiểm thử connected/database/Android cần xử lý môi trường trước; không dùng demo làm bằng chứng Cloud.

| Thuộc tính | Kết quả |
|---|---|
| Checkout | `D:\VKULearningMaterials\Year4_Semester1\Cross Platform\bunly` |
| Branch | `codex/complete-m2`, ahead origin 4 commits tại thời điểm kiểm tra |
| HEAD đầu vào | `3ae5be9625edaa3a761253a4e578daa416a97322` |
| Working tree đầu vào | 5 file tracked đã sửa: AGENTS.md, README.md, SUPABASE-CLOUD.md, PRD M2, kế hoạch TEAM-M2-M3. Có 24 file untracked theo manifest, gồm knowledge pack, các kế hoạch/brief/design và template/handoff. Không coi chúng là nội dung đã nằm trong HEAD. |
| Danh tính Git hiện có | `Vcoch27 <hoangtungmy123@gmail.com>`; không đổi cấu hình identity và không tạo commit |
| Bằng chứng mới | Lệnh chạy trên **HEAD + working tree chưa commit**. Không gán các bổ sung tài liệu hiện tại cho commit HEAD hoặc CI lịch sử. |
| Lưu log local | `build/a00-evidence-2026-11-09/`, nằm ngoài Git. Manifest SHA256 ghi 29 file đã sửa/untracked trước khi bổ sung báo cáo A00; không chứa giá trị credentials. Log này không phải artifact công khai đã upload. |

## 2. Công cụ, cấu hình và dịch vụ

Ready nghĩa là chỉ sẵn sàng cho phạm vi đã kiểm tra; không có nghĩa sản phẩm đã nghiệm thu.

| Hạng mục | Trạng thái / bằng chứng ngày 09/11 | Việc tiếp theo / owner |
|---|---|---|
| Flutter/Dart pin | **Ready để kiểm tra mã**. SDK `D:\SDK\flutter-3.35.7`: Flutter 3.35.7, framework `adc9010625`, Dart 3.9.2. Binary không có trong PATH; gọi bằng đường dẫn đầy đủ. Doctor cảnh báo user-branch/unknown upstream. | Hoàng giữ pin; có thể đặt PATH riêng tiến trình. Chưa xác minh lại nguồn cài SDK, không tự đổi channel hoặc nâng version. |
| Dependencies Flutter | `flutter pub get --enforce-lockfile` exit 0; không nâng package. Các thông báo phiên bản mới không phải lý do nâng dependency. | Dùng lockfile hiện tại cho task kế tiếp. |
| Node/npm | **Ready**: Node 24.20.0, npm 10.8.2; thỏa `node >=22` trong package.json. | Không thay package-lock để đồng nhất version máy khi chưa cần. |
| Supabase CLI | **Ready binary**: repo-local CLI 2.121.0; đã xem `status --help`; không dùng bản mới mà CLI gợi ý. | Tiếp tục `npm run supabase -- ...`. Chưa cần npm ci vì binary pin hiện hoạt động. |
| Docker/local Supabase | **Blocked runtime**. Docker client 28.5.2; Linux engine pipe không tồn tại. `supabase status -o json` exit 1 vì không inspect được container `supabase_db_bunly`. | A01 Hoàng khởi động/sửa Docker; sau đó kiểm tra local stack đầy đủ Auth, DB, mail. Không reset DB. |
| Supabase hosted | **Blocked integration**. `get_project` trực tiếp trả `bunly-dev`, ref `jbyxiihjqveqooenofsr`, region `ap-southeast-1`, status **INACTIVE**. | Hoàng xác định nguyên nhân/target/phạm vi trước hành động restore. Không restore trong A00. |
| Android SDK | **Partial**. Doctor nhận SDK 36.0.0, Android Studio 2026.1.3; báo thiếu `cmdline-tools`, license status unknown. Thư mục licenses có tồn tại không chứng minh mọi license đã chấp nhận. | A01 bổ sung cmdline-tools đúng SDK và kiểm tra license. Không tự chấp nhận điều khoản trong A00. |
| Android device | **Blocked device test**. `adb devices -l` không có thiết bị; `flutter devices` chỉ có Windows, Chrome, Edge. | Hoàng kết nối Android/USB debugging hoặc chuẩn bị emulator; Samsung A11 trong biên bản 29/10 là lịch sử. |
| Java/Gradle | **Blocked APK build**. `java -version` trên PATH là Java 8; JAVA_HOME trỏ JDK21; Flutter doctor chọn JBR25 của Android Studio; Gradle wrapper 8.12. Build demo lỗi `.zip.lck` vì cache trỏ đường dẫn Scoop không dùng được. Chưa xác nhận JDK17 từ các vị trí đã kiểm tra. | A01 kiểm tra `GRADLE_USER_HOME`, chọn cache ghi được và JDK17 cho riêng tiến trình theo guide; không đổi Java toàn máy hoặc nâng Gradle để vượt lỗi. |
| Windows/iOS | Visual Studio C++ chưa có theo doctor; không có bằng chứng macOS/Xcode/iPhone trong lần kiểm tra này. | Windows desktop không phải target baseline; iOS chưa xác minh, cần thiết bị/máy build riêng. |
| Client config | Chỉ kiểm tra tên trường/trạng thái: `development.local.json` là connected/Cloud, client key có; `m2-test.local.json` là connected/localhost, có trường email test A. Không in email/mật khẩu/key. | Có file chưa chứng minh key/session hợp lệ. Test config cần chuẩn bị lại khi local stack sẵn sàng. |
| Ignore secrets | `git check-ignore` xác nhận development, m2-test, supabase-admin local JSON đều bị ignore. | Giữ file admin DPAPI riêng máy; không chia sẻ cho team. |

## 3. Kết quả kiểm tra mã và giới hạn

| Kiểm tra | Kết quả mới | Bằng chứng / giới hạn |
|---|---|---|
| `flutter pub get --enforce-lockfile` | **PASS**, exit 0 | `pub-get.log`; lockfile không đổi |
| `dart format --output=none --set-exit-if-changed lib test integration_test test_connected` | **PASS**, exit 0; 40 file, 0 đổi | `format.log` |
| `flutter analyze --no-pub` | **PASS**, exit 0; No issues found | `analyze.log`, 104.7 giây; analyzer không tự kiểm tra mọi quy tắc kiến trúc của PRD |
| `flutter test --no-pub --reporter expanded` | **PASS**, exit 0; **24/24** tests | `flutter-test.log`; chỉ suite `test/`, không tự bao gồm `test_connected/` và Android integration |
| `dart run build_runner build --delete-conflicting-outputs` + `git diff --exit-code -- lib/core/database/app_database.g.dart` | **PASS**, cả hai exit 0 | `codegen.log`, `codegen-exits.json`; build_runner 64 giây, mã sinh tracked không lệch; không đổi schema |
| `flutter build apk --debug --no-pub --dart-define-from-file=config/demo.example.json` | **FAIL — environment**, exit 1 | `apk-build.log`; Gradle wrapper không tạo/mở được `.zip.lck` ở cache `C:\Users\LENOVO\scoop\apps\gradle\current\.gradle\wrapper\dists\gradle-8.12-all\...`. Dừng trước kiểm chứng biên dịch APK. Không quy lỗi này cho source app; chưa có APK mới từ A00. |
| Local migration/lint/RLS | **NOT RUN — Docker unavailable** | Không đổi SQL, không khởi động/reset local stack trong A00 |
| Connected SDK | **NOT RUN — local backend unavailable** | Test dùng user local; không chuyển sang Cloud hoặc chạy vào URL khác để vượt lỗi |
| Android integration/manual UAT | **NOT RUN — no Android device** | Chưa kiểm tra bàn phím Nhật, camera, Wi-Fi/data, force-stop hoặc email thật |
| Cloud Auth/API/RLS/UAT | **NOT RUN — INACTIVE** | Chỉ đọc metadata project; không truy vấn dữ liệu tài khoản |
| CI remote | **NOT RUN** | Workflow có sẵn; kết quả 29/10 thuộc commit cũ, không dùng làm kết quả A00 |

## 4. Rà M2 và khoảng trống theo PRD

| Phạm vi | Hiện trạng source / test | Khoảng trống và bước nhỏ tiếp theo |
|---|---|---|
| M2 FR-01: Auth/profile | Auth repository, Authenticate, form, profile/UpdateLearning đã có | Chưa xác minh Cloud email/restore session hôm nay. Reset password và callback còn thiếu; A03 mở rộng theo contract A02. |
| M2 FR-02: kho | SearchGrammar, mapper, Supabase/asset source, SQLite cache, filter/detail đã có. Asset thực tế **3 mẫu: 2 N5, 1 N4**. | Nội dung còn thiếu so với 80–120; cache metadata đang phụ thuộc implementation tại screen, cần xử lý ở A03. |
| M2 FR-03/04: học tập | SaveNote/UpdateLearning, saved/notes/status/profile; Drift schema v2 và migration v1→v2 có source/tests | Cần connected/device regression; count trạng thái không đại diện accuracy quiz. |
| M2 FR-05: sync | Worker push/pull bốn loại `profiles`, `notes`, `saved_grammar`, `progress`, queue theo sequence, session checks, pending protection | Chỉ một thiết bị; chưa version/conflict đa thiết bị. A02 chốt contract trước A07. |
| M2 FR-06: isolation | Source RLS + tests A/B và các case đổi phiên trong unit/widget | Chưa chạy lại SQL/connected; không kết luận RLS runtime đạt từ việc có policy trong file. |
| OCR/AI/quota | Không có scanner/analysis Function hoặc dependency OCR trong source hiện tại | A02 chốt input/output/errors/fixture; A04/A05 hiện thực thật sau đó. |
| Practice/review/home stats | Chưa có feature practice/review và question bank; hiện chỉ có thống kê trạng thái tự đánh giá | A02 chốt attempts/answer rules/review order; A06 bổ sung. |
| Reminders/Free-Pro | Chưa có tích hợp tương ứng | A08 làm local reminder; A05 làm server entitlement/quota. |
| UI shell | App hiện Auth → GrammarScreen, profile mở riêng; light/dark có nền | Chưa đủ 4 tab; chưa xem node Figma trong A00. A03 đọc Figma cụ thể rồi hiện thực UI. |
| Release | Gradle `release` còn `signingConfigs.getByName("debug")` | Chưa phải release signing riêng; A10 cần keystore/config/bằng chứng bản cài. |

### Những điểm kiến trúc A03 cần sửa

1. `lib/features/grammar/presentation/grammar_screen.dart` import `../data/cached_grammar_repository.dart` và kiểm tra concrete type để đọc `lastLoadFromCache` (dòng 9, 70–71 tại baseline). Presentation phụ thuộc implementation data; đưa metadata nguồn/cache qua domain contract và state thay vì cast implementation.
2. Cùng screen gọi `authRepositoryProvider.signOut()` trực tiếp (dòng 44), chưa đi qua use case/controller. Bổ sung use case SignOut và presentation action, giữ lỗi và account-switch behavior.
3. Đã rà **9 file domain**, không thấy import package ngoài, data hoặc presentation. Đây là kết quả rà imports hiện tại, không phải chứng minh mọi đường gọi toàn dự án đã đúng kiến trúc.

Không sửa các điểm này trong A00 để baseline audit có phạm vi rõ. Test/analyze xanh không làm các điểm lệch quy tắc trên tự biến mất.

## 5. Phạm vi cụ thể cho A02 và A03

| Task tiếp theo | File/phạm vi dự kiến | Acceptance và điều chưa được nhận là hoàn thành |
|---|---|---|
| A02-01 — Contract và lỗi | Thêm tài liệu contract trong `documents/development/`; đối chiếu domain hiện có | Chốt OCR draft, phân tích request/result, allowlist grammar ID, lỗi timeout/quota/no-match; định nghĩa offset Unicode; fixture success/failure dùng chung. Chưa gọi là AI thật. |
| A02-02 — Attempts/review/sync | Contract entity/ID/content version/idempotency, review ordering/clock-skew/revision/tombstone | Có ví dụ hai máy, retry sau commit, duplicate attempt, delete-vs-edit, đổi owner; review time không phụ thuộc đồng hồ client không kiểm tra. Chưa tạo/áp hosted migration. |
| A02-03 — Nội dung tích hợp và trạng thái UI | Danh sách 12 mẫu B0 và fixture MCQ/cloze, map states/CTA | Giữ 3 UUID hiện có; thêm 9 draft riêng; Vy duyệt trước nhận là nội dung hoàn thành. Không tính fixture/draft vào 80–120 mẫu đã duyệt. |
| A03-01 — Sửa boundary đã phát hiện | `grammar/domain`, use case load metadata, repository/controller, `auth/domain` SignOut, providers và tests | Presentation không import concrete cache repository; signOut qua use case; vẫn hiển thị nguồn cache và lỗi quyền đúng; test đổi account không hồi quy. |
| A03-02 — Shell thật theo Figma | App navigation/providers và presentation 4 tab; đọc node trước khi code | Hôm nay/Tra cứu/Sổ học/Tiến độ giữ ngữ cảnh/account isolation; dùng dữ liệu thật sẵn có. Vùng quiz/AI chưa hiện thực không có số giả hoặc CTA giả được nhận là hoàn thành. |
| A03-03 — Auth/settings | Reset/callback state, theme settings và UI lỗi; backend config ở A01 | Domain/widget tests làm local được; email callback/Cloud/device vẫn giữ chưa xác minh tới khi thử thật. |

**Owner:** Hoàng điều phối/tích hợp; Ánh review contract/boundary/data; Vy duyệt flow/nội dung/UAT. Chưa có review của Ánh/Vy trong A00; không ghi Approved thay họ.

## 6. Điều kiện tiếp tục

A02 có thể tiến hành ngay từ source và kết quả kiểm tra offline. A03-01 có thể triển khai sau khi chốt contract load metadata/SignOut, không phải chờ Cloud. A01 cần xử lý Gradle cache/JDK, Docker/Android toolchain/device/Cloud để mở build và các kiểm tra tích hợp; provider LLM/ngân sách và SMTP là đầu vào trước A05/UAT rộng. Gói A00 hoàn tất báo cáo hiện trạng không đồng nghĩa G0 hoặc M2 đã nghiệm thu.

**Trạng thái bàn giao A00:** báo cáo và kiểm tra offline đã thực hiện, sẵn sàng Ánh đối chiếu; chưa nhận review của thành viên. Không có thay đổi source/SQL/lockfile trong A00. Manifest xác nhận các file dirty/untracked có trước được giữ nguyên, ngoại trừ README được thêm liên kết audit có chủ đích; báo cáo M2 và kế hoạch được bổ sung ghi chú riêng, không viết lại kết quả cũ.
