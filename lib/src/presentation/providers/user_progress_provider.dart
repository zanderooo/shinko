import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinko/src/domain/entities/user_progress.dart';
import 'package:shinko/src/domain/entities/user_stats.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/entities/achievement.dart';
import 'package:shinko/src/core/navigator_key.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';

class UserProgressProvider with ChangeNotifier {
  static const _userProgressKey = 'user_progress';
  static const _achievementsKey = 'achievements';
  static const _xpGainHistoryKey = 'xp_gain_history';
  
  // XP gain rate limiting
  static const _maxDailyXP = 5000;
  static const _maxHourlyXP = 1000;

  UserProgress _userProgress = UserProgress(
    totalXP: 0,
    currentLevel: 1,
    xpToNextLevel: 100,
    dailyStreak: 0,
    bestDailyStreak: 0,
    weeklyStreak: 0,
    bestWeeklyStreak: 0,
    totalHabitsCompleted: 0,
    totalPerfectDays: 0,
    createdAt: DateTime.now(),
    lastActiveDate: DateTime.now(),
    stats: const UserStats(),
    totalStreakFreezesUsed: 0,
  );

  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;
  
  // Track XP gains for rate limiting
  final Map<String, int> _xpGainHistory = {}; // Format: 'yyyy-MM-dd-HH' -> amount

  UserProgress get userProgress => _userProgress;
  List<Achievement> get achievements => _achievements;
  
  // Track hidden achievements
  Set<String> _hiddenAchievementIds = {};
  
  List<Achievement> get unlockedAchievements =>
      _achievements
          .where((a) => a.isUnlocked && !_hiddenAchievementIds.contains(a.id))
          .toList()
          ..sort((a, b) => (b.unlockedAt ?? DateTime.now())
              .compareTo(a.unlockedAt ?? DateTime.now()));
              
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get levelProgress {
    if (_userProgress.currentLevel == 1) {
      return _userProgress.totalXP / _userProgress.xpToNextLevel;
    }
    final xpForCurrentLevel = _userProgress.xpForCurrentLevel;
    final currentLevelXP = _userProgress.totalXP - xpForCurrentLevel;
    return (currentLevelXP / _userProgress.xpToNextLevel).clamp(0.0, 1.0);
  }

  Future<void> loadUserProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userProgressString = prefs.getString(_userProgressKey);
      if (userProgressString != null) {
        _userProgress = UserProgress.fromJson(jsonDecode(userProgressString));
      } else {
        _userProgress = _createFreshUserProgress();
      }

      final achievementsString = prefs.getString(_achievementsKey);
      if (achievementsString != null) {
        final decoded = jsonDecode(achievementsString) as List<dynamic>;
        _achievements =
            decoded.map((e) => Achievement.fromJson(e)).toList();
      } else {
        _achievements = _createInitialAchievements();
      }
      
      // Load hidden achievements
      final hiddenAchievementsString = prefs.getString('hidden_achievements');
      if (hiddenAchievementsString != null) {
        final decoded = jsonDecode(hiddenAchievementsString) as List<dynamic>;
        _hiddenAchievementIds = decoded.cast<String>().toSet();
      }
      
