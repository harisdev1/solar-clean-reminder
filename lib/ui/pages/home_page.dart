import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/app_defaults.dart';
import '../../core/app_strings.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/appearance_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../widgets/big_dialog.dart';
import '../widgets/chips.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/expressive_button.dart';
import '../widgets/prefs_controls.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      final cubit = context.read<AppCubit>();
      cubit.ensurePermissionsIfNeeded().then((_) {
        if (mounted) cubit.reschedule();
      });
    }
  }

  Future<void> _clean(AppState s) async {
    final ok = await showBigDialog(
      context,
      icon: Icons.cleaning_services_rounded,
      title: AppStrings.cleanConfirmTitle,
      body: AppStrings.cleanConfirmBody(s.intervalDays),
      primary: AppStrings.yesDone,
      secondary: AppStrings.notNow,
    );
    if (ok != true || !mounted) return;
    final cubit = context.read<AppCubit>();
    await cubit.markCleaned();
    if (!mounted) return;
    final next = cubit.state.nextDue!;
    await showBigDialog(
      context,
      icon: Icons.celebration_rounded,
      title: AppStrings.celebrateTitle,
      body: AppStrings.nextClean(DateFormat('EEE, d MMM').format(next)),
      primary: AppStrings.thanks,
    );
  }

  Future<void> _postpone(AppState s) async {
    final t = TimeOfDay(hour: s.hour, minute: s.minute).format(context);
    final ok = await showBigDialog(
      context,
      icon: Icons.event_repeat_rounded,
      title: AppStrings.postponeTitle,
      body: AppStrings.postponeBody(t),
      primary: AppStrings.yesTomorrow,
      secondary: AppStrings.cancel,
    );
    if (ok == true && mounted) context.read<AppCubit>().postpone();
  }

  void _settings() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        shape: sheetShape,
        builder: (_) => const SettingsSheet(),
      );

  void _history(AppState s) => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        shape: sheetShape,
        builder: (c) {
          final cs = Theme.of(c).colorScheme;
          return SizedBox(
            height: MediaQuery.sizeOf(c).height * .6,
            child: s.history.isEmpty
                ? Center(
                    child: Text(AppStrings.historyEmpty,
                        textAlign: TextAlign.center))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: s.history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(28)),
                      child: Row(children: [
                        Icon(Icons.check_circle_rounded, color: cs.primary),
                        const SizedBox(width: 12),
                        Text(
                            DateFormat('EEE, d MMM y • h:mm a')
                                .format(s.history[i]),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    )
                        .animate(delay: (40 * math.min(i, 10)).ms)
                        .fadeIn()
                        .slideX(begin: .1),
                  ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return BlocBuilder<AppCubit, AppState>(builder: (context, s) {
      context.watch<LocaleCubit>();
      final now = DateTime.now();
      final due = s.nextDue ?? now;
      final isDue = !now.isBefore(due);
      final daysLeft = dayDiff(due, now);
      final late = isDue ? dayDiff(now, due) : 0;
      final color = isDue
          ? cs.error
          : daysLeft <= 3
              ? const Color(0xFFF59E0B)
              : const Color(0xFF2E9E5B);
      final big = isDue
          ? (late == 0 ? AppStrings.today : '$late')
          : (daysLeft == 0 ? AppStrings.today : '$daysLeft');
      final label = isDue
          ? (late == 0 ? AppStrings.dueNow : AppStrings.daysLate)
          : (daysLeft == 0 ? AppStrings.cleaningDay : AppStrings.daysLeft);
      final progress = isDue
          ? 1.0
          : ((s.intervalDays - daysLeft) / s.intervalDays)
              .clamp(0.0, 1.0)
              .toDouble();
      final first = (s.user?.displayName ?? '').trim().split(' ').first;
      final name = first.isEmpty ? AppStrings.friendFallback : first;
      final fmt = DateFormat('EEE, d MMM');

      final buttons = <Widget>[
        ExpressiveButton(
          label: AppStrings.cleaned,
          icon: Icons.task_alt_rounded,
          onPressed: () => _clean(s),
        ),
        if (!s.inProgress && isDue)
          ExpressiveButton(
            label: AppStrings.inProgressAction,
            icon: Icons.water_drop_rounded,
            kind: BtnKind.tonal,
            onPressed: () => context.read<AppCubit>().startCleaning(),
          ),
        if (isDue || s.inProgress)
          ExpressiveButton(
            label: AppStrings.postponeAction,
            icon: Icons.skip_next_rounded,
            kind: BtnKind.tonal,
            onPressed: () => _postpone(s),
          ),
      ];

      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Row(children: [
                Expanded(
                  child: Text(AppStrings.greet(name),
                      style: tt.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                IconButton.filledTonal(
                    onPressed: () => _history(s),
                    icon: const Icon(Icons.history_rounded)),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                    onPressed: _settings,
                    icon: const Icon(Icons.tune_rounded)),
              ]),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(44),
                ),
                child: Column(children: [
                  CountdownRing(
                    progress: progress,
                    color: color,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (c, a) => ScaleTransition(
                            scale: a,
                            child: FadeTransition(opacity: a, child: c)),
                        child: Text(big,
                            key: ValueKey(big),
                            style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: color)),
                      ),
                      const SizedBox(height: 4),
                      Text(label,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        InfoChip(Icons.event_rounded,
                            AppStrings.dueChip(fmt.format(due))),
                        InfoChip(
                            Icons.alarm_rounded,
                            TimeOfDay(hour: s.hour, minute: s.minute)
                                .format(context)),
                        InfoChip(
                            Icons.cleaning_services_rounded,
                            s.lastCleaned == null
                                ? AppStrings.lastNone
                                : AppStrings
                                    .lastChip(fmt.format(s.lastCleaned!))),
                      ]),
                ]),
              ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(.94, .94),
                  curve: Curves.easeOutBack,
                  duration: 500.ms),
              const SizedBox(height: 20),
              if (s.inProgress)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(28)),
                  child: Row(children: [
                    Icon(Icons.water_drop_rounded,
                        color: cs.onTertiaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(AppStrings.inProgressBanner,
                          style: TextStyle(color: cs.onTertiaryContainer)),
                    ),
                  ]),
                ),
              for (final b in buttons) ...[b, const SizedBox(height: 12)],
            ],
          ),
        ),
      );
    });
  }
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late int _interval;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppCubit>().state;
    _interval = s.intervalDays;
    _time = TimeOfDay(hour: s.hour, minute: s.minute);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<AppCubit>();
    context.watch<LocaleCubit>();
    context.watch<AppearanceCubit>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(AppStrings.settings,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const LanguagePicker(),
          const SizedBox(height: 20),
          const AppearanceControls(),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(AppStrings.cleaningInterval)),
            Text(AppStrings.daysCount(_interval),
                style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900, color: cs.primary)),
          ]),
          Slider(
            min: AppDefaults.intervalMin.toDouble(),
            max: AppDefaults.intervalMax.toDouble(),
            divisions: AppDefaults.intervalMax - AppDefaults.intervalMin,
            value: _interval.toDouble(),
            label: '$_interval',
            onChanged: (v) => setState(() => _interval = v.round()),
          ),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            tileColor: cs.surfaceContainerHigh,
            leading: const Icon(Icons.alarm_rounded),
            title: Text(AppStrings.alarmTime),
            trailing: Text(_time.format(context),
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            onTap: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
          ),
          const SizedBox(height: 16),
          ExpressiveButton(
            label: AppStrings.save,
            icon: Icons.check_rounded,
            onPressed: () {
              cubit.updateSettings(_interval, _time.hour, _time.minute);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          ExpressiveButton(
            label: AppStrings.testAlarm,
            icon: Icons.notifications_active_rounded,
            kind: BtnKind.tonal,
            onPressed: () {
              cubit.testAlarm();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          ExpressiveButton(
            label: AppStrings.permissionsCheck,
            icon: Icons.verified_user_rounded,
            kind: BtnKind.tonal,
            onPressed: () => cubit.requestPermissions(),
          ),
          const SizedBox(height: 10),
          ExpressiveButton(
            label: AppStrings.logout,
            icon: Icons.logout_rounded,
            kind: BtnKind.danger,
            onPressed: () async {
              final ok = await showBigDialog(
                context,
                icon: Icons.logout_rounded,
                title: AppStrings.logoutTitle,
                body: AppStrings.logoutBody,
                primary: AppStrings.yesLogout,
                secondary: AppStrings.cancel,
                danger: true,
              );
              if (ok == true && context.mounted) {
                Navigator.pop(context);
                cubit.signOut();
              }
            },
          ),
        ]),
      ),
    );
  }
}
