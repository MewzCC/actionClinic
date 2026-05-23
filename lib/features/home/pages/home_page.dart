import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../core/utils/task_status_utils.dart';
import '../../../data/models/app_statistics.dart';
import '../../../data/models/app_setting_model.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/action_widgets.dart';
import '../../../shared/widgets/layout_widgets.dart';
import '../../../shared/widgets/visual_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.task,
    required this.tasks,
    required this.settings,
    required this.onStart,
    required this.onComplete,
    required this.onReset,
    required this.onToggleGross,
    required this.onOpenAllTasks,
    required this.onOpenWidget,
    required this.onOpenTask,
    required this.onCompleteTask,
    required this.onAddTask,
  });

  final ClinicTask task;
  final List<ClinicTask> tasks;
  final UserSettings settings;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReset;
  final ValueChanged<bool> onToggleGross;
  final VoidCallback onOpenAllTasks;
  final VoidCallback onOpenWidget;
  final ValueChanged<String> onOpenTask;
  final ValueChanged<String> onCompleteTask;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBlock(
            title: '行动治疗所',
            subtitle: '今天别再拖了',
            trailing: const Icon(Icons.event_available_rounded),
            mascotMood: MascotMood.ready,
            onAdd: onAddTask,
          ),
          const SizedBox(height: 18),
          if (tasks.isEmpty)
            EmptyGoalCard(onAddTask: onAddTask)
          else
            HeroGoalCard(task: task, onStart: onStart, onComplete: onComplete),
          const SizedBox(height: 20),
          StatsStrip(statistics: AppStatistics.fromTasks(tasks)),
          const SizedBox(height: 26),
          SectionTitle(
            title: '今日任务',
            action: tasks.isEmpty ? '新增' : '查看全部',
            onAction: tasks.isEmpty ? onAddTask : onOpenAllTasks,
          ),
          const SizedBox(height: 12),
          TaskListCard(
            tasks: tasks,
            onOpenTask: onOpenTask,
            onCompleteTask: onCompleteTask,
            onAddTask: onAddTask,
          ),
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            PunishmentPreviewCard(
              task: task,
              enabled: settings.grossMode,
              onChanged: onToggleGross,
            ),
            const SizedBox(height: 18),
            FloatingWindowPreview(
              enabled: settings.floatingWindowEnabled,
              widgetEnabled: settings.widgetEnabled,
              onOpenWidget: onOpenWidget,
            ),
            const SizedBox(height: 12),
          ],
          if (tasks.isNotEmpty)
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('清空任务数据'),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class HeroGoalCard extends StatelessWidget {
  const HeroGoalCard({
    super.key,
    required this.task,
    required this.onStart,
    required this.onComplete,
  });

  final ClinicTask task;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final completed = task.status == TaskStatus.completed;
    final progress = completed
        ? 1.0
        : 1 - task.remainingSeconds / math.max(1, task.totalSeconds);
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftBadge(text: '🎯 今日主目标', color: AppColors.green),
                const SizedBox(height: 18),
                Text(
                  completed ? '任务已完成' : task.title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '今天 ${task.deadlineLabel} 截止',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: BigActionButton(
                        label: completed ? '已完成' : '立即开始',
                        icon: completed
                            ? Icons.check_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: completed ? onComplete : onStart,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: '完成打卡',
                      onPressed: onComplete,
                      icon: const Icon(Icons.done_all_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 124,
            height: 124,
            child: CountdownRing(
              progress: progress,
              time: completed
                  ? '100%'
                  : '${(progress * 100).clamp(0, 100).round()}%',
              subtitle: '进度',
              task: statusText(task.status),
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyGoalCard extends StatelessWidget {
  const EmptyGoalCard({super.key, required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Mascot(size: 94, mood: MascotMood.write),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SoftBadge(text: '还没有任务', color: AppColors.green),
                const SizedBox(height: 12),
                const Text(
                  '先添加一个今天要完成的行动',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  '新增后会进入计划页，可设置时间、惩罚规则和拦截退出。',
                  style: TextStyle(color: AppColors.muted, height: 1.35),
                ),
                const SizedBox(height: 16),
                BigActionButton(
                  label: '新增任务',
                  icon: Icons.add_rounded,
                  onPressed: onAddTask,
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.statistics});

  final AppStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: '所有已保存任务的实际专注秒数累计，任务运行时会实时增加。',
            child: StatCard(
              icon: Icons.timer_rounded,
              title: '专注时长',
              value: (statistics.focusSeconds / 3600).toStringAsFixed(1),
              unit: '小时',
              detail: '累计真实计时',
              color: AppColors.green,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Tooltip(
            message: '任务被惩罚、放弃或自动记录拖延时累加。',
            child: StatCard(
              icon: Icons.alarm_rounded,
              title: '拖延次数',
              value: '${statistics.delayCount}',
              unit: '次',
              detail: '来自任务记录',
              color: AppColors.red,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Tooltip(
            message: '已完成任务数 / 全部已保存任务数。',
            child: StatCard(
              icon: Icons.bar_chart_rounded,
              title: '执行率',
              value: '${statistics.executionRate}',
              unit: '%',
              detail:
                  '${statistics.completedCount}/${statistics.totalCount} 完成',
              color: AppColors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              Tooltip(
                message: detail,
                child: Icon(Icons.info_outline_rounded, size: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(unit, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          MiniWave(color: color),
        ],
      ),
    );
  }
}

class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.tasks,
    required this.onOpenTask,
    required this.onCompleteTask,
    required this.onAddTask,
  });

  final List<ClinicTask> tasks;
  final ValueChanged<String> onOpenTask;
  final ValueChanged<String> onCompleteTask;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_add,
                    color: AppColors.green,
                    size: 42,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '暂无任务',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '点击新增后，任务会保存到本地。',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onAddTask,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('新增任务'),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < tasks.take(3).length; i++) ...[
            TaskRow(
              title: tasks[i].title,
              time: '今天 ${tasks[i].deadlineLabel} 截止',
              status: statusText(tasks[i].status),
              statusColor: statusColor(tasks[i].status),
              checked: tasks[i].status == TaskStatus.completed,
              onTap: () => onOpenTask(tasks[i].id),
              onCheck: () => onCompleteTask(tasks[i].id),
            ),
            if (i != tasks.take(3).length - 1)
              const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    this.checked = false,
    this.onTap,
    this.onCheck,
    this.trailing,
  });

  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final bool checked;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            InkWell(
              onTap: onCheck,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: checked ? AppColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checked ? AppColors.green : const Color(0xFFB8C3CE),
                    width: 2,
                  ),
                ),
                child: checked
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.muted,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing ?? SoftBadge(text: status, color: statusColor),
          ],
        ),
      ),
    );
  }
}

