import 'dart:math' as math;

String formatClock(int seconds) {
  final value = math.max(0, seconds);
  final minutes = value ~/ 60;
  final secs = value % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
