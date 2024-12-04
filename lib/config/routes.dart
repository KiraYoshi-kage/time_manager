import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/course/course_screen.dart';
import '../screens/todo/todo_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/backup_screen.dart';
import '../screens/settings/semester_settings_screen.dart';

class AppRoutes {
  // 路由名称
  static const String home = '/';
  static const String course = '/course';
  static const String todo = '/todo';
  static const String settings = '/settings';
  static const String backup = '/backup';
  static const String semester = '/semester';

  // 路由映射表
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    course: (context) => const CourseScreen(),
    todo: (context) => const TodoScreen(),
    settings: (context) => const SettingsScreen(),
    backup: (context) => const BackupScreen(),
    semester: (context) => const SemesterSettingsScreen(),
  };

  // 路由配置
  static RouteSettings routeSettings(String name) {
    return RouteSettings(name: name);
  }

  // 页面切换动画
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }

  // 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
        ),
        body: Center(
          child: Text('未找到页面: ${settings.name}'),
        ),
      ),
    );
  }
}
