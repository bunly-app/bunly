# A01 — Môi trường Android/Gradle Bunly

Ngày kiểm tra: **09/11/2026**, Asia/Bangkok. Checkout hiện có: `D:\VKULearningMaterials\Year4_Semester1\Cross Platform\bunly`. HEAD đầu vào `3ae5be9625edaa3a761253a4e578daa416a97322` + working tree đang được chat Flutter sửa song song. Không tạo commit; bằng chứng dưới đây không phải kết quả CI hoặc kết quả build của HEAD.

Đã đọc `AGENTS.md`, vai trò CLI/môi trường, `documents/development/GETTING_STARTED.md` (không có bản ở gốc), PRD M2, báo cáo A00 và A02-A03-01. Phạm vi chỉ chuẩn bị môi trường; không sửa báo cáo M2 hoặc tài liệu kế hoạch chung theo giới hạn đợt song song.

## 1. Kết quả thực tế

| Hạng mục | Bằng chứng ngày 09/11 | Trạng thái / giới hạn |
|---|---|---|
| Nguyên nhân `.zip.lck` | `GRADLE_USER_HOME` Process/User là `C:\Users\LENOVO\scoop\apps\gradle\current\.gradle`. `current` là junction tới Scoop Gradle 9.2.0; `.gradle` là junction tới `C:\Users\LENOVO\scoop\persist\gradle\.gradle`; đích cuối **không tồn tại**. Log A00 báo FileNotFoundException tại chính cây này. | Đã xác định đường dẫn hỏng; không xóa cache/junction cũ, không đổi cấu hình User/Machine. Scoop 9.2.0 không phải wrapper pin của Bunly. |
| Cache thay thế | `D:\SDK\bunly-a01\gradle-cache`, ngoài checkout. Tạo/mở độc quyền file `.zip.lck` thử trong cây `wrapper/dists` đạt. Wrapper tải/giải nén Gradle 8.12 và `--version` exit 0 bằng cache này. | Đã vượt bước wrapper/cache từng lỗi trong A00; **chưa xác nhận APK build**. Probe chỉ xóa file thử UUID do chính nó tạo. |
| JDK17 | Microsoft OpenJDK **17.0.21.0.2+1-LTS**, `java -version` và `javac -version` exit 0. Giải nén ZIP ngoài checkout ở `D:\SDK\bunly-a01\jdk\jdk-17.0.21.0.2+1`. | Sẵn sàng cho tiến trình Gradle. Không chạy installer, không đổi registry, JAVA_HOME/PATH toàn máy hoặc Flutter config. |
| Java Gradle thực dùng | `gradlew.bat --console=plain --no-daemon "-Dorg.gradle.java.home=…" --version`: Gradle **8.12**, Launcher JVM **17.0.21.0.2**, Daemon JVM trỏ JDK17 vừa chuẩn bị. | Chỉ bootstrap/version, không configure/compile app hoặc chạy Flutter. Không nâng wrapper/AGP/Kotlin. |
| Android SDK | `android/local.properties` hiện trỏ `D:\SDK\android-sdk`, Flutter SDK `D:\SDK\flutter-3.35.7`. Có platform 34/35/36/37.0; build-tools 34.0.0/35.0.0/36.0.0; NDK 27.0.12077973/27.1.12297006/28.2.13676358. | Chỉ kiểm kê, chưa xác minh mọi package đủ cho build hiện tại. Không sửa local.properties hoặc SDK dùng chung. |
| cmdline-tools / license | Không có thư mục cmdline-tools; tìm `sdkmanager.bat` toàn SDK không có kết quả. Có `licenses/android-sdk-license` dài 42 byte. | **Thiếu cmdline-tools; license status chưa xác minh**. File license hiện hữu không chứng minh mọi điều khoản cần thiết đã được chấp nhận. Không chạy `--licenses`, không tự trả lời yes hoặc ghi license hash. |
| Android thật | SDK ADB **37.0.1**; `adb devices -l` có một thiết bị trạng thái `device`. `adb -d shell getprop`: **SM-A115F (Samsung A11), Android 12, API 31**. | Đã xác nhận ADB kết nối; không cài/mở app hay chạy integration/UAT. Khác A00 vốn chưa có thiết bị. |
| Emulator | Emulator **37.1.11**; `emulator -list-avds` liệt kê `Bunly_M2`, `Pixel_8`. Có system image Android 35. | Chưa khởi động/xác minh AVD chạy được. |
| Docker | `docker version --format '{{.Client.Version}}'` in client **28.5.2** rồi exit 1; `docker info --format '{{.ServerVersion}}'` exit 1: thiếu named pipe `dockerDesktopLinuxEngine`. Không thấy tiến trình Docker Desktop/backend tại lúc kiểm tra. | **Docker engine chưa sẵn sàng**. Không khởi động/đổi Docker context, không start/reset DB; SQL/RLS/connected chưa chạy. |
| APK / Flutter | Không chạy Flutter pub/codegen/format/analyze/test/build; không chạy Gradle `assembleDebug` trong đợt này. | **BUILD CHƯA CHẠY**, chờ chat Flutter kết thúc và bàn giao cửa sổ build. Không có APK mới hoặc kết luận source biên dịch đạt. |

