import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/providers/tomorrow_message_provider.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';
import 'package:shinko/src/presentation/screens/settings_screen.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/presentation/widgets/quest_card.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HabitProvider>().loadHabits();
      context.read<UserProgressProvider>().loadUserProgress();
      context.read<TomorrowMessageProvider>().loadMessage();
      await context.read<QuestProvider>().ensureGeneratedForToday();
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Shinkō'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddModal(context),
        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
        elevation: 8,
        highlightElevation: 12,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.2),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Glassmorphism overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              backgroundBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Consumer4<HabitProvider, UserProgressProvider, TomorrowMessageProvider, QuestProvider>(
              builder: (context, habitProvider, userProvider, tomorrowProvider, questProvider, child) {
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
                      color: AppTheme.darkTheme.colorScheme.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(),
                            const SizedBox(height: 16),
                            _buildTomorrowMessageCard(tomorrowProvider),
                            const SizedBox(height: 16),
                            _buildQuestsSection(questProvider),
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
        ],
      ),
    );
  }

  Widget _buildTomorrowMessageCard(TomorrowMessageProvider tomorrowProvider) {
    final hasMessage = tomorrowProvider.currentMessage != null;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Message to Tomorrow You',
                style: AppTheme.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMessage)
            Text(
              tomorrowProvider.currentMessage!,
              style: AppTheme.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            )
          else
            Text(
              'Write a message to your future self...',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: Text(hasMessage ? 'Edit' : 'Write'),
              onPressed: () => _showTomorrowMessageDialog(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
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

  Widget _buildQuestsSection(QuestProvider questProvider) {
    final quests = questProvider.todayQuests;
    final chest = questProvider.bonusChest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Quests', style: AppTheme.titleLarge),
        const SizedBox(height: 8),
        if (quests.isEmpty)
          Text('Generating quests...', style: AppTheme.bodyMedium)
        else
          ...quests.map((q) => Padding(padding: const EdgeInsets.only(bottom: 8), child: QuestCard(quest: q))),
        if (chest != null) ...[
          const SizedBox(height: 8),
          Container(
            decoration: AppTheme.glassCardDecoration,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(child: Text(chest.title, style: AppTheme.bodyLarge)),
                if (chest.isCompleted)
                  ElevatedButton(
                    onPressed: () async {
                      final localContext = context;
                      final claimed = await questProvider.claimBonusChest(localContext, (xp, cosmeticId) async {
                        final up = localContext.read<UserProgressProvider>();
                        await up.addXPWithAnimation(xp, 'bonus_chest');
                        if (cosmeticId != null && localContext.mounted) {
                          // optional: unlock cosmetic via provider if passed
                        }
                        if (localContext.mounted) {
                          ScaffoldMessenger.of(localContext).showSnackBar(
                            SnackBar(content: Text('Bonus chest: +$xp XP')),
                          );
                        }
                      });
                      if (claimed != null && context.mounted) {
                        setState(() {});
                      }
                    },
                    child: const Text('Claim'),
                  )
                else
                  Text('Locked', style: AppTheme.caption.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressCard(UserProgressProvider userProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      decoration: AppTheme.neonCardDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Colors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.purple.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Level ${userProvider.userProgress.currentLevel}',
                    style: AppTheme.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '${userProvider.userProgress.totalXP} XP',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.purple.shade300,
                          Colors.pink.shade200,
                          Colors.orange.shade300,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.8 * userProvider.levelProgress,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to Level ${userProvider.userProgress.currentLevel + 1}',
                style: AppTheme.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(userProvider.levelProgress * 100).toStringAsFixed(0)}%',
                style: AppTheme.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: userProvider.levelProgress > 0.9 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.4),
                    Colors.teal.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '🚀 Almost there!',
                style: AppTheme.caption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildAnimatedStatCard(
            'Daily Streak',
            stats['totalCurrentStreak']?.toString() ?? '0',
            '🔥',
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnimatedStatCard(
            'Best Streak',
            stats['maxStreak']?.toString() ?? '0',
            '⚡',
            Colors.yellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnimatedStatCard(
            'Habits',
            stats['habitCount']?.toString() ?? '0',
            '🎯',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, String emoji, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * animation),
          child: Opacity(
            opacity: animation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    title,
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final habitProvider = context.watch<HabitProvider>();
    final canUseFreeze = habitProvider.canUseStreakFreeze(habit.id);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: isCompleted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.2),
                  Colors.green.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : AppTheme.glassCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isCompleted) {
              context.read<HabitProvider>().uncompleteHabit(habit.id);
            } else {
              context.read<HabitProvider>().completeHabit(habit.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            habit.category.color.withValues(alpha: 0.3),
                            habit.category.color.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: habit.category.color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          habit.category.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: isCompleted
                                ? AppTheme.bodyLarge.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.white54,
                                  )
                                : AppTheme.bodyLarge.copyWith(
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${habit.currentStreak} day streak • ${habit.xpValue} XP',
                            style: AppTheme.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        key: ValueKey('${habit.id}_$isCompleted'),
                        icon: Icon(
                          isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          color: isCompleted ? Colors.green : Colors.white54,
                          size: 28,
                        ),
                        onPressed: () {
                          if (isCompleted) {
                            context.read<HabitProvider>().uncompleteHabit(habit.id);
                          } else {
                            context.read<HabitProvider>().completeHabit(habit.id);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (!isCompleted && (habit.streakFreezes > 0 || canUseFreeze)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (habit.streakFreezes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${habit.streakFreezes} ❄️',
                            style: AppTheme.caption.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (canUseFreeze)
                        TextButton.icon(
                          onPressed: () async {
                            final localContext = context;
                            final success = await habitProvider.useStreakFreeze(habit.id);
                            if (success && localContext.mounted) {
                              ScaffoldMessenger.of(localContext).showSnackBar(
                                SnackBar(
                                  content: Text('Streak freeze used! ❄️'),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.ac_unit, size: 16),
                          label: const Text('Use Freeze'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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

  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Create Your Habit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCustomHabitDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Custom Habit'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }



  void _showCustomHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    HabitCategory selectedCategory = HabitCategory.health;
    HabitDifficulty selectedDifficulty = HabitDifficulty.easy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.cardTheme.color,
        title: const Text('Create Custom Habit'),
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

  void _showTomorrowMessageDialog(BuildContext context) {
    final tomorrowProvider = context.read<TomorrowMessageProvider>();
    final textController = TextEditingController(
      text: tomorrowProvider.currentMessage ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message to Tomorrow You'),
        content: TextField(
          controller: textController,
          maxLines: 4,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Write something encouraging for tomorrow...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tomorrowProvider.saveTomorrowMessage(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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