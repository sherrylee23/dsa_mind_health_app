import 'package:dsa_mind_health/todo_item.dart';

class TodoListModel {
   int list_id;
  final int user_id;
  String title;
  DateTime updated_at;
  List<TodoItemModel> items;


  TodoListModel({
    required this.list_id,
    required this.user_id,
    required this.title,
    required this.updated_at,
    this.items = const [],
  });

  TodoListModel copyWith({
    int? list_id,
    int? user_id,
    String? title,
    List<TodoItemModel>? items,
    DateTime? updated_at,
  }) {
    return TodoListModel(
      list_id: list_id ?? this.list_id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      items: items ?? this.items,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory TodoListModel.fromJson(Map<String, dynamic> json){
    return TodoListModel(
      list_id: json['list_id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      updated_at: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TodoItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'list_id': list_id == 0 ? null : list_id,
    'user_id': user_id, // 4. Added userId to toMap
    'title': title,
    'updated_at': updated_at.toIso8601String(),
  };
}
