import 'package:flutter/material.dart';

class Course {
  final int? id; // 数据库ID
  final String name; // 课程名称
  final String teacher; // 教师
  final String location; // 上课地点
  final int weekStart; // 起始周
  final int weekEnd; // 结束周
  final int dayOfWeek; // 星期几（1-7）
  final int startSection; // 开始节数
  final int endSection; // 结束节数
  final int weekType; // 周类型：0-全周，1-单周，2-双周
  final Color color; // 课程颜色

  Course({
    this.id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekStart,
    required this.weekEnd,
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    this.weekType = 0,
    required this.color,
  });

  // 从JSON创建对象
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      name: json['name'] as String,
      teacher: json['teacher'] as String,
      location: json['location'] as String,
      weekStart: json['weekStart'] as int,
      weekEnd: json['weekEnd'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      startSection: json['startSection'] as int,
      endSection: json['endSection'] as int,
      weekType: json['weekType'] as int,
      color: Color(json['color'] as int),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'dayOfWeek': dayOfWeek,
      'startSection': startSection,
      'endSection': endSection,
      'weekType': weekType,
      'color': color.value,
    };
  }

  // 复制对象并修改部分属性
  Course copyWith({
    String? name,
    String? teacher,
    String? location,
    int? weekStart,
    int? weekEnd,
    int? dayOfWeek,
    int? startSection,
    int? endSection,
    int? weekType,
    Color? color,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weekType: weekType ?? this.weekType,
      color: color ?? this.color,
    );
  }
}
