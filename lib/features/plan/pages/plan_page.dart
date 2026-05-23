import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_label_utils.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/action_widgets.dart';
import '../../../shared/widgets/layout_widgets.dart';
import '../../../shared/widgets/visual_widgets.dart';
import '../widgets/plan_time_picker_sheet.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({
    super.key,
    required this.task,
    required this.isCreating,
    required this.onSave,
    required this.onAddTask,
  });

  final ClinicTask task;
  final bool isCreating;
  final ValueChanged<ClinicTask> onSave;
  final VoidCallback onAddTask;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late String _title;
  late String _description;
  late String _start;
  late String _deadline;
  late int _durationMinutes;
  late int _graceMinutes;
  late VerificationType _verify;
  late PunishmentType _rule;
  late PunishmentIntensity _intensity;
  late bool _blockExit;

  @override
  void initState() {
    super.initState();
    _load(widget.task);
  }

  @override
  void didUpdateWidget(covariant PlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) _load(widget.task);
  }

  void _load(ClinicTask task) {
    _title = task.title;
    _description = task.description;
    _start = task.startLabel;
    _deadline = task.deadlineLabel;
    _durationMinutes = math.max(
      1,
      positiveMinutesBetweenLabels(task.startLabel, task.deadlineLabel),
    );
    _graceMinutes = math.max(1, (task.graceSeconds / 60).round());
    _verify = task.verificationType;
    _rule = task.punishmentType;
    _intensity = task.intensity;
    _blockExit = task.blockExit;
  }

  void _save() {
    final durationMinutes = math.max(1, _durationMinutes);
    final title = _title.trim().isEmpty ? '新的行动任务' : _title.trim();
    final description = _description.trim().isEmpty
        ? '写清楚下一步要完成什么'
        : _description.trim();
    widget.onSave(
      widget.task.copyWith(
        title: title,
        description: description,
        startLabel: _start,
        deadlineLabel: _deadline,
        totalSeconds: durationMinutes * 60,
        remainingSeconds: durationMinutes * 60,
        graceSeconds: _graceMinutes * 60,
        verificationType: _verify,
        punishmentType: _rule,
        intensity: _intensity,
        blockExit: _blockExit,
        status: TaskStatus.monitoring,
      ),
    );
  }

  void _syncDurationFromTime() {
    setState(() {
      _durationMinutes = positiveMinutesBetweenLabels(_start, _deadline);
    });
  }

  void _changeDuration(int delta) {
    setState(() {
      _durationMinutes = math.max(1, _durationMinutes + delta);
      final startMinutes = minutesOfDay(parseTimeLabel(_start));
      _deadline = formatMinutesOfDay(startMinutes + _durationMinutes);
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final result = await showPlanTimePickerSheet(
      context: context,
      title: isStart ? '设置开始时间' : '设置截止时间',
      subtitle: isStart ? '到点开始监督行动' : '超过时间会升级提醒',
      initialLabel: isStart ? _start : _deadline,
    );
    if (result == null) return;
    setState(() {
      if (isStart) {
        _start = result;
      } else {
        _deadline = result;
      }
      _durationMinutes = positiveMinutesBetweenLabels(_start, _deadline);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBlock(
            title: '行动计划',
            subtitle: widget.isCreating ? '先创建一个任务' : '给拖延一点压力',
            trailing: const Icon(Icons.calendar_month_rounded),
            mascotMood: MascotMood.clipboard,
            onAdd: widget.onAddTask,
          ),
          const SizedBox(height: 18),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '任务名称',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    SoftBadge(
                      text: widget.isCreating ? '新建中' : '今日任务',
                      color: AppColors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('title-${widget.task.id}'),
                  initialValue: _title,
                  onChanged: (value) => _title = value.trim(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    labelText: '任务名称',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: ValueKey('description-${widget.task.id}'),
                  initialValue: _description,
                  onChanged: (value) => _description = value.trim(),
                  minLines: 1,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: '任务说明',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _TimeBox(
                        label: '开始时间',
                        value: _start,
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeBox(
                        label: '截止时间',
                        value: _deadline,
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '根据开始/截止时间自动计算：$_durationMinutes 分钟',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _syncDurationFromTime,
                      child: const Text('重新计算'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: '行动验证'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoiceTile(
                  selected: _verify == VerificationType.manual,
                  icon: Icons.touch_app_rounded,
                  title: '手动打卡',
                  subtitle: '完成后手动确认',
                  onTap: () =>
                      setState(() => _verify = VerificationType.manual),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceTile(
                  selected: _verify != VerificationType.manual,
                  icon: Icons.phone_iphone_rounded,
                  title: '应用/传感器检测',
                  subtitle: '模拟自动识别',
                  onTap: () =>
                      setState(() => _verify = VerificationType.appLaunch),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: '惩罚规则'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RuleCard(
                  selected: _rule == PunishmentType.gentle,
                  icon: Icons.notifications_rounded,
                  title: '温柔提醒',
                  subtitle: '轻轻提醒',
                  color: AppColors.yellow,
                  onTap: () => setState(() => _rule = PunishmentType.gentle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RuleCard(
                  selected: _rule == PunishmentType.vibration,
                  icon: Icons.vibration_rounded,
                  title: '震动提醒',
                  subtitle: '强提醒',
                  color: AppColors.blue,
                  onTap: () => setState(() => _rule = PunishmentType.vibration),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RuleCard(
                  selected: _rule == PunishmentType.gross,
                  custom: const PoopFace(size: 54),
                  title: '恶心提醒',
                  subtitle: '全屏阻断',
                  color: AppColors.green,
                  onTap: () => setState(() => _rule = PunishmentType.gross),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '触发强度',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          Slider(
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: AppColors.green,
            value: _intensity.index.toDouble(),
            onChanged: (value) => setState(
              () => _intensity = PunishmentIntensity.values[value.round()],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _StepperCard(
                  title: '专注时长',
                  value: _durationMinutes,
                  unit: '分钟',
                  onAdd: () => _changeDuration(5),
                  onRemove: () => _changeDuration(-5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StepperCard(
                  title: '宽限时间',
                  value: _graceMinutes,
                  unit: '分钟',
                  onAdd: () => setState(() => _graceMinutes += 1),
                  onRemove: () => setState(
                    () => _graceMinutes = math.max(1, _graceMinutes - 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassPanel(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.green,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '拦截退出',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(width: 6),
                          Tooltip(
                            message:
                                '开启后，Android 会尝试进入全屏强提醒/锁定任务模式，减少切到其他应用的机会。',
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '尝试阻止中途退出；普通手机授权后效果更强。',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _blockExit,
                  activeThumbColor: AppColors.green,
                  onChanged: (value) => setState(() => _blockExit = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          BigActionButton(
            label: widget.isCreating ? '创建并开始监督' : '保存并开始监督',
            icon: Icons.play_arrow_rounded,
            onPressed: _save,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        color: selected ? const Color(0xFFEFFFF8) : Colors.white,
        borderColor: selected ? AppColors.green : Colors.white,
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : icon,
              color: selected ? AppColors.green : AppColors.ink,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.icon,
    this.custom,
  });
  final bool selected;
  final IconData? icon;
  final Widget? custom;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        color: Colors.white,
        borderColor: selected ? AppColors.green : Colors.white,
        child: Column(
          children: [
            custom ?? Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.onAdd,
    required this.onRemove,
  });
  final String title;
  final int value;
  final String unit;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Text(
                  '$value $unit',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
