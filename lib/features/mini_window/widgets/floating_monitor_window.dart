import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../core/utils/task_status_utils.dart';
import '../../../data/models/task_model.dart';

class FloatingMonitorWindow extends StatelessWidget {
  const FloatingMonitorWindow({
    super.key,
    required this.task,
    required this.offset,
    required this.collapsed,
    required this.onDrag,
    required this.onToggleCollapse,
    required this.onStart,
    required this.onComplete,
    required this.onPunish,
  });

  final ClinicTask task;
  final Offset offset;
  final bool collapsed;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onToggleCollapse;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onPunish;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: collapsed ? 72 : 332,
          padding: EdgeInsets.all(collapsed ? 10 : 12),
          decoration: BoxDecoration(
            color: task.status == TaskStatus.punished
                ? const Color(0xFFFFE3D8)
                : Colors.white.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(collapsed ? 30 : 22),
            border: Border.all(
              color: task.status == TaskStatus.punished
                  ? AppColors.red.withValues(alpha: .42)
                  : AppColors.green.withValues(alpha: .26),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: collapsed
              ? _Collapsed(task: task, onTap: onToggleCollapse)
              : _Expanded(
                  task: task,
                  onStart: onStart,
                  onComplete: onComplete,
                  onPunish: onPunish,
                  onToggleCollapse: onToggleCollapse,
                ),
        ),
      ),
    );
  }
}

class _Collapsed extends StatelessWidget {
  const _Collapsed({required this.task, required this.onTap});
  final ClinicTask task;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            task.status == TaskStatus.punished
                ? Icons.warning_rounded
                : Icons.timer_rounded,
            color: task.status == TaskStatus.punished
                ? AppColors.red
                : AppColors.green,
          ),
          Text(
            formatClock(task.remainingSeconds),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Expanded extends StatelessWidget {
  const _Expanded({
    required this.task,
    required this.onStart,
    required this.onComplete,
    required this.onPunish,
    required this.onToggleCollapse,
  });
  final ClinicTask task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onPunish;
  final VoidCallback onToggleCollapse;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: task.status == TaskStatus.punished
              ? AppColors.red
              : AppColors.green,
          child: const Icon(Icons.timer_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatClock(task.remainingSeconds)} · ${statusText(task.status)}',
                style: TextStyle(
                  color: task.status == TaskStatus.punished
                      ? AppColors.red
                      : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: '开始',
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded, color: AppColors.green),
        ),
        IconButton(
          tooltip: '完成',
          onPressed: onComplete,
          icon: const Icon(Icons.check_rounded, color: AppColors.orange),
        ),
        IconButton(
          tooltip: task.status == TaskStatus.punished ? '打开惩罚' : '收起',
          onPressed: task.status == TaskStatus.punished
              ? onPunish
              : onToggleCollapse,
          icon: Icon(
            task.status == TaskStatus.punished
                ? Icons.warning_rounded
                : Icons.remove_rounded,
            color: task.status == TaskStatus.punished
                ? AppColors.red
                : AppColors.muted,
          ),
        ),
      ],
    );
  }
}
