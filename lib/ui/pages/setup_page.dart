import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/app_defaults.dart';
import '../../core/app_strings.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../widgets/big_dialog.dart';
import '../widgets/chips.dart';
import '../widgets/expressive_button.dart';
import '../widgets/prefs_controls.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _step = 0;
  /// 0 = already cleaned (past/today); 1 = first clean upcoming (today/future).
  int _mode = 0;
  int _interval = AppDefaults.intervalDays;
  DateTime _date = _today();
  TimeOfDay _time =
      const TimeOfDay(hour: AppDefaults.hour, minute: AppDefaults.minute);
  bool _saving = false;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool get _alreadyCleaned => _mode == 0;

  DateTime get _due =>
      atTime(_date, _alreadyCleaned ? _interval : 0, _time.hour, _time.minute);

  DateTime get _minDate => _alreadyCleaned
      ? _today().subtract(const Duration(days: 365))
      : _today();

  DateTime get _maxDate =>
      _alreadyCleaned ? _today() : _today().add(const Duration(days: 365));

  bool _isAllowed(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return !day.isBefore(_minDate) && !day.isAfter(_maxDate);
  }

  void _setMode(int mode) {
    setState(() {
      _mode = mode;
      if (!_isAllowed(_date)) _date = _today();
    });
  }

  void _setDate(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    if (!_isAllowed(day)) return;
    setState(() => _date = day);
  }

  Future<void> _finish() async {
    final cubit = context.read<AppCubit>();
    setState(() => _saving = true);
    final ok = await showBigDialog(
      context,
      icon: Icons.alarm_on_rounded,
      title: AppStrings.permTitle,
      body: AppStrings.permBody,
      primary: AppStrings.allow,
      secondary: AppStrings.later,
    );
    if (ok == true) await cubit.requestPermissions();
    final today = _today();
    await cubit.finishSetup(
      due: _due,
      lastCleaned:
          (_alreadyCleaned && !_date.isAfter(today)) ? _date : null,
      intervalDays: _interval,
      hour: _time.hour,
      minute: _time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    context.watch<LocaleCubit>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Row(children: [
              const LanguageToggleIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? cs.primary
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                            begin: const Offset(.08, 0), end: Offset.zero)
                        .animate(a),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => _step0(cs, tt),
                    1 => _step1(cs, tt),
                    _ => _step2(cs, tt),
                  },
                ),
              ),
            ),
            Row(children: [
              if (_step > 0) ...[
                IconButton.filledTonal(
                  iconSize: 28,
                  padding: const EdgeInsets.all(16),
                  onPressed: () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ExpressiveButton(
                  label: _step < 2 ? AppStrings.next : AppStrings.start,
                  icon: _step < 2
                      ? Icons.arrow_forward_rounded
                      : Icons.rocket_launch_rounded,
                  busy: _saving,
                  onPressed: () =>
                      _step < 2 ? setState(() => _step++) : _finish(),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _title(TextTheme tt, String t, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t,
              style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(sub, style: tt.bodyLarge),
          const SizedBox(height: 24),
        ],
      );

  Widget _reminderPreview(ColorScheme cs, TextTheme tt) {
    final dueLabel =
        '${DateFormat('EEE, d MMM').format(_due)} • ${_time.format(context)}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: cs.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        Icon(Icons.alarm_rounded, color: cs.onPrimaryContainer),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppStrings.firstAlarm(dueLabel),
            style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800, color: cs.onPrimaryContainer),
          ),
        ),
      ]),
    );
  }

  /// Step 0: mode only.
  Widget _step0(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(tt, AppStrings.setupPlanTitle, AppStrings.setupPlanSub),
      ChoiceCard(
        icon: Icons.history_rounded,
        title: AppStrings.modeLastTitle,
        subtitle: AppStrings.modeLastSub,
        selected: _mode == 0,
        onTap: () => _setMode(0),
      ),
      const SizedBox(height: 12),
      ChoiceCard(
        icon: Icons.event_available_rounded,
        title: AppStrings.modeFirstTitle,
        subtitle: AppStrings.modeFirstSub,
        selected: _mode == 1,
        onTap: () => _setMode(1),
      ),
    ]);
  }

  /// Step 1: date + days gap + accurate preview.
  Widget _step1(ColorScheme cs, TextTheme tt) {
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));
    final sel = _date == today
        ? 0
        : (!_alreadyCleaned && _date == tomorrow)
            ? 1
            : 2;
    final dateTitle = _alreadyCleaned
        ? AppStrings.setupDateTitleLast
        : AppStrings.setupDateTitleFirst;
    final gapTitle = _alreadyCleaned
        ? AppStrings.setupGapTitleLast
        : AppStrings.setupGapTitleFirst;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(dateTitle,
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Text(AppStrings.whichDate,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        ChoiceChip(
          label: Text(AppStrings.today),
          selected: sel == 0,
          onSelected: (_) => _setDate(today),
        ),
        if (!_alreadyCleaned)
          ChoiceChip(
            label: Text(AppStrings.tomorrow),
            selected: sel == 1,
            onSelected: (_) => _setDate(tomorrow),
          ),
        ChoiceChip(
          avatar: const Icon(Icons.calendar_month_rounded, size: 18),
          label: Text(sel == 2
              ? DateFormat('d MMM y').format(_date)
              : AppStrings.pickDate),
          selected: sel == 2,
          onSelected: (_) async {
            final initial = _isAllowed(_date)
                ? _date
                : (_alreadyCleaned ? _maxDate : _minDate);
            final d = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: _minDate,
              lastDate: _maxDate,
              selectableDayPredicate: _isAllowed,
            );
            if (d != null) _setDate(d);
          },
        ),
      ]),
      const SizedBox(height: 28),
      Text(gapTitle,
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Center(
        child: Column(children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text('$_interval',
                key: ValueKey(_interval),
                style: const TextStyle(
                    fontSize: 72, fontWeight: FontWeight.w900, height: 1)),
          ),
          Text(AppStrings.days, style: tt.titleLarge),
        ]),
      ),
      Slider(
        min: AppDefaults.intervalMin.toDouble(),
        max: AppDefaults.intervalMax.toDouble(),
        divisions: AppDefaults.intervalMax - AppDefaults.intervalMin,
        value: _interval.toDouble(),
        label: '$_interval',
        onChanged: (v) {
          HapticFeedback.selectionClick();
          setState(() => _interval = v.round());
        },
      ),
      Wrap(spacing: 10, children: [
        for (final d in [14, 20, 30, 45])
          ChoiceChip(
              label: Text(AppStrings.daysCount(d)),
              selected: _interval == d,
              onSelected: (_) => setState(() => _interval = d)),
      ]),
      const SizedBox(height: 12),
      Text(AppStrings.setupPlanHint,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 16),
      _reminderPreview(cs, tt),
    ]);
  }

  Widget _step2(ColorScheme cs, TextTheme tt) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(tt, AppStrings.alarmTimeTitle, AppStrings.alarmTimeSub),
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Column(children: [
                  Text(_time.format(context),
                      style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer)),
                  const SizedBox(height: 6),
                  Text(AppStrings.tapToChange,
                      style: TextStyle(color: cs.onPrimaryContainer)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _reminderPreview(cs, tt),
        ],
      );
}
