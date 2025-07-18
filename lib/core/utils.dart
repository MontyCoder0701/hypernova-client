import 'package:intl/intl.dart';

extension DateTimeFormatHelper on DateTime {
  String get formattedTime => DateFormat('HH:mm:ss').format(this);

  String get formattedDate => DateFormat('yyyy-MM-dd').format(this);
}
