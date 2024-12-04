import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/course_provider.dart';
import '../../models/todo.dart';
import '../../config/course_time.dart';

// 时间段类
class _TimeRange {
  final DateTime start;
  final DateTime end;

  _TimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // 解析时间字符串
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  // 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }

  // 计算空闲时间段
  List<_TimeRange> _calculateFreeTimeSlots(
    List<_TimeRange> busySlots, {
    required int startHour,
    required int endHour,
  }) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day, startHour);
    final dayEnd = DateTime(now.year, now.month, now.day, endHour);

    if (busySlots.isEmpty) {
      return [_TimeRange(start: dayStart, end: dayEnd)];
    }

    // 按开始时间排序
    busySlots.sort((a, b) => a.start.compareTo(b.start));

    final freeSlots = <_TimeRange>[];
    var currentTime = dayStart;

    for (final busy in busySlots) {
      if (currentTime.isBefore(busy.start)) {
        freeSlots.add(_TimeRange(
          start: currentTime,
          end: busy.start,
        ));
      }
      currentTime = busy.end;
    }

    if (currentTime.isBefore(dayEnd)) {
      freeSlots.add(_TimeRange(
        start: currentTime,
        end: dayEnd,
      ));
    }

    return freeSlots;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodoProgress(context),
          const SizedBox(height: 24),
          _buildTodayCourses(context),
          const SizedBox(height: 24),
          _buildFreeTime(context),
        ],
      ),
    );
  }

  Widget _buildTodoProgress(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.todos;
        final completed =
            todos.where((todo) => todo.status == TodoStatus.completed).length;
        final total = todos.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '待办进度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  '已完成 $completed / $total 项',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayCourses(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final weekday = now.weekday;
        final courses = provider.courses
            .where((course) => course.dayOfWeek == weekday)
            .toList();
        courses.sort((a, b) => a.startSection.compareTo(b.startSection));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日课程',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (courses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '今天没有课程',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final timeSlot =
                          CourseTime.getTimeSlotBySection(course.startSection);
                      return ListTile(
                        leading: Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: course.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(course.name),
                        subtitle: Text(
                          '${timeSlot?.start} @ ${course.location}',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFreeTime(BuildContext context) {
    // 定义工作时间范围
    const startHour = 8;
    const endHour = 22;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '空闲时间',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showTodoScheduler(context),
                  child: const Text('安排待办'),
                ),
              ],
            ),
            Consumer2<CourseProvider, TodoProvider>(
              builder: (context, courseProvider, todoProvider, child) {
                final now = DateTime.now();
                final weekday = now.weekday;
                final courses = courseProvider.courses
                    .where((course) => course.dayOfWeek == weekday)
                    .toList();

                // 获取所有课程时间段
                final busyTimeSlots = courses.map((course) {
                  final start =
                      CourseTime.getTimeSlotBySection(course.startSection);
                  final end =
                      CourseTime.getTimeSlotBySection(course.endSection);
                  return _TimeRange(
                    start: _parseTime(start?.start ?? ""),
                    end: _parseTime(end?.end ?? ""),
                  );
                }).toList();

                // 计算空闲时间段
                final freeTimeSlots = _calculateFreeTimeSlots(
                  busyTimeSlots,
                  startHour: startHour,
                  endHour: endHour,
                );

                if (freeTimeSlots.isEmpty) {
                  return Text(
                    '今天的课程排得很满',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 空闲时间段列表
                    Column(
                      children: freeTimeSlots.map((slot) {
                        // 获取该时间段内的待办事项
                        final todosInSlot = todoProvider.todos.where((todo) {
                          return todo.status == TodoStatus.pending &&
                              todo.startTime.isAfter(slot.start) &&
                              todo.endTime.isBefore(slot.end);
                        }).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: Text(
                                '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                              ),
                              subtitle: Text(
                                '空闲 ${_formatDuration(slot.duration)}',
                              ),
                            ),
                            if (todosInSlot.isNotEmpty)
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: todosInSlot.length,
                                  itemBuilder: (context, index) {
                                    final todo = todosInSlot[index];
                                    return Card(
                                      margin: const EdgeInsets.only(right: 8),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              todo.title,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                            Text(
                                              _formatTime(todo.startTime),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 显示待办安排对话框
  void _showTodoScheduler(BuildContext context) {
    final todos = Provider.of<TodoProvider>(context, listen: false)
        .todos
        .where((todo) => todo.status == TodoStatus.pending)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安排待办事项'),
        content: SizedBox(
          width: double.maxFinite,
          child: todos.isEmpty
              ? const Text('没有待办事项可安排')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.schedule),
                        onPressed: () {
                          Navigator.pop(context);
                          _showTimeSlotPicker(context, todo);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showTimeSlotPicker(BuildContext context, Todo todo) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final provider = Provider.of<CourseProvider>(context, listen: false);
    final courses = provider.courses
        .where((course) => course.dayOfWeek == weekday)
        .toList();

    // 获取所有课程时间段
    final busyTimeSlots = courses.map((course) {
      final start = CourseTime.getTimeSlotBySection(course.startSection);
      final end = CourseTime.getTimeSlotBySection(course.endSection);
      return _TimeRange(
        start: _parseTime(start?.start ?? ""),
        end: _parseTime(end?.end ?? ""),
      );
    }).toList();

    // 计算空闲时间段
    final freeTimeSlots = _calculateFreeTimeSlots(
      busyTimeSlots,
      startHour: 8,
      endHour: 22,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择时间段'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: freeTimeSlots.length,
            itemBuilder: (context, index) {
              final slot = freeTimeSlots[index];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  '${_formatTime(slot.start)} - ${_formatTime(slot.end)}',
                ),
                subtitle: Text('空闲 ${_formatDuration(slot.duration)}'),
                onTap: () {
                  Navigator.pop(context);
                  _scheduleTodo(context, todo, slot);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _scheduleTodo(BuildContext context, Todo todo, _TimeRange timeSlot) {
    final updatedTodo = todo.copyWith(
      startTime: timeSlot.start,
      endTime: timeSlot.end,
      duration: timeSlot.duration.inMinutes,
    );

    Provider.of<TodoProvider>(context, listen: false)
        .updateTodo(updatedTodo)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已将"${todo.title}"安排到 ${_formatTime(timeSlot.start)}'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .updateTodo(todo);
            },
          ),
        ),
      );
    });
  }
}
