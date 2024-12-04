import 'package:flutter/material.dart';
import '../../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? todo; // 如果是编辑模式，传入待办事项对象

  const AddTodoScreen({super.key, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  TodoPriority _priority = TodoPriority.medium;
  DateTime? _customReminderTime;
  bool _reminderBeforeFiveMin = true;
  bool _enableReminder = true;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      // 如果是编辑模式，初始化表单数据
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _startTime = widget.todo!.startTime;
      _endTime = widget.todo!.endTime;
      _priority = widget.todo!.priority;
      _customReminderTime = widget.todo!.customReminderTime;
      _reminderBeforeFiveMin = widget.todo!.reminderBeforeFiveMin;
      _enableReminder = widget.todo!.enableReminder;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        id: widget.todo?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        duration: _endTime.difference(_startTime).inMinutes,
        priority: _priority,
        status: widget.todo?.status ?? TodoStatus.pending,
        createdAt: widget.todo?.createdAt,
        customReminderTime: _customReminderTime,
        reminderBeforeFiveMin: _reminderBeforeFiveMin,
        enableReminder: _enableReminder,
      );

      Navigator.pop(context, todo);
    }
  }

  Future<void> _selectStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );

      if (time != null) {
        setState(() {
          _startTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
      );

      if (time != null) {
        setState(() {
          _endTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectCustomReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customReminderTime ??
          _startTime.subtract(const Duration(minutes: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: _startTime,
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _customReminderTime ??
              _startTime.subtract(const Duration(minutes: 30)),
        ),
      );

      if (time != null) {
        setState(() {
          _customReminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑待办事项' : '添加待办事项'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('开始时间'),
                subtitle: Text(
                  '${_startTime.year}-${_startTime.month}-${_startTime.day} '
                  '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectStartTime,
              ),
              ListTile(
                title: const Text('结束时间'),
                subtitle: Text(
                  '${_endTime.year}-${_endTime.month}-${_endTime.day} '
                  '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectEndTime,
              ),
              const SizedBox(height: 16),
              const Text('优先级'),
              const SizedBox(height: 8),
              SegmentedButton<TodoPriority>(
                segments: const [
                  ButtonSegment(
                    value: TodoPriority.low,
                    label: Text('低'),
                  ),
                  ButtonSegment(
                    value: TodoPriority.medium,
                    label: Text('中'),
                  ),
                  ButtonSegment(
                    value: TodoPriority.high,
                    label: Text('高'),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (Set<TodoPriority> selected) {
                  setState(() {
                    _priority = selected.first;
                  });
                },
              ),
              ListTile(
                title: const Text('提醒设置'),
                subtitle: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('启用提醒'),
                      value: _enableReminder,
                      onChanged: (value) {
                        setState(() {
                          _enableReminder = value;
                        });
                      },
                    ),
                    if (_enableReminder) ...[
                      CheckboxListTile(
                        title: const Text('开始前5分钟'),
                        value: _reminderBeforeFiveMin,
                        onChanged: (value) {
                          setState(() {
                            _reminderBeforeFiveMin = value ?? true;
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('自定义提醒'),
                        subtitle: Text(
                          _customReminderTime != null
                              ? _formatDateTime(_customReminderTime!)
                              : '未设置',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_customReminderTime != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _customReminderTime = null;
                                  });
                                },
                              ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: _selectCustomReminder,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 续时间选择对话框
class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;
  final String title;
  final int maxHours;

  const DurationPickerDialog({
    super.key,
    required this.initialDuration,
    required this.title,
    this.maxHours = 24,
  });

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _hours,
                  decoration: const InputDecoration(
                    labelText: '小时',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    widget.maxHours,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text('$index'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hours = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _minutes,
                  decoration: const InputDecoration(
                    labelText: '分钟',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    60,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text('$index'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _minutes = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final duration = Duration(
              hours: _hours,
              minutes: _minutes,
            );
            Navigator.pop(context, duration);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
