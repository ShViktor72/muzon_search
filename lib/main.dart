import 'package:flutter/material.dart';
import 'package:muzon_search/screens/donate.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Поиск музыки',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/menu': (context) => const MenuScreen(),
        '/donate': (context) => const DonateScreen(),
      },
    );
  }
}
