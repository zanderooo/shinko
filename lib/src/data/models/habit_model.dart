import 'package:shinko/src/domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.title,
    super.description,
    required super.type,
    required super.category,
    required super.difficulty,
    super.targetCount,
    super.currentStreak,
    super.bestStreak,
    super.totalCompletions,
    required super.createdAt,
    super.lastCompletedAt,
    super.completionHistory,
    super.isActive,
    super.reminderTime,
    required super.xpValue,
    super.streakFreezes,
    super.lastStreakFreezeUsed,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<int> parseCompletionHistory(dynamic historyData) {
      if (historyData == null) return [];
      if (historyData is List) {
        return historyData.map((e) => e as int).toList();
      }
      if (historyData is String) {
        try {
          if (historyData == '[]' || historyData.isEmpty) return [];
          // Handle string format like "1,2,3" or "[1,2,3]"
          final cleaned = historyData.replaceAll('[', '').replaceAll(']', '');
          if (cleaned.trim().isEmpty) return [];
          return cleaned.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
        } catch (e) {
          return [];
        }
      }
      return [];
    }

    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: HabitType.values[json['type'] as int],
      category: HabitCategory.values[json['category'] as int],
      difficulty: HabitDifficulty.values[json['difficulty'] as int],
      targetCount: json['targetCount'] as int? ?? json['target_count'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? json['current_streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? json['best_streak'] as int? ?? 0,
      totalCompletions: json['totalCompletions'] as int? ?? json['total_completions'] as int? ?? 0,
      createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : json['last_completed_at'] != null
              ? DateTime.parse(json['last_completed_at'] as String)
              : null,
      completionHistory: parseCompletionHistory(json['completionHistory'] ?? json['completion_history']),
      isActive: (json['isActive'] as int? ?? json['is_active'] as int? ?? 1) == 1,
      reminderTime: json['reminderTime'] as String? ?? json['reminder_time'] as String?,
      xpValue: json['xpValue'] as int? ?? json['xp_value'] as int? ?? 10,
      streakFreezes: json['streakFreezes'] as int? ?? json['streak_freezes'] as int? ?? 0,
      lastStreakFreezeUsed: json['lastStreakFreezeUsed'] != null
          ? DateTime.parse(json['lastStreakFreezeUsed'] as String)
          : json['last_streak_freeze_used'] != null
              ? DateTime.parse(json['last_streak_freeze_used'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'category': category.index,
      'difficulty': difficulty.index,
      'target_count': targetCount,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'total_completions': totalCompletions,
      'created_at': createdAt.toIso8601String(),
      'last_completed_at': lastCompletedAt?.toIso8601String(),
      'completion_history': completionHistory.join(','),
      'is_active': isActive ? 1 : 0,
      'reminder_time': reminderTime,
      'xp_value': xpValue,
      'streak_freezes': streakFreezes,
      'last_streak_freeze_used': lastStreakFreezeUsed?.toIso8601String(),
    };
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      type: habit.type,
      category: habit.category,
      difficulty: habit.difficulty,
      targetCount: habit.targetCount,
      currentStreak: habit.currentStreak,
      bestStreak: habit.bestStreak,
      totalCompletions: habit.totalCompletions,
      createdAt: habit.createdAt,
      lastCompletedAt: habit.lastCompletedAt,
      completionHistory: habit.completionHistory,
      isActive: habit.isActive,
      reminderTime: habit.reminderTime,
      xpValue: habit.xpValue,
      streakFreezes: habit.streakFreezes,
      lastStreakFreezeUsed: habit.lastStreakFreezeUsed,
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      description: description,
      type: type,
      category: category,
      difficulty: difficulty,
      targetCount: targetCount,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      createdAt: createdAt,
      lastCompletedAt: lastCompletedAt,
      completionHistory: completionHistory,
      isActive: isActive,
      reminderTime: reminderTime,
      xpValue: xpValue,
      streakFreezes: streakFreezes,
      lastStreakFreezeUsed: lastStreakFreezeUsed,
    );
  }
}