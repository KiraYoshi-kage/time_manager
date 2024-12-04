import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Todo> get todos {
    switch (_filter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.pending:
        return _todos
            .where((todo) => todo.status == TodoStatus.pending)
            .toList();
      case TodoFilter.completed:
        return _todos
            .where((todo) => todo.status == TodoStatus.completed)
            .toList();
      case TodoFilter.overdue:
        return _todos
            .where(
                (todo) => todo.status == TodoStatus.pending && todo.isOverdue)
            .toList();
    }
  }

  TodoFilter get filter => _filter;

  // 加载所有待办事项
  Future<void> loadTodos() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _db.getAllTodos();
      _updateOverdueTodos();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加待办事项
  Future<void> addTodo(Todo todo) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _db.insertTodo(todo);
      final newTodo = Todo(
        id: id,
        title: todo.title,
        description: todo.description,
        startTime: todo.startTime,
        endTime: todo.endTime,
        duration: todo.duration,
        priority: todo.priority,
        status: todo.status,
        createdAt: todo.createdAt,
        customReminderTime: todo.customReminderTime,
        reminderBeforeFiveMin: todo.reminderBeforeFiveMin,
      );
      _todos.add(newTodo);
      _updateOverdueTodos();
      await NotificationService.instance.scheduleNotifications(newTodo);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新待办事项
  Future<void> updateTodo(Todo todo) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _updateOverdueTodos();
        await NotificationService.instance.scheduleNotifications(todo);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除待办事项
  Future<void> deleteTodo(int id) async {
    await _db.deleteTodo(id);
    _todos.removeWhere((todo) => todo.id == id);
    await NotificationService.instance.cancelNotifications(id);
    notifyListeners();
  }

  // 切换待办事项状态
  Future<void> toggleTodoStatus(Todo todo) async {
    _isLoading = true;
    notifyListeners();

    final newStatus = todo.status == TodoStatus.completed
        ? TodoStatus.pending
        : TodoStatus.completed;

    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      startTime: todo.startTime,
      endTime: todo.endTime,
      duration: todo.duration,
      priority: todo.priority,
      status: newStatus,
      createdAt: todo.createdAt,
      customReminderTime: todo.customReminderTime,
      reminderBeforeFiveMin: todo.reminderBeforeFiveMin,
      enableReminder: todo.enableReminder,
    );

    try {
      await _db.updateTodo(updatedTodo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        _updateOverdueTodos();
        await NotificationService.instance.scheduleNotifications(updatedTodo);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 设置筛选条件
  void setFilter(TodoFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  // 更新过期状态
  void _updateOverdueTodos() {
    for (final todo in _todos) {
      if (todo.isOverdue && todo.status == TodoStatus.pending) {
        updateTodo(todo.copyWith(status: TodoStatus.overdue));
      }
    }
  }

  // 定时检查过期待办事项
  void startOverdueCheck() {
    Future.delayed(const Duration(minutes: 1), () {
      _updateOverdueTodos();
      startOverdueCheck();
    });
  }
}

enum TodoFilter {
  all,
  pending,
  completed,
  overdue,
}
