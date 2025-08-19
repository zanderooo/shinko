import 'package:flutter/material.dart';
import 'package:shinko/src/data/repositories/habit_repository_impl.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/screens/main_screen.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

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
      ],
      child: MaterialApp(
        title: 'Shinkō',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}
