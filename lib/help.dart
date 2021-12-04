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
late List<String> om = ["On", "On", "On", "On", "On"];

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class HelpApp extends StatefulWidget {
  @override
  HelpAppState createState() => HelpAppState();
}

class HelpAppState extends State<HelpApp> {
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
            "감사노트 ＜오늘감사＞",
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
                    subtitle: detail_cont()),
              )),
          WidgetBTN(0, 16, 25),
          WidgetBTN(1, 16, 26),
          WidgetBTN(2, 13, 27),
          WidgetBTN(3, 13, 28),
          WidgetBTN(4, 13, 29),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text('하루에 등록한 감사갯수에 따라 아이콘이 바뀝니다.'),
          ),
          Card(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(MdiIcons.batteryOutline, color: Colors.black),
                    Icon(MdiIcons.batteryLow, color: Colors.black),
                    Icon(MdiIcons.batteryMedium, color: Colors.black),
                    Icon(MdiIcons.batteryHigh, color: Colors.black),
                    Icon(MdiIcons.batteryCharging, color: Colors.black),
                    Icon(MdiIcons.batteryHeartVariant, color: Colors.black)
                  ],
                ),
              )),
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
          onPressed: () => {
            _dailyAtTimeNotification(noti_no, hh, ii),
            setNoti(),
          },
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

  Text detail_cont() {
    return Text('''

2020년 겨울,
하루에 5번 감사하자는 어떤분의 이야기를 듣고,
감사의 표현이 잘 안되는 나를 돌아보게 되었습니다.

그래도 다시 한번 해보려고,
미루지 말고 생각났을 때 바로 기록해보려고,
내손안에 두었다 다시 돌아보려고,

그렇게 감사노트<오늘감사>가 만들어졌습니다.

개발자도 몸부림 치고 있다고 할까요?
우리 함께 몸부림 쳐 볼까요?

'감사하랬더니 
감사노트가 머리에 떠오르는 이 직업병..
한심하기 짝이 없지만 누군가에게 도움이 된다면,
그리고 감사의 제목들이 기록되어
훗날 다시 돌아보고 은혜앞에 다시 서게 된다면.. \' ''',
        style: TextStyle(
          color: Colors.black87,
        ));
  }
}

Future _dailyAtTimeNotification(int noti_id, int hh, int ii) async {
  final notiTitle = '오늘감사 시작해볼까요?';
  final notiDesc = '감사로 하루를 시작해보세요.';

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
