import 'package:shared_preferences/shared_preferences.dart';

class SemesterService {
  static final SemesterService instance = SemesterService._();
  SemesterService._();

  static const String _startDateKey = 'semester_start_date';
  late SharedPreferences _prefs;
  DateTime? _startDate;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final startDateStr = _prefs.getString(_startDateKey);
    if (startDateStr != null) {
      _startDate = DateTime.parse(startDateStr);
    }
  }

  Future<void> setStartDate(DateTime date) async {
    _startDate = DateTime(date.year, date.month, date.day);
    await _prefs.setString(_startDateKey, _startDate!.toIso8601String());
  }

  DateTime? get startDate => _startDate;

  int get currentWeek {
    if (_startDate == null) return 1;

    final now = DateTime.now();
    final difference = now.difference(_startDate!);
    final weekNumber = (difference.inDays / 7).ceil();
    return weekNumber > 0 ? weekNumber : 1;
  }
}
