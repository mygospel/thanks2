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
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

late List<Event> tEvent = [];

//tEvent.add(Event('Today\'s Event 49999999'));
//tEvent.addAll([Event('Today\'s Event 49999999')]);

var _kEventSource = Map.fromIterable(List.generate(1, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: tEvent,
  })
  ..addAll({
    kTommorow: [Event('요거는 4일 '), Event('요거는 4일 '), Event('요거는 4일 ')],
    kTommorow2: [
      Event('요거는 5일 '),
      Event('요거는 5일 '),
    ],
  });

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
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
