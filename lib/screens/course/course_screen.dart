import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../widgets/course/course_card.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';
import '../../providers/course_provider.dart';
import '../../services/semester_service.dart';

// 课程表主界面
class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  static const int _maxWeek = 20; // 最大周数
  static const int _maxSection = 12; // 每天最大节数
  final List<String> _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    // 初始化时加载课程数据
    Provider.of<CourseProvider>(context, listen: false).loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () {
              // TODO: 实现课表导入功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekSelector(),
          Expanded(
            child: _buildCourseGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 构建周数选择器
  Widget _buildWeekSelector() {
    final semesterService = Provider.of<SemesterService>(context);
    final currentWeek = semesterService.currentWeek;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('第$currentWeek周'),
          if (semesterService.startDate == null)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/semester');
              },
              child: const Text('设置开学时间'),
            ),
        ],
      ),
    );
  }

  // 构建课程表网格
  Widget _buildCourseGrid() {
    return SingleChildScrollView(
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTimeColumn(),
              Row(
                children: List.generate(
                  _weekdays.length,
                  (index) => _buildDayColumn(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建时间列（第几节课）
  Widget _buildTimeColumn() {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        ...List.generate(
          _maxSection,
          (index) => Container(
            height: 100,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text('${index + 1}'),
          ),
        ),
      ],
    );
  }

  // 构建每一天的课程列
  Widget _buildDayColumn(int dayIndex) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text('周${_weekdays[dayIndex]}'),
        ),
        ..._buildCourseCells(dayIndex + 1),
      ],
    );
  }

  // 新增：构建一天的课程格子列表
  List<Widget> _buildCourseCells(int day) {
    final List<Widget> cells = [];
    final courseProvider = Provider.of<CourseProvider>(context);
    Course? lastCourse;
    int continuousCount = 0;

    for (int section = 1; section <= _maxSection; section++) {
      final course = courseProvider.courses.firstWhere(
        (c) =>
            c.dayOfWeek == day &&
            section >= c.startSection &&
            section <= c.endSection &&
            courseProvider.currentWeek >= c.weekStart &&
            courseProvider.currentWeek <= c.weekEnd &&
            (c.weekType == 0 ||
                (c.weekType == 1 && courseProvider.currentWeek % 2 == 1) ||
                (c.weekType == 2 && courseProvider.currentWeek % 2 == 0)),
        orElse: () => Course(
          name: '',
          teacher: '',
          location: '',
          weekStart: 0,
          weekEnd: 0,
          dayOfWeek: 0,
          startSection: 0,
          endSection: 0,
          color: Colors.transparent,
        ),
      );

      // 检查是否需要合并单元格
      if (lastCourse != null &&
          course.name.isNotEmpty &&
          course.id == lastCourse.id) {
        // 如果当前课程与上一个课程相同，增加连续计数
        continuousCount++;
        continue; // 跳过创建新的单元格
      } else {
        // 如果有需要合并的单元格，创建合并后的单元格
        if (lastCourse != null && continuousCount > 0) {
          cells.removeLast(); // 移除上一个创建的单元格
          cells.add(
            Container(
              height: 100.0 * (continuousCount + 1), // 根据连续数量调整高度
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: lastCourse.name.isNotEmpty
                  ? CourseCard(
                      course: lastCourse,
                      onTap: () => _showCourseDetail(lastCourse!),
                    )
                  : null,
            ),
          );
        }

        // 创建新的单元格
        cells.add(
          Container(
            height: 100,
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: course.name.isNotEmpty
                ? CourseCard(
                    course: course,
                    onTap: () => _showCourseDetail(course),
                  )
                : null,
          ),
        );

        // 重置计数器和上一个课程
        lastCourse = course;
        continuousCount = 0;
      }
    }

    // 处理最后一组连续课程
    if (lastCourse != null && continuousCount > 0) {
      cells.removeLast();
      cells.add(
        Container(
          height: 100.0 * (continuousCount + 1),
          width: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: lastCourse.name.isNotEmpty
              ? CourseCard(
                  course: lastCourse,
                  onTap: () => _showCourseDetail(lastCourse!),
                )
              : null,
        ),
      );
    }

    return cells;
  }

  // 新增：显示课程详情
  void _showCourseDetail(Course course) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );

    if (result is Course) {
      final success = await Provider.of<CourseProvider>(
        context,
        listen: false,
      ).updateCourse(result);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('课程时间冲突')),
        );
      }
    } else if (result == true) {
      await Provider.of<CourseProvider>(
        context,
        listen: false,
      ).deleteCourse(course.id!);
    }
  }

  // 添加新课程
  void _addCourse() async {
    final course = await Navigator.push<Course>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCourseScreen(),
      ),
    );

    if (course != null) {
      final success = await Provider.of<CourseProvider>(
        context,
        listen: false,
      ).addCourse(course);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('课程时间冲突')),
        );
      }
    }
  }
}
