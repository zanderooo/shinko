import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TomorrowMessageProvider with ChangeNotifier {
  String? _tomorrowMessage;
  String? _currentMessage;
  // Tracks when the message was last shown; reserved for future use
  // ignore: unused_field
  DateTime? _lastMessageDate;

  String? get currentMessage => _currentMessage;
  String? get tomorrowMessage => _tomorrowMessage;

  Future<void> loadMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastMessageDateStr = prefs.getString('last_message_date');
    final savedMessage = prefs.getString('tomorrow_message');

    // Check if we need to show the saved message for today
    if (lastMessageDateStr != null) {
      final lastDate = DateTime.parse(lastMessageDateStr);
      
      // If the saved message was for yesterday, show it today
      if (_isYesterday(lastDate, today)) {
        _currentMessage = savedMessage;
        _lastMessageDate = today;
        
        // Clear the tomorrow message after showing it
        await prefs.remove('tomorrow_message');
        await prefs.setString('last_message_date', today.toIso8601String());
      } else if (_isSameDay(lastDate, today)) {
        // Message already shown today
        _currentMessage = null;
      } else {
        // Old message, clear it
        _currentMessage = null;
        await prefs.remove('tomorrow_message');
      }
    }

    notifyListeners();
  }

  Future<void> saveTomorrowMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    
    _tomorrowMessage = message;
    await prefs.setString('tomorrow_message', message);
    await prefs.setString('last_message_date', today.toIso8601String());
    
    notifyListeners();
  }

  bool _isYesterday(DateTime date, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  Future<void> clearMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tomorrow_message');
    _tomorrowMessage = null;
    _currentMessage = null;
    notifyListeners();
  }
}