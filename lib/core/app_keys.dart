/// Non-UI identifiers: Firestore, notifications, assets, OAuth, ValueKeys.
abstract final class AppKeys {
  // Firestore
  static const users = 'users';
  static const history = 'history';
  static const intervalDays = 'intervalDays';
  static const hour = 'hour';
  static const minute = 'minute';
  static const nextDue = 'nextDue';
  static const lastCleaned = 'lastCleaned';
  static const inProgress = 'inProgress';
  static const createdAt = 'createdAt';
  static const at = 'at';

  // Notification actions / channels / ids
  static const actionClean = 'clean';
  static const actionTomorrow = 'tomorrow';
  static const actionOpen = 'open';
  static const channelAlarm = 'solar_alarm_v2';
  static const channelSoft = 'solar_soft_v2';
  static const notificationAlarmBaseId = 100;
  static const notificationSoftId = 200;
  static const notificationConfirmId = 300;
  static const notificationTestId = 999;

  // Assets / OAuth
  static const logoAsset = 'assets/icons/image.png';
  static const googleWebClientId =
      '668072490463-10a93p0hq9ua6tjh601s8kt1pun1ufpq.apps.googleusercontent.com';

  // Widget ValueKeys
  static const pageSplash = 'splash';
  static const pageAuth = 'auth';
  static const pageSetup = 'setup';
  static const pageHome = 'home';
  static const pageError = 'err';
}
