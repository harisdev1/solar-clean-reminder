import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_defaults.dart';
import '../core/app_keys.dart';

class UserDoc {
  const UserDoc({
    required this.intervalDays,
    required this.hour,
    required this.minute,
    required this.nextDue,
    this.lastCleaned,
    this.inProgress = false,
  });

  final int intervalDays, hour, minute;
  final DateTime nextDue;
  final DateTime? lastCleaned;
  final bool inProgress;

  static UserDoc? fromMap(Map<String, dynamic>? d) {
    if (d == null || d[AppKeys.nextDue] == null) return null;
    return UserDoc(
      intervalDays: (d[AppKeys.intervalDays] as int?) ?? AppDefaults.intervalDays,
      hour: (d[AppKeys.hour] as int?) ?? AppDefaults.hour,
      minute: (d[AppKeys.minute] as int?) ?? AppDefaults.minute,
      nextDue: (d[AppKeys.nextDue] as Timestamp).toDate(),
      lastCleaned: (d[AppKeys.lastCleaned] as Timestamp?)?.toDate(),
      inProgress: (d[AppKeys.inProgress] as bool?) ?? false,
    );
  }
}

class UserRepository {
  UserRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection(AppKeys.users).doc(_auth.currentUser!.uid);

  void _fire(Future<Object?> f) => f.then((_) {}, onError: (_) {});

  void save(Map<String, dynamic> data) =>
      _fire(_doc.set(data, SetOptions(merge: true)));

  Future<UserDoc?> load() async {
    final d = (await _doc.get()).data();
    return UserDoc.fromMap(d);
  }

  Future<List<DateTime>> loadHistory() async {
    try {
      final q = await _doc
          .collection(AppKeys.history)
          .orderBy(AppKeys.at, descending: true)
          .limit(AppDefaults.historyLimit)
          .get();
      return q.docs
          .map((e) => (e[AppKeys.at] as Timestamp).toDate())
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void finishSetup({
    required DateTime due,
    DateTime? lastCleaned,
    required int intervalDays,
    required int hour,
    required int minute,
  }) {
    save({
      AppKeys.intervalDays: intervalDays,
      AppKeys.hour: hour,
      AppKeys.minute: minute,
      AppKeys.nextDue: Timestamp.fromDate(due),
      AppKeys.lastCleaned:
          lastCleaned == null ? null : Timestamp.fromDate(lastCleaned),
      AppKeys.inProgress: false,
      AppKeys.createdAt: FieldValue.serverTimestamp(),
    });
  }

  void markCleaned({required DateTime now, required DateTime nextDue}) {
    save({
      AppKeys.lastCleaned: Timestamp.fromDate(now),
      AppKeys.nextDue: Timestamp.fromDate(nextDue),
      AppKeys.inProgress: false,
    });
    _fire(_doc.collection(AppKeys.history).add({
      AppKeys.at: Timestamp.fromDate(now),
    }));
  }

  void postpone(DateTime nextDue) => save({
        AppKeys.nextDue: Timestamp.fromDate(nextDue),
        AppKeys.inProgress: false,
      });

  void setInProgress(bool v) => save({AppKeys.inProgress: v});

  void updateSettings({
    required int interval,
    required int hour,
    required int minute,
    required DateTime nextDue,
  }) {
    save({
      AppKeys.intervalDays: interval,
      AppKeys.hour: hour,
      AppKeys.minute: minute,
      AppKeys.nextDue: Timestamp.fromDate(nextDue),
    });
  }
}
