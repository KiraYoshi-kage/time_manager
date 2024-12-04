import 'package:flutter/material.dart';
import '../../models/course.dart';
import './add_course_screen.dart';

// 课程详情界面，显示课程的详细信息
class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedCourse = await Navigator.push<Course>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCourseScreen(course: course),
                ),
              );

              if (updatedCourse != null && context.mounted) {
                Navigator.pop(context, updatedCourse);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTimeCard(),
          ],
        ),
      ),
    );
  }

  // 构建课程基本信息卡片
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: course.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoItem(Icons.person, '教师', course.teacher),
            const SizedBox(height: 12),
            _buildInfoItem(Icons.location_on, '地点', course.location),
          ],
        ),
      ),
    );
  }

  // 构建课程时间信息卡片
  Widget _buildTimeCard() {
    String weekType;
    switch (course.weekType) {
      case 0:
        weekType = '全周';
        break;
      case 1:
        weekType = '单周';
        break;
      case 2:
        weekType = '双周';
        break;
      default:
        weekType = '未知';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '上课时间',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoItem(
              Icons.date_range,
              '周数',
              '第${course.weekStart}-${course.weekEnd}周',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.schedule,
              '时间',
              '周${_getWeekdayText(course.dayOfWeek)} '
                  '第${course.startSection}-${course.endSection}节',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(Icons.repeat, '类型', weekType),
          ],
        ),
      ),
    );
  }

  // 构建信息项（图标+标签+值）
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // 获取星期几的文本
  String _getWeekdayText(int dayOfWeek) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[dayOfWeek - 1];
  }

  // 显示删除确认对话框
  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除课程'),
        content: const Text('确定要删除这门课程吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // 返回true表示删除课程
    }
  }
}
