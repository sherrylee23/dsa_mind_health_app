import 'package:dsa_mind_health/todo_item.dart';

class TodoListModel {
  int list_id;
  final int user_id;
  String title;
  String updated_at; // 1. Changed type to String
  List<TodoItemModel> items;

  TodoListModel({
    required this.list_id,
    required this.user_id,
    required this.title,
    required this.updated_at, // 2. Constructor updated to take String
    this.items = const [],
  });

  TodoListModel copyWith({
    int? list_id,
    int? user_id,
    String? title,
    List<TodoItemModel>? items,
    String? updated_at, // 3. Changed copyWith parameter to String
  }) {
    return TodoListModel(
      list_id: list_id ?? this.list_id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      items: items ?? this.items,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory TodoListModel.fromJson(Map<String, dynamic> json) {
    return TodoListModel(
      list_id: json['list_id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      // 4. Directly assign the value as a String
      updated_at: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TodoItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'list_id': list_id == 0 ? null : list_id,
    'user_id': user_id,
    'title': title,
    // 5. No need to call .toIso8601String() because it's already a String
    'updated_at': updated_at,
  };
}