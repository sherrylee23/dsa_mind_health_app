import 'package:flutter/material.dart';

/// MODEL FOR ONE TO-DO LIST
class TodoListModel {
  TodoListModel({
    required this.id,
    required this.title,
    required this.items,
    required this.updatedAt,
  });

  final int id;
  String title;
  List<Map<String, dynamic>> items; // {title, completed}
  DateTime updatedAt;
}

/// PAGE 1 – SHOW ALL TO-DO LISTS
class TodoListHomePage extends StatefulWidget {
  const TodoListHomePage({super.key});

  @override
  State<TodoListHomePage> createState() => _TodoListHomePageState();
}

class _TodoListHomePageState extends State<TodoListHomePage> {
  final List<TodoListModel> _lists = [];

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d-$m-$y  $hh:$mm';
  }

  Future<void> _openNewList() async {
    final newList = await Navigator.push<TodoListModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const TodoPage(),
      ),
    );

    if (newList != null) {
      setState(() {
        _lists.add(newList);
      });
    }
  }

  Future<void> _openExistingList(TodoListModel list) async {
    final updated = await Navigator.push<TodoListModel>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoPage(existingList: list),
      ),
    );

    if (updated != null) {
      setState(() {
        final index = _lists.indexWhere((l) => l.id == updated.id);
        if (index != -1) {
          _lists[index] = updated;
        }
      });
    }
  }

  Future<void> _deleteList(TodoListModel list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete To Do List'),
            content: Text('Are you sure you want to delete "${list.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _lists.removeWhere((l) => l.id == list.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color topBlue = Color(0xFF90A4D4);

    // sort by latest update (descending)
    _lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: topBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'All To Do Lists',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _lists.isEmpty
                  ? const Center(
                child: Text('No To Do List yet. Tap + to create.'),
              )
                  : ListView.builder(
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  final list = _lists[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: const Color(0xFF90A4D4),
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _openExistingList(list),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      list.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last updated: ${_formatDateTime(
                                          list.updatedAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteList(list),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: topBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _openNewList,
                child: const Text(
                  'Create New To Do List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PAGE 2 – EDIT ONE TO-DO LIST
class TodoPage extends StatefulWidget {
  const TodoPage({super.key, this.existingList});

  final TodoListModel? existingList;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _taskCtrl = TextEditingController();
  final TextEditingController _editCtrl = TextEditingController();

  late List<Map<String, dynamic>> _todos;

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      _titleCtrl.text = widget.existingList!.title;
      _todos = List<Map<String, dynamic>>.from(widget.existingList!.items);
    } else {
      _todos = [];
    }
  }

  void _addTodo() {
    if (_taskCtrl.text.trim().isEmpty) return;
    setState(() {
      _todos.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': _taskCtrl.text.trim(),
        'completed': false,
      });
      _taskCtrl.clear();
    });
  }

  void _toggleTodo(int id) {
    setState(() {
      final index = _todos.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        _todos[index]['completed'] = !(_todos[index]['completed'] as bool);
      }
    });
  }

  void _deleteTodo(int id) {
    setState(() {
      _todos.removeWhere((t) => t['id'] == id);
    });
  }

  void _editTodo(int id) {
    final index = _todos.indexWhere((t) => t['id'] == id);
    if (index == -1) return;
    _editCtrl.text = _todos[index]['title'] as String;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _editCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task',
                ),
                onSubmitted: (_) => _saveEdit(id),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveEdit(id),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveEdit(int id) {
    if (_editCtrl.text.trim().isEmpty) return;
    setState(() {
      final index = _todos.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        _todos[index]['title'] = _editCtrl.text.trim();
      }
    });
    Navigator.pop(context);
  }

  // “Add To Do List” => save and go back to home page
  void _saveAndReturn() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for this list')),
      );
      return;
    }

    final now = DateTime.now();

    if (widget.existingList != null) {
      widget.existingList!
        ..title = _titleCtrl.text.trim()
        ..items = _todos
        ..updatedAt = now;
      Navigator.pop(context, widget.existingList);
    } else {
      final newList = TodoListModel(
        id: now.millisecondsSinceEpoch,
        title: _titleCtrl.text.trim(),
        items: _todos,
        updatedAt: now,
      );
      Navigator.pop(context, newList);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _taskCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color topBlue = Color(0xFF90A4D4);
    const Color cardBlue = Color(0xFFE1ECFF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: topBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'To Do List',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // TITLE FIELD at the top
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'To Do List Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // big rounded card with tasks
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                decoration: BoxDecoration(
                  color: cardBlue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // input + button (add task)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: TextField(
                              controller: _taskCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Enter task...',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _addTodo(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _addTodo,
                            child: const Text('+ Add'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // list of tasks
                    Expanded(
                      child: _todos.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          final id = todo['id'] as int;
                          final completed =
                              todo['completed'] as bool? ?? false;

                          return Row(
                            children: [
                              Checkbox(
                                value: completed,
                                onChanged: (_) => _toggleTodo(id),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  todo['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editTodo(id),
                              ),
                              IconButton(
                                icon:
                                const Icon(Icons.delete_outline_outlined),
                                onPressed: () => _deleteTodo(id),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // bottom button: "Add To Do List" -> save & back
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: topBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveAndReturn,
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


