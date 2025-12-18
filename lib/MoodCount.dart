import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MoodModel.dart';
import 'MoodDatabase.dart';

class MoodCount extends StatefulWidget {
  final DateTime displayMonth;
  const MoodCount({super.key, required this.displayMonth});

  @override
  State<MoodCount> createState() => _MoodCountState();
}

class _MoodCountState extends State<MoodCount> {
  final moodDB = MoodDatabase();
  DateTime _currentMonth = DateTime.now();
  String _filterType = 'Month';

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.displayMonth;
  }

  String _getAssetPath(int scale) {
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

  List<MoodModel> _filterMoods(List<MoodModel> allMoods) {
    return allMoods.where((mood) {
      if (mood.createdOn.isEmpty) return false;

      try {
        DateTime moodDate = DateTime.parse(mood.createdOn);
        if (_filterType == 'Month') {
          return moodDate.month == _currentMonth.month &&
              moodDate.year == _currentMonth.year;
        } else {
          return moodDate.year == _currentMonth.year;
        }
      } catch (e) {
        return false;
      }
    }).toList();
  }

  String _getDisplayTitle() {
    if (_filterType == 'Month') {
      return DateFormat('MMM yyyy').format(_currentMonth);
    } else {
      return DateFormat('yyyy').format(_currentMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Index"),
        backgroundColor: Colors.blue.shade200,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<MoodModel>>(
        future: moodDB.getMood(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final filteredMoods = _filterMoods(snapshot.data!);

            Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0, 0: 0};
            for (var mood in filteredMoods) {
              counts[mood.scale] = (counts[mood.scale] ?? 0) + 1;
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mood Index",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: _filterType,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Month',
                              child: Text('By Month'),
                            ),
                            DropdownMenuItem(
                              value: 'Year',
                              child: Text('By Year'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _filterType = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            if (_filterType == 'Month') {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            } else {
                              _currentMonth = DateTime(_currentMonth.year - 1);
                            }
                          });
                        },
                      ),
                      Text(
                        _getDisplayTitle(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          setState(() {
                            if (_filterType == 'Month') {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            } else {
                              _currentMonth = DateTime(_currentMonth.year + 1);
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildRow(" ", "Total", isHeader: true),
                        const Divider(height: 1, color: Colors.black),
                        _buildRow(_getAssetPath(5), counts[5].toString()),
                        _buildRow(_getAssetPath(4), counts[4].toString()),
                        _buildRow(_getAssetPath(3), counts[3].toString()),
                        _buildRow(_getAssetPath(2), counts[2].toString()),
                        _buildRow(_getAssetPath(1), counts[1].toString()),
                        _buildRow(_getAssetPath(0), counts[0].toString()),
                      ],
                    ),
                  ),
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "DONE",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Error"));
        },
      ),
    );
  }

  Widget _buildRow(String assetLabel, String count, {bool isHeader = false}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 50,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.black)),
            ),
            alignment: Alignment.center,
            child: isHeader
                ? Text(
                    assetLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : Image.asset(assetLabel, width: 30, height: 30),
          ),
        ),

        Expanded(
          flex: 3,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              count,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
