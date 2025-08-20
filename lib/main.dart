import 'package:flutter/material.dart';
import 'package:shinko/src/data/repositories/habit_repository_impl.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/providers/motivation_provider.dart';
import 'package:shinko/src/presentation/providers/tomorrow_message_provider.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/presentation/providers/cosmetic_provider.dart';
import 'package:shinko/src/presentation/screens/main_screen.dart';
import 'package:shinko/src/presentation/screens/onboarding_screen.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';
import 'package:shinko/src/core/navigator_key.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShinkoApp());
}

class ShinkoApp extends StatelessWidget {
  const ShinkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HabitProvider(HabitRepositoryImpl(DatabaseHelper.instance)),
        ),
        ChangeNotifierProvider(create: (_) => UserProgressProvider()),
        ChangeNotifierProvider(create: (_) => MotivationProvider()),
        ChangeNotifierProvider(create: (_) => TomorrowMessageProvider()),
        ChangeNotifierProvider(create: (_) => CosmeticProvider()..load()),
        ChangeNotifierProxyProvider<HabitProvider, QuestProvider>(
          create: (context) => QuestProvider(context.read<HabitProvider>()),
          update: (context, habits, previous) => (previous ?? QuestProvider(habits))..onHabitsChanged(),
        ),
      ],
      child: MaterialApp(
        title: 'Shinkō',
        theme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    final showOnboarding = await OnboardingHelper.shouldShowOnboarding();
    
    if (!mounted) return;

    if (showOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_graph,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
