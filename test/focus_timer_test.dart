import 'package:flutter_test/flutter_test.dart';
import 'package:procrastination_treatment_app/data/models/task_model.dart';
import 'package:procrastination_treatment_app/features/app/controllers/app_controller.dart';

void main() {
  test('running task decreases remaining time and increases focus seconds', () {
    final controller = AppController();
    controller.task = ClinicTask.initial().copyWith(
      status: TaskStatus.running,
      totalSeconds: 10,
      remainingSeconds: 10,
      focusSeconds: 0,
    );

    controller.tick();

    expect(controller.task.remainingSeconds, 9);
    expect(controller.task.focusSeconds, 1);
    controller.dispose();
  });

  test('monitoring task triggers punishment when grace time ends', () {
    final controller = AppController();
    controller.task = ClinicTask.initial().copyWith(
      status: TaskStatus.monitoring,
      graceSeconds: 1,
    );

    controller.tick();

    expect(controller.task.status, TaskStatus.punished);
    expect(
      controller.drainEvents().any((event) => event.type == AppEventType.punishment),
      isTrue,
    );
    controller.dispose();
  });
}
