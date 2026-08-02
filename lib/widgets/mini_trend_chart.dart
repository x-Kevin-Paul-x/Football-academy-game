import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class MiniTrendChart extends StatelessWidget {
  final String title;
  final String value;
  final String percentageChange;
  final List<double> dataPoints;
  final Color lineColor;

  const MiniTrendChart({
    Key? key,
    required this.title,
    required this.value,
    required this.percentageChange,
    required this.dataPoints,
    this.lineColor = AppTheme.accentGreen,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentageChange,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: lineColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(
                dataPoints: dataPoints,
                lineColor: lineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _WavePainter({
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height - 10)) - 5;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormalizedY = (dataPoints[i - 1] - minVal) / range;
        final prevY = size.height - (prevNormalizedY * (size.height - 10)) - 5;

        final controlX1 = prevX + (stepX / 2);
        final controlY1 = prevY;
        final controlX2 = prevX + (stepX / 2);
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.lineColor != lineColor;
  }
}
