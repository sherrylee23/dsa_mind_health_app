import 'package:flutter/material.dart';
import 'MoodDatabase.dart';
import 'todo_list.dart';
import 'todo_item.dart';

// ==================== PAGE 1 – ALL TO DO LISTS ====================

class TodoListHomePage extends StatefulWidget {
  const TodoListHomePage({super.key});

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
    final lists = await MoodDatabase().getTodoList(user_id: 1); // use logged-in userId
    setState(() {
      _lists.clear();
      _lists.addAll(lists);
    });
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d-$m-$y  $hh:$mm';
  }

  List<TodoListModel> get _filteredLists {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _lists;
    return _lists.where((l) => l.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _openNewList() async {
    final newList = await Navigator.push<TodoListModel>(
      context,
      MaterialPageRoute(builder: (_) => const TodoPage()),
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
      MaterialPageRoute(builder: (_) => TodoPage(existingList: list)),
    );

    if (updated != null) {
      setState(() {
        final index = _lists.indexWhere((l) => l.list_id == updated.list_id);
        if (index != -1) _lists[index] = updated;
      });
    }
  }


  Future<void> _deleteList(TodoListModel list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      await MoodDatabase().deleteList(list.list_id); // delete from DB
      setState(() {
        _lists.removeWhere((l) => l.list_id == list.list_id);
      });
    }
  }

  void _onSearchPressed() {
    final visible = _filteredLists;
    if (visible.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No List Found'),
          content: const Text('No to do list matches your search.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color topBlue = Color(0xFF90A4D4);
    _lists.sort((a, b) => b.updated_at.compareTo(a.updated_at));
    final visibleLists = _filteredLists;

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search To Do Lists',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _onSearchPressed,
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: visibleLists.isEmpty
                  ? const Center(child: Text('No To Do List yet. Tap + to create.'))
                  : ListView.builder(
                itemCount: visibleLists.length,
                itemBuilder: (context, index) {
                  final list = visibleLists[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: topBlue,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _openExistingList(list),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(list.title,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last updated: ${_formatDateTime(list.updated_at)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _openNewList,
                child: const Text('Create New To Do List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE 2 – SINGLE TO DO LIST ====================

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

  late List<TodoItemModel> _todos;

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      _titleCtrl.text = widget.existingList!.title;
      _todos = List<TodoItemModel>.from(widget.existingList!.items);
    } else {
      _todos = [];
    }
  }

  int get _completedCount => _todos.where((t) => t.completed == 1).length;
  double get _progress => _todos.isEmpty ? 0 : _completedCount / _todos.length;

  void _addTodo() {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;

    final newItem = TodoItemModel(
      item_id: 0,
      list_id: widget.existingList?.list_id ?? 0, // 0 for new list temporarily
      title: text,
      completed: 0,
      created_at: DateTime.now(),
    );

    setState(() {
      _todos.add(newItem);
      _taskCtrl.clear();
    });


    // Save immediately (won't error if list_id=0)
    MoodDatabase().insertItem(newItem).catchError((e) => debugPrint('Item save: $e'));
  }

  void _toggleTodo(TodoItemModel todo) {
    setState(() {
      todo.completed = todo.completed == 1 ? 0 : 1;
    });
  }

  void _deleteTodo(TodoItemModel todo) {
    setState(() {
      _todos.remove(todo);
    });
  }

  void _editTodo(TodoItemModel todo) {
    _editCtrl.text = todo.title;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _editCtrl),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todo.title = _editCtrl.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndReturn() async {
    try {
      if (_titleCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title')),
        );
        return;
      }

      final now = DateTime.now();

      if (widget.existingList != null) {
        final updatedList = widget.existingList!.copyWith(
          title: _titleCtrl.text.trim(),
          items: _todos,
          updated_at: now,
        );

        await MoodDatabase().editList(updatedList);
        Navigator.pop(context, updatedList);
      } else {
        final newList = TodoListModel(
          list_id:0,
          user_id: 1,
          title: _titleCtrl.text.trim(),
          items: _todos,
          updated_at: DateTime.now(),
        );

        await MoodDatabase().insertList(newList);
        Navigator.pop(context, newList);
      }
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: const Text('To Do List', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'To Do List Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Completed $_completedCount out of ${_todos.length} tasks',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _progress, minHeight: 8),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskCtrl,
                            decoration: const InputDecoration(hintText: 'Enter task...', border: OutlineInputBorder()),
                            onSubmitted: (_) => _addTodo(),
                          ),
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
                          final todo = _todos[index];
                          return Row(
                            children: [
                              Checkbox(value: todo.completed == 1, onChanged: (_) => _toggleTodo(todo)),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.completed == 1 ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTodo(todo)),
                              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTodo(todo)),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndReturn,
                child: const Text('Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
