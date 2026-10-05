# Solar Clean Reminder — Flutter App Spec

> Goal: User solar panels dhona bhool jata hai. App specific din baad **notification + alarm** se yaad dilaye, aur user "clean kar raha hun / kal karunga / ho gaya" bol sake. UI: **Material 3 Expressive**, bade dialogs, smooth animations, acha splash.

---

## 1. Core Features

1. Firebase Auth (email/password signup + login, forgot password; optional Google Sign-In baad mein).
2. First-time setup: user batata hai
   - **Last clean kab hua / ya first clean kab plan hai** (date picker: aaj, kal, ya koi bhi date. Default = aaj).
   - **Cleaning interval** (default **20 days**, user change kar sake: 7–90).
   - **Reminder time** (default **10:00 PM**, user change kar sake).
3. Due date par **notification** + **alarm** (same time par).
4. Alarm/notification actions:
   - ✅ **Clean ho gaya** → cycle reset, next due = aaj + interval.
   - 🧽 **Abhi kar raha hun** → "In progress" state, 2 ghante baad confirm poochho.
   - ⏭️ **Kal kar dunga** → next day same time par shift.
5. Agar user ne kuch nahi kiya (dismiss/ignore) → **agle din same time par phir alarm**, jab tak "Clean ho gaya" na dabaye (escalation).
6. Home screen: next cleaning countdown, last cleaned, streak, history.
7. Settings: interval, time, alarm sound, vibration, notification-only mode, theme.

> ⚠️ **Open question (confirm kar lo):** tumne "20 days" aur "30 days" dono likha. Is spec mein: **interval default 20 days (editable)** aur due date par reminder. Agar 30 days alag cheez hai (e.g. 20 din par soft reminder, 30 din par urgent alarm) to Section 4 mein "Two-stage reminder" option enable kar dena.

---

## 2. Cleaning State Machine

```
SCHEDULED ──(due time)──► DUE ──(Clean ho gaya)──► CLEANED ──► SCHEDULED (next cycle)
                           │
                           ├─(Kal kar dunga)──► POSTPONED ──(next day due time)──► DUE
                           ├─(Abhi kar raha hun)──► IN_PROGRESS ──(confirm)──► CLEANED
                           └─(ignore / dismiss)──► OVERDUE ──(next day due time)──► DUE (repeat)
```

Rules:
- Har state change par **saare local alarms/notifications cancel + dobara schedule** hon (single source of truth).
- `overdueDays` count hota rahe → UI mein red/urgent tone, alarm louder pattern.
- Optional: 3 din overdue ke baad daily 2 reminders (morning 9 AM + user time).

---

## 3. Packages

| Kaam | Package |
|---|---|
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Local notifications | `flutter_local_notifications` |
| Timezone scheduling | `timezone`, `flutter_timezone` |
| Real alarm (ringing screen + sound) | `alarm` (Android + iOS) — ya Android-only ke liye `android_alarm_manager_plus` |
| Permissions | `permission_handler` |
| Boot / background reschedule | `workmanager` (backup), `RECEIVE_BOOT_COMPLETED` |
| State mgmt | `flutter_bloc` (Cubit) |
| DI | `get_it`, `injectable` |
| Navigation | `go_router` |
| Local cache | `shared_preferences` / `hive_ce` |
| Dynamic color | `dynamic_color` |
| Animations | `flutter_animate`, `lottie` / `rive`, `motor` (spring motion) |
| Fonts | `google_fonts` |
| Splash | `flutter_native_splash` |
| Date/format | `intl` |
| Haptics | built-in `HapticFeedback` |

> Versions pub.dev se latest lena. `motor` aur Expressive-style helpers ka status check kar lena — agar na milen to custom `SpringSimulation` use karo.

### notification vs alarm — fark
- **Notification** = status bar mein aati hai, easily miss ho jati hai.
- **Alarm** = exact time par sound + full-screen ringing UI. Yahi "bhool jate hain" problem solve karega.
- App dono schedule kare: **alarm primary**, notification backup (same time, alarm fail ho to).

---

## 4. Scheduling Strategy

### 4.1 Default calculation
```
firstDue   = startDate (user ne pick ki) at reminderTime
nextDue    = lastCleanedAt + intervalDays at reminderTime
```
- Agar user ne "aaj" select kiya aur reminderTime guzar chuka ho → next day same time.
- Agar user "pehli safai kab plan hai" select kare (future date) → wohi `firstDue`.

