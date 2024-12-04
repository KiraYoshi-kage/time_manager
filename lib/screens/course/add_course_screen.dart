import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../config/theme.dart';

// 添加/编辑课程的界面
class AddCourseScreen extends StatefulWidget {
  final Course? course; // 如果是编辑模式，则传入现有课程

  const AddCourseScreen({super.key, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _locationController = TextEditingController();

  // 课程信息
  int _weekStart = 1; // 开始周
  int _weekEnd = 16; // 结束周
  int _dayOfWeek = 1; // 星期几
  int _startSection = 1; // 开始节数
  int _endSection = 2; // 结束节数
  int _weekType = 0; // 周类型（全周/单周/双周）
  Color _selectedColor = AppTheme.courseColors[0]; // 课程颜色

  // 界面选项数据
  final List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  final List<String> _weekTypes = ['全周', '单周', '双周'];

  // 界面初始化
  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      // 如果是编辑模式，初始化表单数据
      _nameController.text = widget.course!.name;
      _teacherController.text = widget.course!.teacher;
      _locationController.text = widget.course!.location;
      _weekStart = widget.course!.weekStart;
      _weekEnd = widget.course!.weekEnd;
      _dayOfWeek = widget.course!.dayOfWeek;
      _startSection = widget.course!.startSection;
      _endSection = widget.course!.endSection;
      _weekType = widget.course!.weekType;
      _selectedColor = widget.course!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: widget.course?.id, // 如果是编辑模式，保留原来的ID
        name: _nameController.text,
        teacher: _teacherController.text,
        location: _locationController.text,
        weekStart: _weekStart,
        weekEnd: _weekEnd,
        dayOfWeek: _dayOfWeek,
        startSection: _startSection,
        endSection: _endSection,
        weekType: _weekType,
        color: _selectedColor,
      );

      Navigator.pop(context, course);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑课程' : '添加课程'),
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '课程名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入课程名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: '教师',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入教师姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '上课地点',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入上课地点';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _weekStart,
                      decoration: const InputDecoration(
                        labelText: '起始周',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        25,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _weekStart = value!;
                          if (_weekEnd < _weekStart) {
                            _weekEnd = _weekStart;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _weekEnd,
                      decoration: const InputDecoration(
                        labelText: '结束周',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        25,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _weekEnd = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: '星期',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_weekdays[index]),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _dayOfWeek = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _startSection,
                      decoration: const InputDecoration(
                        labelText: '开始节数',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _startSection = value!;
                          if (_endSection < _startSection) {
                            _endSection = _startSection;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _endSection,
                      decoration: const InputDecoration(
                        labelText: '结束节数',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _endSection = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _weekType,
                decoration: const InputDecoration(
                  labelText: '周类型',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  _weekTypes.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(_weekTypes[index]),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _weekType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('课程颜色'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppTheme.courseColors.map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
