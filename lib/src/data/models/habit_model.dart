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
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: HabitType.values[json['type'] as int],
      category: HabitCategory.values[json['category'] as int],
      difficulty: HabitDifficulty.values[json['difficulty'] as int],
      targetCount: json['targetCount'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalCompletions: json['totalCompletions'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      completionHistory: (json['completionHistory'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String?,
      xpValue: json['xpValue'] as int,
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
      'targetCount': targetCount,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCompletions': totalCompletions,
      'createdAt': createdAt.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'completionHistory': completionHistory,
      'isActive': isActive,
      'reminderTime': reminderTime,
      'xpValue': xpValue,
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
    );
  }
}