import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TomorrowMessageProvider with ChangeNotifier {
  static const _keyTomorrowMessage = 'tomorrow_message';
  static const _keyLastMessageDate = 'last_message_date';

  String? _tomorrowMessage;
  String? _currentMessage;

  String? get currentMessage => _currentMessage;
  String? get tomorrowMessage => _tomorrowMessage;

  /// Load logic:
  /// - If yesterday had a saved message → show it today.
  /// - If we've *already promoted today* → don't show again.
  Future<void> loadMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _stripTime(DateTime.now());

    final lastMessageDateStr = prefs.getString(_keyLastMessageDate);
    final savedMessage = prefs.getString(_keyTomorrowMessage);

    if (lastMessageDateStr != null) {
      final lastDate = _stripTime(DateTime.parse(lastMessageDateStr));

      if (_isYesterday(lastDate, today) && savedMessage != null) {
        // Promotion: yesterday’s tomorrow message becomes today’s current
        _currentMessage = savedMessage;
        _tomorrowMessage = null;

        await prefs.remove(_keyTomorrowMessage);
        await prefs.setString(_keyLastMessageDate, today.toIso8601String());
      } else if (_isSameDay(lastDate, today)) {
        // Already promoted today
        _currentMessage = null;
      } else {
        // Outdated / reset
        _currentMessage = null;
        _tomorrowMessage = savedMessage;
      }
    } else {
      // First launch logic
      _currentMessage = null;
      _tomorrowMessage = savedMessage;
    }

    notifyListeners();
  }

  /// Save tomorrow’s message and stamp today; promoted next day.
  Future<void> saveTomorrowMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    _tomorrowMessage = message;

    await prefs.setString(_keyTomorrowMessage, message);
    await prefs.setString(_keyLastMessageDate, _stripTime(DateTime.now()).toIso8601String());
    notifyListeners();
  }

  /// Full clear
  Future<void> clearMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTomorrowMessage);
    await prefs.remove(_keyLastMessageDate);

    _tomorrowMessage = null;
    _currentMessage = null;
    notifyListeners();
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isYesterday(DateTime date, DateTime today) =>
      date.isAtSameMomentAs(_stripTime(today.subtract(const Duration(days: 1))));

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}