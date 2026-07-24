# Hướng dẫn triển khai Fastlane — Flutter Base

Hướng dẫn tự triển khai fastlane từ đầu cho project này, tạo mới toàn bộ config
(keystore, Google Play service account, Firebase App Distribution, App Store
Connect API key) và CI trên GitHub Actions.

Cấu hình project đang có (dùng xuyên suốt guide):

| Mục | Giá trị |
|-----|---------|
| Flavors | `dev`, `uat`, `prod` (dimension `env`) |
| Entry point | `lib/main_<flavor>.dart` |
| Android appId | `com.fox.base.flutter` (+ suffix `.dev`, `.uat`; prod không suffix) |
| iOS bundle id | `com.fox.base.flutter.dev` / `.uat` / (prod) `com.fox.base.flutter` |
| iOS build config | `Release-dev`, `Release-uat`, `Release-prod` |
| iOS scheme | `dev`, `uat`, `prod` |
| Apple Team ID | `GH2PAB3V62` |

Nguyên tắc: **không commit secret**. Mọi key đọc từ biến môi trường / GitHub
Secrets. Xem checklist ở [Phần D](#phần-d--checklist-secrets--gitignore).

---

## Phần 0 — Chuẩn bị môi trường

Fastlane chạy bằng Ruby. Khuyến nghị cài qua Bundler để version cố định.

```bash
# 1. Kiểm tra Ruby (macOS đã có sẵn; nên dùng >= 3.0)
ruby --version

# 2. Cài bundler
gem install bundler

# 3. (macOS, cho iOS) cài Xcode command line tools nếu chưa có
xcode-select --install
```

Cấu trúc thư mục sẽ tạo:

```
android/
├── Gemfile
└── fastlane/
    ├── Appfile
    ├── Fastfile
    └── Pluginfile
ios/
├── Gemfile
└── fastlane/
    ├── Appfile
    ├── Fastfile
    └── Pluginfile
.github/workflows/
├── android_release.yml
└── ios_release.yml
```

---

## Phần A — Android

### A1. Khởi tạo fastlane

> **Lưu ý bug:** prompt tương tác của `fastlane init` / `add_plugin` hiện dính
> lỗi encoding `invalid byte sequence in UTF-8` ngay sau khi nhập package name.
> Có 2 cách xử lý dưới đây — chọn 1.

#### Cách 1 (khuyến nghị) — tạo file tay, bỏ hẳn `fastlane init`

`fastlane init` chỉ tạo giúp `Appfile` + `Fastfile` qua prompt (đang crash). Ta
tự tạo, vừa nhanh vừa tránh bug:

```bash
cd android
mkdir -p fastlane
touch Gemfile fastlane/Appfile fastlane/Fastfile fastlane/Pluginfile
```

Sau đó dán nội dung: `Gemfile` (ngay dưới đây), `Pluginfile` (cuối A1),
`Appfile` (mục A6), `Fastfile` (mục A7).

#### Cách 2 — dùng `fastlane init` + fix locale (KHÔNG ổn định trên Ruby 4.x)

Set locale UTF-8 rồi chạy lại (thêm 2 dòng `export` vào `~/.zshrc` cho lần sau):

```bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
cd android
rm -rf fastlane            # xóa folder tạo dở từ lần init lỗi trước
fastlane init              # nhập package name: com.fox.base.flutter
```

> ⚠️ Trên **Ruby 4.0.x** (ví dụ 4.0.5 cài qua Homebrew), set locale vẫn KHÔNG
> hết crash — do `highline 2.0.3` không tương thích Ruby 4.x. Nếu vẫn lỗi
> `invalid byte sequence in UTF-8`, hãy quay lại **Cách 1** (chắc chắn chạy được
> vì không có prompt), hoặc dùng Ruby 3.2–3.3 qua `rbenv`/`asdf` rồi mới init.
> Khuyến nghị: cứ theo Cách 1 cho gọn.

---

Tạo file `android/Gemfile` để khóa version (dùng cho cả 2 cách):

```ruby
# android/Gemfile
source "https://rubygems.org"

gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), "fastlane", "Pluginfile")
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

Cài plugin Firebase App Distribution — cũng có 2 cách:

**Cách 1 (khuyến nghị)** — tạo `android/fastlane/Pluginfile` tay rồi cài:

```ruby
# android/fastlane/Pluginfile
gem "fastlane-plugin-firebase_app_distribution"
```

```bash
cd android
bundle install
```

**Cách 2** — dùng `add_plugin` (qua prompt, cần set locale như A1 trước):

```bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
cd android
fastlane add_plugin firebase_app_distribution
bundle install
```

### A2. Tạo keystore release (config mới)

Release build phải ký bằng keystore riêng (không dùng debug key). Ở đây ta gen
keystore **trong project** tại `android/signing/` và để git ignore nó (không đẩy
lên remote).

```bash
mkdir -p android/signing        # keytool không tự tạo thư mục cha

keytool -genkey -v \
  -keystore android/signing/flutter_base_upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Giải thích các flag:

- `-alias upload` → đây chính là **keyAlias**, được truyền thẳng trong lệnh nên
  keytool KHÔNG hỏi lại. Keystore của bạn có alias là `upload`.
- Chỉ nhập **1 mật khẩu** ("Enter keystore password"). keytool mặc định tạo
  keystore định dạng **PKCS12** dùng chung một mật khẩu cho cả store lẫn key —
  nên KHÔNG có prompt "key password" riêng. Trong `key.properties`,
  `keyPassword` = `storePassword`.

Kiểm tra alias:

```bash
keytool -list -v -keystore android/signing/flutter_base_upload.jks
# tìm dòng: Alias name: upload
```

Tạo `android/key.properties` (file này **không commit** — xem A2b). Dùng đường
dẫn **tương đối** (Gradle `file()` trong module `app` tính từ `android/app`, nên
`..` lùi ra `android/` rồi vào `signing/`):

```properties
storePassword=<mật khẩu bạn nhập>
keyPassword=<giống storePassword>
keyAlias=upload
storeFile=../signing/flutter_base_upload.jks
```

### A2b. Đảm bảo git ignore keystore + key.properties

`android/.gitignore` đã sẵn `key.properties`, `**/*.jks`, `**/*.keystore` —
nên file `.jks` trong `android/signing/` và `key.properties` **tự động bị
ignore**. Để chắc chắn ignore cả thư mục (kể cả file khác lỡ để trong đó), thêm
1 dòng vào `android/.gitignore`:

```gitignore
/signing/
```

Xác nhận trước khi commit (không được hiện file nào):

```bash
git status --porcelain android/signing android/key.properties
git check-ignore android/signing/flutter_base_upload.jks android/key.properties
```

> Lưu ý: keystore bị ignore nên CI (GitHub Actions) sẽ KHÔNG có file này. Trên
> CI phải nạp keystore qua secret base64 (xem Phần C). Tuyệt đối không
> `git add -f` file `.jks`.

### A3. Đấu signing config vào Gradle

Sửa `android/app/build.gradle.kts`. Thêm phần đọc `key.properties` ở **đầu file**
(trước block `android {}`):

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Trong block `android {}` thêm `signingConfigs` và sửa `buildTypes.release`:

```kotlin
android {
    // ... namespace, compileSdk, defaultConfig, flavors giữ nguyên ...

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Dùng release key nếu có key.properties, ngược lại fallback debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
```

Phần gitignore đã xử lý ở A2b.

### A4. Google Play service account (config mới — cho lane deploy Play)

Bỏ qua phần này nếu chưa cần upload lên Play Store.

1. Play Console → **Setup → API access** → link tới Google Cloud project.
2. **Create new service account** → mở Google Cloud Console → tạo service
   account → tạo **JSON key** → tải về (ví dụ `play-store.json`).
3. Về Play Console → **Users and permissions** → Invite service account email →
   cấp quyền **Release** (Admin cho app tương ứng).
4. Lưu file JSON ngoài repo, trỏ tới nó bằng env `PLAY_STORE_JSON_KEY`.

Kiểm tra key hợp lệ:

```bash
cd android
PLAY_STORE_JSON_KEY=/path/play-store.json \
  fastlane run validate_play_store_json_key
```

### A5. Firebase App Distribution (config mới — cho lane test dev/uat)

1. [Firebase Console](https://console.firebase.google.com) → chọn project của
   flavor (dev/uat/prod) → thêm **Android app** với package đúng
   (`com.fox.base.flutter.dev` cho dev, v.v.).
2. Vào **Release & Monitor → App Distribution** → enable.
3. Lấy **App ID** (dạng `1:1234567890:android:abcdef...`) trong Project Settings →
   General → Your apps. Mỗi flavor một App ID.
4. Tạo service account để CI upload: Project Settings → **Service accounts** →
   Generate new private key → JSON. Trỏ bằng env `FIREBASE_SERVICE_CREDENTIALS`.
5. Tạo tester group tên `testers` (hoặc tùy) trong App Distribution.

### A6. Appfile

Ghi đè `android/fastlane/Appfile`:

```ruby
# android/fastlane/Appfile
json_key_file(ENV["PLAY_STORE_JSON_KEY"] || "fastlane/play-store.json")
package_name("com.fox.base.flutter")
```

### A7. Fastfile

Ghi đè `android/fastlane/Fastfile`:

```ruby
# android/fastlane/Fastfile
# Flavor-aware lanes for Flutter Base (dev / uat / prod).
# Flutter builds run from the project root; fastlane runs from android/.

default_platform(:android)

# Absolute path to the Flutter project root (one level above android/).
PROJECT_ROOT = File.expand_path("../..", __dir__)

# Firebase App Distribution app ids, one per flavor (from env).
FIREBASE_APP_IDS = {
  "dev"  => ENV["FIREBASE_ANDROID_APP_ID_DEV"],
  "uat"  => ENV["FIREBASE_ANDROID_APP_ID_UAT"],
  "prod" => ENV["FIREBASE_ANDROID_APP_ID_PROD"],
}.freeze

platform :android do
  # HELPERS

  # Run a flutter command from the project root, fail the lane on error.
  def flutter(args)
    Dir.chdir(PROJECT_ROOT) { sh("flutter #{args}") }
  end

  def validate_flavor(flavor)
    unless %w[dev uat prod].include?(flavor)
      UI.user_error!("Unknown flavor '#{flavor}'. Use dev | uat | prod.")
    end
    flavor
  end

  # BUILD

  desc "Build an artifact. Params: flavor:dev|uat|prod format:apk|aab"
  lane :build do |options|
    flavor = validate_flavor(options[:flavor] || "dev")
    format = options[:format] || "apk"
    UI.user_error!("format must be apk or aab") unless %w[apk aab].include?(format)

    flutter("pub get")
    flutter("pub run build_runner build --delete-conflicting-outputs")

    target = "lib/main_#{flavor}.dart"
    if format == "aab"
      flutter("build appbundle --flavor #{flavor} -t #{target} --release")
    else
      flutter("build apk --flavor #{flavor} -t #{target} --release")
    end
    UI.success("Built #{flavor} #{format}.")
  end

  # FIREBASE APP DISTRIBUTION

  desc "Build + upload to Firebase App Distribution. Params: flavor:dev|uat|prod"
  lane :firebase do |options|
    flavor = validate_flavor(options[:flavor] || "dev")
    app_id = FIREBASE_APP_IDS[flavor]
    if app_id.to_s.empty?
      UI.user_error!("Missing FIREBASE_ANDROID_APP_ID_#{flavor.upcase}.")
    end

    build(flavor: flavor, format: "apk")

    apk = File.join(PROJECT_ROOT, "build/app/outputs/flutter-apk",
                    "app-#{flavor}-release.apk")

    firebase_app_distribution(
      app: app_id,
      apk_path: apk,
      groups: ENV["FIREBASE_TESTER_GROUPS"] || "testers",
      release_notes: options[:notes] || "Automated #{flavor} build.",
      service_credentials_file: ENV["FIREBASE_SERVICE_CREDENTIALS"]
    )
    UI.success("Uploaded #{flavor} APK to Firebase App Distribution.")
  end

  # GOOGLE PLAY

  desc "Build prod aab + upload Play. Params: track:internal|beta|production"
  lane :playstore do |options|
    track = options[:track] || "internal"
    build(flavor: "prod", format: "aab")

    aab = File.join(PROJECT_ROOT, "build/app/outputs/bundle/prodRelease",
                    "app-prod-release.aab")

    upload_to_play_store(
      track: track,
      aab: aab,
      skip_upload_apk: true,
      release_status: options[:status] || "draft"
    )
    UI.success("Uploaded prod bundle to Play (#{track}).")
  end

  # SHORTCUTS
  desc "Build dev APK";  lane(:build_dev)  { build(flavor: "dev",  format: "apk") }
  desc "Build uat APK";  lane(:build_uat)  { build(flavor: "uat",  format: "apk") }
  desc "Build prod AAB"; lane(:build_prod) { build(flavor: "prod", format: "aab") }
end
```

### A8. Chạy thử Android

```bash
cd android

# Chỉ build
bundle exec fastlane build flavor:dev format:apk

# Upload Firebase (cần env)
FIREBASE_ANDROID_APP_ID_DEV=1:xxx:android:yyy \
FIREBASE_SERVICE_CREDENTIALS=/path/firebase-sa.json \
  bundle exec fastlane firebase flavor:dev

# Upload Play internal
PLAY_STORE_JSON_KEY=/path/play-store.json \
  bundle exec fastlane playstore track:internal
```

---

## Phần B — iOS (chạy trên macOS)

### B1. Khởi tạo

Giống Android — tạo file tay, không dùng `fastlane init` (dính bug UTF-8):

```bash
cd ios
mkdir -p fastlane
touch Gemfile fastlane/Appfile fastlane/Fastfile fastlane/Pluginfile
```

Nội dung `ios/Gemfile`:

```ruby
# ios/Gemfile
source "https://rubygems.org"
gem "fastlane"
plugins_path = File.join(File.dirname(__FILE__), "fastlane", "Pluginfile")
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

Nội dung `ios/fastlane/Pluginfile`:

```ruby
# ios/fastlane/Pluginfile
gem "fastlane-plugin-firebase_app_distribution"
```

Rồi cài:

```bash
cd ios
bundle install
```

> Dán `Appfile` (B4) và `Fastfile` (B5) vào các file tương ứng. Nếu vẫn muốn
> chạy `fastlane init` / `add_plugin`, set `LC_ALL=en_US.UTF-8` và
> `LANG=en_US.UTF-8` trước (xem A1).

### B2. App Store Connect API key (config mới — cho TestFlight/App Store)

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access →
   Integrations → App Store Connect API** → tạo key role **App Manager**.
2. Tải file `AuthKey_XXXXXX.p8` (chỉ tải được 1 lần). Ghi lại **Key ID** và
   **Issuer ID**.
3. Lưu ngoài repo. Sẽ dùng qua env: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`.

### B3. Code signing

Hai lựa chọn:

- **match** (khuyến nghị cho team/CI): lưu cert + provisioning profile mã hóa
  trong 1 git repo riêng.
  ```bash
  cd ios
  fastlane match init          # nhập URL git repo lưu cert
  fastlane match appstore      # tạo cert + profile cho distribution
  ```
- **Manual**: tạo cert + provisioning profile thủ công trong Apple Developer
  portal, tải về, dùng `update_code_signing_settings` trong Fastfile.

Vì có 3 bundle id (dev/uat/prod), nếu dùng match hãy chạy `match appstore` cho cả
3 app id, hoặc dùng wildcard profile.

### B4. Appfile

```ruby
# ios/fastlane/Appfile
app_identifier(ENV["IOS_BUNDLE_ID"] || "com.fox.base.flutter")
apple_id(ENV["APPLE_ID"])       # email tài khoản Apple Developer
team_id("GH2PAB3V62")
```

### B5. Fastfile

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

PROJECT_ROOT = File.expand_path("../..", __dir__)

# Per-flavor mapping: scheme, build config, bundle id, firebase app id.
FLAVORS = {
  "dev" => {
    scheme: "dev", config: "Release-dev",
    bundle: "com.fox.base.flutter.dev",
    firebase: ENV["FIREBASE_IOS_APP_ID_DEV"],
  },
  "uat" => {
    scheme: "uat", config: "Release-uat",
    bundle: "com.fox.base.flutter.uat",
    firebase: ENV["FIREBASE_IOS_APP_ID_UAT"],
  },
  "prod" => {
    scheme: "prod", config: "Release-prod",
    bundle: "com.fox.base.flutter",
    firebase: ENV["FIREBASE_IOS_APP_ID_PROD"],
  },
}.freeze

platform :ios do
  def flutter(args)
    Dir.chdir(PROJECT_ROOT) { sh("flutter #{args}") }
  end

  def flavor_config(name)
    cfg = FLAVORS[name]
    UI.user_error!("Unknown flavor '#{name}'.") unless cfg
    cfg
  end

  # Load the App Store Connect API key from env (used by TestFlight/App Store).
  def load_asc_api_key
    app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"]
    )
  end

  # BUILD (produces an .ipa)
  desc "Build IPA. Params: flavor:dev|uat|prod"
  lane :build do |options|
    cfg = flavor_config(options[:flavor] || "dev")

    # Precompile Flutter for iOS (no codesign; fastlane handles signing).
    flutter("pub get")
    flutter("build ios --flavor #{options[:flavor] || "dev"} " \
            "-t lib/main_#{options[:flavor] || "dev"}.dart --release --no-codesign")

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: cfg[:scheme],
      configuration: cfg[:config],
      export_method: options[:export_method] || "app-store",
      output_directory: File.join(PROJECT_ROOT, "build/ios/ipa"),
      export_options: {
        provisioningProfiles: {
          cfg[:bundle] => ENV["IOS_PROVISIONING_PROFILE"] || ""
        }
      }
    )
    UI.success("Built #{options[:flavor]} IPA.")
  end

  # FIREBASE APP DISTRIBUTION
  desc "Build + upload IPA to Firebase App Distribution. Params: flavor:..."
  lane :firebase do |options|
    flavor = options[:flavor] || "dev"
    cfg = flavor_config(flavor)
    UI.user_error!("Missing FIREBASE_IOS_APP_ID_#{flavor.upcase}.") if cfg[:firebase].to_s.empty?

    build(flavor: flavor, export_method: "ad-hoc")

    firebase_app_distribution(
      app: cfg[:firebase],
      ipa_path: Dir[File.join(PROJECT_ROOT, "build/ios/ipa/*.ipa")].first,
      groups: ENV["FIREBASE_TESTER_GROUPS"] || "testers",
      release_notes: options[:notes] || "Automated #{flavor} build.",
      service_credentials_file: ENV["FIREBASE_SERVICE_CREDENTIALS"]
    )
    UI.success("Uploaded #{flavor} IPA to Firebase.")
  end

  # TESTFLIGHT (prod)
  desc "Build prod + upload to TestFlight"
  lane :beta do
    load_asc_api_key
    build(flavor: "prod", export_method: "app-store")
    upload_to_testflight(
      ipa: Dir[File.join(PROJECT_ROOT, "build/ios/ipa/*.ipa")].first,
      skip_waiting_for_build_processing: true
    )
    UI.success("Uploaded prod to TestFlight.")
  end
