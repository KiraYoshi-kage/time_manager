import 'package:flutter/material.dart';
import '../course/course_screen.dart';
import '../todo/todo_screen.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../settings/settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 页面列表
  final List<Widget> _pages = [
    const DashboardScreen(),
    const CourseScreen(),
    const TodoScreen(),
  ];

  // 底部导航项
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: '主页',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: '课程表',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.check_circle_outline),
      label: '待办事项',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('时间管理'),
        actions: [
          IconButton(
            icon: Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                );
              },
            ),
            onPressed: () {
              Provider.of<ThemeService>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _bottomNavItems,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
