import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thanks2/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    reloadTotal();
    readTodayDB();
    //total_count = 23;

    Timer(Duration(seconds: 4),
        () => Navigator.pushNamed(context, '/TodayScreen'));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: Image.asset(
        'assets/splash_img.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
