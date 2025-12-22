class TodoItemModel {
  int item_id;
  int list_id;
  String title;
  int completed;
  final String created_at; // 1. Changed type from DateTime to String

  TodoItemModel({
    required this.item_id,
    required this.list_id,
    required this.title,
    required this.completed,
    required this.created_at, // 2. Updated constructor
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      item_id: json['item_id'] ?? 0,
      list_id: json['list_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      completed: json['completed'] ?? 0,
      // 3. Directly read the value as a String
      created_at: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() => {
    'item_id': item_id == 0 ? null : item_id, // This is fine
    'list_id': list_id, // FIX: Remove the '== 0 ? null' check
    'title': title,
    'completed': completed,
    'created_at': created_at,
  };
}