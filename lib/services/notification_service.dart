import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo.dart';
import 'package:rxdart/subjects.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  NotificationService._();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationClick.add(details.payload);
      },
    );
  }

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_reminders',
        '待办提醒',
        channelDescription: '待办事项提醒通知',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> scheduleNotifications(Todo todo) async {
    // 取消之前的提醒
    await cancelNotifications(todo.id!);

    // 如果未启用提醒，直接返回
    if (!todo.enableReminder) {
      return;
    }

    // 如果已完成，不需要提醒
    if (todo.status == TodoStatus.completed) {
      return;
    }

    final startTime = todo.startTime;
    final List<Duration> reminders = [];

    // 添加5分钟提醒
    if (todo.reminderBeforeFiveMin) {
      reminders.add(const Duration(minutes: 5));
    }

    // 添加自定义提醒
    if (todo.customReminderTime != null) {
      final reminderDuration =
          todo.startTime.difference(todo.customReminderTime!);
      if (!reminderDuration.isNegative) {
        reminders.add(reminderDuration);
      }
    }

    for (final reminder in reminders) {
      final notificationTime = startTime.subtract(reminder);
      if (notificationTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          todo.id! * 10 + reminders.indexOf(reminder),
          '待办提醒',
          '待办事项"${todo.title}"将在${_formatDuration(reminder)}后开始',
          tz.TZDateTime.from(notificationTime, tz.local),
          _notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: todo.id.toString(),
        );
      }
    }
  }

  Future<void> cancelNotifications(int todoId) async {
    // 取消所有相关的提醒（包括自定义提醒）
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel(todoId * 10 + i);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }
}
