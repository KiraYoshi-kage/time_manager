import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/theme_service.dart';
import 'providers/course_provider.dart';
import 'providers/todo_provider.dart';
import 'services/notification_service.dart';
import 'services/notification_settings_service.dart';
import 'services/course_settings_service.dart';
import 'services/semester_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 先初始化主题服务
  final themeService = ThemeService();
  await themeService.initialized;

  // 初始化其他服务
  await Future.wait([
    NotificationService.instance.init(),
    NotificationSettingsService.instance.init(),
    CourseSettingsService.instance.init(),
    SemesterService.instance.init(),
  ]);

  // 添加全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    // 处理Flutter框架错误
  };

  // 添加异步错误处理
  PlatformDispatcher.instance.onError = (error, stack) {
    // 处理平台错误
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        Provider.value(value: SemesterService.instance),
        ChangeNotifierProvider(
          create: (_) {
            final provider = CourseProvider();
            provider.loadCourses(); // 立即加载课程数据
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = TodoProvider();
            provider.loadTodos(); // 立即加载待办事项数据
            provider.startOverdueCheck();
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: '时间管理',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
        );
      },
    );
  }
}
