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
    // Uses the passed userId to filter lists [cite: 6, 58]
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
        await MoodDatabase().deleteList(list.list_id); // [cite: 78]
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
                  return Card(
                    color: topBlue,
                    child: ListTile(
                      title: Text(list.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Last updated: ${_formatDateTime(list.updated_at)}', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _openExistingList(list)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () => _deleteList(list)),
                        ],
                      ),
                      onTap: () => _openExistingList(list),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _openNewList, child: const Text('Create New To Do List')),
            ),
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
      _todos = List<TodoItemModel>.from(widget.existingList!.items); // [cite: 30]
    } else {
      _todos = [];
    }
  }

  // --- LOGIC METHODS ---

  double get _completionPercentage {
    if (_todos.isEmpty) return 0.0;
    int completedCount = _todos.where((item) => item.completed == 1).length;
    return completedCount / _todos.length;
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
      await MoodDatabase().insertItem(newItem); // [cite: 82]
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

  Future<void> _toggleTodo(TodoItemModel item) async {
    setState(() {
      item.completed = (item.completed == 1) ? 0 : 1;
    });

    if (widget.existingList != null && item.item_id != 0) {
      await MoodDatabase().editItem(item); //
    }
  }

  Future<void> _editTodoItem(int index) async {
    final item = _todos[index];
    final TextEditingController editCtrl = TextEditingController(text: item.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(controller: editCtrl, autofocus: true, decoration: const InputDecoration(hintText: "Enter task name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, editCtrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        item.title = newTitle;
      });

      if (widget.existingList != null && item.item_id != 0) {
        await MoodDatabase().editItem(item); //
      }
    }
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
      await MoodDatabase().editList(updatedList); // [cite: 75]
      Navigator.pop(context, updatedList);
    } else {
      final newList = TodoListModel(
        list_id: 0,
        user_id: widget.userId,
        title: title,
        items: _todos,
        updated_at: now,
      );
      await MoodDatabase().insertFullList(newList); // [cite: 68]
      Navigator.pop(context, newList);
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To Do List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'To Do List Title',
                    border: OutlineInputBorder()
                )
            ),
            const SizedBox(height: 16),
            Text('You completed ${_todos.where((t) => t.completed == 1).length} out of ${_todos.length} tasks'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _completionPercentage,
              color: Colors.green,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _taskCtrl,
                        decoration: const InputDecoration(hintText: 'Enter task...')
                    )
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTodo, child: const Text('+ Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final item = _todos[index];
                  return ListTile(
                    leading: Checkbox(
                      value: item.completed == 1,
                      onChanged: (_) => _toggleTodo(item),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                          decoration: item.completed == 1 ? TextDecoration.lineThrough : null,
                          color: item.completed == 1 ? Colors.grey : Colors.black
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                            onPressed: () => _editTodoItem(index)
                        ),
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() => _todos.removeAt(index));
                              // Optional: Add DB delete logic here if list exists
                            }
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90A4D4)),
                  onPressed: _saveAndReturn,
                  child: const Text('Done', style: TextStyle(color: Colors.white))
              ),
            ),
          ],
        ),
      ),
    );
  }
}