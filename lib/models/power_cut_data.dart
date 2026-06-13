class PowerCutEvent {
  final DateTime date;
  final int durationMinutes;
  final String severity;
  final double consumedPowerKw;

  PowerCutEvent({
    required this.date,
    required this.durationMinutes,
    required this.severity,
    required this.consumedPowerKw,
  });
}

class PowerCutData {
  final int totalDurationMinutes;
  final int totalEvents;
  final List<PowerCutEvent> events;
  final double averageDurationMinutes;

  PowerCutData({
    required this.totalDurationMinutes,
    required this.totalEvents,
    required this.events,
    required this.averageDurationMinutes,
  });

  static PowerCutData demo() {
    final now = DateTime.now();
    final events = [
      // ── TODAY (3 events) ──
      PowerCutEvent(date: DateTime(now.year, now.month, now.day, 6, 30),  durationMinutes: 45,  severity: 'low',    consumedPowerKw: 1.2),
      PowerCutEvent(date: DateTime(now.year, now.month, now.day, 11, 0), durationMinutes: 120, severity: 'medium', consumedPowerKw: 3.5),
      PowerCutEvent(date: DateTime(now.year, now.month, now.day, 18, 45),durationMinutes: 90,  severity: 'high',   consumedPowerKw: 4.8),

      // ── THIS WEEK – day 1 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 1, hours: 2)),  durationMinutes: 200, severity: 'high',   consumedPowerKw: 5.2),
      PowerCutEvent(date: now.subtract(const Duration(days: 1, hours: 7)),  durationMinutes: 60,  severity: 'low',    consumedPowerKw: 1.8),
      PowerCutEvent(date: now.subtract(const Duration(days: 1, hours: 14)), durationMinutes: 150, severity: 'medium', consumedPowerKw: 3.1),
      PowerCutEvent(date: now.subtract(const Duration(days: 1, hours: 20)), durationMinutes: 30,  severity: 'low',    consumedPowerKw: 0.9),

      // ── THIS WEEK – day 2 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 2, hours: 3)),  durationMinutes: 180, severity: 'high',   consumedPowerKw: 4.6),
      PowerCutEvent(date: now.subtract(const Duration(days: 2, hours: 10)), durationMinutes: 75,  severity: 'low',    consumedPowerKw: 2.0),

      // ── THIS WEEK – day 3 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 3, hours: 5)),  durationMinutes: 240, severity: 'high',   consumedPowerKw: 6.1),
      PowerCutEvent(date: now.subtract(const Duration(days: 3, hours: 15)), durationMinutes: 90,  severity: 'medium', consumedPowerKw: 2.7),

      // ── THIS WEEK – day 5 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 5, hours: 8)),  durationMinutes: 110, severity: 'medium', consumedPowerKw: 3.3),
      PowerCutEvent(date: now.subtract(const Duration(days: 5, hours: 18)), durationMinutes: 55,  severity: 'low',    consumedPowerKw: 1.5),

      // ── THIS WEEK – day 6 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 6, hours: 1)),  durationMinutes: 160, severity: 'high',   consumedPowerKw: 4.2),
      PowerCutEvent(date: now.subtract(const Duration(days: 6, hours: 12)), durationMinutes: 45,  severity: 'low',    consumedPowerKw: 1.1),

      // ── THIS MONTH – week 2 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 9)),  durationMinutes: 300, severity: 'high',   consumedPowerKw: 7.5),
      PowerCutEvent(date: now.subtract(const Duration(days: 10)), durationMinutes: 85,  severity: 'medium', consumedPowerKw: 2.4),
      PowerCutEvent(date: now.subtract(const Duration(days: 11)), durationMinutes: 60,  severity: 'low',    consumedPowerKw: 1.6),
      PowerCutEvent(date: now.subtract(const Duration(days: 12)), durationMinutes: 210, severity: 'high',   consumedPowerKw: 5.8),
      PowerCutEvent(date: now.subtract(const Duration(days: 13)), durationMinutes: 95,  severity: 'medium', consumedPowerKw: 2.9),

      // ── THIS MONTH – week 3 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 15)), durationMinutes: 130, severity: 'medium', consumedPowerKw: 3.6),
      PowerCutEvent(date: now.subtract(const Duration(days: 16)), durationMinutes: 50,  severity: 'low',    consumedPowerKw: 1.3),
      PowerCutEvent(date: now.subtract(const Duration(days: 17)), durationMinutes: 270, severity: 'high',   consumedPowerKw: 6.8),
      PowerCutEvent(date: now.subtract(const Duration(days: 18)), durationMinutes: 40,  severity: 'low',    consumedPowerKw: 1.0),

      // ── THIS MONTH – week 4 ──
      PowerCutEvent(date: now.subtract(const Duration(days: 20)), durationMinutes: 180, severity: 'high',   consumedPowerKw: 4.9),
      PowerCutEvent(date: now.subtract(const Duration(days: 22)), durationMinutes: 70,  severity: 'low',    consumedPowerKw: 1.9),
      PowerCutEvent(date: now.subtract(const Duration(days: 24)), durationMinutes: 115, severity: 'medium', consumedPowerKw: 3.2),
      PowerCutEvent(date: now.subtract(const Duration(days: 26)), durationMinutes: 230, severity: 'high',   consumedPowerKw: 5.5),

      // ── CUSTOM / OLDER ──
      PowerCutEvent(date: now.subtract(const Duration(days: 33)), durationMinutes: 140, severity: 'medium', consumedPowerKw: 3.8),
      PowerCutEvent(date: now.subtract(const Duration(days: 38)), durationMinutes: 310, severity: 'high',   consumedPowerKw: 7.8),
      PowerCutEvent(date: now.subtract(const Duration(days: 44)), durationMinutes: 55,  severity: 'low',    consumedPowerKw: 1.4),
      PowerCutEvent(date: now.subtract(const Duration(days: 50)), durationMinutes: 195, severity: 'high',   consumedPowerKw: 5.1),
      PowerCutEvent(date: now.subtract(const Duration(days: 56)), durationMinutes: 80,  severity: 'medium', consumedPowerKw: 2.2),
      PowerCutEvent(date: now.subtract(const Duration(days: 62)), durationMinutes: 260, severity: 'high',   consumedPowerKw: 6.5),
      PowerCutEvent(date: now.subtract(const Duration(days: 70)), durationMinutes: 45,  severity: 'low',    consumedPowerKw: 1.2),
      PowerCutEvent(date: now.subtract(const Duration(days: 78)), durationMinutes: 175, severity: 'medium', consumedPowerKw: 4.4),
      PowerCutEvent(date: now.subtract(const Duration(days: 85)), durationMinutes: 320, severity: 'high',   consumedPowerKw: 8.0),
      PowerCutEvent(date: now.subtract(const Duration(days: 90)), durationMinutes: 65,  severity: 'low',    consumedPowerKw: 1.7),
    ];

    final total = events.fold(0, (sum, e) => sum + e.durationMinutes);
    return PowerCutData(
      totalDurationMinutes: total,
      totalEvents: events.length,
      events: events,
      averageDurationMinutes: total / events.length,
    );
  }
}
