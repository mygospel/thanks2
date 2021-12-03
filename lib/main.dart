import 'dart:async';

import 'dart:collection';
import 'package:calendar_calendar/calendar_calendar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './database/memo.dart';
import './database/db.dart';
import './splash.dart';
import './edit.dart';
import './help.dart';
import './calendar.dart';
import './calendar_util.dart';

TextEditingController titleController = new TextEditingController();
TextEditingController dateController = new TextEditingController();

List<Color> arr_color = [
  Colors.lightGreen.shade600,
  Colors.lightGreen.shade600,
  Colors.lightGreen.shade600,
  Colors.lightGreen.shade600,
  Colors.lightGreen.shade600,
  Colors.lightGreen.shade600
];

List<Icon> arr_icon = [
  Icon(MdiIcons.batteryOutline, color: Colors.white),
  Icon(MdiIcons.batteryLow, color: Colors.white),
  Icon(MdiIcons.batteryMedium, color: Colors.white),
  Icon(MdiIcons.batteryHigh, color: Colors.white),
  Icon(MdiIcons.batteryCharging, color: Colors.white),
  Icon(MdiIcons.batteryHeartVariant, color: Colors.white)
];

late List memoLists = [];
int sel_no = 0;
int total_count = 0;
int today_count = 0;
bool needUpdate = false;
String view_mode = "today";
Color today_color = arr_color[0];
Icon today_icon = arr_icon[0];

Color total_bg = Colors.white;
Color today_bg = Colors.white;

DBHelper sd = DBHelper();

// Future<void> _calReadToday() async {
//   await readTodayDB();

//   print("목록:");
//   print(memoLists.length);
//   for (var i = 0; i <= memoLists.length - 1; i++) {
//     tEvent.addAll([Event(memoLists[i].title)]);
//   }
// }

Future<void> _calReadTotal() async {
  memoLists = await sd.memos();

  //late Set<String,Map<DateTime, List<Event>>> tEventMap = [{}];
  late Map<String, List<Event>> someMap = {};
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  for (var i = 0; i <= memoLists.length - 1; i++) {
    //DateTime aa = DateTime.utc(2021, 12, 3);
    var datekey = formatter.format(DateTime.parse(memoLists[i].dt)).toString();
    //someMap[datekey] = [Event(memoLists[i].title)];

    if (someMap[datekey] == null) {
      someMap[datekey] = [];
      someMap[datekey]!.addAll([Event(memoLists[i].title)]);
    } else {
      someMap[datekey]!.addAll([Event(memoLists[i].title)]);
    }
  }

  //print(someMap);

  someMap.forEach((dkey, element) => _addEventsToCalendar(dkey, element));
}

