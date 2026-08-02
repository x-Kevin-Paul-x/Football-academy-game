import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class StatRingWidget extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final String title;
  final String centerValue;
  final String subtitle;
  final Color ringColor;

  const StatRingWidget({
    Key? key,
    required this.percentage,
    required this.title,
    required this.centerValue,
    required this.subtitle,
    this.ringColor = AppTheme.darkAccentPill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.capsuleCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _RingPainter(
                      percentage: percentage,
                      activeColor: ringColor,
                      inactiveColor: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerValue,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color inactiveColor;

  _RingPainter({
    required this.percentage,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const count = 48; // Spoke bars count

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final activeSpokes = (count * percentage.clamp(0.0, 1.0)).round();

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - (math.pi / 2);
      final innerRadius = radius - 10;
      final outerRadius = radius;

      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      final isSpokeActive = i <= activeSpokes;
      canvas.drawLine(start, end, isSpokeActive ? activePaint : inactivePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.activeColor != activeColor;
  }
}