## 2. Tệp và công cụ đã chuẩn bị

Trong repository chỉ thêm báo cáo này và `scripts/a01-android-env.ps1`. Script nhận đường dẫn qua tham số, không nhúng đường dẫn riêng máy. Mặc định `Action=Check`; chỉ kiểm tra JDK17, khả năng tạo lock file và Gradle wrapper `--version`. Lần đầu Check có thể tải bản Gradle được pin sẵn trong wrapper.

Script đặt `JAVA_HOME`, `GRADLE_USER_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, PATH trong tiến trình hiện tại và khôi phục trong `finally`, kể cả khi lỗi. `-Dorg.gradle.java.home` chỉ rõ JDK của Gradle, tránh việc Flutter tự chọn JBR của Android Studio. Không gọi `flutter config --jdk-dir`. Cache phải ở ngoài checkout. Không dot-source để giữ biến sau lệnh.

Ngoài checkout đã tạo `D:\SDK\bunly-a01\`: ZIP JDK, JDK giải nén, cache Gradle mới, metadata/checksum và log `check-final.log`. Đây là công cụ local, không phải artifact đã upload hoặc nội dung cần commit. Để ngừng dùng, bỏ gọi script; không cần đổi lại biến User/Machine vì chúng không được chỉnh sửa. Không tự dọn thư mục trong đợt này.

Nguồn JDK: [Microsoft OpenJDK downloads](https://learn.microsoft.com/en-us/java/openjdk/download), ZIP `https://aka.ms/download-jdk/microsoft-jdk-17.0.21.0.2-windows-x64.zip`, checksum từ URL cùng tên thêm `.sha256sum.txt`. SHA256 tải về khớp công bố:

```text
49154292866386b2f4f09a3ecf3be07ab80a419149c84ec1d4419b9eec9e4b64
```

Đã thử tải Temurin 17 qua API Adoptium trước đó; GitHub binary trả HTTP 504 cả Invoke-WebRequest và curl retry. Không dùng binary tải lỗi. Chuyển sang ZIP chính thức Microsoft và xác minh checksum trước giải nén; không tắt TLS/checksum và không chạy bước chấp nhận điều khoản thay người dùng.