end
```

> Lưu ý: build iOS theo flavor với fastlane hơi nhạy về provisioning profile.
> Nếu dùng match, thay block `export_options` bằng `sync_code_signing` / `match`
> trước `build_app` và bỏ `provisioningProfiles` thủ công.

### B6. Chạy thử iOS

```bash
cd ios
bundle exec fastlane build flavor:dev export_method:ad-hoc
IOS_BUNDLE_ID=com.fox.base.flutter bundle exec fastlane beta
```

---

## Phần C — GitHub Actions CI

### C1. Secrets cần tạo (Settings → Secrets and variables → Actions)

| Secret | Dùng cho |
|--------|----------|
| `PLAY_STORE_JSON_KEY_BASE64` | Play service account JSON (base64) |
| `ANDROID_KEYSTORE_BASE64` | keystore `.jks` (base64) |
| `ANDROID_KEY_PROPERTIES` | nội dung `key.properties` |
| `FIREBASE_SERVICE_CREDENTIALS_BASE64` | Firebase SA JSON (base64) |
| `FIREBASE_ANDROID_APP_ID_DEV/UAT/PROD` | App ID Android theo flavor |
| `FIREBASE_IOS_APP_ID_DEV/UAT/PROD` | App ID iOS theo flavor |
| `ASC_KEY_ID`, `ASC_ISSUER_ID` | App Store Connect API |
| `ASC_KEY_P8_BASE64` | file `.p8` (base64) |
| `MATCH_PASSWORD`, `MATCH_GIT_URL` | nếu dùng match |

Tạo base64: `base64 -i file.jks | pbcopy` (macOS).

### C2. Android workflow

`.github/workflows/android_release.yml`:

```yaml
name: Android Release

