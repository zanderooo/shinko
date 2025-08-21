import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shinko/src/core/navigator_key.dart';
import 'package:shinko/src/core/services/notification_service.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:shinko/src/data/repositories/habit_repository_impl.dart';

import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/providers/motivation_provider.dart';
import 'package:shinko/src/presentation/providers/tomorrow_message_provider.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/presentation/providers/cosmetic_provider.dart';

import 'package:shinko/src/presentation/screens/main_screen.dart';
import 'package:shinko/src/presentation/screens/onboarding_screen.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const ShinkoApp());
}

class ShinkoApp extends StatelessWidget {
  const ShinkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Core habit + progress state
        ChangeNotifierProvider(
          create: (_) => HabitProvider(
            HabitRepositoryImpl(DatabaseHelper.instance),
          ),
        ),
        ChangeNotifierProvider(create: (_) => UserProgressProvider()),

        /// Motivation, streak & message state
        ChangeNotifierProvider(create: (_) => MotivationProvider()),
        ChangeNotifierProvider(create: (_) => TomorrowMessageProvider()),

        /// Cosmetics + quests
        ChangeNotifierProvider(create: (_) => CosmeticProvider()..load()),
        ChangeNotifierProxyProvider<HabitProvider, QuestProvider>(
          create: (context) => QuestProvider(context.read<HabitProvider>()),
          update: (context, habits, previous) =>
              (previous ?? QuestProvider(habits))..onHabitsChanged(),
        ),
      ],
      child: Consumer<CosmeticProvider>(
        builder: (context, cos, _) => MaterialApp(
          title: 'Shinkō',
          theme: AppTheme.themeFor(cos.equippedByType['theme']),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/main': (_) => const MainScreen(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    /// Simulate init (DB load, settings, etc.)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final showOnboarding = await OnboardingHelper.shouldShowOnboarding();

    if (!mounted) return;

    if (showOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_graph, size: 80, color: color),
              const SizedBox(height: 24),
              CircularProgressIndicator(color: color),
            ],
          ),
        ),
      ),
    );
  }
}