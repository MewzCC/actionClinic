import 'package:flutter_test/flutter_test.dart';
import 'package:procrastination_treatment_app/data/models/app_setting_model.dart';
import 'package:procrastination_treatment_app/data/models/task_model.dart';
import 'package:procrastination_treatment_app/features/app/controllers/app_controller.dart';

void main() {
  test('gross mode off prevents punishment route event', () {
    final controller = AppController();
    controller.settings = UserSettings.initial().copyWith(grossMode: false);
    controller.task = ClinicTask.initial().copyWith(status: TaskStatus.running);

    controller.triggerPunishment();

    expect(controller.task.status, TaskStatus.running);
    expect(controller.drainEvents(), isEmpty);
    controller.dispose();
  });
}
