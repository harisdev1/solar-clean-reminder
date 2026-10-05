abstract final class AppDefaults {
  static const intervalDays = 15;
  static const hour = 22;
  static const minute = 0;
  static const intervalMin = 7;
  static const intervalMax = 90;
  static const historyLimit = 30;
  static const splashMs = 2400;
  static const splashAnimMs = 2200;
  static const softReminderDaysBefore = 2;
  static const alarmChainDays = 7;
  static const confirmAfterHours = 2;
  static const testAlarmMinutes = 1;
  static const seedColor = 0xFFFFB300;
}

/// Calendar date + time helper used by setup / scheduling.
DateTime atTime(DateTime d, int addDays, int h, int m) =>
    DateTime(d.year, d.month, d.day + addDays, h, m);

int dayDiff(DateTime a, DateTime b) => DateTime.utc(a.year, a.month, a.day)
    .difference(DateTime.utc(b.year, b.month, b.day))
    .inDays;
