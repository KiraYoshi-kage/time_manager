import 'package:flutter/material.dart';

class AppTheme {
  // 颜色常量
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accentLight = Color(0xFFFFC107);
  static const Color accentDark = Color(0xFFFFB300);

  // 文字样式
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  );

  // 亮色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
    ),
  );

  // 暗色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF2C2C2C),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
    ),
  );

  // 课程卡片颜色
  static const List<Color> courseColors = [
    Color(0xFF1E88E5), // 蓝色
    Color(0xFF43A047), // 绿色
    Color(0xFFE53935), // 红色
    Color(0xFF8E24AA), // 紫色
    Color(0xFFF4511E), // 橙色
    Color(0xFF00ACC1), // 青色
    Color(0xFF3949AB), // 靛蓝
    Color(0xFF7CB342), // 浅绿
  ];

  // 获取课程颜色
  static Color getCourseColor(int index) {
    return courseColors[index % courseColors.length];
  }
}

// 添加更多预定义样式
class AppStyles {
  static const cardPadding = EdgeInsets.all(16.0);
  static const itemSpacing = 8.0;
  static final cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
}
