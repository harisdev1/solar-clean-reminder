import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/app_keys.dart';
import '../cubit/app_cubit.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/retry_page.dart';
import 'pages/setup_page.dart';
import 'pages/splash_page.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listenWhen: (a, b) => b.message != null && b.message != a.message,
      listener: (c, s) {
        ScaffoldMessenger.of(c).showSnackBar(SnackBar(
          content: Text(s.message!),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ));
        c.read<AppCubit>().clearMessage();
      },
      buildWhen: (a, b) => a.status != b.status,
      builder: (c, s) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: switch (s.status) {
          Status.splash =>
            const SplashPage(key: ValueKey(AppKeys.pageSplash)),
          Status.loggedOut =>
            const AuthPage(key: ValueKey(AppKeys.pageAuth)),
          Status.needsSetup =>
            const SetupPage(key: ValueKey(AppKeys.pageSetup)),
          Status.ready => const HomePage(key: ValueKey(AppKeys.pageHome)),
          Status.error =>
            const RetryPage(key: ValueKey(AppKeys.pageError)),
        },
      ),
    );
  }
}
