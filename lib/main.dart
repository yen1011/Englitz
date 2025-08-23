import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/rank_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Englitz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF788CC3)),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/rank': (context) => const RankScreen(),
        // '/review': (context) => const ReviewScreen(), // 추후 구현
      },
    );
  }
}