### 4.2 Two-stage reminder (optional)
- Stage 1: `interval - 2 days` par soft notification ("2 din baad panels dhone hain").
- Stage 2: due day par alarm.

### 4.3 Escalation
- Due par alarm ring → user ne action nahi liya → `OVERDUE`.
- Next day same time par dobara alarm (naya ID, `overdueDays++`).
- Alarm ringing screen mein snooze (10 min, max 2 baar) + "Kal kar dunga".

### 4.4 Reschedule triggers
- App start, login, settings change, state change.
- Device reboot (boot receiver / workmanager).
- Timezone change.
- Firestore se data sync ke baad (agar doosre device se change hua).

### 4.5 ID scheme
```
alarmId        = 1000 + cycleIndex
notificationId = 2000 + cycleIndex
softReminderId = 3000 + cycleIndex
```
Predictable IDs rakho taake cancel aasan ho.

---

## 5. Platform Setup

### Android
Permissions (`AndroidManifest.xml`):
- `POST_NOTIFICATIONS` (Android 13+, runtime request)
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` (Android 12+/14 — Play policy check karo; alarm-clock type app ko `USE_EXACT_ALARM` mil sakta hai)
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`, `WAKE_LOCK`
- `USE_FULL_SCREEN_INTENT` (lock screen par ringing screen)
- `FOREGROUND_SERVICE` (alarm package ke liye)

Aur:
- Battery optimization / OEM autostart (Xiaomi, Oppo, Vivo, Samsung) — onboarding mein guide dialog: "Alarm reliably bajne ke liye battery restriction off karo".
- Notification channel: `solar_alarm` (high importance), `solar_soft` (default).

### iOS
- True alarm API nahi hota. Options: `alarm` package (background audio trick, limited), ya **time-sensitive notification** + chain of repeating notifications (e.g. 10 min gap par 5 notifications).
- Critical alerts ke liye Apple entitlement chahiye — shayad na mile.
- UI mein clearly bata do ke iOS par alarm "notification-style" hoga.

---

## 6. Firestore Data Model

```
users/{uid}
  email, displayName, createdAt

users/{uid}/settings/main
  intervalDays: 20
  reminderHour: 22
  reminderMinute: 0
  alarmEnabled: true
  notificationEnabled: true
  softReminderDays: 2
  timezone: "Asia/Karachi"

users/{uid}/cycle/current
  state: SCHEDULED | DUE | POSTPONED | IN_PROGRESS | OVERDUE
  lastCleanedAt: Timestamp?
  nextDueAt: Timestamp
  overdueDays: 0
  postponedCount: 0

users/{uid}/history/{id}
  cleanedAt, wasOverdueDays, note?
```

Security rules: user sirf apna `users/{uid}/**` read/write kare.
Offline: Firestore persistence on; scheduling **local data** se ho, network pe depend na kare.

---

## 7. Architecture (Clean Architecture)

```
lib/
 ├─ core/
 │   ├─ di/  theme/  router/  utils/  constants/
 │   └─ services/ (notification_service, alarm_service, permission_service)
 ├─ features/
 │   ├─ auth/        (data / domain / presentation)
 │   ├─ onboarding/  (permissions + setup wizard)
 │   ├─ schedule/    (cycle, scheduling use-cases)
 │   ├─ home/
 │   ├─ history/
 │   ├─ alarm_ring/  (full-screen ringing UI)
 │   └─ settings/
 └─ main.dart
```

Key use-cases: `SetupSchedule`, `MarkCleaned`, `PostponeOneDay`, `StartCleaning`, `RescheduleAll`, `HandleOverdue`.
`AlarmService` interface rakho taake Android/iOS implementation alag ho sake.

---

## 8. Screens & Flow

1. **Splash** → auth check
2. **Welcome / Onboarding** (3 slides, illustrations)
3. **Login / Signup**
4. **Permission Wizard** (notification → exact alarm → battery optimization), har step par bada friendly dialog
5. **Setup Wizard**
   - Step 1: "Panels last kab saaf kiye?" → Aaj / Kal / Date chuno / Abhi tak nahi kiye
   - Step 2: Interval (slider + chips: 14 / 20 / 30)
   - Step 3: Reminder time (default 10:00 PM, big time picker)
   - Step 4: Summary + "Shuru karo"
