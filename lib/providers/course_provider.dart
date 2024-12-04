import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/database_service.dart';
import '../services/semester_service.dart';

// 课程数据管理器，负责课程数据的状态管理
class CourseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Course> _courses = []; // 存储所有课程
  bool _isLoading = false;
  String? _error;

  // getter方法
  List<Course> get courses => _courses;
  int get currentWeek => SemesterService.instance.currentWeek;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载所有课程数据
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _courses = await _db.getAllCourses();
    } catch (e) {
      _error = '加载课程失败：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载指定周的课程数据
  Future<void> loadCoursesByWeek(int week) async {
    notifyListeners();
  }

  // 添加新课程
  Future<bool> addCourse(Course course) async {
    // 检查时间冲突
    if (await _db.hasTimeConflict(course)) {
      return false;
    }

    // 插入课程并获取ID
    final id = await _db.insertCourse(course);
    final newCourse = Course(
      id: id,
      name: course.name,
      teacher: course.teacher,
      location: course.location,
      weekStart: course.weekStart,
      weekEnd: course.weekEnd,
      dayOfWeek: course.dayOfWeek,
      startSection: course.startSection,
      endSection: course.endSection,
      weekType: course.weekType,
      color: course.color,
    );
    _courses.add(newCourse);
    notifyListeners();
    return true;
  }

  // 更新现有课程
  Future<bool> updateCourse(Course course) async {
    // 检查时间冲突
    if (await _db.hasTimeConflict(course)) {
      return false;
    }

    await _db.updateCourse(course);
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      notifyListeners();
    }
    return true;
  }

  // 删除课程
  Future<void> deleteCourse(int id) async {
    await _db.deleteCourse(id);
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }

  // 设置当前周数
  void setCurrentWeek(int week) {
    notifyListeners();
  }
}
