import 'app_locale.dart';

/// Bilingual copy: Roman Urdu (default) + English.
abstract final class AppStrings {
  static AppLocale locale = AppLocale.romanUrdu;

  static void setLocale(AppLocale l) => locale = l;

  static bool get _en => locale == AppLocale.english;

  static String _t(String roman, String en) => _en ? en : roman;

  static const appName = 'SolarAlarm';
  static String get tagline =>
      _t('Panels chamkate raho ☀️', 'Keep your panels shining ☀️');

  // Language UI
  static String get language => _t('Zaban', 'Language');
  static String get english => 'English';
  static String get romanUrdu => _t('Roman Urdu', 'Roman Urdu');
  static String get appearance => _t('Dikhao', 'Appearance');
  static String get themeMode => _t('Theme', 'Theme');
  static String get themeSystem => _t('System', 'System');
  static String get themeLight => _t('Light', 'Light');
  static String get themeDark => _t('Dark', 'Dark');
  static String get accentColor => _t('Color', 'Accent');
  static String get fontLabel => _t('Font', 'Font');
  static String get accentSolar => _t('Solar', 'Solar');
  static String get accentOcean => _t('Ocean', 'Ocean');
  static String get accentLeaf => _t('Leaf', 'Leaf');
  static String get accentEmber => _t('Ember', 'Ember');
  static String get accentTeal => _t('Teal', 'Teal');
  static String get accentRose => _t('Rose', 'Rose');

  // Auth
  static String get signupSubtitle =>
      _t('Naya account banao', 'Create a new account');
  static String get loginSubtitle =>
      _t('Wapis aao, login karo', 'Welcome back — sign in');
  static String get email => 'Email';
  static String get password => 'Password';
  static String get forgotPassword =>
      _t('Password bhool gaye?', 'Forgot password?');
  static String get createAccount =>
      _t('Account banao', 'Create account');
  static String get login => _t('Login', 'Log in');
  static String get or => _t('ya', 'or');
  static String get continueWithGoogle =>
      _t('Google se continue karo', 'Continue with Google');
  static String get haveAccountLogin =>
      _t('Pehle se account hai? Login', 'Already have an account? Log in');
  static String get newUserSignup =>
      _t('Naya user? Account banao', 'New here? Create an account');
  static String get enterEmailFirst =>
      _t('Pehle email likho', 'Enter your email first');
  static String get resetLinkSent => _t(
        'Reset link bhej diya, email check karo 📩',
        'Reset link sent — check your email 📩',
      );
  static String get wrongEmailPassword =>
      _t('Email ya password galat hai', 'Wrong email or password');
  static String get emailAlreadyUsed => _t(
        'Ye email pehle se registered hai',
        'This email is already registered',
      );
  static String get weakPassword => _t(
        'Password kam az kam 6 characters ka rakho',
        'Use at least 6 characters for the password',
      );
  static String get invalidEmail =>
      _t('Email sahi nahi hai', 'Invalid email address');
  static String get networkError =>
      _t('Internet check karo', 'Check your internet connection');
  static String get authDisabled => _t(
        'Email/Password Auth band hai. Firebase Console → Authentication → Sign-in method.',
        'Email/Password sign-in is disabled in Firebase Console.',
      );
  static String get authConfigMissing => _t(
        'Firebase Auth config missing. Console → Authentication check karo.',
        'Firebase Auth is not configured. Check Authentication in Console.',
      );
  static String get googleLoginFailed => _t(
        'Google login nahi hua. SHA-1 / google-services.json check karo.',
        'Google sign-in failed. Check SHA-1 / google-services.json.',
      );
  static String get googleIdTokenMissing => _t(
        'Google idToken null. Production Auth Google provider + SHA-1 required.',
        'Google idToken missing. Enable Google provider + SHA-1.',
      );
  static String somethingWentWrong(Object e) =>
      _t('Kuch masla hua: $e', 'Something went wrong: $e');
  static String get authErrorFallback => _t('Auth error', 'Auth error');

  // Retry / load
  static String get loadFailed => _t(
        'Data load nahi hua. Internet check karo.',
        'Could not load data. Check your internet.',
      );
  static String get retry => _t('Dobara try karo', 'Try again');
  static String get close => 'close';

