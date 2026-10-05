import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_defaults.dart';
import '../core/app_keys.dart';
import '../core/app_strings.dart';
import '../data/auth_service.dart';
import '../data/user_repository.dart';
import '../services/notification_service.dart';
import 'app_state.dart';

export 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    AuthService? auth,
    UserRepository? users,
    NotificationService? notifications,
  })  : _auth = auth ?? AuthService(),
        _users = users ?? UserRepository(),
        _notifications = notifications ?? NotificationService.instance,
        super(const AppState()) {
    _minSplash =
        Future<void>.delayed(const Duration(milliseconds: AppDefaults.splashMs));
    _notifications.onAction = _onAction;
    _sub = _auth.authStateChanges.listen(_onUser);
  }

  final AuthService _auth;
  final UserRepository _users;
  final NotificationService _notifications;
  late final Future<void> _minSplash;
  StreamSubscription<User?>? _sub;

  Future<void> _onUser(User? u) async {
    await _minSplash;
    if (u == null) {
      await _notifications.cancelAll();
      emit(const AppState(status: Status.loggedOut));
    } else {
      await _load(u);
    }
  }

  Future<void> retry() async {
    final u = _auth.currentUser;
    if (u != null) await _load(u);
  }

  Future<void> _load(User u) async {
    UserDoc? doc;
    try {
      doc = await _users.load();
    } catch (_) {
      emit(AppState(status: Status.error, user: u));
      return;
    }
    if (doc == null) {
      emit(AppState(status: Status.needsSetup, user: u));
      return;
    }
    final hist = await _users.loadHistory();
    emit(AppState(
      status: Status.ready,
      user: u,
      intervalDays: doc.intervalDays,
      hour: doc.hour,
      minute: doc.minute,
      lastCleaned: doc.lastCleaned,
      nextDue: doc.nextDue,
      inProgress: doc.inProgress,
      history: hist,
    ));
    await ensurePermissionsIfNeeded();
    await reschedule();
    final a = _notifications.takeLaunchAction();
    if (a != null) await _onAction(a);
  }

  Future<void> reschedule() async {
    final s = state;
    if (s.status != Status.ready || s.nextDue == null) return;
    await _notifications.scheduleAll(
      due: s.nextDue!,
      hour: s.hour,
      minute: s.minute,
    );
  }

  Future<void> _onAction(String id) async {
    if (state.status != Status.ready) return;
    if (id == AppKeys.actionClean) {
      await markCleaned();
    } else if (id == AppKeys.actionTomorrow) {
      await postpone();
    }
  }

  Future<bool> requestPermissions() async {
    final ok = await _notifications.requestPermissions();
    emit(state.copyWith(
      message: ok ? AppStrings.permissionsOk : AppStrings.permissionsDenied,
    ));
    return ok;
  }

  /// Ask only when notification permission is missing (returning users skip setup).
  Future<void> ensurePermissionsIfNeeded() async {
    if (await _notifications.isNotificationGranted()) return;
    await requestPermissions();
  }

  Future<void> finishSetup({
    required DateTime due,
    DateTime? lastCleaned,
    required int intervalDays,
    required int hour,
    required int minute,
  }) async {
    final u = _auth.currentUser!;
    _users.finishSetup(
      due: due,
      lastCleaned: lastCleaned,
      intervalDays: intervalDays,
      hour: hour,
      minute: minute,
    );
    emit(AppState(
      status: Status.ready,
      user: u,
      intervalDays: intervalDays,
      hour: hour,
      minute: minute,
      lastCleaned: lastCleaned,
      nextDue: due,
    ));
    await ensurePermissionsIfNeeded();
    await reschedule();
  }

  Future<void> markCleaned() async {
    final s = state;
    final now = DateTime.now();
    final due = atTime(now, s.intervalDays, s.hour, s.minute);
    _users.markCleaned(now: now, nextDue: due);
    emit(s.copyWith(
      lastCleaned: now,
      nextDue: due,
      inProgress: false,
      history: [now, ...s.history],
    ));
    await reschedule();
  }

  Future<void> postpone() async {
    final s = state;
    final due = atTime(DateTime.now(), 1, s.hour, s.minute);
    _users.postpone(due);
    emit(s.copyWith(nextDue: due, inProgress: false));
    await reschedule();
  }

  Future<void> startCleaning() async {
    _users.setInProgress(true);
    emit(state.copyWith(
      inProgress: true,
      message: AppStrings.cleaningStarted,
    ));
    await reschedule();
    await _notifications.confirmIn(
      const Duration(hours: AppDefaults.confirmAfterHours),
    );
  }

  Future<void> updateSettings(int interval, int h, int m) async {
    final s = state;
    final due = (interval != s.intervalDays && s.lastCleaned != null)
        ? atTime(s.lastCleaned!, interval, h, m)
        : atTime(s.nextDue!, 0, h, m);
    _users.updateSettings(
      interval: interval,
      hour: h,
      minute: m,
      nextDue: due,
    );
    emit(s.copyWith(intervalDays: interval, hour: h, minute: m, nextDue: due));
    await reschedule();
  }

  Future<void> testAlarm() async {
    await _notifications.testIn(
      const Duration(minutes: AppDefaults.testAlarmMinutes),
    );
    emit(state.copyWith(message: AppStrings.testAlarmScheduled));
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  Future<void> signIn(String email, String pass) =>
      _run(() => _auth.signIn(email, pass));

  Future<void> signUp(String email, String pass) =>
      _run(() => _auth.signUp(email, pass));

  Future<void> google() => _run(() => _auth.google());

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      emit(state.copyWith(message: AppStrings.enterEmailFirst));
      return;
    }
    try {
      await _auth.resetPassword(email);
      emit(state.copyWith(message: AppStrings.resetLinkSent));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(message: _auth.messageFor(e)));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _run(Future<void> Function() f) async {
    emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await f();
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(busy: false, message: _auth.messageFor(e)));
    } on GoogleSignInException catch (e) {
      emit(state.copyWith(
        busy: false,
        message: e.code == GoogleSignInExceptionCode.canceled
            ? null
            : AppStrings.googleLoginFailed,
      ));
    } catch (e) {
      emit(state.copyWith(
        busy: false,
        message: AppStrings.somethingWentWrong(e),
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
