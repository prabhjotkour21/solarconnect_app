import 'dart:math';
import 'package:flutter/material.dart';

enum LineStyle {
  solidGlow,   // solid line + bright dot travelling along it  (Solar, Battery)
  dotted,      // small dot-dot dashes                         (Grid)
  shortDash,   // slightly longer dashes                       (Home)
}

class EnergyFlowPainter extends CustomPainter {
  final double animValue;

  final double canvasW;
  final double canvasH;

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
    const outerR  = 36.0;
    const centerR = 44.0;
    const gap     = 4.0;

    final arms = [
      _ArmDef(solarCenter,   inverterCenter, solarColor,   solarActive,   outerR, centerR, LineStyle.solidGlow),
      _ArmDef(gridCenter,    inverterCenter, gridColor,    gridActive,    outerR, centerR, LineStyle.dotted),
      _ArmDef(homeCenter,    inverterCenter, homeColor,    homeActive,    outerR, centerR, LineStyle.shortDash),
      _ArmDef(batteryCenter, inverterCenter, batteryColor, batteryActive, outerR, centerR, LineStyle.solidGlow),
    ];

    for (final arm in arms) {
      if (!arm.active) continue;

      final dir    = arm.to - arm.from;
      final length = dir.distance;
      if (length < 1) continue;
      final unit = dir / length;

      final start   = arm.from + unit * (arm.fromR + gap);
      final end     = arm.to   - unit * (arm.toR   + gap);
      final lineLen = (end - start).distance;
      if (lineLen < 1) continue;

      switch (arm.style) {
        case LineStyle.solidGlow:
          _drawSolidGlow(canvas, start, end, unit, lineLen, arm.color);
          break;
        case LineStyle.dotted:
          _drawDotted(canvas, start, unit, lineLen, arm.color);
          break;
        case LineStyle.shortDash:
          _drawShortDash(canvas, start, unit, lineLen, arm.color);
          break;
      }
    }
  }

  /// Solid dim line + a bright glowing dot that travels from node → inverter
  void _drawSolidGlow(Canvas canvas, Offset start, Offset end,
      Offset unit, double lineLen, Color color) {
    // Dim base line
    canvas.drawLine(
      start, end,
      Paint()
        ..color       = color.withOpacity(0.25)
        ..strokeWidth = 2.0
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // Travelling bright dot
    final dotPos = start + unit * (animValue * lineLen);
    // Outer glow
    canvas.drawCircle(
      dotPos, 6.0,
      Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.fill,
    );
    // Inner bright dot
    canvas.drawCircle(
      dotPos, 3.5,
      Paint()..color = color.withOpacity(0.95)..style = PaintingStyle.fill,
    );
  }

  /// Small dot–dot dashes (like the Grid line in the reference)
  void _drawDotted(Canvas canvas, Offset start, Offset unit,
      double lineLen, Color color) {
    final paint = Paint()
      ..color       = color.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    const dotLen = 2.0;
    const gapLen = 5.0;
    const period = dotLen + gapLen;
    final offset = animValue * period;

    double d = -offset;
    while (d < lineLen) {
      final ds = max(0.0, d);
      final de = min(lineLen, d + dotLen);
      if (ds < de) {
        canvas.drawLine(start + unit * ds, start + unit * de, paint);
      }
      d += period;
    }
  }

  /// Short solid dashes (like the Home line in the reference)
  void _drawShortDash(Canvas canvas, Offset start, Offset unit,
      double lineLen, Color color) {
    final paint = Paint()
      ..color       = color.withOpacity(0.85)
      ..strokeWidth = 2.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    const dashLen = 8.0;
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

  @override
  bool shouldRepaint(EnergyFlowPainter old) =>
      old.animValue     != animValue     ||
      old.solarActive   != solarActive   ||
      old.gridActive    != gridActive    ||
      old.homeActive    != homeActive    ||
      old.batteryActive != batteryActive;
}

class _ArmDef {
  final Offset    from;
  final Offset    to;
  final Color     color;
  final bool      active;
  final double    fromR;
  final double    toR;
  final LineStyle style;
  const _ArmDef(this.from, this.to, this.color, this.active,
      this.fromR, this.toR, this.style);
}
