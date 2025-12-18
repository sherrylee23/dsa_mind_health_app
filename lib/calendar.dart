import 'package:dsa_mind_health/MoodCount.dart';
import 'package:dsa_mind_health/monthlyMoodDetail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'MoodModel.dart';
import 'MoodDatabase.dart';

class calendar extends StatefulWidget {
  const calendar({super.key});

  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar> {
  DateTime _displayMonth = DateTime.now();
  final moodDB = MoodDatabase();

  int _refreshKey = 0;

  String _getAssetPathFromScale(int scale) {
    switch (scale) {
      case 5:
        return 'assets/images/Great.png';
      case 4:
        return 'assets/images/Good.png';
      case 3:
        return 'assets/images/Okay.png';
      case 2:
        return 'assets/images/No_Great.png';
      case 1:
        return 'assets/images/Bad.png';
      case 0:
        return 'assets/images/Angry.png';
      default:
        return 'assets/images/Okay.png';
    }
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOfMonthIndex(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

  void _refreshCalendar() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = _daysInMonth(_displayMonth);
    final int firstDayIndex = _firstDayOfMonthIndex(_displayMonth);
    final int totalRow = daysInMonth + firstDayIndex;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                  );
                });
              },
            ),
            Text(
              DateFormat('MMM yyyy').format(_displayMonth),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoodCount(displayMonth: _displayMonth),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<MoodModel>>(
        key: ValueKey(_refreshKey),
        future: moodDB.getMood(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Scaffold(body: Center(child: Text("No data found")));
          }

          final startOfMonth = DateTime(
            _displayMonth.year,
            _displayMonth.month,
            1,
          );
          final endOfMonth = DateTime(
            _displayMonth.year,
            _displayMonth.month + 1,
            0,
          );

          final currentMonthMoods = snapshot.data!.where((mood) {
            final moodDate = DateTime.parse(mood.createdOn);
            return moodDate.isAfter(
                  startOfMonth.subtract(const Duration(days: 1)),
                ) &&
                moodDate.isBefore(endOfMonth.add(const Duration(days: 1)));
          }).toList();

          return Column(
            children: [
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                children: List.generate(7, (index) {
                  final dayNames = [
                    'Sun',
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                  ];
                  return Center(
                    child: Text(
                      dayNames[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: totalRow,
                  itemBuilder: (context, index) {
                    final int dayNumber = index - firstDayIndex + 1;
                    if (index < firstDayIndex || dayNumber > daysInMonth) {
                      return Container();
                    }

                    final moodsForThisDay = currentMonthMoods.where((mood) {
                      return DateTime.parse(mood.createdOn).day == dayNumber;
                    }).toList();

                    MoodModel? moodForDay;
                    if (moodsForThisDay.isNotEmpty) {
                      try {
                        moodForDay = moodsForThisDay.firstWhere(
                          (m) => m.isFavorite == 1,
                        );
                      } catch (e) {
                        moodForDay = moodsForThisDay.first;
                      }
                    }

                    final currentDay = DateTime(
                      _displayMonth.year,
                      _displayMonth.month,
                      dayNumber,
                    );

                    return GestureDetector(
                      onTap: () async {
                        if (moodForDay != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Monthlymooddetail(
                                displayMonth: _displayMonth,
                              ),
                            ),
                          );
                          _refreshCalendar();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontWeight:
                                    currentDay.day == DateTime.now().day &&
                                        currentDay.month == DateTime.now().month
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    currentDay.day == DateTime.now().day &&
                                        currentDay.month == DateTime.now().month
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),

                            if (moodForDay != null)
                              Image.asset(
                                _getAssetPathFromScale(moodForDay.scale),
                                width: 30,
                                height: 30,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue.shade300,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('DONE', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
