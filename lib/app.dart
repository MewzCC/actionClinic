import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/task_status_utils.dart';
import 'data/models/task_model.dart';
import 'features/app/controllers/app_controller.dart';
import 'features/focus/pages/focus_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/mine/pages/mine_page.dart';
import 'features/mini_window/widgets/floating_monitor_window.dart';
import 'features/plan/pages/plan_page.dart';
import 'features/punishment/pages/punishment_page.dart';
import 'services/platform/android_channel.dart';
import 'shared/widgets/layout_widgets.dart';

class ActionClinicApp extends StatelessWidget {
  const ActionClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '行动治疗所',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController()
      ..addListener(_handleControllerChange)
      ..startTicker();
    _controller.loadPersistedState();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChange)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    setState(() {});
    final events = _controller.drainEvents();
    for (final event in events) {
      switch (event.type) {
        case AppEventType.snack:
          _showSnack(event.title);
        case AppEventType.popup:
          _showPopupReminder(title: event.title, message: event.message ?? '');
        case AppEventType.punishment:
          _openPunishmentRoute();
      }
    }
  }

  void _showSnack(String message) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
        ),
      );
  }

  Future<void> _showPopupReminder({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后处理'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () {
              Navigator.of(context).pop();
              _controller.startTask();
            },
            child: const Text('马上开始'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPunishmentRoute() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PunishmentPage(
          task: _controller.task,
          onStart: () {
            Navigator.of(context).pop();
            _controller.closePunishment();
            _controller.startTask();
          },
          onConfirmStarted: () {
            Navigator.of(context).pop();
            _controller.closePunishment();
            _controller.startTask();
          },
          onComplete: () {
            Navigator.of(context).pop();
            _controller.completeTask();
          },
          onAbandon: () {
            Navigator.of(context).pop();
            _controller.abandonTask();
          },
        ),
      ),
    );
    if (mounted) _controller.closePunishment();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        task: _controller.task,
        tasks: _controller.tasks,
        settings: _controller.settings,
        onStart: _controller.startTask,
        onComplete: _controller.completeTask,
        onReset: _controller.resetTask,
        onToggleGross: (value) {
          _controller.saveSettings(
            _controller.settings.copyWith(grossMode: value),
          );
        },
        onOpenAllTasks: _showAllTasks,
        onOpenWidget: () => _controller.selectTab(3),
        onOpenTask: (id) => _controller.selectTask(id, tabIndex: 2),
        onCompleteTask: (id) {
          _controller.selectTask(id);
          _controller.completeTask();
        },
        onAddTask: _controller.beginCreateTask,
      ),
      PlanPage(
        task: _controller.task,
        isCreating: _controller.isCreatingTask,
        onSave: _controller.startMonitoring,
        onAddTask: _controller.beginCreateTask,
      ),
      FocusPage(
        task: _controller.task,
        onStarted: _controller.startTask,
        onPaused: _controller.pauseTask,
        onCompleted: _controller.completeTask,
        onPunishment: () => _controller.triggerPunishment(auto: false),
        onGentleReminder: _controller.showGentleReminder,
      ),
      MinePage(
        task: _controller.task,
        settings: _controller.settings,
        onSettingsChanged: _controller.saveSettings,
        onSyncWidget: _controller.syncWidget,
        onPopup: _controller.showWindowPopupDemo,
        onReset: _controller.resetTask,
        onOverlayPermission: AndroidChannel.openOverlayPermission,
        onPinTaskWidget: () {
          _controller.syncWidget();
          return AndroidChannel.pinTaskWidget();
        },
        onPinFocusWidget: () {
          _controller.syncWidget();
          return AndroidChannel.pinFocusWidget();
        },
        onPinPunishmentWidget: () {
          _controller.syncWidget();
          return AndroidChannel.pinPunishmentWidget();
        },
      ),
    ];

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final content = Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey(_controller.selectedIndex),
                    child: pages[_controller.selectedIndex],
                  ),
                ),
                if (_controller.settings.floatingWindowEnabled &&
                    _controller.taskActive)
                  FloatingMonitorWindow(
                    task: _controller.task,
                    offset: _controller.floatingOffset,
                    collapsed: _controller.floatingCollapsed,
                    onDrag: (delta) {
                      _controller.updateFloatingOffset(
                        delta,
                        Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                    onToggleCollapse: _controller.toggleFloatingCollapsed,
                    onStart: _controller.startTask,
                    onComplete: _controller.completeTask,
                    onPunish: () => _controller.triggerPunishment(auto: false),
                  ),
              ],
            );

            if (constraints.maxWidth < 720 || constraints.maxHeight < 620) {
              return content;
            }
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEAF8FF), Color(0xFFFFF5EA)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 430,
                  height: math.min(constraints.maxHeight - 40, 920),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.page,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 36,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: content,
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            final nav = AppBottomNav(
              selectedIndex: _controller.selectedIndex,
              onTap: _controller.selectTab,
            );
            if (constraints.maxWidth < 720) return nav;
            return SizedBox(
              height: 78,
              child: Center(child: SizedBox(width: 430, child: nav)),
            );
          },
        ),
      ),
    );
  }

  void _showAllTasks() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '今日全部任务',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _controller.beginCreateTask();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('添加'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _controller.tasks.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.line),
                itemBuilder: (context, index) {
                  final task = _controller.tasks[index];
                  return TaskRow(
                    title: task.title,
                    time: '今天 ${task.deadlineLabel} 截止',
                    status: statusText(task.status),
                    statusColor: statusColor(task.status),
                    checked: task.status == TaskStatus.completed,
                    onTap: () {
                      Navigator.of(context).pop();
                      _controller.selectTask(task.id, tabIndex: 2);
                    },
                    onCheck: () {
                      _controller.selectTask(task.id);
                      _controller.completeTask();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: '编辑任务',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _controller.beginEditTask(task.id);
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.muted,
                          ),
                        ),
                        IconButton(
                          tooltip: '删除任务',
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteTask(task);
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTask(ClinicTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('删除任务'),
        content: Text('确定删除「${task.title}」吗？这会同时更新统计数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _controller.deleteTask(task.id);
  }
}