6. **Home**
7. **Alarm Ring Screen** (full-screen)
8. **History**
9. **Settings**

---

## 9. UI / UX — Material 3 Expressive Focus

### 9.1 Design principles
- **Bade shapes**: cards radius 28–40, buttons fully rounded / squircle, dialogs radius 36+.
- **Bold typography**: display/headline large aur expressive weights; numbers (countdown) bohat bade.
- **Color**: `dynamic_color` + fallback seed (warm solar yellow/orange `#FFB300` + sky blue tertiary). Light + Dark dono.
- **Motion**: spring-based (bouncy but short), shape morphing, container transform.
- **Haptics**: har major action par `selectionClick` / `mediumImpact`.
- **Large touch targets** (min 56dp), kam text, zyada visuals.

> Flutter mein Material 3 Expressive ke saare components abhi built-in nahi hain. Approach: `useMaterial3: true` + **custom expressive components** (shape morphing buttons, big FAB, wavy/thick progress, large segmented controls). Component list niche.

### 9.2 Home screen
- Top: greeting + sun/panel animated header (sun halo slowly pulsing, panel shine sweep).
- Centre: **huge countdown card** — "**12** din baaki" (number spring animation on change).
  - Colors by state: green (safe) → amber (due soon, ≤3 days) → red (overdue).
- Circular/wavy progress ring cycle ke around.
- Info chips: Last cleaned, Next due, Reminder time.
- Primary big button: **"Clean ho gaya ✓"** (rounded, press = scale 0.96 + haptic, success confetti).
- Secondary: "Kal kar dunga", "Abhi kar raha hun".
- Bottom nav: expressive pill-shaped navigation bar (Home / History / Settings).

### 9.3 Dialogs (bade aur acche — chhote default Android wale nahi)
Sab dialogs **custom full-width bottom sheet ya large centered dialog**:
- Top par bada illustration/Lottie (80–120dp), phir title (headline), body, phir **stacked full-width buttons**.
- Enter animation: scale 0.9→1 + fade + slight slide, spring curve.
- Background blur / scrim 50%.
- Corner radius 36–40, drag handle (sheets).

Dialogs list:
| Dialog | Illustration | Buttons |
|---|---|---|
| Notification permission | bell Lottie | "Allow karo" / "Baad mein" |
| Exact alarm permission | alarm clock | "Settings kholo" / "Skip" |
| Battery optimization guide | battery | "Guide dekho" |
| Clean confirm | sparkling panel | "Haan, ho gaya" / "Cancel" |
| Postpone | calendar | "Kal same time" / "Time change karo" |
| In progress | bucket/sponge | "Theek hai" |
| Logout / delete account | warning | Destructive style button |
| Success (cleaned) | confetti + sun | "Shukriya!" |

### 9.4 Alarm Ring Screen
- Full-screen, gradient background (state color), bada pulsing sun/panel icon.
- Current time bohat bada, "Solar panels dhone ka time!" text.
- **Slide-to-act** controls ya 3 bade buttons: Clean ho gaya / Kal kar dunga / Snooze 10 min.
- Ripple waves animation peeche, vibration pattern sync.
- Lock screen par show hone ke liye full-screen intent.

### 9.5 Setup Wizard visuals
- Har step full-screen, animated progress indicator (segmented, morphing).
- Date selection: bade **choice cards** (Aaj / Kal / Custom) + Material date picker.
- Interval: large slider with bubble value + quick chips.
- Time: custom big time picker (hour/minute wheels) — default 10:00 PM pre-selected.

### 9.6 Expressive components to build
- `ExpressiveButton` (press scale + shape morph)
- `ExpressiveCard` (large radius, tonal elevation)
- `CountdownRing` (CustomPainter, thick wavy stroke)
- `ExpressiveDialog` / `ExpressiveSheet`
- `StateChip` (animated color transition)
- `MorphingNavBar`
- `ConfettiOverlay`

---

## 10. Animations List

| Jahan | Animation |
|---|---|
| Splash | Sun rise + panel shine + logo scale |
| Page transitions | Shared axis / container transform |
| Home header | Sun pulse, light rays rotate slowly |
| Countdown number | AnimatedSwitcher + spring slide |
| Progress ring | Animate to value on load (800ms, easeOutBack) |
| Buttons | Scale 0.96 on press, spring back |
| List (history) | Staggered fade+slide-in (`flutter_animate`) |
| Success | Confetti + check morph |
| Dialogs | Scale+fade spring |
| Alarm screen | Ripple waves, shake icon, pulsing |
| State color change | `TweenAnimationBuilder<Color?>` |

