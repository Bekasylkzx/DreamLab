import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _tasks = [];

  int _taskIdCounter = 0;

  void _addTask(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _tasks.add({
        'id': _taskIdCounter++,
        'title': title.trim(),
        'isCompleted': false,
      });
    });
  }


  void _toggleTask(int taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['isCompleted'] = !_tasks[taskIndex]['isCompleted'];
      }
    });
  }

  void _deleteTask(int taskId) {
    setState(() {
      _tasks.removeWhere((task) => task['id'] == taskId);
    });
  }

  Future<void> _showAddTaskDialog() async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Новая задача'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Введите название задачи',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      _addTask(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DreamTasks Lite'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: _tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return _buildTaskItem(task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Добавить задачу',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Нет задач',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы добавить задачу',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }


  Widget _buildTaskItem(Map<String, dynamic> task) {
    final int taskId = task['id'] as int;
    final String title = task['title'] as String;
    final bool isCompleted = task['isCompleted'] as bool;

    return Dismissible(
      key: Key('task_$taskId'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        _deleteTask(taskId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Задача "$title" удалена'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () {
                setState(() {
                  _tasks.insert(
                    _tasks.length,
                    {
                      'id': taskId,
                      'title': title,
                      'isCompleted': isCompleted,
                    },
                  );
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: Checkbox(
            value: isCompleted,
            onChanged: (bool? value) {
              _toggleTask(taskId);
            },
          ),
          title: Text(
            title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey,
              color: isCompleted ? Colors.grey[600] : null,
              fontSize: 16,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[400],
            onPressed: () => _deleteTask(taskId),
            tooltip: 'Удалить задачу',
          ),
        ),
      ),
    );
  }
}
