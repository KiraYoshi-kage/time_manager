import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import 'backup_screen.dart';
import '../../services/notification_settings_service.dart';
import '../../services/course_settings_service.dart';
import '../../widgets/settings/reminder_settings_dialog.dart';
import '../../widgets/settings/number_picker_dialog.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';
import '../../services/semester_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildThemeSection(context),
          const Divider(),
          _buildDataSection(context),
          const Divider(),
          _buildAboutSection(context),
          const Divider(),
          _buildNotificationSection(context),
          const Divider(),
          _buildCourseSection(context),
          const Divider(),
          _buildSemesterSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '主题设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('切换深色/浅色主题'),
              value: themeService.isDarkMode,
              onChanged: (value) => themeService.setThemeMode(value),
            );
          },
        ),
        ListTile(
          title: const Text('跟随系统'),
          subtitle: const Text('自动跟随系统主题设置'),
          trailing: const Icon(Icons.sync),
          onTap: () {
            Provider.of<ThemeService>(context, listen: false)
                .useSystemTheme(context);
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '数据管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('数据备份'),
          subtitle: const Text('备份和恢复数据'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BackupScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('清除数据'),
          subtitle: const Text('删除所有本地数据'),
          onTap: () => _showClearDataDialog(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '关于',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('版本信息'),
          subtitle: const Text('v1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('用户协议'),
          onTap: () {
            // TODO: 显示用户协议
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('隐私政策'),
          onTap: () {
            // TODO: 显示隐私政策
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '通知设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('启用通知'),
          subtitle: const Text('开启/关闭待办事项提醒'),
          value: NotificationSettingsService.instance.isEnabled,
          onChanged: (value) async {
            await NotificationSettingsService.instance.setEnabled(value);
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('提醒时间'),
          subtitle: Text(_formatReminders()),
          trailing: const Icon(Icons.arrow_forward_ios),
          enabled: NotificationSettingsService.instance.isEnabled,
          onTap: () => _showReminderSettings(context),
        ),
      ],
    );
  }

  Widget _buildCourseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '课表设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('总周数'),
          subtitle: Text('${CourseSettingsService.instance.maxWeek}周'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showWeekSettings(context),
        ),
        ListTile(
          title: const Text('每日节数'),
          subtitle: Text('${CourseSettingsService.instance.maxSection}节'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showSectionSettings(context),
        ),
      ],
    );
  }

  Widget _buildSemesterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '学期设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('开学时间'),
          subtitle: Text(
            Provider.of<SemesterService>(context).startDate != null
                ? DateFormat('yyyy-MM-dd')
                    .format(Provider.of<SemesterService>(context).startDate!)
                : '未设置',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.pushNamed(context, '/semester');
          },
        ),
      ],
    );
  }

  String _formatReminders() {
    final reminders = NotificationSettingsService.instance.reminders;
    return reminders.map((d) {
      final hours = d.inHours;
      final minutes = d.inMinutes % 60;
      if (hours > 0) {
        return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
      }
      return '$minutes分钟';
    }).join('、');
  }

  Future<void> _showReminderSettings(BuildContext context) async {
    final reminders = NotificationSettingsService.instance.reminders;
    final result = await showDialog<List<Duration>>(
      context: context,
      builder: (context) => ReminderSettingsDialog(
        initialReminders: reminders,
      ),
    );

    if (result != null) {
      await NotificationSettingsService.instance.setReminders(result);
      setState(() {});
    }
  }

  Future<void> _showWeekSettings(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => NumberPickerDialog(
        title: '设置总周数',
        initialValue: CourseSettingsService.instance.maxWeek,
        minValue: 10,
        maxValue: 30,
      ),
    );

    if (result != null) {
      await CourseSettingsService.instance.setMaxWeek(result);
      setState(() {});
    }
  }

  Future<void> _showSectionSettings(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => NumberPickerDialog(
        title: '设置每日节数',
        initialValue: CourseSettingsService.instance.maxSection,
        minValue: 8,
        maxValue: 16,
      ),
    );

    if (result != null) {
      await CourseSettingsService.instance.setMaxSection(result);
      setState(() {});
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除数据'),
        content: const Text('确定要删除所有数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await DatabaseService.instance.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清除')),
        );
      }
    }
  }
}
