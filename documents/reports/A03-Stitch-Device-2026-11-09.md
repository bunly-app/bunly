# Kiểm tra bản UI native Stitch trên Samsung Galaxy A11 — 09/11/2026

Báo cáo kiểm tra build APK Demo Debug từ working tree Stitch native UI (`HEAD` `3ae5be9625edaa3a761253a4e578daa416a97322` + thay đổi local chưa commit) và cài đặt trực tiếp lên thiết bị thật **Samsung Galaxy A11 (`SM-A115F`, serial `R9JN409P9RJ`, Android 12 / API 31, 720×1560 @ 280 dpi, Night Mode)**. Không chỉnh sửa code Dart/Drift/lockfiles hay cấu hình Supabase; không gỡ cài đặt hoặc xóa dữ liệu người dùng.

## Build & Cài đặt giữ dữ liệu

- Lệnh build (A01 pinned Android tooling):
  `./scripts/a01-android-env.ps1 -JdkHome 'D:/SDK/bunly-a01/jdk/jdk-17.0.21.0.2+1' -GradleUserHome 'D:/SDK/bunly-a01/gradle-cache' -AndroidSdkRoot 'D:/SDK/android-sdk' -Action BuildDemo`
  → **BUILD SUCCESSFUL in 3m 40s** (253 tasks: 29 executed, 224 up-to-date; `compileFlutterBuildDebug` thực thi lại đầy đủ, không dính `UP-TO-DATE` giả).
- Artifact APK: `build/app/outputs/flutter-apk/app-debug.apk`
  - Kích thước: **172,414,189 bytes**
  - SHA256: `AAFD390183DEB78EFC1418E77A7E4A0CB74CDD9F8E3846BE1F08A2ECFFE6CB94`
- Cài đặt giữ dữ liệu: `adb -d install -r build\app\outputs\flutter-apk\app-debug.apk` → **Success**.
- Xác nhận package trên A11 (`dumpsys package app.bunly.bunly`):
  - `versionCode=1`, `versionName=0.1.0`, `minSdk=24`, `targetSdk=36`
  - `firstInstallTime=2026-10-29 14:31:10` (giữ nguyên cài đặt gốc, không clear app data)
  - `lastUpdateTime=2026-11-09 19:25:59`
- Khởi chạy trên A11: `app.bunly.bunly/.MainActivity` (**PID 7878**), rendering backend **Impeller (Vulkan)**, `Displayed/Fully drawn: +14s726ms` (chế độ Debug trên phần cứng A11).

## Dữ liệu người dùng & Kiểm tra tương tác trên màn hình thật

Thư mục ảnh/log kiểm tra trên máy dev (đã gitignore): `build/stitch-device-check-2026-11-09/` (`01-home.png` đến `13-notebook-final.png`, `final-session-logcat-bunly.txt`). Mọi ảnh chỉ chụp khi `mCurrentFocus` xác nhận là `app.bunly.bunly/.MainActivity`.

