import 'package:shared_preferences/shared_preferences.dart';

class CourseSettingsService {
  static final CourseSettingsService instance = CourseSettingsService._();
  CourseSettingsService._();

  static const String _maxWeekKey = 'course_max_week';
  static const String _maxSectionKey = 'course_max_section';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get maxWeek => _prefs.getInt(_maxWeekKey) ?? 20;
  int get maxSection => _prefs.getInt(_maxSectionKey) ?? 12;

  Future<void> setMaxWeek(int weeks) async {
    await _prefs.setInt(_maxWeekKey, weeks);
  }

  Future<void> setMaxSection(int sections) async {
    await _prefs.setInt(_maxSectionKey, sections);
  }
}
