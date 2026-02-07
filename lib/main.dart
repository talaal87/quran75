import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WordProvider())],
      child: MaterialApp(
        title: 'Quran75',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Use our custom theme
        home: const HomeScreen(),
      ),
    );
  }
}
