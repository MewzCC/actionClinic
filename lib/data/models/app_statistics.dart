import 'task_model.dart';

class AppStatistics {
  const AppStatistics({
    required this.focusSeconds,
    required this.delayCount,
    required this.executionRate,
    required this.completedCount,
    required this.totalCount,
  });

  final int focusSeconds;
  final int delayCount;
  final int executionRate;
  final int completedCount;
  final int totalCount;

  factory AppStatistics.fromTasks(List<ClinicTask> tasks) {
    final total = tasks.length;
    final completed = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final failed = tasks
        .where(
          (task) =>
              task.status == TaskStatus.abandoned ||
              task.status == TaskStatus.punished,
        )
        .length;

    return AppStatistics(
      focusSeconds: tasks.fold(0, (sum, task) => sum + task.focusSeconds),
      delayCount: tasks.fold(0, (sum, task) => sum + task.delayCount) + failed,
      executionRate: total == 0 ? 0 : ((completed / total) * 100).round(),
      completedCount: completed,
      totalCount: tasks.length,
    );
  }
}
