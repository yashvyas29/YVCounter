import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHandler {
  static const dateFormat = 'yyyy-MM-dd';
  static const dateTimeFormat = 'yyyy-MM-dd\nhh:mm a';
  static DateTime get today => DateTime.now();

  static String getString(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }

  static DateTime getDateTime(String date, String format) {
    return DateFormat(format).parse(date);
  }

  static bool isToday(DateTime date) {
    return DateUtils.isSameDay(date, today);
  }
}