| Màn hình / Luồng | Kết quả quan sát trên A11 (Dark Mode, 720×1560) |
|---|---|
| `Hôm nay` (`TodayScreen`) | Header `文` + `Bunly · Demo` + `ぶんぽう`, mục tiêu `Lộ trình N5 · 15 phút mỗi ngày`, CTA `Mở kho ngữ pháp`, thẻ `N4 · 〜たことがある` giữ trạng thái đã lưu. Không tràn khung. |
| `Tra cứu` (`GrammarScreen`) | Thanh tìm kiếm, nút quét nhanh câu, filter chip `Tất cả` / `N5 (2)` / `N4 (1)` / `N3 · Sắp ra mắt`, nhóm chủ đề, chip `Chỉ mẫu đã lưu`, dải làm mới `Kho hiện có 3 mẫu.`, danh sách 3 mẫu rõ ràng. |
| `Sổ học` (`NotebookScreen`) | **Bảo toàn dữ liệu cũ 100%**: `1 mẫu đã lưu`, `1 ghi chú` (`Ghi nhớ: DEMO: Ghi chu luu tren dien thoai that.`). Header gọn không che thanh điều hướng; tab `Mẫu đã lưu (1)` / `Ghi chú (1)`, bộ lọc phụ `Tất cả` / `N5` / `N4` / `Có ghi chú` và nút `Chi tiết và ghi chú` hiển thị đầy đủ (kiểm tra lại lần cuối ở `13-notebook-final.png`). |
| `Tiến độ` (`ProgressScreen`) | `Lộ trình N5 · Mục tiêu: 15 phút/ngày`, `Đã bắt đầu 0/3 mẫu`, `StackedProgressBar`, lưới 2×2 trạng thái (`0/0/0/3`), ghi chú trung thực chưa tính % đúng/sai, nút `Xem lịch sử bài làm` & `Mở sổ lỗi cần ôn`. |
| `Xác nhận câu tiếng Nhật` (`SentenceReviewScreen`) | Đếm ký tự, chip chèn nhanh (`。`, `、`, `は`, `が`, `へ`), `Nhập tay toàn bộ`, 3 ví dụ trong kho (`日本へ行ったことがあります。`, ...), thẻ bảo mật demo, CTA cố định đáy `Xác nhận và xem kết quả demo`. Chạm chọn ví dụ #1 và xác nhận điều hướng mượt. |
| `Ngữ pháp trong câu` (`SentenceResultScreen`) | Hiển thị câu đã xác nhận `日本へ行ったことがあります。`, badge `CÂU BẠN ĐÃ XÁC NHẬN` + `Chưa qua AI/OCR` không overflow, đối chiếu `1 mẫu` (`N4 · 〜たことがある`), CTA `Xem chi tiết mẫu và ví dụ`. (Không bấm lưu ghi chú thử để giữ nguyên `1 ghi chú` của người dùng.) |
| `Chi tiết ngữ pháp` (`GrammarDetailScreen`) | Trạng thái bookmark giữ nguyên, banner `Câu bạn đã xác nhận`, công thức `Động từ thể た + ことがある`, cách dùng, ví dụ Nhật–Việt, 4 pill `Trạng thái học` tự xuống dòng gọn, CTA `Thử phiên luyện mẫu này · Demo`. |
| `Chọn phiên luyện tập` (`PracticeSetupScreen`) | Mục `Viết & Nói · Demo` (`Dịch Việt → Nhật · Demo`, `Nói một câu · Demo`), `Nguồn bài luyện` (`Hai câu mẫu trên thiết bị · Offline`), các dạng bài và CTA `Bắt đầu phiên demo (2 câu)`. |
| `Dịch Việt → Nhật · Demo` (`WritingPracticeScreen`) | Đề bài `“Tôi đã từng đi Nhật.”`, ngữ cảnh, ô nhập kèm `0 ký tự` (`0/2000`), accordion `Xem gợi ý cấu trúc`, nút `Xác nhận văn bản`. |
| `Trắc nghiệm 1/2` & `Điền khuyết 2/2` (`PracticeSessionScreen`) | Câu 1 MCQ: chọn đáp án `B (行った)` → `Kiểm tra đáp án` hiện phản hồi `Chính xác` + giải thích và thanh tiến độ 1/2; chuyển tiếp sang Câu 2 Điền khuyết (`納豆を [     ] ことがありません。`) kèm chuyển `Ngân hàng từ` / `Bàn phím Nhật` rõ ràng. |
| `Hồ sơ học tập` (`ProfileScreen`) | Mở từ avatar góc phải trên tab `Tiến độ`, giữ nguyên `Trình độ: N5`, `Phút học mỗi ngày: 15`, nút `Lưu hồ sơ` và thẻ thông tin lưu trên thiết bị. |
| `Lịch sử bài làm` (`PracticeHistoryScreen`) | Mở từ `Tiến độ → Xem lịch sử bài làm`, bộ lọc ngang (`Tất cả`, `MCQ & Điền từ`, `Dịch`, `Nói`), empty state minh bạch chưa kết nối dữ liệu và CTA thử bài demo. |

## Kiểm tra Logcat phiên chạy (PID 7878)

- Phiên chạy xuyên suốt từ `19:26` đến `19:34` giữ nguyên **1 tiến trình duy nhất (`PID 7878`)**, không crash hay khởi động lại.
- Trong **253 dòng log** của `PID 7878` (`final-session-logcat-bunly.txt`): **0** dòng `FATAL`, **0** `AndroidRuntime` / `Unhandled Exception` / `E/flutter`, **0** cảnh báo `RenderFlex overflowed`.
- 2 dòng `IOException` / `FileNotFoundException` ở `PID 1510` (`SemWifiTransportLayerUtils` tra cứu Play Store của hệ thống Samsung cho debug package) không phải lỗi từ Bunly.
- Ô tròn nổi bốn hình vuông nhỏ xuất hiện ở giữa màn hình là nút Trợ năng (Accessibility shortcut) của hệ điều hành Samsung One UI, nằm ngoài lớp giao diện Flutter của Bunly.

## Giới hạn chưa kiểm chứng trong lượt này

