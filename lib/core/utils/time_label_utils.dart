import 'package:flutter/material.dart';

TimeOfDay parseTimeLabel(String label) {
  final parts = label.split(':');
  if (parts.length != 2) return const TimeOfDay(hour: 0, minute: 0);
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
}

String formatTimeLabel(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int minutesOfDay(TimeOfDay time) => time.hour * 60 + time.minute;

String formatMinutesOfDay(int minutes) {
  final normalized = minutes % (24 * 60);
  final hour = normalized ~/ 60;
  final minute = normalized % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

int positiveMinutesBetweenLabels(String startLabel, String deadlineLabel) {
  final start = minutesOfDay(parseTimeLabel(startLabel));
  final deadline = minutesOfDay(parseTimeLabel(deadlineLabel));
  final diff = deadline - start;
  return diff > 0 ? diff : diff + 24 * 60;
}