Rules: durations 250–500ms, `Curves.easeOutBack` / spring; reduced-motion setting respect karo (`MediaQuery.disableAnimations`).

---

## 11. Splash Screen

Do layers:
1. **Native splash** (`flutter_native_splash`): solid brand color + logo. Android 12+ ke liye animated icon support (`android12` config).
2. **Flutter animated splash** (1.5–2s):
   - Dark → sunrise gradient transition
   - Sun peeche se uthta hai, panel grid draw hoti hai (CustomPainter ya Lottie)
   - Panel par shine sweep
   - App name fade+scale in
   - Phir auth state check → Home ya Login (fade-through)

Tip: auth + Firestore initial fetch splash ke dauran parallel mein karo taake delay feel na ho.

---

## 12. Edge Cases

- User ne notification permission deny ki → persistent banner on Home + settings link.
- Exact alarm permission revoke → fallback inexact + warning.
- Reboot → alarms restore.
- Timezone / DST change → reschedule.
- Multiple devices, same account → Firestore listener + reschedule on change.
- User offline signup ke baad → local cache, sync later.
- Phone silent/DND mode → alarm stream use, DND bypass info dialog.
- App force-stopped (Android) → alarms ud sakte hain; onboarding mein bata do.
- User date past mein select kare → validate (future ya aaj/past dono allow, but nextDue calculate sahi ho).
- Interval change mid-cycle → nextDue recalc from `lastCleanedAt`.

---

## 13. Testing Checklist

- [ ] Alarm app killed state mein bajta hai
- [ ] Alarm lock screen par full-screen aata hai
- [ ] Reboot ke baad reschedule
- [ ] Postpone → next day same time
- [ ] Ignore → next day dobara ring
- [ ] Clean → cycle reset, history entry
- [ ] Interval/time change → purane alarms cancel
- [ ] Android 12, 13, 14, 15 par test
- [ ] Xiaomi/Samsung/Oppo par battery restriction test
- [ ] Dark/light, dynamic color, large font scale, tablet/small screens
- [ ] Debug mode mein "test alarm in 1 minute" button

Dev tip: schedule logic ko **pure Dart functions** mein rakho (date calc) aur unit test karo — time travel ke liye `Clock` abstraction.

---

## 14. Build Phases

**Phase 1 — Foundation**: project setup, flavors, theme (M3 + dynamic color), router, Firebase auth, splash.
**Phase 2 — Setup flow**: onboarding, permission wizard, setup wizard, Firestore settings.
**Phase 3 — Scheduling**: cycle state machine, notification service, alarm service, reschedule logic.
**Phase 4 — Home & actions**: countdown UI, clean/postpone/in-progress, history.
**Phase 5 — Alarm ring screen**: full-screen intent, snooze, escalation.
**Phase 6 — Polish**: animations, dialogs, confetti, haptics, reduced motion.
**Phase 7 — Hardening**: OEM battery guide, edge cases, tests, store release.

---

## 15. Future Ideas
- Weather API: baarish ho jaye to cleaning skip suggestion.
- Dust/season based interval suggestion (garmiyon mein kam interval).
- Multiple locations (ghar, dukan).
- Home-screen widget (days left).
- Family sharing (ek account, multiple members ko alarm).
- Cleaning cost/energy-output tracker.

---

## 16. Quick Prompt (AI coding tool ke liye)

> Build a Flutter app "Solar Clean Reminder" using Clean Architecture + Cubit + GetIt. Firebase Auth login/signup. User sets last-clean/first-clean date (default today), interval (default 20 days), reminder time (default 10 PM). Schedule exact alarm (`alarm` package) + `flutter_local_notifications` backup at due time. Actions: Cleaned (reset cycle), Postpone to next day same time, In progress. If ignored, ring again next day same time until cleaned. Store settings/cycle/history in Firestore with offline-first local scheduling. UI must follow Material 3 Expressive: large rounded shapes, dynamic color, bold typography, big custom dialogs/sheets with Lottie, spring animations, animated splash screen (sunrise + panel shine), full-screen alarm ring screen.
