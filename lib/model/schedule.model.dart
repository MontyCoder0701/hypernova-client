class Schedule {
  final int id;
  final List<String> days;
  final String time;
  final bool isActive;
  final String startDate;

  Schedule({
    required this.id,
    required this.days,
    required this.time,
    required this.isActive,
    required this.startDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      days: List<String>.from(json['days']),
      time: json['time'],
      isActive: json['is_active'],
      startDate: json['start_date'],
    );
  }
}
