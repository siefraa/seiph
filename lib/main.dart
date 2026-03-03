import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/family_tree_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FamilyTreeProvider(),
      child: MaterialApp(
        title: 'Family Tree',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFFE8C97F),
          scaffoldBackgroundColor: const Color(0xFFF4F4F4),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A1A2E),
            secondary: Color(0xFFE8C97F),
            surface: Colors.white,
            background: Color(0xFFF4F4F4),
          ),
          dividerColor: const Color(0xFFE0E0E0),
          cardColor: Colors.white,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
