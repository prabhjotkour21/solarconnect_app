import 'dart:math';
import 'package:flutter/material.dart';

/// Draws four animated dashed arms in a + cross:
///   Solar (top) ─── Inverter (center) ─── Home (right)
///                        │
///                      Grid (left) &amp; Battery (bottom)
///
/// Each arm uses the color of its respective node.
class EnergyFlowPainter extends CustomPainter {
  final double animValue;

  final double canvasW;
  final double canvasH;

  // Center of each node's icon circle (not label)
  final Offset solarCenter;
  final Offset gridCenter;
  final Offset homeCenter;
  final Offset batteryCenter;
  final Offset inverterCenter;

  final Color solarColor;
  final Color gridColor;
  final Color homeColor;
  final Color batteryColor;

  final bool solarActive;
  final bool gridActive;
  final bool homeActive;
  final bool batteryActive;

  const EnergyFlowPainter({
    required this.animValue,
    required this.canvasW,
    required this.canvasH,
    required this.solarCenter,
    required this.gridCenter,
    required this.homeCenter,
    required this.batteryCenter,
    required this.inverterCenter,
    required this.solarColor,
    required this.gridColor,
    required this.homeColor,
    required this.batteryColor,
    this.solarActive   = true,
    this.gridActive    = true,
    this.homeActive    = true,
    this.batteryActive = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const outerR  = 36.0;   // outer node icon circle radius
    const centerR = 44.0;   // inverter circle radius
    const gap     = 4.0;

    final arms = [
      _Arm(solarCenter,   inverterCenter, solarColor,   solarActive,   outerR, centerR),
      _Arm(gridCenter,    inverterCenter, gridColor,    gridActive,    outerR, centerR),
      _Arm(homeCenter,    inverterCenter, homeColor,    homeActive,    outerR, centerR),
      _Arm(batteryCenter, inverterCenter, batteryColor, batteryActive, outerR, centerR),
    ];

    for (final arm in arms) {
      if (!arm.active) continue;

      final dir    = arm.to - arm.from;
      final length = dir.distance;
      if (length < 1) continue;
      final unit = dir / length;

      // Start just outside the outer node, end just outside inverter
      final start = arm.from + unit * (arm.fromR + gap);
      final end   = arm.to   - unit * (arm.toR   + gap);
      final lineLen = (end - start).distance;
      if (lineLen < 1) continue;

      final paint = Paint()
        ..color       = arm.color.withOpacity(0.9)
        ..strokeWidth = 2.5
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round;

      const dashLen = 9.0;
      const gapLen  = 5.0;
      const period  = dashLen + gapLen;
      final offset  = animValue * period;

      double d = -offset;
      while (d < lineLen) {
        final ds = max(0.0, d);
        final de = min(lineLen, d + dashLen);
        if (ds < de) {
          canvas.drawLine(start + unit * ds, start + unit * de, paint);
        }
        d += period;
      }
    }
  }

  @override
  bool shouldRepaint(EnergyFlowPainter old) =>
      old.animValue     != animValue     ||
      old.solarActive   != solarActive   ||
      old.gridActive    != gridActive    ||
      old.homeActive    != homeActive    ||
      old.batteryActive != batteryActive;
}

class _Arm {
  final Offset from;
  final Offset to;
  final Color  color;
  final bool   active;
  final double fromR;
  final double toR;
  const _Arm(this.from, this.to, this.color, this.active, this.fromR, this.toR);
}
