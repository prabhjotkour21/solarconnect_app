import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Draws animated dashed flow lines from the center to each corner node.
class EnergyFlowPainter extends CustomPainter {
  final double animValue; // 0.0 – 1.0, drives dash offset
  final bool solarActive;
  final bool gridActive;
  final bool homeActive;
  final bool batteryActive;

  EnergyFlowPainter({
    required this.animValue,
    this.solarActive = true,
    this.gridActive = true,
    this.homeActive = true,
    this.batteryActive = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const nodeRadius = 36.0;
    const centerRadius = 44.0;
    const gap = 8.0;

    final corners = [
      Offset(nodeRadius + gap, nodeRadius + gap),                   // TL – solar
      Offset(size.width - nodeRadius - gap, nodeRadius + gap),      // TR – grid
      Offset(nodeRadius + gap, size.height - nodeRadius - gap),     // BL – battery
      Offset(size.width - nodeRadius - gap, size.height - nodeRadius - gap), // BR – home
    ];

    final actives = [solarActive, gridActive, batteryActive, homeActive];
    final colors = [AppColors.success, AppColors.info, AppColors.warning, AppColors.primary];

    for (int i = 0; i < 4; i++) {
      if (!actives[i]) continue;
      _drawFlowLine(canvas, center, corners[i], colors[i], centerRadius, nodeRadius);
    }
  }

  void _drawFlowLine(Canvas canvas, Offset from, Offset to, Color color,
      double fromRadius, double toRadius) {
    final dir = (to - from);
    final length = dir.distance;
    final unit = dir / length;

    final start = from + unit * fromRadius;
    final end = to - unit * toRadius;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLen = 8.0;
    const gapLen = 6.0;
    const period = dashLen + gapLen;
    final lineLength = (end - start).distance;

    final offset = animValue * period;

    double drawn = -offset;
    while (drawn < lineLength) {
      final dashStart = max(0.0, drawn);
      final dashEnd = min(lineLength, drawn + dashLen);
      if (dashStart < dashEnd) {
        canvas.drawLine(
          start + unit * dashStart,
          start + unit * dashEnd,
          paint,
        );
      }
      drawn += period;
    }
  }

  @override
  bool shouldRepaint(EnergyFlowPainter old) =>
      old.animValue != animValue ||
      old.solarActive != solarActive ||
      old.gridActive != gridActive;
}
