# Permissions Reference

Full reference for all `Permission.*` values from the [`permission_handler`](https://pub.dev/packages/permission_handler) package.

Each entry documents: what it does, which platforms support it, minimum API level, required manifest/plist entries, and practical notes.

---

## CALENDAR

### `Permission.calendar` ⚠️ DEPRECATED
- **Deprecated since** `permission_handler` v11 — split into `calendarWriteOnly` and `calendarFullAccess` to align with iOS 17.
- Use `calendarWriteOnly` or `calendarFullAccess` instead.

### `Permission.calendarWriteOnly`
- Create and modify events, but **cannot read** existing ones.
- **Android:** `READ_CALENDAR` + `WRITE_CALENDAR` (same as full access on Android — no write-only distinction at OS level)
- **iOS 17+:** `EKAuthorizationStatusWriteOnly`
- **iOS 16 and below:** identical to `calendarFullAccess`
- **Use case:** Adding reminders/appointments without exposing the user's existing schedule.

### `Permission.calendarFullAccess`
- Full read and write access to the device calendar.
- **Android:** `READ_CALENDAR` + `WRITE_CALENDAR`
- **iOS:** `EKEventStore` full authorization
- **Use case:** Calendar sync, scheduling apps, event management.

---

## CAMERA

### `Permission.camera`
- Access to front and rear cameras.
- **Android:** `android.permission.CAMERA`
- **iOS:** `NSCameraUsageDescription` (Privacy - Camera Usage Description)
- **Use cases:** Taking photos/videos, QR & barcode scanning, video calls, AR features.
- **iOS Info.plist:**
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Used to take photos and scan QR codes.</string>
  ```

---

## CONTACTS

### `Permission.contacts`
- Read and write access to the device address book.
- **Android:** `READ_CONTACTS`, `WRITE_CONTACTS`, `GET_ACCOUNTS`
- **iOS:** `CNContactStore` (AddressBook)
- **Use cases:** Auto-fill contact info, phonebook sync, sharing content with contacts.
- **iOS Info.plist:**
  ```xml
  <key>NSContactsUsageDescription</key>
  <string>Used to find and sync your contacts.</string>
  ```

---

## LOCATION

### `Permission.locationWhenInUse`
- Precise and approximate location **while the app is in the foreground only**.
- **Android:** `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
- **iOS:** `CoreLocation` — `kCLAuthorizationStatusAuthorizedWhenInUse`
- **Use cases:** Maps, directions, nearby search, location-based check-ins.
- **iOS Info.plist:**
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Used to show your location on the map.</string>
  ```

### `Permission.locationAlways`
- Location access **at all times**, including background.
- **Android 10+ (API 29+):** `ACCESS_BACKGROUND_LOCATION`
  > ⚠️ On Android 10+, the user must first grant foreground location (`locationWhenInUse`). Requesting `locationAlways` afterwards will show an additional dialog or open the location settings page for the user to manually select "Allow all the time".
- **Android below API 29:** `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
- **iOS:** `CoreLocation` — `kCLAuthorizationStatusAuthorizedAlways`
- **Use cases:** Geofencing, live delivery tracking, fitness tracking that continues in background.
- **iOS Info.plist:**
  ```xml
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Used to track your route in the background.</string>
  ```

### `Permission.location`
- Convenience permission that covers both `locationWhenInUse` and `locationAlways` in one request.
- **Android:** `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
- **iOS:** Requests both WhenInUse and Always authorization.
- **Use case:** When the exact access level will be determined at runtime based on user choice.

---

## MEDIA — AUDIO / VIDEO / PHOTOS

> **Android media permission strategy by API level:**
>
> | API level | Images | Video | Audio |
> |---|---|---|---|
> | < 29 (Android 9-) | `READ_EXTERNAL_STORAGE` | `READ_EXTERNAL_STORAGE` | `READ_EXTERNAL_STORAGE` |
> | 29–32 (Android 10–12) | `READ_EXTERNAL_STORAGE` | `READ_EXTERNAL_STORAGE` | `READ_EXTERNAL_STORAGE` |
> | 33+ (Android 13+) | `READ_MEDIA_IMAGES` | `READ_MEDIA_VIDEO` | `READ_MEDIA_AUDIO` |
>
> Recommended runtime check:
> ```dart
> final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
> final permission = sdk >= 33 ? Permission.photos : Permission.storage;
> ```

### `Permission.audio`
- Access to audio files on external storage.
- **Android 13+ (API 33+):** `READ_MEDIA_AUDIO` — replaces `storage` for audio files.
- **Android below 13:** Use `Permission.storage` instead.
- **iOS:** Not applicable.
- **AndroidManifest.xml:**
  ```xml
  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
  ```
- **Use cases:** Audio file picker, music player, podcast app, ringtone selector.

### `Permission.videos`
- Access to video files on external storage.
- **Android 13+ (API 33+):** `READ_MEDIA_VIDEO` — replaces `storage` for video files.
- **Android below 13:** Use `Permission.storage` instead.
- **iOS:** Not applicable.
- **AndroidManifest.xml:**
  ```xml
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
  ```
- **Use cases:** Video file picker, media player, video editor.

### `Permission.photos`
- Read and write access to the device photo library.
- **Android 13+ (API 33+):** `READ_MEDIA_IMAGES`
- **Android 12 and below (API 32-):** `READ_EXTERNAL_STORAGE`
- **iOS 14+:** `PHPhotoLibrary` — read & write access level
- **Use cases:** Image picker, profile photo upload, photo editor.
- **iOS Info.plist:**
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Used to select photos from your library.</string>
  ```

### `Permission.photosAddOnly`
- **iOS only** — Save images to the photo library **without** read access to existing photos.
- **iOS 14+:** `PHPhotoLibrary` — addOnly access level
- **Android:** Not applicable — use `Permission.photos` or `Permission.storage`.
- **Use case:** Saving generated or edited images to the gallery when the app has no need to browse existing photos.
- **iOS Info.plist:**
  ```xml
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>Used to save photos to your library.</string>
  ```

### `Permission.mediaLibrary`
- **iOS only** — Access to the device media library (Apple Music, iTunes).
- **iOS 9.3+:** `MPMediaLibrary`
- **Android:** Not applicable.
- **Use case:** Reading the user's Apple Music / iTunes library, building a music player that integrates with the native library.
- **iOS Info.plist:**
  ```xml
  <key>NSAppleMusicUsageDescription</key>
  <string>Used to access your music library.</string>
  ```

### `Permission.accessMediaLocation`
- Access to GPS location metadata (EXIF tags) embedded in photos and videos.
- **Android 10+ (API 29+):** `ACCESS_MEDIA_LOCATION`
- **iOS:** Not applicable — location metadata is already accessible alongside `Permission.photos`.
- **AndroidManifest.xml:**
  ```xml
  <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
  ```
- **Use cases:** Displaying a map of where photos were taken, geotagging features, photo location export.

---

## MICROPHONE

### `Permission.microphone`
- Access to the device microphone for audio input/recording.
- **Android:** `android.permission.RECORD_AUDIO`
- **iOS:** `AVAudioSession`
- **Use cases:** Voice messages, video recording with audio, voice-to-text, VoIP calls.
- **iOS Info.plist:**
  ```xml
  <key>NSMicrophoneUsageDescription</key>
  <string>Used to record audio for voice messages.</string>
  ```

---

## SPEECH

### `Permission.speech`
- Access to the device's speech recognition engine.
- **Android:** Requests `RECORD_AUDIO` — functionally identical to `Permission.microphone` on Android.
- **iOS:** `SFSpeechRecognizer` — a **separate** permission from microphone.
  > ⚠️ On iOS, you need **both** `Permission.speech` and `Permission.microphone` for voice input.
- **Use cases:** Voice search, voice commands, live transcription.
- **iOS Info.plist:**
  ```xml
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>Used to convert your speech to text.</string>
  ```

---

## STORAGE (legacy)

### `Permission.storage`
- General read/write access to external storage.
- **Android below 13 (API 32-):** `READ_EXTERNAL_STORAGE` + `WRITE_EXTERNAL_STORAGE`
- **Android 13+ (API 33+):** ⚠️ **DEPRECATED** — always returns `PermissionStatus.denied`. Use `Permission.photos`, `Permission.videos`, `Permission.audio`, or `Permission.manageExternalStorage` instead.
- **iOS:** Access to `Documents`/`Downloads` folders — implicitly granted, no dialog shown.
- **Use case (legacy only):** File picker, download manager targeting Android < 13.

### `Permission.manageExternalStorage`
- Unrestricted access to **all files** on external storage, bypassing scoped storage.
- **Android 11+ (API 30+):** `MANAGE_EXTERNAL_STORAGE`
- **iOS:** Not applicable.
- > ⚠️ **Google Play warning:** Apps using this permission must submit a [Permission Declaration Form](https://support.google.com/googleplay/android-developer/answer/9214102). Only approved use cases (file managers, backup tools, antivirus apps) are allowed.
- When privacy-friendly APIs ([Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider) or [MediaStore](https://developer.android.com/training/data-storage/shared/media)) are sufficient, use those instead.
- **Use case:** File manager apps, backup tools, antivirus — not for general app use.

---

## NOTIFICATIONS

### `Permission.notification`
- Permission to display push notifications to the user.
- **Android 13+ (API 33+):** `POST_NOTIFICATIONS` — runtime permission, must be requested.
- **Android below 13:** Granted by default, no runtime dialog.
- **iOS:** `UNUserNotificationCenter` authorization — requests alert, sound, and badge.
- **Use cases:** FCM push notifications, local notifications, reminders.

### `Permission.criticalAlerts`
- **iOS only** — Send notifications that bypass Do Not Disturb and the ringer switch.
- > ⚠️ Requires an explicit entitlement approved by Apple. This is **not** available to general apps — you must apply and justify the use case to Apple.
- **Use cases:** Medical device alarms, life-safety alerts, emergency notifications.

### `Permission.accessNotificationPolicy`
- Modify the device's notification interruption policy (Do Not Disturb).
- **Android 6+ (API 23+):** `ACCESS_NOTIFICATION_POLICY`
- **iOS:** Not applicable.
- **Use case:** Apps that need to programmatically enable or disable Do Not Disturb mode (e.g., focus/productivity apps, alarm apps).

---

## BLUETOOTH

### `Permission.bluetooth`
- Access to the Bluetooth adapter state.
- **Android:** Always allowed — no runtime permission needed.
- **iOS 13+:** `CBCentralManager` authorization (`CBManagerAuthorization`)
- **iOS below 13:** Always allowed.
- > ⚠️ iOS 13.0 only: `bluetooth.status` always returns `denied` regardless of actual state. Call `bluetooth.request()` instead for the actual state.
- **iOS Info.plist:**
  ```xml
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>Used to connect to Bluetooth accessories.</string>
  ```

### `Permission.bluetoothScan`
- Scan for nearby Bluetooth Low Energy (BLE) devices.
- **Android 12+ (API 31+):** `BLUETOOTH_SCAN`
- **Android below 12:** Covered by `Permission.bluetooth` + location permissions.
- **iOS:** Covered by `Permission.bluetooth`.
- **Use cases:** BLE device discovery, IoT device pairing, proximity detection.

### `Permission.bluetoothAdvertise`
- Make this device discoverable to other Bluetooth devices.
- **Android 12+ (API 31+):** `BLUETOOTH_ADVERTISE`
- **iOS:** Covered by `Permission.bluetooth`.
- **Use cases:** BLE beacon functionality, peer-to-peer discovery.

### `Permission.bluetoothConnect`
- Communicate with already-paired Bluetooth devices.
- **Android 12+ (API 31+):** `BLUETOOTH_CONNECT`
- **iOS:** Covered by `Permission.bluetooth`.
- **Use cases:** Sending data to paired peripherals — headsets, smartwatches, printers, etc.

---

## NEARBY / WIFI

### `Permission.nearbyWifiDevices`
- Access to nearby Wi-Fi devices **without** needing location permission.
- **Android 13+ (API 33+):** `NEARBY_WIFI_DEVICES`
- **iOS:** Not applicable.
- **Use cases:** Wi-Fi Direct, peer-to-peer connections, Chromecast/AirPlay discovery, local network scanning.

---

## PHONE

### `Permission.phone`
- Access to phone state and telephony identity.
- **Android:** `READ_PHONE_STATE`, `CALL_PHONE`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `ADD_VOICEMAIL`, `USE_SIP`, `PROCESS_OUTGOING_CALLS`
- **iOS:** Not applicable.
- **Use cases:** Detecting/intercepting incoming calls, VoIP apps, reading device IMEI/phone number.

---

## SMS

### `Permission.sms`
- Read and send SMS and MMS messages.
- **Android:** `READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `RECEIVE_WAP_PUSH`, `RECEIVE_MMS`
- **iOS:** Not applicable.
- > ⚠️ **Google Play warning:** Restricted to SMS/call-screening apps and a small set of approved use cases. Requires manual approval before publishing.
- **Use cases:** OTP auto-read, SMS-based 2FA, SMS backup apps.

---

## SENSORS

### `Permission.sensors`
- Access to body sensors (heart rate monitor, step counter, etc.).
- **Android:** `BODY_SENSORS`
- **iOS:** `CoreMotion` (some sensors may additionally require HealthKit entitlement)
- **iOS Info.plist:**
  ```xml
  <key>NSMotionUsageDescription</key>
  <string>Used to track your physical activity.</string>
  ```
- **Use cases:** Health/fitness apps reading heart rate, step count, cadence.

### `Permission.sensorsAlways`
- Continuous access to body sensors **while the app is in the background**.
- **Android 13+ (API 33+):** `BODY_SENSORS_BACKGROUND`
- **iOS:** Not applicable — use HealthKit background delivery instead.
- **Use case:** Wearable companion apps that continuously sync health data in the background.

---

## ACTIVITY RECOGNITION

### `Permission.activityRecognition`
- Detect the user's physical activity (walking, running, cycling, driving, etc.).
- **Android 10+ (API 29+):** `ACTIVITY_RECOGNITION`
- **iOS:** `CMMotionActivityManager`
- **iOS Info.plist:**
  ```xml
  <key>NSMotionUsageDescription</key>
  <string>Used to detect your movement activity.</string>
  ```
- **Use cases:** Fitness tracking, auto-pause in running apps, trip detection.

---

## REMINDERS

### `Permission.reminders`
- **iOS only** — Read and write access to the iOS Reminders app.
- **iOS:** `EKEventStore` (reminders entity type)
- **Android:** Not applicable.
- **iOS Info.plist:**
  ```xml
  <key>NSRemindersUsageDescription</key>
  <string>Used to sync your reminders.</string>
  ```
- **Use case:** Reading or writing reminders from/to the native iOS Reminders app.

---

## SYSTEM / DEVICE MANAGEMENT

### `Permission.systemAlertWindow`
- Draw overlay windows on top of all other apps.
- **Android 6+ (API 23+):** `SYSTEM_ALERT_WINDOW`
- **iOS:** Not applicable.
- > ⚠️ This permission **cannot** be granted via a runtime dialog. Requesting it opens the device Settings page where the user must enable it manually.
- **Use cases:** Floating chat heads, PiP overlays, screen recorders, assistive tools.

### `Permission.requestInstallPackages`
- Install APK packages from sources outside the Play Store.
- **Android 8+ (API 26+):** `REQUEST_INSTALL_PACKAGES`
- **iOS:** Not applicable.
- **Use case:** In-app update mechanism that downloads and installs APKs directly (enterprise or sideloaded apps).

### `Permission.ignoreBatteryOptimizations`
- Exempt the app from Android's battery optimization (Doze mode) restrictions.
- **Android 6+ (API 23+):** `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
- **iOS:** Not applicable.
- > ⚠️ **Google Play warning:** Only approved for apps with a genuine need to run in the background continuously — VoIP, alarms, health monitoring. Requires justification in the store listing.
- **Use case:** Preventing the OS from killing long-running background tasks (VoIP, real-time sync, alarm apps).

### `Permission.scheduleExactAlarm`
- Schedule alarms that fire at a precise time, even in battery-saving modes.
- **Android 12+ (API 31+):** `SCHEDULE_EXACT_ALARM`
- **Android 13+ (API 33+):** `USE_EXACT_ALARM` (automatically granted, no dialog)
- **iOS:** Not applicable.
- **Use cases:** Alarm clock apps, calendar event reminders, time-critical task schedulers.

---

## PRIVACY / TRACKING

### `Permission.appTrackingTransparency`
- **iOS 14+ only** — Permission to track the user across apps and websites owned by other companies (IDFA access).
- **iOS:** `ATTrackingManager` — shows the App Tracking Transparency dialog.
- **Android:** Not applicable — use in-app consent dialogs as required by GDPR/privacy laws.
- **iOS Info.plist:**
  ```xml
  <key>NSUserTrackingUsageDescription</key>
  <string>Used to deliver personalized ads and measure ad effectiveness.</string>
  ```
- **Use cases:** Advertising SDKs that rely on IDFA (Meta Audience Network, Google Ads, etc.).

---

## ASSISTANT / SIRI

### `Permission.assistant`
- **iOS only** — Integrate with the Siri voice assistant via SiriKit.
- **iOS:** `INPreferences.requestSiriAuthorization`
- **Android:** Not applicable.
- **iOS Info.plist:**
  ```xml
  <key>NSSiriUsageDescription</key>
  <string>Used to let you control the app with Siri.</string>
  ```
- **Use cases:** Siri Shortcuts, voice-driven actions, Siri domain integrations.

---

## BACKGROUND REFRESH

### `Permission.backgroundRefresh`
- **iOS only** — Read the current background app refresh authorization status.
- **iOS:** `UIApplication.shared.backgroundRefreshStatus`
- **Android:** Not applicable.
- > ℹ️ This is **read-only** — the value can only be changed by the user in **Settings → General → Background App Refresh**. You cannot request or prompt for it programmatically.
- **Use case:** Checking whether background refresh is enabled before relying on silent push or background fetch. Inform the user to enable it in Settings if it's off.

---

## UNKNOWN

### `Permission.unknown`
- Sentinel value returned when the permission type cannot be determined.
- **Never request this directly.**
