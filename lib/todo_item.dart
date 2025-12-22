class TodoItemModel {
   int item_id;
   int list_id;
  String title;
  int completed;
  final DateTime created_at;

  TodoItemModel({
    required this.item_id,
    required this.list_id,
    required this.title,
    required this.completed,
    required this.created_at,
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json){
    return TodoItemModel(
      item_id: json['item_id'] ?? 0,
      list_id: json['list_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      completed: json['completed'] ?? 0,
      created_at: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'item_id': item_id == 0 ? null : item_id,
    'list_id': list_id == 0 ? null : list_id,
    'title': title,
    'completed': completed,
    'created_at': created_at.toIso8601String(),
  };
}