      // Load XP gain history
      final xpGainHistoryString = prefs.getString(_xpGainHistoryKey);
      if (xpGainHistoryString != null) {
        final decoded = jsonDecode(xpGainHistoryString) as Map<String, dynamic>;
        _xpGainHistory.clear();
        decoded.forEach((key, value) {
          _xpGainHistory[key] = value as int;
        });
        
        // Clean up old entries (older than 24 hours)
        _cleanupXpGainHistory();
      }
    } catch (e) {
      _error = 'Failed to load user progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userProgressKey, jsonEncode(_userProgress.toJson()));
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _achievementsKey,
        jsonEncode(_achievements.map((e) => e.toJson()).toList()));
  }
  
  Future<void> _saveXpGainHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_xpGainHistoryKey, jsonEncode(_xpGainHistory));
  }
  
  Future<void> _saveHiddenAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hidden_achievements', jsonEncode(_hiddenAchievementIds.toList()));
  }
  
  // Methods for managing recent achievements display
  Future<void> hideAchievementFromRecent(String achievementId) async {
    _hiddenAchievementIds.add(achievementId);
    await _saveHiddenAchievements();
    notifyListeners();
  }
  
  Future<void> restoreHiddenAchievement(String achievementId) async {
    _hiddenAchievementIds.remove(achievementId);
    await _saveHiddenAchievements();
    notifyListeners();
  }
  
  Future<void> clearRecentAchievements() async {
    // Add all unlocked achievement IDs to hidden set
    for (final achievement in _achievements.where((a) => a.isUnlocked)) {
      _hiddenAchievementIds.add(achievement.id);
    }
    await _saveHiddenAchievements();
    notifyListeners();
  }

  UserProgress _createFreshUserProgress() {
    return UserProgress(
      totalXP: 0,
      currentLevel: 1,
      dailyStreak: 0,
      bestDailyStreak: 0,
      weeklyStreak: 0,
      bestWeeklyStreak: 0,
      totalHabitsCompleted: 0,
      totalPerfectDays: 0,
      lastActiveDate: DateTime.now(),
      createdAt: DateTime.now(),
      stats: const UserStats(),
      totalStreakFreezesUsed: 0,
      coins: 0,
    );
  }

  List<Achievement> _createInitialAchievements() {
    return [
      Achievement(
        id: 'first_habit',
        title: 'First Steps',
        description: 'Create your first habit',
        type: AchievementType.firstHabit,
        rarity: AchievementRarity.common,
        xpReward: 50,
        iconData: '🌱',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_3',
        title: 'Three Day Streak',
        description: 'Maintain a 3-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        xpReward: 30,
        iconData: '🔥',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 3,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 100,
        iconData: '🔥',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 7,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_14',
        title: 'Fortnight Fighter',
        description: 'Maintain a 14-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        xpReward: 200,
        iconData: '❄️',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 14,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        xpReward: 500,
        iconData: '👑',
        streakFreezeReward: 3,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 30,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'habit_master_10',
        title: 'Getting Started',
        description: 'Complete 10 habits',
        type: AchievementType.completion,
        rarity: AchievementRarity.common,
        xpReward: 75,
        iconData: '🎯',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 10,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'habit_master_50',
        title: 'Habit Master',
        description: 'Complete 50 habits',
        type: AchievementType.completion,
        rarity: AchievementRarity.rare,
        xpReward: 200,
        iconData: '👑',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 50,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        type: AchievementType.level,
        rarity: AchievementRarity.rare,
        xpReward: 150,
        iconData: '⭐',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 5,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'level_10',
        title: 'Level Legend',
        description: 'Reach level 10',
        type: AchievementType.level,
        rarity: AchievementRarity.epic,
        xpReward: 300,
        iconData: '💫',
        streakFreezeReward: 2,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 10,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'perfect_day_1',
        title: 'Perfectionist',
        description: 'Have 1 perfect day',
        type: AchievementType.perfectDays,
        rarity: AchievementRarity.common,
        xpReward: 50,
        iconData: '✅',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_freeze_1',
        title: 'Ice Cold',
        description: 'Use a streak freeze',
        type: AchievementType.streakFreeze,
        rarity: AchievementRarity.common,
        xpReward: 20,
        iconData: '🧊',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> addXP(int amount, String source) async {
    if (amount == 0) return;

    // Only allow XP mutations for valid sources
    if (!source.startsWith('habit_') && !source.startsWith('achievement_') && !source.startsWith('quest_')) {
      print('Invalid XP source: $source');
      return;
    }
    
    // Prevent negative XP exploits except for habit removals
    if (amount < 0 && !source.startsWith('habit_')) {
      print('Negative XP only allowed for habit sources');
      return;
    }
    
    // Cap XP gains per transaction to prevent exploits
    int safeAmount = amount;
    if (amount > 1000) {
      print('XP gain capped from $amount to 1000');
      safeAmount = 1000;
    }
    
    // Apply rate limiting for positive XP gains
    if (safeAmount > 0) {
      final limitedAmount = _applyXpRateLimiting(safeAmount);
      if (limitedAmount <= 0) {
        print('XP gain rate limited - daily or hourly limit reached');
        return; // Skip this XP gain entirely if rate limited
      }
      safeAmount = limitedAmount;
    }

    final newTotalXP = (_userProgress.totalXP + safeAmount).clamp(0, 1 << 31);
    final currentLevel = _userProgress.currentLevel;
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel =
        UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    if (newLevel > currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> addStatXP(HabitCategory category, int amount) async {
    UserStats newStats;
    switch (category) {
      case HabitCategory.fitness:
        newStats = _userProgress.stats
            .copyWith(strength: _userProgress.stats.strength + amount);
        break;
      case HabitCategory.learning:
        newStats = _userProgress.stats.copyWith(
            intelligence: _userProgress.stats.intelligence + amount);
        break;
      case HabitCategory.mindfulness:
        newStats = _userProgress.stats
            .copyWith(wisdom: _userProgress.stats.wisdom + amount);
        break;
      case HabitCategory.social:
        newStats = _userProgress.stats
            .copyWith(charisma: _userProgress.stats.charisma + amount);
        break;
      case HabitCategory.productivity:
        newStats = _userProgress.stats
            .copyWith(dexterity: _userProgress.stats.dexterity + amount);
        break;
      default:
        newStats = _userProgress.stats
            .copyWith(luck: _userProgress.stats.luck + amount);
        break;
    }
    _userProgress = _userProgress.copyWith(stats: newStats);
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> removeStatXP(HabitCategory category, int amount) async {
    UserStats newStats;
    switch (category) {
      case HabitCategory.fitness:
        newStats = _userProgress.stats
            .copyWith(strength: _userProgress.stats.strength - amount);
        break;
      case HabitCategory.learning:
        newStats = _userProgress.stats.copyWith(
            intelligence: _userProgress.stats.intelligence - amount);
        break;
      case HabitCategory.mindfulness:
        newStats = _userProgress.stats
            .copyWith(wisdom: _userProgress.stats.wisdom - amount);
        break;
      case HabitCategory.social:
        newStats = _userProgress.stats
            .copyWith(charisma: _userProgress.stats.charisma - amount);
        break;
      case HabitCategory.productivity:
        newStats = _userProgress.stats
            .copyWith(dexterity: _userProgress.stats.dexterity - amount);
        break;
      default:
        newStats = _userProgress.stats
            .copyWith(luck: _userProgress.stats.luck - amount);
        break;
    }
    _userProgress = _userProgress.copyWith(stats: newStats);
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> addXPWithAnimation(int amount, String source,
      [HabitCategory? category]) async {
    if (amount <= 0) return;
    
    // Only allow XP mutations for valid sources
    if (!source.startsWith('habit_') && !source.startsWith('achievement_') && !source.startsWith('quest_')) {
      print('Invalid XP source: $source');
      return;
    }
    
    // Cap XP gains per transaction to prevent exploits
    int safeAmount = amount;
    if (amount > 1000) {
      print('XP gain capped from $amount to 1000');
      safeAmount = 1000;
    }
    
    // Apply rate limiting for positive XP gains
    if (safeAmount > 0) {
      final limitedAmount = _applyXpRateLimiting(safeAmount);
      if (limitedAmount <= 0) {
        print('XP gain rate limited - daily or hourly limit reached');
        return; // Skip this XP gain entirely if rate limited
      }
      safeAmount = limitedAmount;
    }

    final oldXP = _userProgress.totalXP;
    final newTotalXP = (oldXP + safeAmount).clamp(0, 1 << 31);

    await Future.delayed(const Duration(milliseconds: 300));

    final currentLevel = _userProgress.currentLevel;
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel =
        UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    if (newLevel > currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    // FIX: Do NOT change stats here. Stats only update via habit completions.

    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> incrementHabitCompletion(HabitCategory category) async {
    _userProgress = _userProgress.copyWith(
      totalHabitsCompleted: _userProgress.totalHabitsCompleted + 1,
    );

    await _checkCompletionAchievements();
    await _checkFirstHabitAchievements();

    // FIX: add both stat XP and global XP
    await addStatXP(category, 10);
    await addXP(10, 'habit_${category.name}');

    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> decrementHabitCompletion(HabitCategory category) async {
    _userProgress = _userProgress.copyWith(
      totalHabitsCompleted: (_userProgress.totalHabitsCompleted - 1).clamp(0, 1 << 31),
    );

    // FIX: remove both stat XP and global XP
    await removeStatXP(category, 10);
    await addXP(-10, 'habit_${category.name}');

    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> updateDailyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      dailyStreak: streak,
      bestDailyStreak:
          streak > _userProgress.bestDailyStreak ? streak : _userProgress.bestDailyStreak,
    );

    await _checkStreakAchievements(streak);
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> updateWeeklyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      weeklyStreak: streak,
      bestWeeklyStreak:
          streak > _userProgress.bestWeeklyStreak ? streak : _userProgress.bestWeeklyStreak,
    );
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> incrementPerfectDays() async {
    _userProgress = _userProgress.copyWith(
      totalPerfectDays: _userProgress.totalPerfectDays + 1,
    );
    await _checkPerfectDaysAchievements();
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> useStreakFreeze() async {
    await _checkStreakFreezeAchievements();
    
    // Update user progress to record streak freeze usage
    _userProgress = _userProgress.copyWith(
      totalStreakFreezesUsed: _userProgress.totalStreakFreezesUsed + 1,
    );
    
    await _saveUserProgress();
    notifyListeners();
  }
  
  Future<void> awardStreakFreezes(int count) async {
    // Find all active habits
    final buildContext = navigatorKey.currentContext;
    if (buildContext != null && buildContext.mounted) {
      final habitProvider = Provider.of<HabitProvider>(buildContext, listen: false);
      
      // Award streak freezes to all active habits
      for (final habit in habitProvider.activeHabits) {
        await habitProvider.awardStreakFreezes(habit.id, count);
      }
      
      // Show notification
      if (buildContext.mounted) {
        ScaffoldMessenger.of(buildContext).showSnackBar(
          SnackBar(
            content: Text('$count streak freezes awarded to all habits! ❄️'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  int _calculateLevel(int totalXP) {
    int level = 1;
    int xpNeeded = 0;

    while (true) {
      final xpForLevel = UserProgress.calculateXPForNextLevel(level);
      if (xpNeeded + xpForLevel > totalXP) break;
      xpNeeded += xpForLevel;
      level++;
    }

    return level;
  }

  Future<void> _checkLevelAchievements(int level) async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.level &&
          achievement.target == level &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkStreakAchievements(int streak) async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.streak &&
          achievement.target <= streak &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkCompletionAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.completion &&
          achievement.target <= _userProgress.totalHabitsCompleted &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkFirstHabitAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.firstHabit &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkPerfectDaysAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.perfectDays &&
          achievement.target <= _userProgress.totalPerfectDays &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkStreakFreezeAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.streakFreeze &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      final achievement = _achievements[index];
      _achievements[index] = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progress: achievement.target,
      );

      await addXP(achievement.xpReward, 'achievement_${achievement.id}');

      if (achievement.streakFreezeReward > 0) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final habitProvider =
              Provider.of<HabitProvider>(context, listen: false);
          await habitProvider.awardStreakFreezes(
              achievement.streakFreezeReward.toString(),
              achievement.streakFreezeReward);
        }
      }

      await _saveAchievements();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  double getXPForDay(BuildContext context, DateTime date) {
    final habits = Provider.of<HabitProvider>(context, listen: false);
    return habits.getTotalXPForDay(date).toDouble();
  }
  
  // Clean up XP gain history entries older than 24 hours
  void _cleanupXpGainHistory() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final key in _xpGainHistory.keys) {
      try {
        final parts = key.split('-');
        if (parts.length >= 4) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final hour = int.parse(parts[3]);
          
          final entryTime = DateTime(year, month, day, hour);
          final difference = now.difference(entryTime);
          
          if (difference.inHours > 24) {
            keysToRemove.add(key);
          }
        }
      } catch (e) {
        // Invalid format, remove it
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _xpGainHistory.remove(key);
    }
  }
  
  // Apply XP rate limiting and return the adjusted amount
  int _applyXpRateLimiting(int amount) {
    if (amount <= 0) return amount;
    
    final now = DateTime.now();
    final hourKey = '${now.year}-${now.month}-${now.day}-${now.hour}';
    final dayKey = '${now.year}-${now.month}-${now.day}';
    
    // Calculate current hourly and daily totals
    int hourlyTotal = 0;
    int dailyTotal = 0;
    
    // Calculate hourly total
    if (_xpGainHistory.containsKey(hourKey)) {
      hourlyTotal = _xpGainHistory[hourKey]!;
    }
    
    // Calculate daily total by summing all entries for the current day
    for (final entry in _xpGainHistory.entries) {
      if (entry.key.startsWith(dayKey)) {
        dailyTotal += entry.value;
      }
    }
    
    // Apply rate limits
    int adjustedAmount = amount;
    
    // Check hourly limit
    if (hourlyTotal + adjustedAmount > _maxHourlyXP) {
      adjustedAmount = (_maxHourlyXP - hourlyTotal).clamp(0, amount);
    }
    
    // Check daily limit
    if (dailyTotal + adjustedAmount > _maxDailyXP) {
      adjustedAmount = (_maxDailyXP - dailyTotal).clamp(0, adjustedAmount);
    }
    
    // Update history if we're adding XP
    if (adjustedAmount > 0) {
      _xpGainHistory[hourKey] = (hourlyTotal + adjustedAmount);
      _saveXpGainHistory();
    }
    
    return adjustedAmount;
  }
  
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    
    _userProgress = _userProgress.copyWith(
      coins: (_userProgress.coins + amount).clamp(0, 1 << 31),
    );
    
    await _saveUserProgress();
    notifyListeners();
  }
  
  Future<void> useCoins(int amount) async {
    if (amount <= 0 || _userProgress.coins < amount) return;
    
    _userProgress = _userProgress.copyWith(
      coins: (_userProgress.coins - amount).clamp(0, 1 << 31),
    );
    
    await _saveUserProgress();
    notifyListeners();
  }
  
  bool canUseCoins(int amount) {
    return _userProgress.coins >= amount;
  }
}