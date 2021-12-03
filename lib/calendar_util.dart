// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'dart:core';
import 'dart:collection';

import './database/memo.dart';
import './database/db.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
var kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

late List<Event> tEvent = [];
late LinkedHashMap<DateTime, List<Event>> tEventAll =
    LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

// var _kEventSource;
// _kEventSource = tEventAll;

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kTommorow = DateTime(kToday.year, kToday.month, kToday.day + 1);
final kTommorow2 = DateTime(kToday.year, kToday.month, kToday.day + 2);
final kFirstDay = DateTime(kToday.year - 40, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 3, kToday.month + 3, kToday.day);
