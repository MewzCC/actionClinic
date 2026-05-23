import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/action_widgets.dart';
import '../../../shared/widgets/layout_widgets.dart';
import '../../../shared/widgets/visual_widgets.dart';

class PunishmentPage extends StatefulWidget {
  const PunishmentPage({
    super.key,
    required this.task,
    required this.onStart,
    required this.onConfirmStarted,
    required this.onComplete,
    required this.onAbandon,
  });

  final ClinicTask task;
  final VoidCallback onStart;
  final VoidCallback onConfirmStarted;
  final VoidCallback onComplete;
  final VoidCallback onAbandon;

  @override
  State<PunishmentPage> createState() => _PunishmentPageState();
}

class _PunishmentPageState extends State<PunishmentPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFC8AF), Color(0xFFFFE3CF)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: StainPattern()),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 74,
                      color: Color(0xFFE84F35),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '你又拖延了！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF91331F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '检测到「${widget.task.title}」超时未行动，已触发恶心干预',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF783723),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _shake,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          math.sin(_shake.value * math.pi * 2) * 4,
                          0,
                        ),
                        child: child,
                      ),
                      child: SizedBox(
                        height: 350,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned(
                              left: 10,
                              top: 54,
                              child: StinkBadge(),
                            ),
                            Positioned(
                              right: 4,
                              top: 126,
                              child: TimerSplatter(
                                time: formatClock(
                                  math.min(15, widget.task.graceSeconds),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 20,
                              bottom: 20,
                              child: GoDoBadge(),
                            ),
                            const Positioned(
                              bottom: 0,
                              child: PoopFace(size: 240),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      color: const Color(0xFFFFF7F1),
                      borderColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            '不想再看见它？ 现在立刻开始行动。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          BigActionButton(
                            label: '我马上去做',
                            icon: Icons.play_arrow_rounded,
                            color: AppColors.red,
                            onPressed: widget.onStart,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: widget.onConfirmStarted,
                            child: const Text('我已开始行动'),
                          ),
                          TextButton.icon(
                            onPressed: widget.onComplete,
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                            ),
                            label: const Text('我已完成打卡'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassPanel(
                      color: const Color(0xFFFFF8D8),
                      borderColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '解锁条件',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const RuleLine(
                            icon: Icons.timer_outlined,
                            color: Color(0xFF6E9A20),
                            text: '开始任务 3 分钟后自动关闭',
                          ),
                          const RuleLine(
                            icon: Icons.event_available_rounded,
                            color: Color(0xFF54B832),
                            text: '完成打卡可立即关闭',
                          ),
                          if (widget.task.blockExit)
                            const RuleLine(
                              icon: Icons.lock_rounded,
                              color: AppColors.red,
                              text: '当前开启拦截退出，跳过会记录严重拖延',
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.onAbandon,
                              child: const Text('放弃任务并记录'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StainPattern extends StatelessWidget {
  const StainPattern({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: StainPainter());
}

class StainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1A8A4E2C);
    for (final p in [
      Offset(size.width * .12, size.height * .11),
      Offset(size.width * .78, size.height * .10),
      Offset(size.width * .92, size.height * .30),
      Offset(size.width * .18, size.height * .52),
    ]) {
      canvas.drawCircle(p, 26, paint);
      canvas.drawCircle(p + const Offset(22, 14), 10, paint);
      canvas.drawCircle(p + const Offset(-18, 22), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StinkBadge extends StatelessWidget {
  const StinkBadge({super.key});
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.16,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFA8B533),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        '臭!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class TimerSplatter extends StatelessWidget {
  const TimerSplatter({super.key, required this.time});
  final String time;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFF6F63),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      children: [
        const Text(
          '继续拖延',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class GoDoBadge extends StatelessWidget {
  const GoDoBadge({super.key});
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.10,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Text(
        '快去做!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
