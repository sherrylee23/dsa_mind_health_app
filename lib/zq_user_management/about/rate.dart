import 'package:flutter/material.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _selectedMood = -1;
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }
  
  void _submitRate(){
    final moods = ['Very sad', 'Sad', 'Neutral', 'Happy', 'Very happy'];
    final moodText = _selectedMood == -1? 'No mood selected' : moods[_selectedMood];
    showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text('Thank you!'),
          content: Text('Mood: $moodText\n\nComment:\n${_commentCtrl.text}'
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                child: const Text('OK'),
            ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate'),
        leading: IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xFF9FB7D9),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E6FF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text('How are you feeling?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Your input is valueble in helping us better understand your'
                        'needs and tailor our service accordingly.',
                        textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index){
                            final emojis = ['😢', '🥰', '😊', '😐', '😞'];
                            final selected = _selectedMood == index;
                            return GestureDetector(
                              onTap: (){
                                setState(() {
                                  _selectedMood = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Colors.blueAccent
                                        :Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child:  Text(
                                  emojis[index],
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Add a Comment...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _commentCtrl,
                                maxLines: null,
                                expands: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  border: InputBorder.none,
                                  hintText: 'Write your feedback here...',
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                  )
              ),
              const SizedBox(height: 12),

              //submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _submitRate, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B6CB7),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Submit Now',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                    ),
                    ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