class PunishmentPreviewCard extends StatelessWidget {
  const PunishmentPreviewCard({
    super.key,
    required this.task,
    required this.enabled,
    required this.onChanged,
  });

  final ClinicTask task;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: const Color(0xFFFFEEE8),
      borderColor: const Color(0xFFFFD4C9),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const PoopFace(size: 86),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '恶心提醒模式',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoftBadge(
                      text: enabled ? '已开启' : '已关闭',
                      color: enabled ? AppColors.red : AppColors.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '剩余 ${formatClock(task.remainingSeconds)}，超时未行动将触发全屏提醒',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppColors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class FloatingWindowPreview extends StatelessWidget {
  const FloatingWindowPreview({
    super.key,
    required this.enabled,
    required this.widgetEnabled,
    required this.onOpenWidget,
  });

  final bool enabled;
  final bool widgetEnabled;
  final VoidCallback onOpenWidget;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: Colors.white,
      child: Row(
        children: [
          const Mascot(size: 58, mood: MascotMood.focus),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '悬浮监督小窗',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  enabled ? '已启用，可拖动、收起、开始/完成' : '已关闭，可在我的页面开启',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpenWidget,
            child: Text(widgetEnabled ? '小组件' : '未同步'),
          ),
        ],
      ),
    );
  }
}
