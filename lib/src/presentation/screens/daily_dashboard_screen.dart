import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

class DailyDashboardScreen extends StatefulWidget {
  const DailyDashboardScreen({super.key});

  @override
  State<DailyDashboardScreen> createState() => _DailyDashboardScreenState();
}

class _DailyDashboardScreenState extends State<DailyDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
      context.read<UserProgressProvider>().loadUserProgress();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Shinkō'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile/settings
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Consumer2<HabitProvider, UserProgressProvider>(
          builder: (context, habitProvider, userProvider, child) {
            if (habitProvider.isLoading || userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = habitProvider.getStreakStats();
            final pendingHabits = habitProvider.pendingTodayHabits;
            final completedHabits = habitProvider.completedTodayHabits;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await habitProvider.loadHabits();
                    await userProvider.loadUserProgress();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(),
                        const SizedBox(height: 24),
                        _buildProgressCard(userProvider),
                        const SizedBox(height: 24),
                        _buildStreakStats(stats),
                        const SizedBox(height: 24),
                        _buildTodayTasksSection(pendingHabits, completedHabits),
                        const SizedBox(height: 24),
                        _buildRecentAchievements(userProvider),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '進行 - Progress awaits',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(UserProgressProvider userProvider) {
    return Container(
      decoration: AppTheme.neonCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${userProvider.userProgress.currentLevel}',
                style: AppTheme.titleLarge,
              ),
              Text(
                '${userProvider.userProgress.totalXP} XP',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: userProvider.levelProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.darkTheme.colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(userProvider.levelProgress * 100).toStringAsFixed(0)}% to next level',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Daily Streak',
            stats['totalCurrentStreak']?.toString() ?? '0',
            '🔥',
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Best Streak',
            stats['maxStreak']?.toString() ?? '0',
            '⚡',
            Colors.yellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Habits',
            stats['habitCount']?.toString() ?? '0',
            '🎯',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String emoji, Color color) {
    return Container(
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasksSection(
    List<Habit> pendingHabits,
    List<Habit> completedHabits,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Tasks",
          style: AppTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (pendingHabits.isEmpty && completedHabits.isEmpty)
          Container(
            decoration: AppTheme.glassCardDecoration,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_objects,
                  size: 48,
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits yet!',
                  style: AppTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start building your routine by adding your first habit.',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          if (pendingHabits.isNotEmpty) ...[
            Text(
              'Pending (${pendingHabits.length})',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...pendingHabits.map((habit) => _buildHabitCard(habit, false)),
          ],
          if (completedHabits.isNotEmpty) ...[
            if (pendingHabits.isNotEmpty) const SizedBox(height: 16),
            Text(
              'Completed (${completedHabits.length})',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...completedHabits.map((habit) => _buildHabitCard(habit, true)),
          ],
        ],
      ],
    );
  }

  Widget _buildHabitCard(Habit habit, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: isCompleted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.green.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            )
          : AppTheme.glassCardDecoration,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: habit.category.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              habit.category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          habit.title,
          style: isCompleted
              ? AppTheme.bodyLarge.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.white54,
                )
              : AppTheme.bodyLarge,
        ),
        subtitle: Text(
          '${habit.currentStreak} day streak • ${habit.xpValue} XP',
          style: AppTheme.caption,
        ),
        trailing: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.white54,
          ),
          onPressed: () {
            if (isCompleted) {
              context.read<HabitProvider>().uncompleteHabit(habit.id);
            } else {
              context.read<HabitProvider>().completeHabit(habit.id);
              context.read<UserProgressProvider>().addXP(habit.xpValue, 'habit_${habit.id}');
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(UserProgressProvider userProvider) {
    final recentAchievements = userProvider.unlockedAchievements.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: AppTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (recentAchievements.isEmpty)
          Text(
            'Complete habits to unlock achievements!',
            style: AppTheme.bodyMedium,
          )
        else
          ...recentAchievements.map((achievement) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: AppTheme.glassCardDecoration,
                child: ListTile(
                  leading: Text(
                    achievement.iconData,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    achievement.title,
                    style: AppTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    '+${achievement.xpReward} XP',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    HabitCategory selectedCategory = HabitCategory.health;
    HabitDifficulty selectedDifficulty = HabitDifficulty.easy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.cardTheme.color,
        title: const Text('Add New Habit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Morning Meditation',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the habit',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: HabitCategory.values.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                )).toList(),
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitDifficulty>(
                initialValue: selectedDifficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: HabitDifficulty.values.map((difficulty) => DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.name),
                )).toList(),
                onChanged: (value) {
                  if (value != null) selectedDifficulty = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final habit = Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  type: HabitType.daily,
                  category: selectedCategory,
                  difficulty: selectedDifficulty,
                  xpValue: _calculateXPForDifficulty(selectedDifficulty),
                  createdAt: DateTime.now(),
                );
                
                context.read<HabitProvider>().addHabit(habit);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Habit'),
          ),
        ],
      ),
    );
  }

  int _calculateXPForDifficulty(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return 10;
      case HabitDifficulty.medium:
        return 20;
      case HabitDifficulty.hard:
        return 30;
      case HabitDifficulty.expert:
        return 50;
    }
  }
}

extension HabitCategoryExtension on HabitCategory {
  Color get color {
    switch (this) {
      case HabitCategory.health:
        return Colors.red;
      case HabitCategory.productivity:
        return Colors.blue;
      case HabitCategory.learning:
        return Colors.green;
      case HabitCategory.fitness:
        return Colors.orange;
      case HabitCategory.mindfulness:
        return Colors.purple;
      case HabitCategory.social:
        return Colors.pink;
      case HabitCategory.finance:
        return Colors.amber;
      case HabitCategory.creativity:
        return Colors.teal;
      case HabitCategory.other:
        return Colors.grey;
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.health:
        return '🏥';
      case HabitCategory.productivity:
        return '⚡';
      case HabitCategory.learning:
        return '📚';
      case HabitCategory.fitness:
        return '💪';
      case HabitCategory.mindfulness:
        return '🧘';
      case HabitCategory.social:
        return '👥';
      case HabitCategory.finance:
        return '💰';
      case HabitCategory.creativity:
        return '🎨';
      case HabitCategory.other:
        return '⭐';
    }
  }
}