- Chưa kiểm tra trên A11 ở **Light Mode** và các mức phóng to phông chữ hệ thống khác nhau trên thiết bị thật (mới phủ Light `320×640 @ textScale 2.0` và Dark `1024×768 @ textScale 1.4` trong `flutter test`).
- Thời gian khởi động lạnh **`+14s726ms`** là đo ở bản **Debug APK**; chưa build/đo thời gian khởi động ở chế độ **Profile** hoặc **Release**.
- Chưa kết nối hoặc nghiệm thu trên thiết bị thật đối với **Supabase Cloud UAT**, đăng nhập/đồng bộ tài khoản thật, camera OCR, micro/ASR, AI giải thích/chấm câu, lưu trữ lịch sử bài luyện bền vững, sổ lỗi hay SRS nhắc học.

---

# Lượt kiểm tra cập nhật Figma Image-to-Code trên Samsung Galaxy A11 — 09/11/2026 (20:13–20:25)

Kiểm tra bản APK Demo Debug build lại sau khi chuyển 5 ảnh Figma (`39hHCJ2CmxZNbe5NAUd6sA`) sang code Flutter native (`S00a`, `S00b`, `S01`, `S02`, `S13`, `S20`, `S37`, `S38`, `S27`, `S28/S17`, `S29`, `S18`, `S33`, `S34`, `S35`) và khắc phục lỗi tràn dòng ở `320×640 @ textScale 2.0` cùng lỗi `ExpansionTile` + `PageStorageKey` trên `PracticeHistoryScreen`.

## Build & Cài đặt giữ dữ liệu (Lượt 20:13)

- Lệnh build (A01 pinned Android tooling):
  `./scripts/a01-android-env.ps1 -JdkHome 'D:/SDK/bunly-a01/jdk/jdk-17.0.21.0.2+1' -GradleUserHome 'D:/SDK/bunly-a01/gradle-cache' -AndroidSdkRoot 'D:/SDK/android-sdk' -Action BuildDemo`
  → **BUILD SUCCESSFUL in 39s** (`compileFlutterBuildDebug` thực thi đầy đủ).
- Artifact APK: `build/app/outputs/flutter-apk/app-debug.apk`
  - Kích thước: **172,458,614 bytes**
  - SHA256: `879DCA056E786A4236387A0EDF09F2E04B90239E3A253E1DF3C20405398D6D45`
- Cài đặt giữ dữ liệu: `adb -s R9JN409P9RJ install -r build\app\outputs\flutter-apk\app-debug.apk` → **Success**.
- Xác nhận package trên A11 (`dumpsys package app.bunly.bunly`):
  - `versionCode=1`, `versionName=0.1.0`, `minSdk=24`, `targetSdk=36`
  - `firstInstallTime=2026-10-29 14:31:10` (bảo toàn 100% dữ liệu người dùng)
  - `lastUpdateTime=2026-11-09 20:13:42`
- Tiến trình chạy suốt phiên kiểm tra: `app.bunly.bunly/.MainActivity` (**PID 10131**, Impeller Vulkan).

## Ảnh chụp & Quan sát thực tế trên A11 (Dark Mode, 720×1560)

Thư mục bằng chứng cục bộ (đã gitignore): `build/figma-device-check-2026-11-09/` (`00-launch.png`–`22-notebook-final.png`, `figma-session-logcat.txt`).

