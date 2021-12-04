import 'dart:async';
import 'package:calendar_calendar/calendar_calendar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import './main.dart';

late List<String> saved_noti = ["", "", "", "", ""];
late List<Color> btn_color = [
  Colors.green,
  Colors.green,
  Colors.green,
  Colors.green,
  Colors.green
];

late List<String> notice_msg_title = [
  "오늘감사로 하루를 시작해볼까요?",
  "오늘감사로 멋진 오후를 맞이해요~",
  "오늘감사로 하루를 마무리해보세요~",
  "On",
  "On"
];
late List<String> notice_msg_cont = [
  "감사를 기록하고 하루를 시작해보세요.",
  "감사는 또 다른 감사의 만들어 냅니다.",
  "감사는 평강으로 인도합니다.",
  "On",
  "On"
];

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class SettingApp extends StatefulWidget {
  @override
  SettingAppState createState() => SettingAppState();
}

class SettingAppState extends State<SettingApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    setNoti();
  }

  void setNoti() async {
    setState(() {
      btn_color[0] =
          ((saved_noti[0] == "1") ? Colors.green[600] : Colors.green[200])!;
      btn_color[1] =
          ((saved_noti[1] == "1") ? Colors.green[600] : Colors.green[200])!;
      btn_color[2] =
          ((saved_noti[2] == "1") ? Colors.green[600] : Colors.green[200])!;
      btn_color[3] =
          ((saved_noti[3] == "1") ? Colors.green[600] : Colors.green[200])!;
      btn_color[4] =
          ((saved_noti[4] == "1") ? Colors.green[600] : Colors.green[200])!;
      print(saved_noti);
      print(btn_color);
    });
  }

  Future _dailyAtTimeNotification(int noti_id, int hh, int ii) async {
    final notiTitle = notice_msg_title[noti_id];
    final notiDesc = notice_msg_cont[noti_id];

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    var android = AndroidNotificationDetails('id', notiTitle,
        channelDescription: notiDesc,
        importance: Importance.max,
        priority: Priority.max);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    if (result != null) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannelGroup('id');

      if (saved_noti[noti_id] != "1") {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          noti_id, // id는 unique해야합니다. int값
          notiTitle,
          notiDesc,
          _setNotiTime(hh, ii),
          detail,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        changeNotiState(noti_id, "1");
      } else {
        await FlutterLocalNotificationsPlugin().cancel(noti_id);
        changeNotiState(noti_id, "0");
      }
    }
    setNoti();
  }

  @override
  Widget build(BuildContext context) {
    late FocusNode myFocusNode;
    myFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(0.0, 5.0, 0.0),
          child: Text(
            "감사노트<오늘감사>는 감사의 습관을 만드는데 도움이 됩니다. 알람을 설정하시면 하루를 시작하면서, 오후를 시작하면서 그리고 하루를 마무리 하면서 감사를 기록하도록 도와줍니다.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          Card(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("감사노트 [오늘감사]는",
                      style: TextStyle(
                        color: Colors.green,
                      )),
                ),
              )),
          WidgetBTN(0, 08, 00),
          WidgetBTN(1, 12, 00),
          WidgetBTN(2, 20, 00),
        ])),
      ),
    );
  }

  Container WidgetBTN(int noti_no, int hh, int ii) {
    String txt = "$hh:$ii";
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: SizedBox(
        height: 40, //height of button
        width: double.infinity, //width of button equal to parent widget
        child: ElevatedButton(
          onPressed: () => {_dailyAtTimeNotification(noti_no, hh, ii)},
          style: ElevatedButton.styleFrom(
              onPrimary: Colors.white,
              textStyle: const TextStyle(fontSize: 20),
              primary: btn_color[noti_no], //background color of button
              //side: BorderSide(width: 0, color: Colors.brown), //border width and color
              elevation: 2, //elevation of button
              padding: EdgeInsets.all(7) //content padding inside button
              ),
          child: Text(txt,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

void changeNotiState(noti_id, state) async {
  saved_noti[noti_id] = state;
  final SharedPreferences prefs = await _prefs;
  await prefs.setString("noti_$noti_id", saved_noti[noti_id]);
}

tz.TZDateTime _setNotiTime(int hh, int ii) {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hh, ii);

  return scheduledDate;
}
