import 'dart:async';
import 'package:calendar_calendar/calendar_calendar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import './main.dart';

class HelpApp extends StatelessWidget {
  const HelpApp({Key? key}) : super(key: key);

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
        ])),
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

그렇게 감사노트가 만들어졌습니다.

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
