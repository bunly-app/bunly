# A01 tiếp tục — APK A03-02 và môi trường local

Ngày 09/11/2026, Asia/Bangkok. Phạm vi mới theo `documents/development/autonomous-run/RUNBOOK.md`: build/verification và backend LOCAL. Đã kiểm tra marker không chờ người dùng và nhận lease bằng `FileMode.CreateNew` trước mutation/build. Không sửa Flutter hoặc deploy hosted.

## Snapshot và kết quả build

HEAD đầu vào `3ae5be9625edaa3a761253a4e578daa416a97322` + working tree A03-02 chưa commit. Không gán kết quả này cho HEAD thuần hoặc CI. Manifest SHA256 từng file đầu vào và Git status ở `build/a01-build-evidence-2026-11-09/`, bị Git ignore; chưa upload.

Lệnh thực tế: `scripts/a01-android-env.ps1` với JDK17/cache/SDK như báo cáo A01, `-Action BuildDemo`. Chế độ đọc `config/demo.example.json` và truyền APP_MODE=demo, target `lib/main.dart`; không gọi pub/codegen/analyze/test đồng thời chat Flutter. Gradle wrapper 8.12, Microsoft JDK17, SDK Flutter pin 3.35.7; không nâng dependency hoặc đổi JAVA_HOME/PATH toàn máy.

Lượt đầu **PASS**, exit 0, `BUILD SUCCESSFUL in 7m 53s`, 253 tasks (216 executed/37 up-to-date). Artifact đầu: `build/app/outputs/flutter-apk/app-debug.apk`, 154249986 byte, SHA256 `BE5DC6BFEA0C02568B6403F3F59350F202209F2671947DEB78EC0A93D03D7AFB`; bản ở `outputs/apk/debug/` có cùng checksum. Đây là APK debug/demo, chưa phải signed release hoặc bằng chứng Supabase thật.

