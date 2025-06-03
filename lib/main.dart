import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueNAS Native',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0, 153, 216, 100)),
      ),
      home: const MyHomePage(title: 'TrueNAS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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
                child: Text("TrueNAS")
              ),
            ),
            DrawerItems(),
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
                leading: Icon(Icons.storage),
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