import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_strings.dart';
import '../../cubit/app_cubit.dart';
import '../widgets/expressive_button.dart';

class RetryPage extends StatelessWidget {
  const RetryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_rounded, size: 64),
              const SizedBox(height: 16),
              Text(AppStrings.loadFailed, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ExpressiveButton(
                  label: AppStrings.retry,
                  icon: Icons.refresh_rounded,
                  onPressed: () => context.read<AppCubit>().retry()),
            ]),
          ),
        ),
      );
}
