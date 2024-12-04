import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/course.dart';
import '../models/todo.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  final DatabaseService _db = DatabaseService.instance;

  // 导出数据
  Future<String> exportData() async {
    final data = {
      'courses': await _db.getAllCourses(),
      'todos': await _db.getAllTodos(),
    };

    final jsonData = {
      'courses': data['courses']!.map((c) => (c as Course).toJson()).toList(),
      'todos': data['todos']!.map((t) => (t as Todo).toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    // 保存到文件
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(jsonData));
    return file.path;
  }

  // 导入数据
  Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 验证版本
      final version = jsonData['version'] as String;
      if (version != '1.0.0') {
        throw Exception('不支持的备份版本');
      }

      // 清除现有数据
      await _db.clearAllData();

      // 导入课程
      final courses = (jsonData['courses'] as List).map((json) {
        return Course.fromJson(json as Map<String, dynamic>);
      }).toList();

      // 导入待办事项
      final todos = (jsonData['todos'] as List).map((json) {
        return Todo.fromJson(json as Map<String, dynamic>);
      }).toList();

      // 批量插入数据
      for (final course in courses) {
        await _db.insertCourse(course);
      }

      for (final todo in todos) {
        await _db.insertTodo(todo);
      }

      return true;
    } catch (e) {
      print('导入数据失败: $e');
      return false;
    }
  }

  // 获取所有备份文件
  Future<List<FileSystemEntity>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  // 删除备份文件
  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
