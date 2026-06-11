class PowerCutEvent {
  final DateTime date;
  final int durationMinutes;
  final String severity; // 'low', 'medium', 'high'

  PowerCutEvent({
    required this.date,
    required this.durationMinutes,
    required this.severity,
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
    final events = [
      PowerCutEvent(date: DateTime(2023, 9, 19), durationMinutes: 240, severity: 'high'),
      PowerCutEvent(date: DateTime(2023, 9, 20), durationMinutes: 120, severity: 'medium'),
      PowerCutEvent(date: DateTime(2023, 9, 21), durationMinutes: 180, severity: 'high'),
      PowerCutEvent(date: DateTime(2023, 9, 22), durationMinutes: 60, severity: 'low'),
      PowerCutEvent(date: DateTime(2023, 9, 23), durationMinutes: 90, severity: 'medium'),
    ];
    
    return PowerCutData(
      totalDurationMinutes: 690,
      totalEvents: events.length,
      events: events,
      averageDurationMinutes: 138,
    );
  }
}
