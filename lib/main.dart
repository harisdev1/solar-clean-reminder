import 'package:flutter/material.dart';

import 'app.dart';
import 'cubit/appearance_cubit.dart';
import 'cubit/locale_cubit.dart';
import 'firebase_bootstrap.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.init();
  await NotificationService.instance.init();

  final localeCubit = LocaleCubit();
  final appearanceCubit = AppearanceCubit();
  await Future.wait([localeCubit.load(), appearanceCubit.load()]);

  runApp(SolarApp(
    localeCubit: localeCubit,
    appearanceCubit: appearanceCubit,
  ));
}
