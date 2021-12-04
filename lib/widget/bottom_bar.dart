import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Container(
        height: 50,
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              child: Text(
                '감사노트',
              ),
            ),
            Tab(
              child: Text(
                '캘린더',
              ),
            ),
            Tab(
              child: Text(
                '설정',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