on:
  workflow_dispatch:
    inputs:
      flavor:
        description: "Flavor"
        type: choice
        options: [dev, uat, prod]
        default: dev
      target:
        description: "firebase | playstore | build"
        type: choice
        options: [firebase, playstore, build]
        default: firebase

jobs:
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.2"
          bundler-cache: true
          working-directory: android

      - name: Restore secrets
        working-directory: android
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > upload.jks
          echo "${{ secrets.ANDROID_KEY_PROPERTIES }}" > key.properties
          echo "storeFile=$(pwd)/upload.jks" >> key.properties
          echo "${{ secrets.PLAY_STORE_JSON_KEY_BASE64 }}" | base64 -d > play-store.json
          echo "${{ secrets.FIREBASE_SERVICE_CREDENTIALS_BASE64 }}" | base64 -d > firebase-sa.json

      - name: flutter pub get
        run: flutter pub get

      - name: Run fastlane
        working-directory: android
        env:
          PLAY_STORE_JSON_KEY: ${{ github.workspace }}/android/play-store.json
          FIREBASE_SERVICE_CREDENTIALS: ${{ github.workspace }}/android/firebase-sa.json
          FIREBASE_ANDROID_APP_ID_DEV: ${{ secrets.FIREBASE_ANDROID_APP_ID_DEV }}
          FIREBASE_ANDROID_APP_ID_UAT: ${{ secrets.FIREBASE_ANDROID_APP_ID_UAT }}
          FIREBASE_ANDROID_APP_ID_PROD: ${{ secrets.FIREBASE_ANDROID_APP_ID_PROD }}
        run: |
          case "${{ inputs.target }}" in
            firebase)  bundle exec fastlane firebase flavor:${{ inputs.flavor }} ;;
            playstore) bundle exec fastlane playstore track:internal ;;
            build)     bundle exec fastlane build flavor:${{ inputs.flavor }} format:apk ;;
          esac
