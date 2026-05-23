import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_label_utils.dart';
import '../../../shared/widgets/action_widgets.dart';

Future<String?> showPlanTimePickerSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String initialLabel,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlanTimePickerSheet(
      title: title,
      subtitle: subtitle,
      initialLabel: initialLabel,
    ),
  );
}

class PlanTimePickerSheet extends StatefulWidget {
  const PlanTimePickerSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialLabel,
  });

  final String title;
  final String subtitle;
  final String initialLabel;

  @override
  State<PlanTimePickerSheet> createState() => _PlanTimePickerSheetState();
}

class _PlanTimePickerSheetState extends State<PlanTimePickerSheet> {
  static const _minuteStep = 5;

  late int _hour;
  late int _minuteIndex;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initial = parseTimeLabel(widget.initialLabel);
    _hour = initial.hour;
    _minuteIndex = (initial.minute / _minuteStep).round().clamp(0, 11);
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _value =>
      TimeOfDay(hour: _hour, minute: _minuteIndex * _minuteStep);

  void _usePreset(String label) {
    final time = parseTimeLabel(label);
    setState(() {
      _hour = time.hour;
      _minuteIndex = (time.minute / _minuteStep).round().clamp(0, 11);
    });
    _hourController.animateToItem(
      _hour,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    _minuteController.animateToItem(
      _minuteIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final current = formatTimeLabel(_value);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFEFFFF8)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: .82)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SoftBadge(text: current, color: AppColors.green),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 176,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .82),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _hourController,
                            itemExtent: 44,
                            selectionOverlay: const _PickerSelectionOverlay(),
                            onSelectedItemChanged: (value) =>
                                setState(() => _hour = value),
                            children: [
                              for (var i = 0; i < 24; i++)
                                Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Text(
                          ':',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _minuteController,
                            itemExtent: 44,
                            selectionOverlay: const _PickerSelectionOverlay(),
                            onSelectedItemChanged: (value) =>
                                setState(() => _minuteIndex = value),
                            children: [
                              for (var i = 0; i < 60; i += _minuteStep)
                                Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in const [
                        '08:30',
                        '10:00',
                        '14:00',
                        '19:00',
                        '20:00',
                        '21:30',
                      ])
                        _PresetChip(
                          label: label,
                          selected: label == current,
                          onTap: () => _usePreset(label),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: BorderSide(
                              color: AppColors.green.withValues(alpha: .42),
                            ),
                            foregroundColor: AppColors.green,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(current),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('确认时间'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerSelectionOverlay extends StatelessWidget {
  const _PickerSelectionOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.green.withValues(alpha: .20)),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