| Màn hình / Luồng kiểm tra | Ảnh đối chiếu | Kết quả thực tế trên A11 |
|---|---|---|
| `S13` Sổ học cá nhân | `01-notebook.png`, `22-notebook-final.png` | **Bảo toàn dữ liệu cũ trước và sau phiên test**: `1 mẫu đã lưu`, `1 ghi chú`, `0 cần ôn`, ghi chú `'DEMO: Ghi chu luu tren dien thoai that.'`, nút `Chi tiết và ghi chú` & `Luyện thử` xếp gọn không tràn. |
| `S20` Tiến độ học tập | `02-progress-top.png`, `03-progress-bottom.png`, `04-progress-errors.png` | Thẻ `Lộ trình N5` + `Đổi lộ trình`, `Mức ghi nhớ N5` (`Tự đánh giá`), `Thực chiến 7 ngày qua` hiển thị 3 hàng `Chưa nối` (0 `%` giả), `Trọng điểm sai sót` (`Cần ưu tiên`) + nút mở Sổ lỗi & Lịch sử. |
| `S37` Sổ lỗi cần ôn | `05-errors-top.png`, `06-errors-scrolled.png` | Banner `0 lỗi cần ôn · Chưa nối dữ liệu` (`0 nhóm ưu tiên`, `0 đã khắc phục`), chip loại lỗi, empty state trung thực, thẻ toggle minh họa. |
| `S38` Lịch sử bài làm + `_DiffSampleCard` | `07-history-top.png`, `08-history-sample.png` | Bộ lọc 2 hàng, chạm mở thẻ `Xem bố cục thẻ nhật ký (Minh họa)` (`Minh họa UI`) mượt mà trong `ListView(PageStorageKey)` — **không crash cast `double`/`bool?`**. |
| `S27` Chọn phiên luyện tập | `09-practice-setup.png`, `10-practice-setup-bottom.png`, `11-practice-setup-start.png` | Badge `Mục tiêu ngày`, các nguồn khóa (`Đến hạn ôn SRS`, `Điểm yếu từ Sổ lỗi`, `Tự chọn theo cấp độ`), thẻ `THIẾT LẬP PHIÊN`, nút `Bắt đầu phiên demo (2 câu)`. |
| `S28/S17` Trắc nghiệm 1/2 | `12-mcq.png`, `13-mcq-feedback.png` | Tô sáng ô trống inline `[ ? ]`, chọn đáp án `A 行く` hiển thị tag `Lựa chọn của bạn` (đỏ) vs `Đáp án chuẩn` (`B 行った`, xanh), giải thích và thẻ `Quy tắc nói: V(た) + ことがある`. |
| `S29` Điền khuyết 2/2 | `21-cloze-wordbank-top.png`, `21-cloze-wordbank-mid.png`, `21-cloze-wordbank-selected.png` | Câu `納豆を [ ______ ] ことがありません。`, chọn `食べた` điền trực tiếp vào ô trống inline + highlight lưới 2 cột + thẻ `Quy tắc chấm tự động linh hoạt` + bật nút `Kiểm tra đáp án`. |
| `S18` Kết quả phiên demo | `14-cloze-top.png` | Thẻ `Kết quả ghi nhận`, `StackedProgressBar`, thẻ `Mẫu ngữ pháp trong phiên` (`〜たことがある · N4 · Cần ôn thêm`). |
| `S33/S34` Dịch Việt → Nhật & Câu tham khảo | `15-translation-top.png`, `16-translation-mid.png`, `17-translation-confirmed.png`, `18-translation-feedback-top.png`, `18-translation-feedback-bottom.png` | Đề bài `“Tôi đã từng đi Nhật.”`, thẻ gradient nhắc thể quá khứ, nhập token `は。` + xác nhận văn bản + `Đối chiếu câu tham khảo` hiển thị `3 tiêu chí mẫu` và `GỢI Ý CÂU THAM KHẢO` gọn gàng. *(Lưu ý nhỏ: AppBar `'Dịch Việt → Nhật · De...'` rút gọn dấu `...` trên bề ngang 720px do pill `'Mẫu Demo'`, không overflow).* |
| `S35` Nói một câu (Text preview) | `19-voice-top.png`, `20-voice-waveform.png` | Thẻ tình huống Phú Sĩ (`富士山 (ふじさん) · 登る (のぼる)`), `GỢI Ý TỪ VỰNG`, khung `_VoiceWaveformPreview` (`Mô phỏng khung thu âm · Chưa kết nối micro / ASR`) và ô nhập văn bản thay lời nói. |

## Kiểm tra Logcat phiên chạy Lượt 2 (PID 10131)

- Phiên chạy liên tục từ `20:14:14` đến `20:25` giữ nguyên **1 tiến trình duy nhất (`PID 10131`)**, không crash hay tự khởi động lại.
- Trong **231 dòng log UTF-8** lọc theo `--pid=10131` (`build/figma-device-check-2026-11-09/figma-session-logcat.txt`): **0** `FATAL`, **0** `AndroidRuntime` / `Unhandled Exception` / `E/flutter`, **0** cảnh báo `RenderFlex overflowed`.

## Chưa kiểm chứng trên A11 ở lượt này

- `S00a/S00b` và `Auth S01/S02` chưa mở trực tiếp trên máy thật nhằm bảo toàn phiên đang giữ ghi chú cục bộ của người dùng (đã kiểm ở `test/presentation/stitch_ui_test.dart`).
- **Light Mode** và các cỡ chữ hệ thống khác nhau chưa kiểm trên phần cứng A11 (đã kiểm `Size(320, 640) @ textScale 2.0` Light trong widget test).
- Tính năng AI grading, micro/ASR, lưu lịch sử/sổ lỗi thật, SRS và Supabase Cloud UAT vẫn giữ ranh giới demo/chưa kết nối.
