import 'package:flutter_test/flutter_test.dart';
import 'package:procrastination_treatment_app/data/models/app_setting_model.dart';
import 'package:procrastination_treatment_app/features/app/controllers/app_controller.dart';

void main() {
  test('disabled notification setting suppresses popup event', () {
    final controller = AppController();
    controller.settings = UserSettings.initial().copyWith(notificationEnabled: false);

    controller.showGentleReminder();

    expect(controller.drainEvents(), isEmpty);
    controller.dispose();
  });
}
