import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MoodModel.dart';
import 'MoodDatabase.dart';

class Monthlymooddetail extends StatefulWidget {
  final DateTime displayMonth;
  final int userId;

  const Monthlymooddetail({super.key, required this.displayMonth, required this.userId});

  @override
  State<Monthlymooddetail> createState() => _MonthlymooddetailState();
}

class _MonthlymooddetailState extends State<Monthlymooddetail> {
  final moodDB = MoodDatabase();

  // Track the current sorting order
  String _currentSort = 'createdOn DESC';

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
  } // <--- FIXED: Added missing closing brace here

  @override
  Widget build(BuildContext context) { // FIXED: context should be lowercase
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMM yyyy').format(widget.displayMonth)),
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // SORTING BUTTON
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                _currentSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'createdOn DESC', child: Text('Newest First')),
              const PopupMenuItem(value: 'createdOn ASC', child: Text('Oldest First')),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<MoodModel>>(
        // Pass the sort string to the database
        future: moodDB.getMood(userId: widget.userId, sortBy: _currentSort),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final monthlyMoods = snapshot.data!.where((mood) {
              DateTime moodDate = DateTime.parse(mood.createdOn);
              return moodDate.month == widget.displayMonth.month &&
                  moodDate.year == widget.displayMonth.year;
            }).toList();

            if (monthlyMoods.isEmpty) {
              return const Center(
                child: Text("No moods recorded for this month."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: monthlyMoods.length,
              itemBuilder: (context, index) {
                final mood = monthlyMoods[index];
                final date = DateTime.parse(mood.createdOn);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            _getAssetPath(mood.scale),
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${date.day}/${date.month}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('EEEE').format(date),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(mood.description),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          mood.isFavorite == 1 ? Icons.star : Icons.star_border,
                          color: mood.isFavorite == 1
                              ? Colors.yellow.shade700
                              : Colors.white,
                        ),
                        onPressed: () async {
                          await moodDB.setAsFavorite(mood);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Something went wrong."));
        },
      ),
    );
  }
}