ZIP Gradle 8.12 tải từ distribution URL hiện có; đối chiếu với [SHA256 chính thức](https://services.gradle.org/distributions/gradle-8.12-all.zip.sha256) đạt:

```text
7ebdac923867a3cec0098302416d1e3c6c0c729fc4e2e05c10637a8af33a76c5
```

Không sửa wrapper properties để thêm checksum trong đợt này; kiểm chứng checksum ở đây là kiểm tra độc lập của bản tải local.

## 3. Cách sử dụng và build sau bàn giao

Từ gốc checkout, kiểm tra riêng môi trường (đã chạy, exit 0):

```powershell
./scripts/a01-android-env.ps1 `
  -JdkHome 'D:/SDK/bunly-a01/jdk/jdk-17.0.21.0.2+1' `
  -GradleUserHome 'D:/SDK/bunly-a01/gradle-cache' `
  -AndroidSdkRoot 'D:/SDK/android-sdk'
```

**Chỉ sau khi chat Flutter xác nhận đã ngừng dùng checkout:** chủ luồng Flutter hoàn tất dependencies/codegen và các kiểm tra liên quan bằng Flutter **3.35.7** theo lockfile hiện tại; xác minh local.properties vẫn đúng SDK. Không chạy pub/codegen đồng thời hai chat. Ghi SHA + trạng thái working tree tại thời điểm build, vì HEAD đơn lẻ không mô tả các thay đổi chưa commit.

Lệnh sau là **cách build đã chuẩn bị, chưa thực thi**:

```powershell
./scripts/a01-android-env.ps1 `
  -JdkHome 'D:/SDK/bunly-a01/jdk/jdk-17.0.21.0.2+1' `
  -GradleUserHome 'D:/SDK/bunly-a01/gradle-cache' `
  -AndroidSdkRoot 'D:/SDK/android-sdk' `
  -Action BuildDemo
```

BuildDemo kiểm tra hiện diện package_config/local.properties/plugin metadata, đọc `config/demo.example.json`, yêu cầu APP_MODE=demo, mã hóa dart-defines rồi gọi wrapper `assembleDebug --console=plain --no-daemon`, target `lib/main.dart`, JDK17 chỉ rõ bằng system property. Không gọi pub/codegen, không chọn hosted config. Kiểm tra hiện diện chưa chứng minh generated files còn mới; chủ luồng Flutter chịu trách nhiệm bàn giao đầu vào nhất quán. Build có thể tải Maven/Android artifacts và còn gặp lỗi package/license/network; không coi bước `--version` là xác nhận các bước đó.

Sau build cần kiểm tra exit code, APK thực tế (thường `build/app/outputs/flutter-apk/app-debug.apk` hoặc `build/app/outputs/apk/debug/app-debug.apk`), SHA256 và ghi log theo snapshot nguồn. Chưa kiểm chứng vị trí artifact của lượt này vì chưa build. APK demo không chứng minh Supabase thật; connected cần lượt nghiệm thu riêng với backend/thiết bị được chỉ định.

## 4. Kiểm chứng script và phần còn chặn

- Parser PowerShell: đạt. Chế độ Check cuối cùng: exit 0, wrapper 8.12/JDK17 đúng, không chạy Flutter/build.
- Kiểm tra khôi phục đủ 5 biến Process sau thành công: đạt; sau lỗi cố ý dùng một file làm cache root: đạt. Bản đầu phát hiện .NET chuyển null thành chuỗi rỗng; đã sửa để xóa biến vốn không tồn tại rồi chạy lại cả hai trường hợp đạt. Không giữ bản có lỗi làm bằng chứng.
- Biến User/Machine đọc lại vẫn như đầu vào: JAVA_HOME Machine JDK21, GRADLE_USER_HOME User đường dẫn Scoop cũ, các Android home chưa đặt. Không đổi Java/PATH/Flutter toàn máy.
- Chưa chạy nhánh BuildDemo, build APK, Flutter checks, SQL/RLS, connected hoặc device UI tests. Kiểm tra Gradle version không cấu hình project và không xác nhận build app.
- Cần người dùng cài Android SDK Command-line Tools vào SDK được chỉ định và tự đọc/xử lý điều khoản nếu công cụ yêu cầu. Sau đó mới kiểm tra đầy đủ sdkmanager/license. Không tự đồng ý trong A01.
- Docker cần được người dùng mở/sửa engine trước khi luồng database kiểm tra stack. Không reset database hoặc dùng hosted để vượt lỗi local.
- Cửa sổ build vẫn chờ chat Flutter bàn giao. Cache mặc định của các terminal khác vẫn hỏng cho tới khi dùng cấu hình riêng; A01 chỉ cung cấp đường chạy thay thế đã kiểm chứng ở bước wrapper.

Không đổi `lib/`, `test/`, `integration_test/`, providers, pubspec/lockfiles, schema, cấu hình Supabase hosted hoặc shared planning docs. Không tạo worktree, xóa cache cũ, chấp nhận license, in credentials hay commit.
