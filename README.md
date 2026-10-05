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
flutter pub get
flutter run
```

## Secrets (do not commit)

| File | Commit? |
|------|---------|
| `android/upload-keystore.jks` | **No** |
| `android/key.properties` | **No** (copy from `key.properties.example`) |
| `android/app/google-services.json` | Yes (Firebase client config) |
| `lib/firebase_options.dart` | Yes |

Never put keystore passwords in git or chat. Firebase API keys in the app are client-restricted; no `.env` package is required.

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
