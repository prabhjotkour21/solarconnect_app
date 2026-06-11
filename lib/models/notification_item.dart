class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'alert', 'info', 'update', 'saving'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  static List<NotificationItem> demoList() {
    return [
      NotificationItem(
        id: 'n1',
        title: 'Weekly Green Performance Update',
        description: 'Your weekly solar generation has saved 17.7 kg CO2 and generated ₹ 177 in savings',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'update',
      ),
      NotificationItem(
        id: 'n2',
        title: 'Savings Details Last Month',
        description: 'You have saved ₹6,120 last month through solar generation',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: 'saving',
      ),
      NotificationItem(
        id: 'n3',
        title: 'Insights Details',
        description: 'Last week 80% of your energy consumption was powered by your solar system',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        type: 'info',
      ),
      NotificationItem(
        id: 'n4',
        title: 'Solar Generation Update',
        description: 'Previous Solar generation has started for the day',
        timestamp: DateTime.now().subtract(const Duration(days: 6)),
        type: 'update',
      ),
      NotificationItem(
        id: 'n5',
        title: 'Solar Generation Update',
        description: 'Previous Solar generation has started for the day',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        type: 'update',
      ),
    ];
  }
}
