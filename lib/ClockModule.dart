import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ClockModule extends StatefulWidget {
  @override
  _ClockModuleState createState() => _ClockModuleState();
}

class _ClockModuleState extends State<ClockModule> {
  String timeString;

  @override
  void initState() {
    super.initState();
    updateTimeString();
    Timer.periodic(Duration(seconds: 1), (Timer t) => updateTimeString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: 400,
      height: 200,
      child: Center(
          child: Text('$timeString',
          overflow: TextOverflow.visible,
              style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 120,
                  letterSpacing: -6,
                  fontWeight: FontWeight.w100))),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 6),
              color: Colors.grey,
              spreadRadius: 2)
        ],
      ),
    );
  }

  void updateTimeString() {
    final DateTime now = DateTime.now();
    var formattedString = DateFormat('hh:mm').format(now);
    if (formattedString.startsWith('0')) {
      formattedString = formattedString.substring(1);
    }

    setState(() {
      timeString = formattedString;
    });
  }
}