```

### C3. iOS workflow

`.github/workflows/ios_release.yml`:

```yaml
name: iOS Release

on:
  workflow_dispatch:
    inputs:
      flavor:
        type: choice
        options: [dev, uat, prod]
        default: dev
      target:
        type: choice
        options: [firebase, beta]
        default: firebase

jobs:
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.2"
          bundler-cache: true
          working-directory: ios

      - name: Restore secrets
        working-directory: ios
        run: |
          echo "${{ secrets.ASC_KEY_P8_BASE64 }}" | base64 -d > asc_key.p8
          echo "${{ secrets.FIREBASE_SERVICE_CREDENTIALS_BASE64 }}" | base64 -d > firebase-sa.json

      - name: flutter pub get
        run: flutter pub get

      - name: Run fastlane
        working-directory: ios
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          ASC_KEY_PATH: ${{ github.workspace }}/ios/asc_key.p8
          APPLE_ID: ${{ secrets.APPLE_ID }}
          FIREBASE_SERVICE_CREDENTIALS: ${{ github.workspace }}/ios/firebase-sa.json
          FIREBASE_IOS_APP_ID_DEV: ${{ secrets.FIREBASE_IOS_APP_ID_DEV }}
          FIREBASE_IOS_APP_ID_UAT: ${{ secrets.FIREBASE_IOS_APP_ID_UAT }}
          FIREBASE_IOS_APP_ID_PROD: ${{ secrets.FIREBASE_IOS_APP_ID_PROD }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: |
          case "${{ inputs.target }}" in
            firebase) bundle exec fastlane firebase flavor:${{ inputs.flavor }} ;;
            beta)     bundle exec fastlane beta ;;
          esac
```

---

## Phần D — Checklist secrets & .gitignore

Thêm vào `.gitignore` ở **root** repo:

```gitignore
# fastlane
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots/**/*.png
**/fastlane/test_output

# secrets — KHÔNG commit
android/key.properties
android/**/*.jks
android/**/*.keystore
android/fastlane/play-store.json
**/firebase-sa.json
ios/**/AuthKey_*.p8
ios/asc_key.p8
```

File **được** commit: `Gemfile`, `Gemfile.lock`, `Appfile`, `Fastfile`,
`Pluginfile`, các workflow `.yml`.

File **không** commit: keystore, `key.properties`, mọi file JSON service
account, `.p8`, `GoogleService-Info.plist`, `google-services.json`.

### Thứ tự triển khai đề xuất

1. Phần 0 — cài môi trường.
2. A1–A3 — fastlane Android + keystore + Gradle → test lane `build`.
3. A4–A8 — Firebase / Play → test lane `firebase`, `playstore`.
4. B — iOS (trên máy Mac).
5. C — CI (chạy tay `workflow_dispatch` từng target trước khi gắn trigger tự động).
6. D — rà lại `.gitignore`, đảm bảo không lộ secret trước khi push.
```
