import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';
import 'services/hive_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  final ds = DataService();
  await ds.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ds),
      ],
      child: const BabyTrackerApp(),
    ),
  );
}

class BabyTrackerApp extends StatelessWidget {
  const BabyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝宝记录',
      debugShowCheckedModeBanner: false,
      // 🌙 自动跟随系统深色模式
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81C9D6),
          brightness: Brightness.light,
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFFB2EBF2),
          surface: const Color(0xFFF8FAFC),
          onSurface: const Color(0xFF1E293B),
          onError: const Color(0xFFEF4444),
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.6),
          labelMedium: const TextStyle(fontSize: 14),
        ).apply(
          bodyColor: const Color(0xFF1E293B),
          displayColor: const Color(0xFF1E293B),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }

  // 🌙 深色模式主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF81C9D6),
        brightness: Brightness.dark,
        primary: const Color(0xFF81C9D6),
        secondary: const Color(0xFF334155),
        surface: const Color(0xFF0F172A),
        onSurface: const Color(0xFFE2E8F0),
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.6),
      ).apply(
        bodyColor: const Color(0xFFE2E8F0),
        displayColor: const Color(0xFFE2E8F0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        color: const Color(0xFF1E293B),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF81C9D6), width: 2),
        ),
      ),
    );
  }
}