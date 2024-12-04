import 'package:sqflite/sqflite.dart';
import '../models/course.dart';
import '../models/todo.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path_provider;

class DatabaseService {
  static const String _databaseName = 'time_manager.db';
  static const int _databaseVersion = 1;

  // 单例模式
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path =
        path_provider.join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建课程表
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacher TEXT NOT NULL,
        location TEXT NOT NULL,
        weekStart INTEGER NOT NULL,
        weekEnd INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startSection INTEGER NOT NULL,
        endSection INTEGER NOT NULL,
        weekType INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    // 创建待办事项表
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        status INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        customReminderTime TEXT,
        enableReminder INTEGER NOT NULL DEFAULT 1,
        reminderBeforeFiveMin INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 版本1升级到版本2的迁移逻辑
    }
  }

  // 课程相关操作
  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert(
      'courses',
      course.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCourse(Course course) async {
    final db = await database;
    return await db.update(
      'courses',
      course.toJson(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Course>> getAllCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) => Course.fromJson(maps[i]));
  }

  Future<Course?> getCourse(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Course.fromJson(maps.first);
  }

  // 获取指定周的课程
  Future<List<Course>> getCoursesByWeek(int week) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'weekStart <= ? AND weekEnd >= ?',
      whereArgs: [week, week],
    );
    return List.generate(maps.length, (i) => Course.fromJson(maps[i]));
  }

  // 检查时间冲突
  Future<bool> hasTimeConflict(Course course) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: '''
        id != ? AND
        dayOfWeek = ? AND
        weekType = ? AND
        ((weekStart <= ? AND weekEnd >= ?) OR (weekStart <= ? AND weekEnd >= ?)) AND
        ((startSection <= ? AND endSection >= ?) OR (startSection <= ? AND endSection >= ?))
      ''',
      whereArgs: [
        course.id ?? -1,
        course.dayOfWeek,
        course.weekType,
        course.weekStart,
        course.weekStart,
        course.weekEnd,
        course.weekEnd,
        course.startSection,
        course.startSection,
        course.endSection,
        course.endSection,
      ],
    );
    return maps.isNotEmpty;
  }

  // 待办事项相关操作
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    final Map<String, dynamic> json = {
      'title': todo.title,
      'description': todo.description,
      'startTime': todo.startTime.toIso8601String(),
      'endTime': todo.endTime.toIso8601String(),
      'duration': todo.duration,
      'priority': todo.priority.index,
      'status': todo.status.index,
      'createdAt': todo.createdAt.toIso8601String(),
      'customReminderTime': todo.customReminderTime?.toIso8601String(),
      'enableReminder': todo.enableReminder ? 1 : 0,
      'reminderBeforeFiveMin': todo.reminderBeforeFiveMin ? 1 : 0,
    };
    return await db.insert('todos', json);
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    final Map<String, dynamic> json = {
      'title': todo.title,
      'description': todo.description,
      'startTime': todo.startTime.toIso8601String(),
      'endTime': todo.endTime.toIso8601String(),
      'duration': todo.duration,
      'priority': todo.priority.index,
      'status': todo.status.index,
      'createdAt': todo.createdAt.toIso8601String(),
      'customReminderTime': todo.customReminderTime?.toIso8601String(),
      'enableReminder': todo.enableReminder ? 1 : 0,
      'reminderBeforeFiveMin': todo.reminderBeforeFiveMin ? 1 : 0,
    };
    return await db.update(
      'todos',
      json,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        startTime: DateTime.parse(maps[i]['startTime'] as String),
        endTime: DateTime.parse(maps[i]['endTime'] as String),
        duration: DateTime.parse(maps[i]['endTime'] as String)
            .difference(DateTime.parse(maps[i]['startTime'] as String))
            .inMinutes,
        priority: TodoPriority.values[maps[i]['priority'] as int],
        status: TodoStatus.values[maps[i]['status'] as int],
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        customReminderTime: maps[i]['customReminderTime'] != null
            ? DateTime.parse(maps[i]['customReminderTime'] as String)
            : null,
        enableReminder: (maps[i]['enableReminder'] as int) == 1,
        reminderBeforeFiveMin: (maps[i]['reminderBeforeFiveMin'] as int) == 1,
      );
    });
  }

  Future<List<Todo>> getTodosByStatus(TodoStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'status = ?',
      whereArgs: [status.index],
    );
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        startTime: DateTime.parse(maps[i]['startTime'] as String),
        endTime: DateTime.parse(maps[i]['endTime'] as String),
        duration: DateTime.parse(maps[i]['endTime'] as String)
            .difference(DateTime.parse(maps[i]['startTime'] as String))
            .inMinutes,
        priority: TodoPriority.values[maps[i]['priority'] as int],
        status: TodoStatus.values[maps[i]['status'] as int],
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        customReminderTime: maps[i]['customReminderTime'] != null
            ? DateTime.parse(maps[i]['customReminderTime'] as String)
            : null,
        enableReminder: (maps[i]['enableReminder'] as int) == 1,
        reminderBeforeFiveMin: (maps[i]['reminderBeforeFiveMin'] as int) == 1,
      );
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('courses');
      await txn.delete('todos');
    });
  }

  Future<void> batchInsertCourses(List<Course> courses) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final course in courses) {
        batch.insert('courses', course.toJson()..remove('id'));
      }
      await batch.commit();
    });
  }

  late final _key = encrypt.Key.fromSecureRandom(32);
  late final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  String _encrypt(String text) {
    return _encrypter.encrypt(text).base64;
  }

  String _decrypt(String text) {
    return _encrypter.decrypt64(text);
  }

  // 添加数据库加密
  Future<void> _encryptDatabase() async {
    final db = await database;
    // 实现数据库加密逻辑
    await db.transaction((txn) async {
      // 在这里实现数据库加密
      // 例如：遍历所有表并加密敏感字段
    });
  }

  // 添加敏感数据处理
  String _encryptSensitiveData(String data) {
    final encrypted = _encrypter.encrypt(data);
    return encrypted.base64;
  }
}
