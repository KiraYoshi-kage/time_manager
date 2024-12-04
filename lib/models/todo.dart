import 'package:flutter/material.dart';

enum TodoPriority {
  low,
  medium,
  high,
}

enum TodoStatus {
  pending,
  completed,
  overdue,
}

class Todo {
  final int? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime createdAt;
  final DateTime? customReminderTime;
  final bool enableReminder;
  final bool reminderBeforeFiveMin;
  final int duration;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.priority = TodoPriority.medium,
    this.status = TodoStatus.pending,
    DateTime? createdAt,
    this.customReminderTime,
    this.enableReminder = true,
    this.reminderBeforeFiveMin = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // 从JSON创建对象
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: json['duration'] as int,
      priority: TodoPriority.values[json['priority'] as int],
      status: TodoStatus.values[json['status'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      customReminderTime: json['customReminderTime'] != null
          ? DateTime.parse(json['customReminderTime'] as String)
          : null,
      enableReminder: json['enableReminder'] as bool? ?? true,
      reminderBeforeFiveMin: json['reminderBeforeFiveMin'] as bool? ?? true,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'customReminderTime': customReminderTime?.toIso8601String(),
      'enableReminder': enableReminder,
      'reminderBeforeFiveMin': reminderBeforeFiveMin,
    };
  }

  // 复制对象并修改部分属性
  Todo copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? customReminderTime,
    bool? enableReminder,
    bool? reminderBeforeFiveMin,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      customReminderTime: customReminderTime ?? this.customReminderTime,
      enableReminder: enableReminder ?? this.enableReminder,
      reminderBeforeFiveMin:
          reminderBeforeFiveMin ?? this.reminderBeforeFiveMin,
    );
  }

  // 获取优先级颜色
  Color get priorityColor {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
    }
  }

  // 检查是否过期
  bool get isOverdue {
    return DateTime.now().isAfter(endTime) && status == TodoStatus.pending;
  }
}