Lượt đầu có lỗi incremental Kotlin do source plugin trong Pub cache ổ C và project ổ D; Kotlin tự fallback compile thường và toàn build vẫn đạt. Đã thêm **chỉ đối số tiến trình** `-Pkotlin.incremental=false` vào nhánh BuildDemo của script A01, không sửa gradle.properties, package cache hoặc dependency. Cách tắt này theo [tài liệu Kotlin chính thức](https://kotlinlang.org/docs/gradle-compilation-and-caches.html).

Lượt cuối sau sửa script: **PASS**, exit 0, `BUILD SUCCESSFUL in 1m 41s`, 253 tasks (23 executed/230 up-to-date), có biên dịch lại Kotlin. Không còn chuỗi lỗi different roots/incremental cache/fallback trong log cuối. APK cuối vẫn **154249986 byte**, cùng SHA256 `BE5DC6BFEA0C02568B6403F3F59350F202209F2671947DEB78EC0A93D03D7AFB`. Hai lượt local cho cùng artifact không chứng minh mọi máy/build tương lai đều giống bit; dependencies, SDK và đầu vào cần được giữ nhất quán.

Evidence: `demo-build.log`, `build-result.json`, `demo-build-final.log`, `build-final-result.json`, `apk-first-build.json`, `apk-final.json` trong evidence directory. Manifest **77 file** đầu vào không đổi sau lượt đầu; kiểm tra cuối trước bàn giao được ghi riêng. SHA256 script sau sửa: `1C15592F4CD8A5830B4B03ACCB9D8770DF8C39831EDB319BCC258FF37890C045`.

Các cảnh báo deprecated API/manifest plugin được giữ nguyên; chúng chưa làm build thất bại. Không nâng Gradle để xử lý warning tương thích Gradle 9 vì repo pin 8.12.

## Smoke trên thiết bị

Samsung A11 SM-A115F, Android 12/API31 đã nhận `adb -d install -r` thành công (giữ dữ liệu, không uninstall). `am start -W -n app.bunly.bunly/.MainActivity` trả `Status: ok`; process app còn tồn tại qua `pidof`. Log ở `adb-install.log`, `adb-launch.log`. Window focus trả `NotificationShade`, không phải màn app: **chưa xác minh UI hoặc luồng end-to-end**, không chụp màn cá nhân và không tự mở khóa thiết bị. Không gọi đây là manual UAT hoặc kết quả integration test.

## Backend độc lập đã chuẩn bị

Xem `A05-01-Analysis-Validation-2026-11-09.md`: module biên kiểm tra request/output/fingerprint và 14 tests Node đạt, không endpoint/DB/model thật. Xem thêm `A05-02-Quota-Ledger-Draft-2026-11-09.md`: proposal ledger có 32 PostgreSQL checks đạt trong DB tạm riêng, chưa áp schema ứng dụng.

## Docker và Supabase local thực tế

Đã mở **Docker Desktop có sẵn**, `Start-Process -WindowStyle Hidden`; không cài/nâng version, sửa cấu hình hoặc bấm chấp nhận điều khoản. Sau đó `docker info --format '{{.ServerVersion}}'` trả **28.5.2**, exit 0. Đã đọc help của CLI pin **2.121.0**, không theo gợi ý nâng CLI v3.

`supabase start` qua binary repo-local: **exit 0**, thông báo Starting database from backup. Dùng lại volume `supabase_db_bunly`, không reset. Container DB/Auth/Kong/mail healthy, REST chạy; config hiện tắt Edge runtime nên chưa có Function endpoint. Không in toàn bộ output status/start vì có secrets. Log tóm tắt đã lọc ở `supabase-start-result.json`.

| Lệnh kiểm tra trên stack local | Kết quả mới |
|---|---|
| `supabase migration list --local` | Exit 0, migration nguồn/applied cùng `20261022000100`; chữ remote trong JSON của lệnh này chỉ DB đang kết nối **local**, không truy cập hosted |
| `supabase db lint --local --level warning --fail-on warning` | Exit 0, No schema errors found |
| `supabase test db --local` | Exit 0, **39 pgTAP tests đạt**; suite dùng transaction/rollback |
| `python scripts/prepare_m2_local.py` | Exit 0, tạo hai user local test dùng một lần, xác nhận bằng admin helper để setup; không ghi admin key vào app. Đây không phải luồng user mở email xác nhận |
| `Flutter 3.35.7 test test_connected/m2_connected_test.dart --no-pub --reporter expanded --dart-define-from-file=config/m2-test.local.json` | Exit 0, **1/1 connected SDK test đạt**: Auth/API, SQLite restart, push/pull, edits/tombstones, owner isolation |

Connected SDK là VM test, chưa phải Android connected UI hoặc Cloud. Test phát cảnh báo Drift tạo nhiều instance AppDatabase (mở DB thứ hai trong suite); test vẫn đạt. Không tắt warning hoặc sửa source Flutter của luồng kia. Nếu mở rộng suite cần owner Flutter rà lifecycle DB và giữ cảnh báo này trong đánh giá, không nhận là đã sửa.

File `config/m2-test.local.json` đã được helper tạo lại và được `git check-ignore` xác nhận. Bản config test trước đó lưu riêng ở `D:\SDK\bunly-a01\private\`, ngoài Git/evidence công khai; không đưa credentials hoặc backup vào artifact chia sẻ. Hai tài khoản thử mới vẫn tồn tại local sau test. Docker/stack được để chạy phục vụ lượt tiếp theo, không stop/reset hoặc dọn dữ liệu người dùng.

Log: `migration-list-local.log`, `db-lint-local.log`, `db-test-local.log`, `db-check-exits.json`, `connected-sdk.log`, `connected-sdk-result.json`. Android cmdline-tools/license vẫn chưa xác minh đầy đủ như báo cáo A01 ban đầu; build lần này không gặp yêu cầu chấp nhận license. Không suy từ build đạt rằng mọi SDK license đều đủ.