  // Setup
  static String get permTitle =>
      _t('Alarm permissions', 'Alarm permissions');
  static String get permBody => _t(
        'Time par alarm bajane ke liye notification, exact alarm aur full-screen permission chahiye. Agli screens par "Allow" dabao.',
        'To ring on time we need notification, exact alarm, and full-screen permission. Tap Allow on the next prompts.',
      );
  static String get allow => _t('Allow karo', 'Allow');
  static String get later => _t('Baad mein', 'Later');
  static String get next => _t('Aage', 'Next');
  static String get start => _t('Shuru karo', 'Get started');
  static String get setupPlanTitle =>
      _t('Alarm set karte hain', 'Set your reminder');
  static String get setupPlanSub => _t(
        'Pehle batao: panels pehle saaf ho chuke hain ya pehli baar?',
        'Did you already clean, or is this the first clean?',
      );
  static String get modeLastTitle =>
      _t('Pehle saaf kar chuka hun', 'I already cleaned');
  static String get modeLastSub => _t(
        'Pehle panels saaf kar chuke ho. Agle step pe last din aur gap choose karoge.',
        'You already cleaned. Next step: pick last clean day and days gap.',
      );
  static String get modeFirstTitle =>
      _t('Pehli baar saaf karunga', 'First clean coming up');
  static String get modeFirstSub => _t(
        'Abhi pehli safai karni hai. Agle step pe din aur gap choose karoge.',
        'First clean is coming. Next step: pick that day and days gap.',
      );
  static String get setupDateTitleLast =>
      _t('Last clean kab hui?', 'When did you last clean?');
  static String get setupDateTitleFirst =>
      _t('Pehli clean kab?', 'When is the first clean?');
  static String get setupGapTitleLast =>
      _t('Kitne din baad dubara?', 'How many days until next clean?');
  static String get setupGapTitleFirst =>
      _t('Phir har kitne din baad?', 'Then every how many days?');
  static String get setupPlanHint => _t(
        'Date aur din badalte hi neeche yaad dikhegi.',
        'Change date or days — reminder updates below.',
      );
  static String get whichDate => _t('Din choose karo', 'Choose the day');
  static String get today => _t('Aaj', 'Today');
  static String get tomorrow => _t('Kal', 'Tomorrow');
  static String get pickDate => _t('Date chuno', 'Pick a date');
  static String get intervalTitle =>
      _t('Kitne din baad?', 'How often?');
  static String get intervalSub => _t(
        'Har kitne din baad panels saaf karne hain.',
        'How many days between panel cleans?',
      );
  static String get days => _t('din', 'days');
  static String daysCount(int n) => _t('$n din', '$n days');
  static String get alarmTimeTitle =>
      _t('Alarm ka time', 'Alarm time');
  static String get alarmTimeSub => _t(
        'Is time par notification aur alarm bajega (default 10 PM).',
        'Notification and alarm at this time (default 10 PM).',
      );
  static String get tapToChange =>
      _t('Tap karke badlo', 'Tap to change');
  static String firstAlarm(String when) =>
      _t('Yaad: $when', 'Reminder: $when');

