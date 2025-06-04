import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/settings_menu.dart';
import 'services/websockets.dart';
import 'dart:convert';

const String isConfiguredKey = 'isConfigured';

void _navigateToSettings(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => const SettingsScreen(),
  ));
}

class MainDashboard extends StatefulWidget {
  final bool isConfigured;
  const MainDashboard({super.key, required this.title, required this.isConfigured});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
                Expanded(
                  child: const Text(
                    "TrueNAS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToSettings(context);
                  },
                )
              ],
            )
          ),
        ),
        ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () {
                  _navigateToMainDashboard(context);
                }
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

Future<void> _navigateToMainDashboard(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final bool isActuallyConfigured = prefs.getBool(isConfiguredKey) ?? false;

  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainDashboard(
          title: 'TrueNAS',
          isConfigured: isActuallyConfigured,
        ),
      ),
    );
  }
}