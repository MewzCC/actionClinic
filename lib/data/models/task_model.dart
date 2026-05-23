enum TaskStatus { waiting, monitoring, running, completed, punished, abandoned }

enum VerificationType { manual, appLaunch, sensor, photo, focusDuration }

enum PunishmentType { gentle, vibration, gross }

enum PunishmentIntensity { light, medium, heavy }

class ClinicTask {
  const ClinicTask({
    required this.id,
    required this.title,
    required this.description,
    required this.startLabel,
    required this.deadlineLabel,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.graceSeconds,
    required this.focusSeconds,
    required this.warningCount,
    required this.delayCount,
    required this.verificationType,
    required this.punishmentType,
    required this.intensity,
    required this.blockExit,
    required this.status,
    required this.createdAtMillis,
    this.completedAtMillis,
  });

  factory ClinicTask.initial() {
    return const ClinicTask(
      id: 'task_prd',
      title: '完成产品需求文档',
      description: '梳理核心需求，输出 PRD 初稿',
      startLabel: '19:00',
      deadlineLabel: '20:00',
      totalSeconds: 25 * 60,
      remainingSeconds: 24 * 60 + 18,
      graceSeconds: 5 * 60,
      focusSeconds: 35 * 60,
      warningCount: 1,
      delayCount: 3,
      verificationType: VerificationType.manual,
      punishmentType: PunishmentType.gross,
      intensity: PunishmentIntensity.medium,
      blockExit: true,
      status: TaskStatus.waiting,
      createdAtMillis: 0,
    );
  }

  factory ClinicTask.draft() {
    return const ClinicTask(
      id: 'task_draft',
      title: '新的行动任务',
      description: '写清楚下一步要完成什么',
      startLabel: '19:00',
      deadlineLabel: '20:00',
      totalSeconds: 25 * 60,
      remainingSeconds: 25 * 60,
      graceSeconds: 5 * 60,
      focusSeconds: 0,
      warningCount: 0,
      delayCount: 0,
      verificationType: VerificationType.manual,
      punishmentType: PunishmentType.gross,
      intensity: PunishmentIntensity.medium,
      blockExit: true,
      status: TaskStatus.waiting,
      createdAtMillis: 0,
    );
  }

  factory ClinicTask.readingSeed() {
    return const ClinicTask(
      id: 'task_reading',
      title: '阅读《深入理解系统设计》第3章',
      description: '记录 3 个可复用的系统设计要点',
      startLabel: '19:30',
      deadlineLabel: '20:00',
      totalSeconds: 30 * 60,
      remainingSeconds: 30 * 60,
      graceSeconds: 5 * 60,
      focusSeconds: 0,
      warningCount: 0,
      delayCount: 0,
      verificationType: VerificationType.manual,
      punishmentType: PunishmentType.gentle,
      intensity: PunishmentIntensity.light,
      blockExit: false,
      status: TaskStatus.waiting,
      createdAtMillis: 0,
    );
  }

  factory ClinicTask.exerciseSeed() {
    return const ClinicTask(
      id: 'task_exercise',
      title: '30 分钟运动（跑步或 HIIT）',
      description: '完成一次能出汗的身体行动',
      startLabel: '21:00',
      deadlineLabel: '21:30',
      totalSeconds: 30 * 60,
      remainingSeconds: 30 * 60,
      graceSeconds: 5 * 60,
      focusSeconds: 0,
      warningCount: 0,
      delayCount: 0,
      verificationType: VerificationType.manual,
      punishmentType: PunishmentType.vibration,
      intensity: PunishmentIntensity.medium,
      blockExit: false,
      status: TaskStatus.waiting,
      createdAtMillis: 0,
    );
  }