  // Home
  static String get friendFallback => _t('dost', 'friend');
  static String greet(String name) =>
      _t('Salam, $name ☀️', 'Hi, $name ☀️');
  static String get dueNow =>
      _t('abhi safai karo!', 'clean now!');
  static String get daysLate => _t('din late ⚠️', 'days late ⚠️');
  static String get cleaningDay =>
      _t('safai ka din', 'cleaning day');
  static String get daysLeft => _t('din baaki', 'days left');
  static String get cleaned =>
      _t('Clean ho gaya ✓', 'All clean ✓');
  static String get inProgressAction =>
      _t('Abhi kar raha hun', 'Cleaning now');
  static String get postponeAction =>
      _t('Kal kar dunga', 'Do it tomorrow');
  static String dueChip(String d) => _t('Due: $d', 'Due: $d');
  static String lastChip(String d) => _t('Last: $d', 'Last: $d');
  static String get lastNone => _t('Last: —', 'Last: —');
  static String get inProgressBanner => _t(
        'Safai chal rahi hai… ho jaye to "Clean ho gaya" dabao.',
        'Cleaning in progress… tap All clean when done.',
      );
  static String get cleanConfirmTitle =>
      _t('Panels saaf ho gaye?', 'Panels cleaned?');
  static String cleanConfirmBody(int days) => _t(
        'Agli safai $days din baad ki set ho jayegi.',
        'Next clean will be set for $days days later.',
      );
  static String get yesDone => _t('Haan, ho gaya', 'Yes, done');
  static String get notNow => _t('Abhi nahi', 'Not now');
  static String get celebrateTitle => _t('Shabash! ✨', 'Nice work! ✨');
  static String nextClean(String d) =>
      _t('Agli safai: $d', 'Next clean: $d');
  static String get thanks => _t('Shukriya!', 'Thanks!');
  static String get postponeTitle =>
      _t('Kal kar loge?', 'Tomorrow instead?');
  static String postponeBody(String t) =>
      _t('Kal $t par dobara alarm bajega.', 'Alarm again tomorrow at $t.');
  static String get yesTomorrow => _t('Haan, kal', 'Yes, tomorrow');
  static String get cancel => _t('Cancel', 'Cancel');
  static String get historyEmpty => _t(
        'Abhi koi safai record nahi.\nPehli safai ke baad yahan dikhegi ✨',
        'No cleaning history yet.\nIt will show after your first clean ✨',
      );
  static String get cleaningStarted => _t(
        'Theek hai! 2 ghante baad confirm poochunga 🧽',
        'Got it! I will ask you to confirm in 2 hours 🧽',
      );
  static String get testAlarmScheduled => _t(
        '1 minute mein test alarm bajega — volume on, DND off, app band karke suno ⏰',
        'Test alarm in 1 minute — volume on, DND off; leave the app and listen ⏰',
      );

  // Settings
  static String get settings => _t('Settings', 'Settings');
  static String get cleaningInterval =>
      _t('Safai ka interval', 'Cleaning interval');
  static String get alarmTime => _t('Alarm time', 'Alarm time');
  static String get save => _t('Save', 'Save');
  static String get testAlarm =>
      _t('Test alarm (1 min)', 'Test alarm (1 min)');
  static String get permissionsCheck =>
      _t('Permissions check', 'Check permissions');
  static String get permissionsOk =>
      _t('Permissions mil gayi ✓', 'Permissions granted ✓');
  static String get permissionsDenied => _t(
        'Permissions nahi mili — Settings se Allow karo',
        'Permissions denied — allow in Settings',
      );
  static String get logout => _t('Logout', 'Log out');
  static String get logoutTitle =>
      _t('Logout karna hai?', 'Log out?');
  static String get logoutBody => _t(
        'Alarms is device se band ho jayenge.',
        'Alarms on this device will be cleared.',
      );
  static String get yesLogout => _t('Haan, logout', 'Yes, log out');

  // Notifications
  static String get notifActionClean =>
      _t('Clean ho gaya ✓', 'All clean ✓');
  static String get notifActionTomorrow =>
      _t('Kal kar dunga', 'Tomorrow');
  static String get channelAlarmName =>
      _t('Cleaning alarm', 'Cleaning alarm');
  static String get channelAlarmDesc =>
      _t('Solar panel cleaning alarm', 'Solar panel cleaning alarm');
  static String get channelSoftName =>
      _t('Cleaning reminders', 'Cleaning reminders');
  static String get channelSoftDesc => _t(
        'Soft reminders before cleaning day',
        'Soft reminders before cleaning day',
      );
  static String get alarmTitle => _t(
        'Solar panels dhone ka time! ☀️',
        'Time to clean solar panels! ☀️',
      );
  static String get alarmBodyDue => _t(
        'Aaj safai ka din hai. Clean kar lo.',
        'Cleaning day is today. Get it done.',
      );
  static String get alarmBodyLate => _t(
        'Safai late ho rahi hai — aaj kar lo.',
        'Cleaning is overdue — do it today.',
      );
  static String get softTitle =>
      _t('Safai qareeb hai', 'Cleaning is coming up');
  static String get softBody => _t(
        '2 din baad panels dhone hain 🧽',
        'Panels due in 2 days 🧽',
      );
  static String get confirmTitle =>
      _t('Safai ho gayi?', 'All cleaned?');
  static String get confirmBody => _t(
        'Panels saaf ho gaye to confirm kar do.',
        'Confirm once the panels are clean.',
      );
  static String get testTitle =>
      _t('Test alarm ⏰', 'Test alarm ⏰');
  static String get testBody => _t(
        'Agar ye bajta hai to alarm sahi setup hai.',
        'If this rings, alarms are set up correctly.',
      );
}
