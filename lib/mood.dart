import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';

class Mood extends StatelessWidget {
  final DateTime now = DateTime.now();
  final Color blueColor = Color.fromRGBO(138,169,217,100);
  Mood({super.key});

  // navigate calendar
  void _calendar(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const CalendarSelectionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d/M/yy E').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
        backgroundColor: blueColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month),
            color: Colors.black,
            tooltip: 'Select Date',
            onPressed: (){
              _calendar(context);
            },
          ),
        ],
      ),

    );
  }
}
