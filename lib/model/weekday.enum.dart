enum Weekday { mon, tue, wed, thu, fri, sat, sun }

extension WeekdayExtension on Weekday {
  int get indexValue => Weekday.values.indexOf(this);

  static const labels = ['월', '화', '수', '목', '금', '토', '일'];

  String get label => labels[index];

  static Weekday fromDateTime(DateTime dt) => Weekday.values[dt.weekday - 1];

  static Weekday fromIndex(int index) => Weekday.values[index];
}
