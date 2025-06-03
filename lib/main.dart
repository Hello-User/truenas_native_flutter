import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/settings_menu.dart';

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
      themeMode: ThemeMode.dark,
      home: isConfigured ? MainDashboard(title: 'TrueNAS') : LoginScreen()
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key, required this.title});

  final String title;

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {

  void _navigateToSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 88,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "TrueNAS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSettings();
                      },
                    )
                  ],
                )
              ),
            ),
            const DrawerItems(),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('placeholder'),
          ],
        ),
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  const DrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
                leading: Icon(Icons.dashboard),
                title: Text("Dashboard"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.dns),
                title: Text("Storage"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.account_tree),
                title: Text("Datasets"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.folder_shared),
                title: Text("Shares"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text("Data Protection"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.device_hub),
                title: Text("Network"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.vpn_key),
                title: Text("Credentials"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.computer),
                title: Text("Instances"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.apps),
                title: Text("Apps"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.assessment),
                title: Text("Reporting"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("System"),
                onTap: () => Navigator.pop(context),
              ),
      ],
    );
  }
}

Future<void> clearConfig(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(truenasUrlKey);
  await prefs.remove(truenasApiKeyKey);
  await prefs.setBool(isConfiguredKey, false);

  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}