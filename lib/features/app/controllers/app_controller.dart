import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/countdown_utils.dart';
import '../../../data/models/app_setting_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/app_state_repository.dart';
import '../../../services/platform/android_channel.dart';

enum AppEventType { snack, popup, punishment }

class AppEvent {
  const AppEvent({
    required this.type,
    required this.title,
    this.message,
    this.auto = false,
  });

  final AppEventType type;
  final String title;
  final String? message;
  final bool auto;
}

class AppController extends ChangeNotifier {
  AppController({AppStateRepository? repository})
    : _repository = repository ?? AppStateRepository();

  final AppStateRepository _repository;
  Timer? _ticker;
  final List<AppEvent> _events = [];
  bool _punishmentOpen = false;
  int _lastTickPersistMillis = 0;

  int selectedIndex = 0;
  List<ClinicTask> tasks = const [];
  String currentTaskId = '';
  UserSettings settings = UserSettings.initial();
  bool floatingCollapsed = false;
  Offset floatingOffset = const Offset(18, 700);

  ClinicTask get task {
    if (tasks.isEmpty || currentTaskId.isEmpty) return ClinicTask.draft();
    return tasks.firstWhere(
      (candidate) => candidate.id == currentTaskId,
      orElse: () => tasks.first,
    );
  }

  set task(ClinicTask value) {
    _upsertTask(value);
  }

  bool get taskActive {
    return task.status == TaskStatus.monitoring ||
        task.status == TaskStatus.running ||
        task.status == TaskStatus.punished;
  }

  bool get isCreatingTask => currentTaskId.isEmpty;

  void startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> loadPersistedState() async {
    final state = await _repository.load();
    tasks = state.tasks;
    currentTaskId =
        tasks.any((candidate) => candidate.id == state.currentTaskId)
        ? state.currentTaskId
        : (tasks.isEmpty ? '' : tasks.first.id);
    settings = state.settings;
    if (tasks.isNotEmpty) await AndroidChannel.syncWidget(task);
    notifyListeners();
  }

