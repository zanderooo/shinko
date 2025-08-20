import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TomorrowMessageProvider with ChangeNotifier {
  // Centralized keys to avoid typos
  static const _keyTomorrowMessage = 'tomorrow_message';
  static const _keyLastMessageDate = 'last_message_date';

  String? _tomorrowMessage;
  String? _currentMessage;

  String? get currentMessage => _currentMessage;
  String? get tomorrowMessage => _tomorrowMessage;

  /// Load the stored message logic:
  /// - If there's a saved message from yesterday → show it today.
  /// - If it's already shown today → don't repeat it.
  /// - Otherwise → clear old messages.
  Future<void> loadMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _stripTime(DateTime.now());

    final lastMessageDateStr = prefs.getString(_keyLastMessageDate);
    final savedMessage = prefs.getString(_keyTomorrowMessage);

    if (lastMessageDateStr != null) {
      final lastDate = _stripTime(DateTime.parse(lastMessageDateStr));

      if (_isYesterday(lastDate, today) && savedMessage != null) {
        // Yesterday's "tomorrow message" becomes today's "current message"
        _currentMessage = savedMessage;
        _tomorrowMessage = null;

        await prefs.remove(_keyTomorrowMessage);
        await prefs.setString(_keyLastMessageDate, today.toIso8601String());
      } else if (_isSameDay(lastDate, today)) {
        // Already showed something today
        _currentMessage = null;
      } else {
        // Stale message → clear it
        _currentMessage = null;
        _tomorrowMessage = null;
        await prefs.remove(_keyTomorrowMessage);
      }
    }

    notifyListeners();
  }

  /// Save a message that should appear *tomorrow*.
  Future<void> saveTomorrowMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _stripTime(DateTime.now());

    _tomorrowMessage = message;

    await prefs.setString(_keyTomorrowMessage, message);
    await prefs.setString(_keyLastMessageDate, today.toIso8601String());

    notifyListeners();
  }

  /// Explicitly clear both current and tomorrow messages.
  Future<void> clearMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTomorrowMessage);
    await prefs.remove(_keyLastMessageDate);

    _tomorrowMessage = null;
    _currentMessage = null;

    notifyListeners();
  }

  // ------------------ 🛠️ Helpers ------------------ //

  DateTime _stripTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  bool _isYesterday(DateTime date, DateTime today) =>
      date == _stripTime(today.subtract(const Duration(days: 1)));

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}