void main() {
  runApp(new MaterialApp(
    home: new SplashScreen(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('ko'),
    ],
    routes: <String, WidgetBuilder>{
      '/TotalScreen': (BuildContext context) => new MyApp(),
      '/TodayScreen': (BuildContext context) => new MyApp(),
      '/Help': (BuildContext context) => new HelpApp(),
    },
  ));
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '감사노트 ＜오늘감사＞',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: '감사노트 ＜오늘감사＞'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _calReadTotal();
    if (view_mode == "all") {
      total_bg = Colors.lightGreen.shade100;
      today_bg = Colors.white;
    } else {
      total_bg = Colors.white;
      today_bg = Colors.lightGreen.shade100;
    }
  }

  void dispose() {
    titleController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0.0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(0.0, 5.0, 0.0),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        //leading: new Icon(Icons.cake), // 왼쪽아이콘.
        actions: <Widget>[
          /// 오른쪽 아이콘
          new IconButton(
              icon: new Icon(Icons.calendar_view_month, color: Colors.white70),
              tooltip: '달력보기',
              onPressed: () => {_gotoCalendar(context)}),

          /// 오른쪽 아이콘
          new IconButton(
              icon: new Icon(Icons.help, color: Colors.white70),
              tooltip: '앱소개',
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpApp()),
                    )
                  }),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: ThanksHeaderToday(context)),
              Expanded(child: ThanksHeaderTotal(context))
            ],
          ),
          Expanded(
            child: SingleChildScrollView(child: ThanksList('')),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        //onPressed: _incrementCounter,
        onPressed: () {
          sel_no = 0;
          viewArticle(context, sel_no);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 목록상단 전체
  InkWell ThanksHeaderTotal(context) {
    return new InkWell(
      child: new Card(
        color: total_bg,
        child: Padding(
          padding: EdgeInsets.all(7.0),
          child: Padding(
            padding: const EdgeInsets.all(21),
            child: Text('전체 $total_count',
                style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      onTap: () async {
        await readDB();
        view_mode = await "all";
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      },
    );
  }

  // 목록상단 오늘
  InkWell ThanksHeaderToday(BuildContext context) {
    return new InkWell(
        child: new Card(
          color: today_bg,
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1, 20, 50, 20),
              child: Badge(
                padding: EdgeInsets.all(10),
                position: BadgePosition.topEnd(top: -12, end: -30),
                badgeColor: today_color, // default: Colors.red
                badgeContent: today_icon,
                child: Text('오늘감사',
                    style: TextStyle(
                        color: Colors.green[500],
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        onTap: () async {
          view_mode = await "today";
          await readTodayDB();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        });
  }

  Future<void> _showDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: SingleChildScrollView(child: new Text("Alert Dialog body")),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget ThanksList(dt) {
    return FutureBuilder(builder: (context, snapshot) {
      //if (snapshot.hasData) {

      if (memoLists.length > 0) {
        // data loaded:
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // new
          shrinkWrap: true, //just set this property
          padding: const EdgeInsets.all(0.0),
          itemCount: memoLists == null ? 0 : memoLists.length,
          //itemExtent: 100.0,
          itemBuilder: (BuildContext context, int index) {
            // 달력에 추가

            return Card(
                child: Container(
                    padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                    child: ListTile(
                        title: Text(memoLists[index].title),
                        subtitle: Text(memoLists[index].dt),
                        onTap: () {
                          sel_no = memoLists[index].id;
                          viewArticle(context, sel_no);
                        })));
          },
        );
      } else {
        if (total_count > 0) {
          return Column(children: [
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                  onTap: () {
                    sel_no = 0;
                    viewArticle(context, sel_no);
                  },
                  title: Text("오늘 첫번째 감사를 기록해 보세요.",
                      style: TextStyle(
                          color: Colors.green[400],
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "감사를 기록할 때마다 감사배터리가 충전됩니다. 하루3번 감사의 기록으로 배터리를 충전해주세요.")),
            )),
          ]);
        } else {
          return Column(children: [
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                  title: Text("감사를 기록해 보세요."),
                  subtitle:
                      Text("매일 감사의 기록해 보세요. 지나간 날들에 쌓여진 감사로 인해  기쁨이 가득합니다.")),
            )),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                  title: Text("하루3번 감사로 배터리를 완충해주세요."),
                  subtitle: Text(
                      "감사를 기록할 때마다 감사 배터리가 충전됩니다. 하루3번 감사의 기록으로 배터리를 충전해주세요.")),
            )),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                  title: Text("감사기록을 공유해 보세요."),
                  subtitle: Text(
                      "감사를 가족, 친구, 동료와 공유해보세요. 나는 기쁨이 두배, 우리 공동체는 감사가 두배")),
            )),
          ]);
        }
      }
      //}
    });
  }
}

Future<void> readDB() async {
  var dt = DateFormat("yyyy-MM-dd").format(DateTime.now());
  today_count = await sd.memosToday(dt);
  total_count = await sd.memosTotal();
  memoLists = await sd.memos();
}

Future<void> readTodayDB() async {
  var dt = DateFormat("yyyy-MM-dd").format(DateTime.now());
  memoLists = await sd.memosList(dt);
}

Future<void> reloadTotal() async {
  var dt = DateFormat("yyyy-MM-dd").format(DateTime.now());
  today_count = await sd.memosToday(dt);
  total_count = await sd.memosTotal();

  int icon_number = (today_count > 5) ? 5 : today_count;

  today_color = arr_color[icon_number];
  today_icon = arr_icon[icon_number];
}

Future<void> viewArticle(context, int id) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const EditRoute()),
  );

  if (id > 0) {
    Memo viewMemo = await sd.memoRead(id);
    titleController.text = await viewMemo.title;
    dateController.text = await viewMemo.dt;
  } else {
    titleController.text = '';
    dateController.text =
        await DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();
  }
}

Future<void> saveDB() async {
  var fido = Memo(
      id: 0,
      title: titleController.text,
      cont: titleController.text,
      dt: dateController.text,
      createTime: DateTime.now().toString(),
      editTime: DateTime.now().toString());

  int new_id = await sd.insertMemo(fido);

  reloadTotal();
  //readDB();
}

Future<void> deleteArticle(context) async {
  if (sel_no > 0) {
    sd.deleteMemo(sel_no);
    var dt = DateFormat("yyyy-MM-dd").format(DateTime.now());
    today_count = await sd.memosToday(dt);
    total_count = await sd.memosTotal();

    titleController.text = "";
    dateController.text = "";

    sel_no = 0;

    await readTodayDB();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  } else {}
}

void _addEventsToCalendar(dkey, element) {
  DateTime aDate;
  aDate = DateTime.parse(dkey);
  tEventAll.addAll({DateTime(aDate.year, aDate.month, aDate.day): element});
}

void _gotoCalendar(context) {
  _calReadTotal();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ThanksCanledar()),
  );
}
