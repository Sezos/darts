import 'package:intl/intl.dart';

String formatMoney(dynamic value, [String suffix = "₮"]) {
  if (value is double) {
    return "${NumberFormat(",###.##", "mn-MN").format(value.floor())}$suffix";
  }
  if (value is int || value is num) {
    return "${NumberFormat(",###.##", "mn-MN").format(value.toDouble())}$suffix";
  }

  if (value is String) {
    if (double.tryParse(value) == null) {
      throw "Value is not number String";
    }
    return "${NumberFormat(",###.##", "mn-MN").format(double.parse(value))}$suffix";
  }
  throw "Unexpected Type";
}

String formatDouble(double value) {
  return NumberFormat(",###.##", "mn-MN").format(value);
}

String formatDate(DateTime date) {
  return DateFormat("yyyy-MM-dd HH:mm", "mn-MN").format(date);
}

String formatDateWithoutTime(DateTime date) {
  return DateFormat("yyyy-MM-dd", "mn-MN").format(date);
}

String formatDateWithoutDate(DateTime date) {
  return DateFormat("HH:mm", "mn-MN").format(date);
}

String formatDurationHHmm(Duration d) {
  final isNegative = d.isNegative;
  d = d.abs();
  final totalMinutes = d.inMinutes;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  final h = hours.toString().padLeft(2, '0');
  final m = minutes.toString().padLeft(2, '0');
  return '${isNegative ? '-' : ''}$h:$m';
}
