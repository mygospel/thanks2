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
import './help.dart';

late List<String> saved_time = ["08:30", "13:30", "21:30", "00:00", "00:00"];
late List<String> saved_timeTxt = ["", "", "", "", ""];
late List<bool> saved_noti = [false, false, false, false, false];
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
  "",
  ""
];
late List<String> notice_msg_cont = [
  "감사를 기록하고 하루를 시작해보세요.",
  "감사는 또 다른 감사의 만들어 냅니다.",
  "감사는 평강으로 인도합니다.",
  "",
  ""
];
late bool read_noti = false;

var time_f = NumberFormat("00", "en_US");

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

int getTime2HH(tm) {
  List<String> tmp = tm.split(':');
  if (tmp[0].isNotEmpty) {
    return int.parse(tmp[0]);
  } else {
    return 0;
  }
}

int getTime2II(tm) {
  List<String> tmp = tm.split(':');
  if (tmp[1].isNotEmpty) {
    return int.parse(tmp[1]);
  } else {
    return 0;
  }
}

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
    final SharedPreferences prefs = await _prefs;
    setState(() {
      if (read_noti == false) {
        for (var i = 0; i <= 4; i++) {
          if (prefs.getBool("notiState_$i") != null) {
            saved_noti[i] = prefs.getBool("notiState_$i")!;
          } else {
            saved_noti[i] = false;
          }
          if (prefs.getString("notiTime_$i") != null &&
              prefs.getString("notiTime_$i") != "") {
            saved_time[i] = prefs.getString("notiTime_$i")!;
            String hhN = time_f.format(getTime2HH(saved_time[i]));
            String iiN = time_f.format(getTime2II(saved_time[i]));
            saved_timeTxt[i] = "$hhN:$iiN";
          } else {
            String hhN = time_f.format(getTime2HH(saved_time[i]));
            String iiN = time_f.format(getTime2II(saved_time[i]));
            saved_timeTxt[i] = "$hhN:$iiN";
          }
        }

        read_noti = true;
      }
      btn_color[0] =
          ((saved_noti[0] == true) ? Colors.green[600] : Colors.green[200])!;
      btn_color[1] =
          ((saved_noti[1] == true) ? Colors.green[600] : Colors.green[200])!;
      btn_color[2] =
          ((saved_noti[2] == true) ? Colors.green[600] : Colors.green[200])!;
      btn_color[3] =
          ((saved_noti[3] == true) ? Colors.green[600] : Colors.green[200])!;
      btn_color[4] =
          ((saved_noti[4] == true) ? Colors.green[600] : Colors.green[200])!;
    });
  }

  void getNotiState() async {}

  Future _dailyAtTimeNotificationFromNotiNo(int notiId) async {
    int hh = getTime2HH(saved_time[notiId]);
    int ii = getTime2II(saved_time[notiId]);
    _dailyAtTimeNotification(notiId, hh, ii, false);
  }

  Future _dailyAtTimeNotification(
      int noti_id, int hh, int ii, bool state) async {
    final notiTitle = notice_msg_title[noti_id];
    final notiDesc = notice_msg_cont[noti_id];

    // 시간을 변경한 경우는 false 상태로 true 가 되게 한다.
    if (state == true) saved_noti[noti_id] = false;

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
      if (saved_noti[noti_id] != true) {
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
        saveNotiState(noti_id, true);
        print("등록 $noti_id $notiTitle = $hh:$ii");
      } else {
        await FlutterLocalNotificationsPlugin().cancel(noti_id);
        if (state != true) {
          saveNotiState(noti_id, false);
          print("취소 $noti_id = $hh:$ii");
        }
      }
      //print(saved_noti);
    }
    saveNotiTime(noti_id, "$hh:$ii");
    setNoti();
  }

  @override
  Widget build(BuildContext context) {
    late FocusNode myFocusNode;
    myFocusNode = FocusNode();
    print("위젯그리기 시작");
    return Scaffold(
      appBar: AppBar(
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Text(
            "<오늘감사> 알람설정",
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
                  title: Text('''
알람을 설정하시면 하루를 시작하면서, 
오후를 시작하면서,
그리고 하루를 마무리 하면서 
감사를 기록하도록 도와줍니다.

원하시는 시간을 클릭하시면 설정됩니다.''',
                      style: TextStyle(
                        color: Colors.green,
                      )),
                ),
              )),
          WidgetBTN(
              context, 0, getTime2HH(saved_time[0]), getTime2II(saved_time[0])),
          WidgetBTN(
              context, 1, getTime2HH(saved_time[1]), getTime2II(saved_time[1])),
          WidgetBTN(
              context, 2, getTime2HH(saved_time[2]), getTime2II(saved_time[2])),
          HelpBTN(context),
        ])),
      ),
    );
  }

  Container WidgetBTN(context, int noti_no, int hh, int ii) {
    // String hhN = f.format(hh);
    // String iiN = f.format(ii);
    // saved_timeTxt[noti_no] = "$hhN:$iiN";
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: SizedBox(
          height: 40, //height of button
          width: double.infinity, //width of button equal to parent widget
          child: Row(children: [
            ElevatedButton(
              onPressed: () {
                showTimePickerPop(context, noti_no);
              },
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  primary: btn_color[noti_no], //background color of button
                  //side: BorderSide(width: 0, color: Colors.brown), //border width and color
                  elevation: 2, //elevation of button
                  padding: EdgeInsets.all(7) //content padding inside button
                  ),
              child: Text(saved_timeTxt[noti_no],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold)),
            ),
            Switch(
              value: saved_noti[noti_no],
              onChanged: (value) {
                setState(() {
                  //saveNotiState(noti_no, value);
                  _dailyAtTimeNotificationFromNotiNo(noti_no);
                });
              },
              activeTrackColor: Colors.greenAccent,
              activeColor: Colors.green,
            )
          ])),
    );
  }

  Container HelpBTN(context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 40, 0, 10),
      child: SizedBox(
        height: 40, //height of button
        width: double.infinity, //width of button equal to parent widget
        child: ElevatedButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpApp()),
            )
          },
          style: ElevatedButton.styleFrom(
              onPrimary: Colors.black,
              textStyle: const TextStyle(fontSize: 20),
              primary: Colors.blue[50], //background color of button
              //side: BorderSide(width: 0, color: Colors.brown), //border width and color
              elevation: 2, //elevation of button
              padding: EdgeInsets.all(7) //content padding inside button
              ),
          child: Text("감사노트 <오늘감사> 는...",
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void showTimePickerPop(context, noti_no) {
    TimeOfDay defaultTime;
    if (saved_time[noti_no] != null && saved_time[noti_no] != "") {
      int hh = int.parse(time_f.format(getTime2HH(saved_time[noti_no])));
      int ii = int.parse(time_f.format(getTime2II(saved_time[noti_no])));

      defaultTime = TimeOfDay(hour: hh, minute: ii);
    } else {
      defaultTime = TimeOfDay.now();
    }

    Future<TimeOfDay?> selectedTime = showTimePicker(
      context: context,
      initialTime: defaultTime,
    );
    selectedTime.then((timeOfDay) {
      setState(() {
        if (timeOfDay != null) {
          // 아래에서 바꿔줌.. .saved_noti[noti_no] = true;
          saved_time[noti_no] = '${timeOfDay.hour}:${timeOfDay.minute}';
          String hh = time_f.format(timeOfDay.hour);
          String ii = time_f.format(timeOfDay.minute);
          saved_timeTxt[noti_no] = '$hh:$ii';
          //print("시작");
          //print(timeOfDay.hour);
          //print(timeOfDay.minute);
          //print("끝");
          _dailyAtTimeNotification(
              noti_no, timeOfDay.hour, timeOfDay.minute, true);
        }

        //print(saved_timeTxt[noti_no]);
        //print(saved_timeTxt);
      });
    });
  }
}

void saveNotiState(noti_id, state) async {
  saved_noti[noti_id] = state;
  final SharedPreferences prefs = await _prefs;
  await prefs.setBool("notiState_$noti_id", saved_noti[noti_id]);
  //setNoti();
}

void saveNotiTime(noti_id, timeText) async {
  saved_time[noti_id] = timeText;
  final SharedPreferences prefs = await _prefs;
  await prefs.setString("notiTime_$noti_id", saved_time[noti_id]);
  //setNoti();
}

tz.TZDateTime _setNotiTime(int hh, int ii) {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hh, ii);

  return scheduledDate;
}
