import 'package:flutter_test/flutter_test.dart';
import 'package:solar_clean/core/app_defaults.dart';

void main() {
  test('atTime adds days and sets clock', () {
    final base = DateTime(2026, 1, 1);
    final due = atTime(base, 20, 22, 0);
    expect(due, DateTime(2026, 1, 21, 22, 0));
  });
}
