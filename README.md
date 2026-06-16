# flutter_base

Flutter production boilerplate — BLoC/Cubit, GoRouter, Hive, Dio/Retrofit, Firebase (FlutterFire).

Based on [itachi1611/flutter_temp_bloc](https://github.com/itachi1611/flutter_temp_bloc).

## Installation

```sh
git clone <repo-url>
cd flutter_base
flutter pub get
flutter run --flavor dev
```

## Pub packages

| Package | Usage |
|---|---|
| [intl](https://pub.dev/packages/intl) | Multi language* |
| [intl_utils](https://pub.dev/packages/intl_utils) | Multi language utils* |
| [bloc](https://pub.dev/packages/bloc) | State management* |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | State management* |
| [equatable](https://pub.dev/packages/equatable) | Value equality for Cubit states* |
| [go_router](https://pub.dev/packages/go_router) | Declarative navigation |
| [hive](https://pub.dev/packages/hive) | Platform-independent local storage |
| [hive_generator](https://pub.dev/packages/hive_generator) | Hive adapter code generation |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Key-value persistent storage |
| [get_storage](https://pub.dev/packages/get_storage) | Fast key-value storage |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Network connectivity status |
| [dio](https://pub.dev/packages/dio) | HTTP client |
| [retrofit](https://pub.dev/packages/retrofit) | Type-safe REST API client |
| [retrofit_generator](https://pub.dev/packages/retrofit_generator) | Retrofit code generation |
| [pretty_dio_logger](https://pub.dev/packages/pretty_dio_logger) | Dio request/response logging |
| [google_fonts](https://pub.dev/packages/google_fonts) | Google Fonts (Lato) |
| [path_provider](https://pub.dev/packages/path_provider) | File system paths |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permission management |
| [url_launcher](https://pub.dev/packages/url_launcher) | Open URLs in browser |
| [another_flushbar](https://pub.dev/packages/another_flushbar) | In-app notification bar |
| [gap](https://pub.dev/packages/gap) | Spacing widget |
| [animations](https://pub.dev/packages/animations) | Pre-built page transitions |
| [lottie](https://pub.dev/packages/lottie) | Lottie animation player |
| [device_info_plus](https://pub.dev/packages/device_info_plus) | Device information |
| [package_info_plus](https://pub.dev/packages/package_info_plus) | App version and build info |
| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | Load `.env` config per flavor at runtime |
| [json_annotation](https://pub.dev/packages/json_annotation) | JSON serialization annotations |
| [json_serializable](https://pub.dev/packages/json_serializable) | JSON serialization code generation |
| [timezone](https://pub.dev/packages/timezone) | Timezone support |
| [logger](https://pub.dev/packages/logger) | Structured console logging |
| [build_runner](https://pub.dev/packages/build_runner) | Code generation runner |
| [flutter_lints](https://pub.dev/packages/flutter_lints) | Lint rules |

> \* Recommended to keep regardless of project

### Firebase (FlutterFire)

| Package | Usage |
|---|---|
| [firebase_core](https://pub.dev/packages/firebase_core) | Firebase core — required by all Firebase packages |
| [firebase_messaging](https://pub.dev/packages/firebase_messaging) | Push notifications (FCM) |
| [firebase_remote_config](https://pub.dev/packages/firebase_remote_config) | Remote feature flags and config |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Display FCM messages as local notifications |

## Flavors

The app supports three build flavors: `dev`, `uat`, `prod`. Always pass `--flavor` when running or building:

```sh
flutter run --flavor dev
flutter build apk --flavor prod --release
```

## Firebase setup

Project này dùng 3 flavor (`dev` / `uat` / `prod`), mỗi flavor tương ứng một Firebase project riêng.

### Bước 1 — Tạo Firebase projects

Vào [Firebase Console](https://console.firebase.google.com) và tạo 3 projects:

| Flavor | Suggested project name |
|---|---|
| dev | `flutter-base-dev` |
| uat | `flutter-base-uat` |
| prod | `flutter-base-prod` |

Với **mỗi project**, thêm hai app:
- **Android** — package name: `com.fox.base.flutter_base` (hoặc tên package bạn đã đổi)
- **iOS** — bundle ID: `com.fox.base.flutterBase`

> Bật **Cloud Messaging** và **Remote Config** trong từng project.

### Bước 2 — Cài Firebase CLI & đăng nhập

```sh
# Cài Firebase CLI (nếu chưa có)
npm install -g firebase-tools

# Đăng nhập
firebase login
```

### Bước 3 — Cài FlutterFire CLI

```sh
# Nếu dùng FVM
fvm dart pub global activate flutterfire_cli

# Nếu không dùng FVM
dart pub global activate flutterfire_cli
```

### Bước 4 — Configure từng flavor

Chạy lệnh sau 3 lần, thay `<project-id>` bằng ID thực tế trên Firebase Console:

```sh
# dev
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-dev \
  --out=lib/firebase/dev/firebase_options.dart \
  --platforms=android,ios

# uat
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-uat \
  --out=lib/firebase/uat/firebase_options.dart \
  --platforms=android,ios

# prod
fvm dart pub global run flutterfire_cli:flutterfire configure \
  --project=flutter-base-prod \
  --out=lib/firebase/prod/firebase_options.dart \
  --platforms=android,ios
```

> Nếu không dùng FVM, thay `fvm dart pub global run flutterfire_cli:flutterfire` bằng `flutterfire`.

Mỗi lần chạy sẽ sinh ra:
- `lib/firebase/{flavor}/firebase_options.dart`
- `android/app/google-services.json` ← **cần copy thủ công** (xem bước 5)
- `ios/Runner/GoogleService-Info.plist` ← **cần copy thủ công** (xem bước 5)

> `firebase_options.dart` được commit vào git. `google-services.json` và `GoogleService-Info.plist` đã được gitignore — **không commit**.

### Bước 5 — Đặt native config theo flavor

**Android** — copy file vào đúng thư mục src của từng flavor:

```
android/app/src/dev/google-services.json
android/app/src/uat/google-services.json
android/app/src/prod/google-services.json
```

**iOS** — copy vào thư mục con theo flavor (cần tạo thư mục nếu chưa có):

```
ios/config/dev/GoogleService-Info.plist
ios/config/uat/GoogleService-Info.plist
ios/config/prod/GoogleService-Info.plist
```

Sau đó thêm Run Script phase trong Xcode để copy đúng file theo build configuration:

```sh
# Xcode Build Phase → Run Script
cp "${PROJECT_DIR}/config/${FLUTTER_BUILD_MODE}/GoogleService-Info.plist" \
   "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
```

### Bước 6 — Cấu hình Android flavor trong build.gradle

Thêm vào `android/app/build.gradle.kts`:

```kotlin
android {
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("uat") {
            dimension = "env"
            applicationIdSuffix = ".uat"
            versionNameSuffix = "-uat"
        }
        create("prod") {
            dimension = "env"
        }
    }
}
```

### Bước 7 — Thêm Google Services plugin (Android)

`android/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

`android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### Kiểm tra

```sh
flutter pub get
flutter run --flavor dev
```

## Changing package name

```sh
# 1. Uncomment change_app_package_name in pubspec.yaml
# 2. Run:
flutter pub run change_app_package_name:main com.new.package.name
# 3. Re-comment the package
```

## iOS setup (Mac ARM)

```sh
sudo arch -x86_64 gem install ffi
sudo arch -x86_64 pod install
```