  @visibleForTesting
  void tick() {
    var nextTask = task;
    var changed = false;

    if (nextTask.status == TaskStatus.monitoring) {
      nextTask = nextTask.copyWith(
        graceSeconds: math.max(0, nextTask.graceSeconds - 1),
      );
      changed = true;
      if (nextTask.graceSeconds == 60 && nextTask.warningCount < 2) {
        nextTask = nextTask.copyWith(warningCount: nextTask.warningCount + 1);
        _emitPopup('宽限预警', '还有 1 分钟宽限期，快点开始行动。');
      }
      if (nextTask.graceSeconds == 0) {
        task = nextTask;
        triggerPunishment(auto: true);
        return;
      }
    }

    if (nextTask.status == TaskStatus.running) {
      nextTask = nextTask.copyWith(
        focusSeconds: nextTask.focusSeconds + 1,
        remainingSeconds: math.max(0, nextTask.remainingSeconds - 1),
      );
      changed = true;
      if (nextTask.remainingSeconds == 5 * 60) {
        nextTask = nextTask.copyWith(warningCount: nextTask.warningCount + 1);
        _emitPopup('截止预警', '距离截止还剩 5 分钟，再冲一下。');
      }
      if (nextTask.remainingSeconds == 0) {
        task = nextTask;
        triggerPunishment(auto: true);
        return;
      }
    }

    if (changed) {
      _upsertTask(nextTask);
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastTickPersistMillis > 15000 ||
          nextTask.remainingSeconds == 0 ||
          nextTask.graceSeconds == 0) {
        _lastTickPersistMillis = now;
        _persist();
        AndroidChannel.syncWidget(nextTask);
      }
      notifyListeners();
    }
  }

  List<AppEvent> drainEvents() {
    final drained = List<AppEvent>.from(_events);
    _events.clear();
    return drained;
  }

  void selectTab(int index) {
    if (tasks.isEmpty && index == 2) {
      selectedIndex = 1;
      _emitSnack('请先新增一个任务，再进入专注。');
      notifyListeners();
      return;
    }
    selectedIndex = index;
    notifyListeners();
  }

  void selectTask(String id, {int? tabIndex}) {
    if (!tasks.any((candidate) => candidate.id == id)) return;
    currentTaskId = id;
    if (tabIndex != null) selectedIndex = tabIndex;
    _persist();
    notifyListeners();
  }

  void beginCreateTask() {
    currentTaskId = '';
    selectedIndex = 1;
    notifyListeners();
  }

  void beginEditTask(String id) {
    if (!tasks.any((candidate) => candidate.id == id)) return;
    currentTaskId = id;
    selectedIndex = 1;
    notifyListeners();
  }

  void addTask(ClinicTask nextTask) {
    tasks = [...tasks, nextTask];
    currentTaskId = nextTask.id;
    selectedIndex = 1;
    _emitSnack('已添加任务：${nextTask.title}');
    _persist();
    AndroidChannel.syncWidget(nextTask);
    notifyListeners();
  }

  void updateTask(ClinicTask nextTask) {
    _upsertTask(nextTask, persist: true);
    currentTaskId = nextTask.id;
    _emitSnack('任务已保存。');
    AndroidChannel.syncWidget(nextTask);
    notifyListeners();
  }

  void deleteTask(String id) {
    final removed = tasks.firstWhere((candidate) => candidate.id == id);
    tasks = tasks.where((candidate) => candidate.id != id).toList();
    if (currentTaskId == id) {
      currentTaskId = tasks.isEmpty ? '' : tasks.first.id;
    }
    _emitSnack('已删除任务：${removed.title}');
    _persist();
    if (tasks.isNotEmpty) AndroidChannel.syncWidget(task);
    notifyListeners();
  }

  void startMonitoring(ClinicTask nextTask) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final monitored = nextTask.copyWith(
      id: nextTask.id == 'task_draft' ? 'task_$now' : nextTask.id,
      createdAtMillis: nextTask.createdAtMillis == 0
          ? now
          : nextTask.createdAtMillis,
      status: TaskStatus.monitoring,
    );
    _upsertTask(monitored, persist: true);
    currentTaskId = monitored.id;
    selectedIndex = 2;
    floatingCollapsed = false;
    _emitSnack('监督已启动。宽限倒计时开始。');
    _emitPopup('监督已开启', '到点未行动会触发递进提醒，最终进入全屏惩罚页。');
    AndroidChannel.scheduleReminders(monitored);
    AndroidChannel.syncWidget(monitored);
    notifyListeners();
  }

  void startTask() {
    final running = task.copyWith(status: TaskStatus.running);
    _upsertTask(running, persist: true);
    selectedIndex = 2;
    floatingCollapsed = false;
    _emitSnack('已开始行动，专注计时运行中。');
    if (settings.minorSafeMode || running.blockExit) {
      AndroidChannel.startStrictFocus(running);
    }
    AndroidChannel.scheduleReminders(running);
    AndroidChannel.syncWidget(running);
    notifyListeners();
  }

  void pauseTask() {
    if (task.status != TaskStatus.running) return;
    final paused = task.copyWith(status: TaskStatus.monitoring);
    _upsertTask(paused, persist: true);
    _emitSnack('已暂停，监督仍在继续。');
    AndroidChannel.stopStrictFocus();
    AndroidChannel.syncWidget(paused);
    notifyListeners();
  }

  void completeTask() {
    if (task.status == TaskStatus.completed) {
      final reopened = task.copyWith(
        status: TaskStatus.waiting,
        remainingSeconds: task.totalSeconds,
        completedAtMillis: null,
      );
      _upsertTask(reopened, persist: true);
      _emitSnack('已恢复为未完成。');
      AndroidChannel.syncWidget(reopened);
      notifyListeners();
      return;
    }
    final completed = task.copyWith(
      status: TaskStatus.completed,
      remainingSeconds: 0,
      completedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    _upsertTask(completed, persist: true);
    _punishmentOpen = false;
    floatingCollapsed = false;
    _emitSnack('打卡完成，今日拖延被你拿下了。');
    AndroidChannel.cancelReminders();
    AndroidChannel.stopStrictFocus();
    AndroidChannel.syncWidget(completed);
    notifyListeners();
  }

  void abandonTask() {
    final abandoned = task.copyWith(
      status: TaskStatus.abandoned,
      delayCount: task.delayCount + 1,
    );
    _upsertTask(abandoned, persist: true);
    _punishmentOpen = false;
    _emitSnack('已记录一次放弃任务。');
    AndroidChannel.cancelReminders();
    AndroidChannel.stopStrictFocus();
    AndroidChannel.syncWidget(abandoned);
    notifyListeners();
  }

  void resetTask() {
    tasks = const [];
    currentTaskId = '';
    selectedIndex = 0;
    _punishmentOpen = false;
    floatingCollapsed = false;
    _emitSnack('任务与统计已清空。');
    _persist();
    AndroidChannel.cancelReminders();
    AndroidChannel.stopStrictFocus();
    notifyListeners();
  }

  void triggerPunishment({bool auto = false}) {
    if (!settings.grossMode || _punishmentOpen) return;
    _punishmentOpen = true;
    final punished = task.copyWith(
      status: TaskStatus.punished,
      warningCount: task.warningCount + (auto ? 1 : 0),
      delayCount: task.delayCount + (auto ? 1 : 0),
    );
    _upsertTask(punished, persist: true);
    floatingCollapsed = false;
    _events.add(
      AppEvent(type: AppEventType.punishment, title: 'punishment', auto: auto),
    );
    AndroidChannel.syncWidget(punished);
    notifyListeners();
  }

  void closePunishment() {
    _punishmentOpen = false;
    notifyListeners();
  }

  void saveSettings(UserSettings nextSettings) {
    settings = nextSettings;
    _emitSnack('设置已持久化保存。');
    _persist();
    notifyListeners();
  }

  void syncWidget() {
    _emitSnack(
      '桌面小组件数据已同步：${task.title} / ${formatClock(task.remainingSeconds)}',
    );
    AndroidChannel.syncWidget(task);
    notifyListeners();
  }

  void showGentleReminder() {
    _emitPopup('温柔提醒', '你已经计划好了，现在只需要开始第一步。');
    notifyListeners();
  }

  void showWindowPopupDemo() {
    _emitPopup('窗口弹出提示', '这是 App 内弹窗提醒；Android 已接入系统通知与定时闹钟通道。');
    notifyListeners();
  }

  void updateFloatingOffset(Offset delta, Size bounds) {
    floatingOffset = Offset(
      (floatingOffset.dx + delta.dx).clamp(8, bounds.width - 90),
      (floatingOffset.dy + delta.dy).clamp(90, bounds.height - 170),
    );
    notifyListeners();
  }

  void toggleFloatingCollapsed() {
    floatingCollapsed = !floatingCollapsed;
    notifyListeners();
  }

  void _emitSnack(String message) {
    _events.add(AppEvent(type: AppEventType.snack, title: message));
  }

  void _emitPopup(String title, String message) {
    if (!settings.notificationEnabled) return;
    _events.add(
      AppEvent(type: AppEventType.popup, title: title, message: message),
    );
  }

  void _upsertTask(ClinicTask nextTask, {bool persist = false}) {
    final index = tasks.indexWhere((candidate) => candidate.id == nextTask.id);
    if (index == -1) {
      tasks = [...tasks, nextTask];
    } else {
      tasks = [...tasks.take(index), nextTask, ...tasks.skip(index + 1)];
    }
    currentTaskId = nextTask.id;
    if (persist) {
      _persist();
      AndroidChannel.syncWidget(nextTask);
    }
  }

  void _persist() {
    unawaited(
      _repository.save(
        tasks: tasks,
        currentTaskId: currentTaskId,
        settings: settings,
      ),
    );
  }

  @override
  void dispose() {
    _persist();
    _ticker?.cancel();
    super.dispose();
  }
}
