import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import 'add_todo_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    // 加载待办事项数据
    Provider.of<TodoProvider>(context, listen: false).loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterChips(),
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoProvider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无待办事项',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimatedList(
            key: GlobalKey<AnimatedListState>(),
            initialItemCount: todoProvider.todos.length,
            itemBuilder: (context, index, animation) {
              final todo = todoProvider.todos[index];
              return SlideTransition(
                position: animation.drive(Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                )),
                child: _buildTodoItem(todo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                TodoFilter.all,
                '全部',
                Icons.list,
                todoProvider,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                TodoFilter.pending,
                '未完成',
                Icons.pending_actions,
                todoProvider,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                TodoFilter.completed,
                '已完成',
                Icons.check_circle,
                todoProvider,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                TodoFilter.overdue,
                '已过期',
                Icons.warning,
                todoProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    TodoFilter filter,
    String label,
    IconData icon,
    TodoProvider provider,
  ) {
    final isSelected = provider.filter == filter;
    final theme = Theme.of(context);
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      onSelected: (bool selected) {
        provider.setFilter(filter);
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Dismissible(
      key: Key(todo.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('待办事项已删除'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.status == TodoStatus.completed,
            onChanged: (bool? value) async {
              await Provider.of<TodoProvider>(context, listen: false)
                  .toggleTodoStatus(todo);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.status == TodoStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(todo.description),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: todo.priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDateTime(todo.startTime)} - ${_formatDateTime(todo.endTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (todo.enableReminder &&
                      (todo.customReminderTime != null ||
                          todo.reminderBeforeFiveMin)) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.notifications, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatReminders(todo),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: todo.isOverdue && todo.status != TodoStatus.completed
              ? const Tooltip(
                  message: '已过期',
                  child: Icon(Icons.warning, color: Colors.red),
                )
              : null,
          onTap: () => _editTodo(todo),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}-${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }

  String _formatReminders(Todo todo) {
    final List<String> reminders = [];

    if (todo.reminderBeforeFiveMin) {
      reminders.add('5分钟前');
    }

    if (todo.customReminderTime != null) {
      reminders.add(_formatDateTime(todo.customReminderTime!));
    }

    return reminders.join(' / ');
  }

  void _addTodo() async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTodoScreen(),
      ),
    );

    if (result != null && mounted) {
      await Provider.of<TodoProvider>(context, listen: false).addTodo(result);
    }
  }

  void _editTodo(Todo todo) async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todo: todo),
      ),
    );

    if (result != null && mounted) {
      await Provider.of<TodoProvider>(context, listen: false)
          .updateTodo(result);
    }
  }
}
