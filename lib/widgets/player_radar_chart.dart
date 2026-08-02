import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';

class PlayerRadarChart extends StatelessWidget {
  final Player player;
  final double size;

  const PlayerRadarChart({
    super.key,
    required this.player,
    this.size = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Attributes to display
    final attributes = [
      {'label': 'PAC', 'value': player.pace.toDouble()},
      {'label': 'SHO', 'value': player.shooting.toDouble()},
      {'label': 'PAS', 'value': player.passing.toDouble()},
      {'label': 'DRI', 'value': player.dribbling.toDouble()},
      {'label': 'DEF', 'value': player.defending.toDouble()},
      {'label': 'PHY', 'value': player.physicality.toDouble()},
    ];

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          attributes: attributes,
          isDark: isDark,
          accentColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> attributes;
  final bool isDark;
  final Color accentColor;

  _RadarChartPainter({
    required this.attributes,
    required this.isDark,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 24;
    final numSides = attributes.length;
    final angleStep = (2 * math.pi) / numSides;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric polygon web (3 levels: 33%, 66%, 100%)
    for (int level = 1; level <= 3; level++) {
      final r = radius * (level / 3.0);
      final path = Path();
      for (int i = 0; i < numSides; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines from center
    for (int i = 0; i < numSides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw filled polygon for player stats
    final polyPath = Path();
    final points = <Offset>[];
    for (int i = 0; i < numSides; i++) {
      final val = (attributes[i]['value'] as double).clamp(0, 100);
      final r = radius * (val / 100.0);
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      final pt = Offset(x, y);
      points.add(pt);
      if (i == 0) {
        polyPath.moveTo(x, y);
      } else {
        polyPath.lineTo(x, y);
      }
    }
    polyPath.close();

    // Fill polygon with semi-transparent accent color
    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(polyPath, fillPaint);

    // Polygon border line
    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(polyPath, borderPaint);

    // Draw vertex dots
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, dotPaint);
    }

    // Render Attribute Text Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < numSides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final labelRadius = radius + 14;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final label = attributes[i]['label'] as String;
      final val = (attributes[i]['value'] as double).round();

      textPainter.text = TextSpan(
        text: '$label\n$val',
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.accentColor != accentColor;
  }
}
