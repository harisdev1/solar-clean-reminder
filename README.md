# Solar Clean Reminder

Flutter + FlutterFire: panel cleaning reminders with **email/password**, **Google Sign-In**, Firestore, and local alarms.

| | |
|--|--|
| Package | `com.haris.solar_clean` |
| Firebase | [`solar-clean-app`](https://console.firebase.google.com/project/solar-clean-app/overview) (**Spark / free**) |
| Android App ID | `1:668072490463:android:04dfad192ab9b981f4806a` |

## Run on your phone (USB)

```powershell
cd c:\Users\QBS\Downloads\solar_clean\solar_clean
# If missing: copy examples or run FlutterFire (see Secrets)
flutter pub get
flutter run
```

## Secrets (do not commit)

| File | Commit? |
|------|---------|
| `android/upload-keystore.jks` | **No** |
| `android/key.properties` | **No** (copy from `key.properties.example`) |
| `android/app/google-services.json` | **No** (example only in repo) |
| `lib/firebase_options.dart` | **No** (example only in repo) |

### If GitHub flagged the Firebase API key

1. [Google Cloud → Credentials](https://console.cloud.google.com/apis/credentials?project=solar-clean-app) — **delete/rotate** the exposed Android API key.
2. Restrict the new key to Android package `com.haris.solar_clean` + your debug/release SHA-1.
3. Regenerate local config:

```powershell
flutterfire configure --project=solar-clean-app --platforms=android
```

Or download `google-services.json` from Firebase Console into `android/app/`, then run FlutterFire so `lib/firebase_options.dart` matches.

Never put keystore passwords or real API keys in git or chat.

## Features

- Auth (email / Google), setup wizard, home countdown, alarms
- Language: English + Roman Urdu (Auth + Settings)
- Appearance: light / dark / system, accent themes, fonts
- Settings: interval, alarm time, test alarm, permissions, logout

## Layout

```
lib/main.dart
lib/app.dart
lib/core/          # strings, keys, defaults, theme
lib/cubit/         # app + locale + appearance
lib/data/
lib/services/
lib/ui/
```
