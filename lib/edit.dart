import 'dart:async';
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

import './database/memo.dart';
import './database/db.dart';
import './main.dart';
import './splash.dart';
import './help.dart';

String _selectedTime = "";

class EditRoute extends StatelessWidget {
  const EditRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late FocusNode myFocusNode;
    myFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Text(
            "감사등록하기",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The first text field is focused on as soon as the app starts.

            // The second text field is focused on when a user taps the
            // FloatingActionButton.
            TextFormField(
              minLines: 5,
              maxLines: 7,
              controller: titleController,
              autocorrect: true,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "감사의 내용을 입력해주세요.",
              ),
            ),
            TextFormField(
              enabled: true, // 변경불가
              //enableInteractiveSelection: false,
              readOnly: false, // 변경불가, 클릭도 안됨.
              controller: dateController,
              autocorrect: false,
              autofocus: true,
              onTap: () {
                showDatePickerPop(context);
              },
            ),
            SizedBox(
              height: 40, //height of button
              width: double.infinity, //width of button equal to parent widget
              child: ElevatedButton(
                onPressed: () {
                  saveArticle(context);
                  //Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                    //primary: Colors.blue[600], //background color of button
                    //side: BorderSide(width: 0, color: Colors.brown), //border width and color
                    elevation: 2, //elevation of button
                    padding: EdgeInsets.all(7) //content padding inside button
                    ),
                child: const Text('작성완료'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCancel(context);
        },
        //backgroundColor: Colors.black54,
        tooltip: '삭제',
        child: const Icon(Icons.delete),
      ),
    );
  }

  Future<void> _neverSatisfied(context) async {
    //이거 왜 쓴건지는 모르겠네.
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('제목'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('Alert Dialog 입니다'),
                Text('OK를 눌러 닫습니다'),
              ],
            ),
          ),
          actions: <Widget>[
            //ok cancel 사용
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                // Todo
                Navigator.of(context).pop(); //pop을 사용 - dialog stack제거
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancel(BuildContext context) async {
    if (sel_no > 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("안내"),
            content: SingleChildScrollView(child: new Text("정말로 삭제하시겠습니까?")),
            actions: <Widget>[
              new FlatButton(
                child: new Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text("삭제"),
                onPressed: () {
                  deleteArticle(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  /* DatePicker 띄우기 */
  void showDatePickerPop(context) {
    Future<DateTime?> selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now(), //초기값
      firstDate: DateTime(2020), //시작일
      lastDate: DateTime(2022), //마지막일

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data:
              ThemeData(primarySwatch: Colors.green, splashColor: Colors.green),
          //data: ThemeData.dark(), //다크 테마
          child: child!,
        );
      },
    );

    selectedDate.then((dateTime) {
      if (dateTime != null)
        dateController.text = dateTime.toString().substring(0, 10);

      /*
      Fluttertoast.showToast(
        msg: dateTime.toString(),
        toastLength: Toast.LENGTH_LONG,
        //gravity: ToastGravity.CENTER,  //위치(default 는 아래)
      );
      */
    });
  }

  Future<void> saveArticle(context) async {
    if (titleController.text.trim() == "") {
      _showDialog(context, '내용을 입력해주세요.');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('내용을 입력해주세요.')),
      // );
      return;
    }

    if (dateController.text.trim() == "") {
      _showDialog(context, '날자를 입력해주세요.');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('날자를 입력해주세요.')),
      // );
      return;
    }

    var fido = Memo(
        id: sel_no,
        title: titleController.text,
        cont: titleController.text,
        dt: dateController.text,
        createTime: DateTime.now().toString(),
        editTime: DateTime.now().toString());

    if (fido.id > 0) {
      await sd.updateMemo(fido);
    } else {
      int new_id = await sd.insertMemo(fido);
      if (new_id > 0) {}
    }

    sel_no = 0;

    //print("저장후 reloadTotal 실행");
    await reloadTotal();

    titleController.text = "";
    dateController.text = "";

    needUpdate = true;

    if (view_mode == "all") {
      await readDB();
    } else {
      await readTodayDB();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }
}

Future<void> _showDialog(BuildContext context, msg) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        //title: new Text("안내"),
        content: SingleChildScrollView(child: new Text(msg)),
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
