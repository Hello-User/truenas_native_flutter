import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'dashboard.dart';

const String isConfiguredKey = 'is_configured';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool configured = prefs.getBool(isConfiguredKey) ?? false;

  runApp(MyApp(isConfigured: configured));
}

class MyApp extends StatelessWidget {
  final bool isConfigured;
  const MyApp({super.key, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueNAS Native',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0, 153, 216, 100),
        brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0, 153, 216, 100),
        brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: isConfigured ? MainDashboard(title: 'TrueNAS', isConfigured: isConfigured) : LoginScreen()
    );
  }
}