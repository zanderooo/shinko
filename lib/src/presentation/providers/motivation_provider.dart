import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class MotivationProvider with ChangeNotifier {
  static const List<String> _motivationalQuotes = [
    "The journey of a thousand miles begins with one step.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "Don't watch the clock; do what it does. Keep going.",
    "The only way to do great work is to love what you do.",
    "Believe you can and you're halfway there.",
    "Progress, not perfection, is what matters most.",
    "Every habit you build is a vote for the type of person you wish to become.",
    "Small daily improvements lead to stunning long-term results.",
    "Your future self is watching right now through memories.",
    "The compound interest of self-improvement is patience.",
    "Consistency beats intensity when it comes to lasting change.",
    "Fall in love with the process, and the results will come.",
    "Discipline is choosing between what you want now and what you want most.",
    "Your daily habits are the architects of your future.",
    "The pain of discipline is far less than the pain of regret.",
    "Excellence is not an act, but a habit.",
    "What you do today can improve all your tomorrows.",
    "Success is the sum of small efforts repeated day in and day out.",
    "The secret of getting ahead is getting started.",
    "Your only limit is your mind.",
    "Make each day your masterpiece.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "You are what you repeatedly do.",
    "Great things are done by a series of small things brought together.",
    "The expert in anything was once a beginner.",
    "Dream big. Start small. Act now.",
    "Focus on the step in front of you, not the whole staircase.",
    "Your habits will determine your future.",
    "Be the energy you want to attract.",
    "Every day is a new beginning. Take a deep breath and start again.",
  ];

  String _currentQuote = "";
  DateTime? _lastUpdated;

  String get currentQuote => _currentQuote;

  Future<void> loadDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastQuoteDate = prefs.getString('last_quote_date');
    final lastQuote = prefs.getString('last_quote');

    // Check if we need a new quote for today
    if (lastQuoteDate == null || 
        lastQuote == null || 
        _isDifferentDay(DateTime.parse(lastQuoteDate), today)) {
      _currentQuote = _getRandomQuote();
      _lastUpdated = today;
      
      // Save to preferences
      await prefs.setString('last_quote_date', today.toIso8601String());
      await prefs.setString('last_quote', _currentQuote);
    } else {
      _currentQuote = lastQuote;
      _lastUpdated = DateTime.parse(lastQuoteDate);
    }

    notifyListeners();
  }

  Future<void> refreshQuote() async {
    _currentQuote = _getRandomQuote();
    _lastUpdated = DateTime.now();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_quote_date', _lastUpdated!.toIso8601String());
    await prefs.setString('last_quote', _currentQuote);
    
    notifyListeners();
  }

  String _getRandomQuote() {
    final random = Random();
    return _motivationalQuotes[random.nextInt(_motivationalQuotes.length)];
  }

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year || 
           date1.month != date2.month || 
           date1.day != date2.day;
  }
}