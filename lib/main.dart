import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/settings_menu.dart';
import 'services/websockets.dart';
import 'dart:convert';

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
  final TrueNASWebSocketService _webSocketService = TrueNASWebSocketService();
  String _webSocketData = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _connectWebSocket();

    _webSocketService.messages.listen((message) {
      if (mounted) {
        setState(() {
          try {
            Map<String, dynamic> tl = jsonDecode(message.toString());
            Map<String, dynamic> decoded = tl['result'];
            _webSocketData = decoded['used']['value'];
          } catch (e) {
            _webSocketData = message.toString();
          }
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _webSocketData = 'Error: $error';
        });
      }
    });
  }

  Future<void> _connectWebSocket() async {
    if (mounted) {
      setState(() {
        _webSocketData = 'Connecting and authenticating...';
      });
    }

    bool isAuthenticated = await _webSocketService.connect();

    if (mounted) {
      if (isAuthenticated && _webSocketService.isConnected) {
        setState(() {
          _webSocketData = 'WebSocket Authenticated. Fetching data...';
        });
        _webSocketService.sendCommand("pool.dataset.get_instance", ["Chronos", {"select": ["id", "used.value", "available.value"]}]);
      } else {
        if (!_webSocketData.startsWith('Error:')) {
          setState(() {
            _webSocketData = 'Authentication Failed. Please check credentials, server, or network.';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

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
        child: Padding(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: Text(
              _webSocketData,
              textAlign: TextAlign.left,
            ),
          ),
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
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text("Storage"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text("Datasets"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.folder_shared),
                title: const Text("Shares"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text("Data Protection"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.device_hub),
                title: const Text("Network"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text("Credentials"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.computer),
                title: const Text("Instances"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.apps),
                title: const Text("Apps"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.assessment),
                title: const Text("Reporting"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("System"),
                onTap: () => Navigator.pop(context),
              ),
      ],
    );
  }
}

Future<void> clearConfig(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(truenasUrlKey);
  await prefs.remove(truenasUsername);
  await prefs.remove(truenasPassword);
  await prefs.setBool(isConfiguredKey, false);

  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}