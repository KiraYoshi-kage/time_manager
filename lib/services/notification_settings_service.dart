import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static final NotificationSettingsService instance =
      NotificationSettingsService._();
  NotificationSettingsService._();

  static const String _enabledKey = 'notification_enabled';
  static const String _remindersKey = 'notification_reminders';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isEnabled => _prefs.getBool(_enabledKey) ?? true;

  List<Duration> get reminders {
    final List<String> saved = _prefs.getStringList(_remindersKey) ??
        [
          '1440', // 24小时
          '120', // 2小时
          '5', // 5分钟
        ];
    return saved.map((e) => Duration(minutes: int.parse(e))).toList();
  }

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
  }

  Future<void> setReminders(List<Duration> reminders) async {
    final List<String> minutes =
        reminders.map((d) => d.inMinutes.toString()).toList();
    await _prefs.setStringList(_remindersKey, minutes);
  }
}
