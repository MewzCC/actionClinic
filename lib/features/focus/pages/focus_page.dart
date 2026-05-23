import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../core/utils/task_status_utils.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/action_widgets.dart';
import '../../../shared/widgets/layout_widgets.dart';
import '../../../shared/widgets/visual_widgets.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({
    super.key,
    required this.task,
    required this.onStarted,
    required this.onPaused,
    required this.onCompleted,
    required this.onPunishment,
    required this.onGentleReminder,
  });

  final ClinicTask task;
  final VoidCallback onStarted;
  final VoidCallback onPaused;
  final VoidCallback onCompleted;
  final VoidCallback onPunishment;
  final VoidCallback onGentleReminder;

  @override
  Widget build(BuildContext context) {
    final isRunning = task.status == TaskStatus.running;
    final progress = task.status == TaskStatus.completed
        ? 1.0
        : 1 - task.remainingSeconds / math.max(1, task.totalSeconds);
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderBlock(
            title: '专注执行中',
            subtitle: '现在就去行动',
            trailing: Icon(Icons.bar_chart_rounded),
            mascotMood: MascotMood.focus,
          ),
          const SizedBox(height: 18),
          GlassPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CountdownRing(
                  progress: progress,
                  time: task.status == TaskStatus.completed
                      ? '完成'
                      : formatClock(task.remainingSeconds),
                  subtitle: isRunning ? '剩余时间' : '等待开始',
                  task: task.title,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MetricPill(
                        icon: Icons.pie_chart_rounded,
                        label: '已坚持',
                        value: '${task.focusSeconds ~/ 60}',
                        unit: '分钟',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        key: const ValueKey('punishment-entry'),
                        behavior: HitTestBehavior.opaque,
                        onTap: onPunishment,
                        child: MetricPill(
                          icon: Icons.warning_amber_rounded,
                          label: '拖延预警',
                          value: '${task.warningCount}',
                          unit: '次',
                          danger: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassPanel(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gpp_good_rounded, color: AppColors.green),
                          SizedBox(width: 8),
                          Text(
                            '本次监督规则',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const RuleLine(
                        icon: Icons.track_changes_rounded,
                        color: AppColors.green,
                        text: '截止前需完成行动',
                      ),
                      RuleLine(
                        icon: Icons.priority_high_rounded,
                        color: AppColors.orange,
                        text: '宽限剩余 ${formatClock(task.graceSeconds)} 后触发提醒',
                      ),
                      RuleLine(
                        icon: Icons.timer_outlined,
                        color: AppColors.blue,
                        text: '验证方式：${verificationText(task.verificationType)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Mascot(size: 92, mood: MascotMood.write),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '快速操作',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ActionChoiceButton(
                  icon: isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  title: isRunning ? '暂停监督' : '我已开始',
                  subtitle: isRunning ? '保留倒计时' : '开始专注打卡',
                  color: AppColors.green,
                  onTap: isRunning ? onPaused : onStarted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionChoiceButton(
                  icon: Icons.check_rounded,
                  title: '提前完成',
                  subtitle: '结束本次专注',
                  color: AppColors.orange,
                  onTap: onCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGentleReminder,
                  icon: const Icon(Icons.notifications_rounded),
                  label: const Text('测试弹窗提醒'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('trigger-punishment-button'),
                  onPressed: onPunishment,
                  icon: const Icon(Icons.warning_rounded),
                  label: const Text('触发惩罚页'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onPunishment,
            child: GlassPanel(
              color: const Color(0xFFFFF2EB),
              borderColor: const Color(0xFFFFC9B8),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const PoopFace(size: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '惩罚倒计时',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '若到点仍无动作，将强制全屏提醒',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${formatClock(task.remainingSeconds)} 后触发恶心提醒',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