  factory ClinicTask.create({
    required String title,
    required String description,
    String startLabel = '19:00',
    String deadlineLabel = '20:00',
    int durationMinutes = 25,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ClinicTask.initial().copyWith(
      id: 'task_$now',
      title: title,
      description: description,
      startLabel: startLabel,
      deadlineLabel: deadlineLabel,
      totalSeconds: durationMinutes * 60,
      remainingSeconds: durationMinutes * 60,
      focusSeconds: 0,
      warningCount: 0,
      delayCount: 0,
      status: TaskStatus.waiting,
      createdAtMillis: now,
      completedAtMillis: null,
    );
  }

  final String id;
  final String title;
  final String description;
  final String startLabel;
  final String deadlineLabel;
  final int totalSeconds;
  final int remainingSeconds;
  final int graceSeconds;
  final int focusSeconds;
  final int warningCount;
  final int delayCount;
  final VerificationType verificationType;
  final PunishmentType punishmentType;
  final PunishmentIntensity intensity;
  final bool blockExit;
  final TaskStatus status;
  final int createdAtMillis;
  final int? completedAtMillis;

  static List<ClinicTask> seedTasks() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      ClinicTask.initial().copyWith(createdAtMillis: now - 2 * 60 * 60 * 1000),
      ClinicTask.readingSeed().copyWith(createdAtMillis: now - 90 * 60 * 1000),
      ClinicTask.exerciseSeed().copyWith(createdAtMillis: now - 30 * 60 * 1000),
    ];
  }

  ClinicTask copyWith({
    String? id,
    String? title,
    String? description,
    String? startLabel,
    String? deadlineLabel,
    int? totalSeconds,
    int? remainingSeconds,
    int? graceSeconds,
    int? focusSeconds,
    int? warningCount,
    int? delayCount,
    VerificationType? verificationType,
    PunishmentType? punishmentType,
    PunishmentIntensity? intensity,
    bool? blockExit,
    TaskStatus? status,
    int? createdAtMillis,
    Object? completedAtMillis = _sentinel,
  }) {
    return ClinicTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startLabel: startLabel ?? this.startLabel,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      graceSeconds: graceSeconds ?? this.graceSeconds,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      warningCount: warningCount ?? this.warningCount,
      delayCount: delayCount ?? this.delayCount,
      verificationType: verificationType ?? this.verificationType,
      punishmentType: punishmentType ?? this.punishmentType,
      intensity: intensity ?? this.intensity,
      blockExit: blockExit ?? this.blockExit,
      status: status ?? this.status,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      completedAtMillis: identical(completedAtMillis, _sentinel)
          ? this.completedAtMillis
          : completedAtMillis as int?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startLabel': startLabel,
      'deadlineLabel': deadlineLabel,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'graceSeconds': graceSeconds,
      'focusSeconds': focusSeconds,
      'warningCount': warningCount,
      'delayCount': delayCount,
      'verificationType': verificationType.index,
      'punishmentType': punishmentType.index,
      'intensity': intensity.index,
      'blockExit': blockExit,
      'status': status.index,
      'createdAtMillis': createdAtMillis,
      'completedAtMillis': completedAtMillis,
    };
  }

  factory ClinicTask.fromJson(Map<String, Object?> json) {
    final fallback = ClinicTask.initial();
    return ClinicTask(
      id: json['id'] as String? ?? fallback.id,
      title: json['title'] as String? ?? fallback.title,
      description: json['description'] as String? ?? fallback.description,
      startLabel: json['startLabel'] as String? ?? fallback.startLabel,
      deadlineLabel: json['deadlineLabel'] as String? ?? fallback.deadlineLabel,
      totalSeconds: json['totalSeconds'] as int? ?? fallback.totalSeconds,
      remainingSeconds:
          json['remainingSeconds'] as int? ?? fallback.remainingSeconds,
      graceSeconds: json['graceSeconds'] as int? ?? fallback.graceSeconds,
      focusSeconds: json['focusSeconds'] as int? ?? fallback.focusSeconds,
      warningCount: json['warningCount'] as int? ?? fallback.warningCount,
      delayCount: json['delayCount'] as int? ?? fallback.delayCount,
      verificationType: _enumAt(
        VerificationType.values,
        json['verificationType'],
        fallback.verificationType,
      ),
      punishmentType: _enumAt(
        PunishmentType.values,
        json['punishmentType'],
        fallback.punishmentType,
      ),
      intensity: _enumAt(
        PunishmentIntensity.values,
        json['intensity'],
        fallback.intensity,
      ),
      blockExit: json['blockExit'] as bool? ?? fallback.blockExit,
      status: _enumAt(TaskStatus.values, json['status'], fallback.status),
      createdAtMillis:
          json['createdAtMillis'] as int? ?? fallback.createdAtMillis,
      completedAtMillis: json['completedAtMillis'] as int?,
    );
  }
}

const _sentinel = Object();

T _enumAt<T>(List<T> values, Object? raw, T fallback) {
  if (raw is! int || raw < 0 || raw >= values.length) return fallback;
  return values[raw];
}
