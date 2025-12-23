import 'package:flutter/material.dart';
import 'MoodDatabase.dart';
import 'todo_list.dart';
import 'todo_item.dart';

// ==================== PAGE 1 – ALL TO DO LISTS ====================

class TodoListHomePage extends StatefulWidget {
  final int userId;
  const TodoListHomePage({super.key, required this.userId});

  @override
  State<TodoListHomePage> createState() => _TodoListHomePageState();
}

class _TodoListHomePageState extends State<TodoListHomePage> {
  final List<TodoListModel> _lists = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoLists();
  }

  Future<void> _loadTodoLists() async {
    // Uses the passed userId to filter lists [cite: 63]
    final lists = await MoodDatabase().getTodoList(user_id: widget.userId);
    setState(() {
      _lists.clear();
      _lists.addAll(lists);
    });
  }

  String _formatDateTime(String dtStr) {
    try {
      DateTime dt = DateTime.parse(dtStr);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d-$m-$y  $hh:$mm';
    } catch (e) {
      return dtStr;
    }
  }

  List<TodoListModel> get _filteredLists {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _lists;
    return _lists.where((l) => l.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _openNewList() async {
    final newList = await Navigator.push<TodoListModel>(
      context,
      MaterialPageRoute(builder: (_) => TodoPage(userId: widget.userId)),
    );
    if (newList != null) _loadTodoLists();
  }

  Future<void> _openExistingList(TodoListModel list) async {
    final updated = await Navigator.push<TodoListModel>(
      context,
      MaterialPageRoute(builder: (_) => TodoPage(existingList: list, userId: widget.userId)),
    );
    if (updated != null) _loadTodoLists();
  }

  Future<void> _deleteList(TodoListModel list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete To Do List'),
        content: Text('Are you sure you want to delete "${list.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MoodDatabase().deleteList(list.list_id);
        _loadTodoLists();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color topBlue = Color(0xFF90A4D4);
    _lists.sort((a, b) => b.updated_at.compareTo(a.updated_at));
    final visibleLists = _filteredLists;

    return Scaffold(
      appBar: AppBar(backgroundColor: topBlue, centerTitle: true, title: const Text('All To Do Lists')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: visibleLists.length,
                itemBuilder: (context, index) {
                  final list = visibleLists[index];
                  return ListTile(
                    tileColor: topBlue,
                    title: Text(list.title),
                    subtitle: Text('Last updated: ${_formatDateTime(list.updated_at)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _openExistingList(list)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteList(list)),
                      ],
                    ),
                    onTap: () => _openExistingList(list),
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: _openNewList, child: const Text('Create New List')),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE 2 – SINGLE TO DO LIST ====================

class TodoPage extends StatefulWidget {
  final TodoListModel? existingList;
  final int userId;

  const TodoPage({super.key, this.existingList, required this.userId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _taskCtrl = TextEditingController();
  late List<TodoItemModel> _todos;

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      _titleCtrl.text = widget.existingList!.title;
      _todos = List<TodoItemModel>.from(widget.existingList!.items); // [cite: 25]
    } else {
      _todos = []; // [cite: 26]
    }
  }

  Future<void> _addTodo() async {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;

    if (widget.existingList != null) {
      final newItem = TodoItemModel(
        item_id: 0,
        list_id: widget.existingList!.list_id,
        title: text,
        completed: 0,
        created_at: DateTime.now().toIso8601String(),
      );
      await MoodDatabase().insertItem(newItem); // Saves to DB immediately for existing lists
      setState(() {
        _todos.add(newItem);
      });
    } else {
      setState(() {
        _todos.add(TodoItemModel(
          item_id: 0,
          list_id: 0,
          title: text,
          completed: 0,
          created_at: DateTime.now().toIso8601String(),
        ));
      });
    }
    _taskCtrl.clear();
  }

  void _saveAndReturn() async {
    final String now = DateTime.now().toIso8601String();
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    if (widget.existingList != null) {
      final updatedList = widget.existingList!.copyWith(
        title: title,
        updated_at: now,
      );
      await MoodDatabase().editList(updatedList); // [cite: 32]
      Navigator.pop(context, updatedList);
    } else {
      final newList = TodoListModel(
        list_id: 0,
        user_id: widget.userId, // Uses the dynamic userId passed from Page 1
        title: title,
        items: _todos,
        updated_at: now,
      );

      await MoodDatabase().insertFullList(newList); // Saves List and Items at once
      Navigator.pop(context, newList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To Do List')),
      body: Column(
        children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          Row(
            children: [
              Expanded(child: TextField(controller: _taskCtrl)),
              ElevatedButton(onPressed: _addTodo, child: const Text('Add')),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) => ListTile(title: Text(_todos[index].title)),
            ),
          ),
          ElevatedButton(onPressed: _saveAndReturn, child: const Text('Done')),
        ],
      ),
    );
  }
}