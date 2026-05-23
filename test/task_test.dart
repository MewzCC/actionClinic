import 'package:flutter_test/flutter_test.dart';
import 'package:procrastination_treatment_app/data/models/task_model.dart';

void main() {
  test('copyWith keeps unchanged fields and updates requested fields', () {
    final task = ClinicTask.initial();
    final updated = task.copyWith(title: '写日报', status: TaskStatus.running);

    expect(updated.title, '写日报');
    expect(updated.status, TaskStatus.running);
    expect(updated.description, task.description);
    expect(updated.deadlineLabel, task.deadlineLabel);
  });
}
