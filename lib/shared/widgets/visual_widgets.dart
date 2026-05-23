import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.progress,
    required this.time,
    required this.subtitle,
    required this.task,
    this.compact = false,
  });

  final double progress;
  final String time;
  final String subtitle;
  final String task;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: RingPainter(progress: progress.clamp(0, 1)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.spa_rounded,
                color: AppColors.green,
                size: compact ? 22 : 34,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: compact ? 35 : 58,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: compact ? 13 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 26),
                child: Text(
                  task,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 14 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  const RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 16;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..color = const Color(0xFFE7F7F1);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13
      ..shader = const LinearGradient(
        colors: [Color(0xFF82E1C9), AppColors.green],
      ).createShader(Offset.zero & size);

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arc,
    );

    final tickPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.green.withValues(alpha: .24);
    for (var i = 0; i < 30; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 30;
      final a = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + a * (radius + 20),
        center + a * (radius + 28),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

enum MascotMood { ready, clipboard, focus, write }

class Mascot extends StatelessWidget {
  const Mascot({super.key, required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: MascotPainter(mood: mood)),
    );
  }
}

class MascotPainter extends CustomPainter {
  const MascotPainter({required this.mood});

  final MascotMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final body = Paint()..color = const Color(0xFF84E8BE);
    final dark = Paint()..color = AppColors.ink;
    final blush = Paint()..color = const Color(0xFFFFA68C);
    final band = Paint()..color = const Color(0xFFE5B163);
    final horn = Paint()..color = const Color(0xFFC8843B);

    canvas.drawOval(Rect.fromLTWH(s * .14, s * .24, s * .72, s * .58), body);
    canvas.drawCircle(Offset(s * .26, s * .62), s * .15, body);
    canvas.drawCircle(Offset(s * .74, s * .62), s * .15, body);
    canvas.drawCircle(Offset(s * .50, s * .22), s * .08, body);
    canvas.drawOval(Rect.fromLTWH(s * .72, s * .25, s * .22, s * .12), horn);

    final bandPath = Path()
      ..moveTo(s * .24, s * .27)
      ..quadraticBezierTo(s * .5, s * .16, s * .78, s * .28)
      ..lineTo(s * .76, s * .40)
      ..quadraticBezierTo(s * .5, s * .30, s * .23, s * .40)
      ..close();
    canvas.drawPath(bandPath, band);

    canvas.drawCircle(Offset(s * .38, s * .50), s * .025, dark);
    canvas.drawCircle(Offset(s * .62, s * .50), s * .025, dark);
    canvas.drawLine(
      Offset(s * .33, s * .44),
      Offset(s * .43, s * .41),
      dark..strokeWidth = s * .025,
    );
    canvas.drawLine(
      Offset(s * .67, s * .44),
      Offset(s * .57, s * .41),
      dark..strokeWidth = s * .025,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * .5, s * .61),
        width: s * .16,
        height: s * .10,
      ),
      mood == MascotMood.ready ? 0 : math.pi,
      math.pi,
      false,
      dark..style = PaintingStyle.stroke,
    );
    dark.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s * .32, s * .58), s * .04, blush);
    canvas.drawCircle(Offset(s * .68, s * .58), s * .04, blush);
  }

  @override
  bool shouldRepaint(covariant MascotPainter oldDelegate) =>
      oldDelegate.mood != mood;
}

class PoopFace extends StatelessWidget {
  const PoopFace({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: PoopPainter()),
    );
  }
}

class PoopPainter extends CustomPainter {
  const PoopPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final brown = Paint()..color = const Color(0xFFB56D31);
    final dark = Paint()..color = AppColors.ink;
    final blush = Paint()..color = const Color(0xFFFF8D7A);
    canvas.drawOval(Rect.fromLTWH(s * .08, s * .58, s * .84, s * .28), brown);
    canvas.drawOval(Rect.fromLTWH(s * .18, s * .40, s * .64, s * .28), brown);
    canvas.drawOval(Rect.fromLTWH(s * .30, s * .24, s * .42, s * .24), brown);
    canvas.drawOval(Rect.fromLTWH(s * .40, s * .08, s * .24, s * .20), brown);
    canvas.drawCircle(
      Offset(s * .36, s * .55),
      s * .09,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(s * .62, s * .55),
      s * .09,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(s * .38, s * .56), s * .04, dark);
    canvas.drawCircle(Offset(s * .60, s * .56), s * .04, dark);
    canvas.drawCircle(Offset(s * .28, s * .66), s * .045, blush);
    canvas.drawCircle(Offset(s * .72, s * .66), s * .045, blush);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * .5, s * .70),
        width: s * .20,
        height: s * .12,
      ),
      0,
      math.pi,
      false,
      dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .035,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniWave extends StatelessWidget {
  const MiniWave({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: CustomPaint(painter: MiniWavePainter(color)),
    );
  }
}

class MiniWavePainter extends CustomPainter {
  const MiniWavePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height * .65);
    for (var i = 0; i <= 4; i++) {
      final x = size.width * (i + .5) / 5;
      final y = i.isEven ? size.height * .22 : size.height * .78;
      path.quadraticBezierTo(x, y, size.width * (i + 1) / 5, size.height * .55);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant MiniWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
