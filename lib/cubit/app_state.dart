import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_defaults.dart';

enum Status { splash, loggedOut, needsSetup, ready, error }

class AppState {
  const AppState({
    this.status = Status.splash,
    this.user,
    this.busy = false,
    this.message,
    this.intervalDays = AppDefaults.intervalDays,
    this.hour = AppDefaults.hour,
    this.minute = AppDefaults.minute,
    this.lastCleaned,
    this.nextDue,
    this.inProgress = false,
    this.history = const [],
  });

  final Status status;
  final User? user;
  final bool busy;
  final String? message;
  final int intervalDays, hour, minute;
  final DateTime? lastCleaned, nextDue;
  final bool inProgress;
  final List<DateTime> history;

  AppState copyWith({
    Status? status,
    bool? busy,
    String? message,
    bool clearMessage = false,
    int? intervalDays,
    int? hour,
    int? minute,
    DateTime? lastCleaned,
    DateTime? nextDue,
    bool? inProgress,
    List<DateTime>? history,
  }) =>
      AppState(
        status: status ?? this.status,
        user: user,
        busy: busy ?? this.busy,
        message: clearMessage ? null : (message ?? this.message),
        intervalDays: intervalDays ?? this.intervalDays,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        lastCleaned: lastCleaned ?? this.lastCleaned,
        nextDue: nextDue ?? this.nextDue,
        inProgress: inProgress ?? this.inProgress,
        history: history ?? this.history,
      );
}
