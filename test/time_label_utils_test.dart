import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:procrastination_treatment_app/core/utils/time_label_utils.dart';

void main() {
  test('formats and parses task time labels', () {
    const time = TimeOfDay(hour: 9, minute: 5);

    expect(formatTimeLabel(time), '09:05');
    expect(parseTimeLabel('19:30'), const TimeOfDay(hour: 19, minute: 30));
    expect(minutesOfDay(const TimeOfDay(hour: 1, minute: 15)), 75);
  });
}
