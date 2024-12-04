import 'package:flutter/material.dart';

class ReminderSettingsDialog extends StatefulWidget {
  final List<Duration> initialReminders;

  const ReminderSettingsDialog({
    super.key,
    required this.initialReminders,
  });

  @override
  State<ReminderSettingsDialog> createState() => _ReminderSettingsDialogState();
}

class _ReminderSettingsDialogState extends State<ReminderSettingsDialog> {
  late List<Duration> _reminders;
  final List<_ReminderOption> _options = [
    _ReminderOption(
      duration: const Duration(hours: 24),
      label: '24小时前',
    ),
    _ReminderOption(
      duration: const Duration(hours: 2),
      label: '2小时前',
    ),
    _ReminderOption(
      duration: const Duration(minutes: 5),
      label: '5分钟前',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _reminders = List.from(widget.initialReminders);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('提醒时间设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _options.map((option) {
            final isSelected = _hasReminder(option.duration);
            return CheckboxListTile(
              title: Text(option.label),
              value: isSelected,
              onChanged: (bool? value) {
                if (value == true) {
                  _addReminder(option.duration);
                } else {
                  _removeReminder(option.duration);
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_reminders.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请至少选择一个提醒时间')),
              );
              return;
            }
            Navigator.pop(context, _reminders);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  bool _hasReminder(Duration duration) {
    return _reminders.any((d) => d.inMinutes == duration.inMinutes);
  }

  void _addReminder(Duration duration) {
    setState(() {
      if (!_hasReminder(duration)) {
        _reminders.add(duration);
      }
    });
  }

  void _removeReminder(Duration duration) {
    setState(() {
      _reminders.removeWhere((d) => d.inMinutes == duration.inMinutes);
    });
  }
}

class _ReminderOption {
  final Duration duration;
  final String label;

  const _ReminderOption({
    required this.duration,
    required this.label,
  });
}
