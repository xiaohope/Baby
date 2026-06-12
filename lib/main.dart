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
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      theme: _buildLightTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF6C63FF),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF8A80),
      onSecondary: Colors.white,
      tertiary: Color(0xFF81C9D6),
      onTertiary: Colors.white,
      surface: Color(0xFFFEF9F0),
      onSurface: Color(0xFF2D3436),
      error: Color(0xFFE74C3C),
      onError: Colors.white,
      surfaceContainerHighest: Color(0xFFFFF5EB),
      outline: Color(0xFFD4C5B5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ).apply(
        bodyColor: const Color(0xFF2D3436),
        displayColor: const Color(0xFF2D3436),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F0EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D3436),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6C63FF));
          }
          return const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF6C63FF), size: 22);
          }
          return const IconThemeData(color: Color(0xFF9E9E9E), size: 22);
        }),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9D97FF),
      onPrimary: Color(0xFF1A1A2E),
      secondary: Color(0xFFFF9E96),
      onSecondary: Color(0xFF1A1A2E),
      tertiary: Color(0xFF81C9D6),
      onTertiary: Color(0xFF1A1A2E),
      surface: Color(0xFF1A1A2E),
      onSurface: Color(0xFFE8E8E8),
      error: Color(0xFFE74C3C),
      onError: Color(0xFF1A1A2E),
      surfaceContainerHighest: Color(0xFF2D2D44),
      outline: Color(0xFF4A4A5A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ).apply(
        bodyColor: const Color(0xFFE8E8E8),
        displayColor: const Color(0xFFE8E8E8),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        color: const Color(0xFF2D2D44),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D44),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9D97FF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFF9D97FF).withValues(alpha: 0.15),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 3,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE8E8E8),
      ),
    );
  }
}
