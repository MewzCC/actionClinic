import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../core/utils/task_status_utils.dart';
import '../../../data/models/app_setting_model.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/action_widgets.dart';
import '../../../shared/widgets/layout_widgets.dart';
import '../../../shared/widgets/visual_widgets.dart';

class MinePage extends StatelessWidget {
  const MinePage({
    super.key,
    required this.task,
    required this.settings,
    required this.onSettingsChanged,
    required this.onSyncWidget,
    required this.onPopup,
    required this.onReset,
    required this.onOverlayPermission,
    required this.onPinTaskWidget,
    required this.onPinFocusWidget,
    required this.onPinPunishmentWidget,
  });

  final ClinicTask task;
  final UserSettings settings;
  final ValueChanged<UserSettings> onSettingsChanged;
  final VoidCallback onSyncWidget;
  final VoidCallback onPopup;
  final VoidCallback onReset;
  final VoidCallback onOverlayPermission;
  final Future<bool> Function() onPinTaskWidget;
  final Future<bool> Function() onPinFocusWidget;
  final Future<bool> Function() onPinPunishmentWidget;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderBlock(
            title: '我的治疗档案',
            subtitle: '把执行力养回来',
            trailing: Icon(Icons.person_outline_rounded),
            mascotMood: MascotMood.ready,
          ),
          const SizedBox(height: 18),
          WidgetPreviewCard(
            task: task,
            onSync: onSyncWidget,
            onPinTask: onPinTaskWidget,
            onPinFocus: onPinFocusWidget,
            onPinPunishment: onPinPunishmentWidget,
          ),
          const SizedBox(height: 18),
          GlassPanel(
            child: Column(
              children: [
                ToggleRow(
                  icon: Icons.notifications_active_rounded,
                  title: '通知/弹窗提醒',
                  value: settings.notificationEnabled,
                  onChanged: (value) => onSettingsChanged(
                    settings.copyWith(notificationEnabled: value),
                  ),
                ),
                ToggleRow(
                  icon: Icons.vibration_rounded,
                  title: '震动提醒',
                  value: settings.vibrationEnabled,
                  onChanged: (value) => onSettingsChanged(
                    settings.copyWith(vibrationEnabled: value),
                  ),
                ),
                ToggleRow(
                  icon: Icons.volume_up_rounded,
                  title: '声音提醒',
                  value: settings.soundEnabled,
                  onChanged: (value) =>
                      onSettingsChanged(settings.copyWith(soundEnabled: value)),
                ),
                ToggleRow(
                  icon: Icons.window_rounded,
                  title: 'App 内悬浮小窗',
                  value: settings.floatingWindowEnabled,
                  onChanged: (value) => onSettingsChanged(
                    settings.copyWith(floatingWindowEnabled: value),
                  ),
                ),
                ToggleRow(
                  icon: Icons.widgets_rounded,
                  title: '桌面小组件同步',
                  value: settings.widgetEnabled,
                  onChanged: (value) => onSettingsChanged(
                    settings.copyWith(widgetEnabled: value),
                  ),
                ),
                ToggleRow(
                  icon: Icons.shield_moon_rounded,
                  title: '强制专注/防切应用',
                  value: settings.minorSafeMode,
                  onChanged: (value) => onSettingsChanged(
                    settings.copyWith(minorSafeMode: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassPanel(
            color: const Color(0xFFEFFFF9),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.orange,
                      size: 42,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '连续完成 5 天，距离“反拖延小能手”还差 2 天。',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPopup,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('测试窗口弹出'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOverlayPermission,
                        icon: const Icon(Icons.admin_panel_settings_rounded),
                        label: const Text('授权悬浮窗'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重置数据'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PermissionGuideCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class WidgetPreviewCard extends StatelessWidget {
  const WidgetPreviewCard({
    super.key,
    required this.task,
    required this.onSync,
    required this.onPinTask,
    required this.onPinFocus,
    required this.onPinPunishment,
  });

  final ClinicTask task;
  final VoidCallback onSync;
  final Future<bool> Function() onPinTask;
  final Future<bool> Function() onPinFocus;
  final Future<bool> Function() onPinPunishment;

  Future<void> _pin(
    BuildContext context,
    Future<bool> Function() request,
    String name,
  ) async {
    onSync();
    final messenger = ScaffoldMessenger.of(context);
    final requested = await request();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: requested ? AppColors.ink : AppColors.orange,
          content: Text(
            requested
                ? '已向桌面发送“$name”添加请求，请在系统弹窗中确认。'
                : '当前系统不支持应用内添加，请长按手机桌面 > 小组件 > 行动治疗所。',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: const Color(0xFFEDFFF9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.widgets_rounded,
                color: AppColors.green,
                size: 30,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '桌面小组件预览',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.tonal(onPressed: onSync, child: const Text('同步')),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '同步会刷新桌面组件内容；添加会调用 Android 系统小组件面板。',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.green.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: statusColor(task.status),
                  child: const Icon(Icons.timer_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Mascot(size: 54, mood: MascotMood.focus),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pin(context, onPinTask, '行动任务'),
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('添加任务组件'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pin(context, onPinFocus, '专注倒计时'),
                icon: const Icon(Icons.timer_rounded),
                label: const Text('添加专注组件'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pin(context, onPinPunishment, '拖延提醒'),
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('添加惩罚组件'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class PermissionGuideCard extends StatelessWidget {
  const PermissionGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '权限接入说明',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          RuleLine(
            icon: Icons.notifications_rounded,
            color: AppColors.green,
            text: '通知权限：Android 已接入 AlarmManager + 全屏高优先级通知。',
          ),
          RuleLine(
            icon: Icons.window_rounded,
            color: AppColors.blue,
            text: '强制专注：Android 使用锁定任务/全屏提醒；完全禁止 Home 键需要系统屏幕固定或设备所有者授权。',
          ),
          RuleLine(
            icon: Icons.widgets_rounded,
            color: AppColors.orange,
            text:
                '桌面小组件：Android 已注册任务、专注、惩罚三类 App Widget，可在本页一键添加，或长按桌面从小组件面板添加。',
          ),
        ],
      ),
    );
  }
}
