import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

const String truenasUrlKey = 'truenas_url';
const String truenasUsername = 'truenas_username';
const String truenasPassword = 'truenas_password';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentialsAndProceed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        String urlToSave = _urlController.text.trim();

        // Ensure the URL ends with a trailing slash before saving
        if (!urlToSave.endsWith('/')) {
          urlToSave += '/';
        }

        await prefs.setString(truenasUrlKey, urlToSave);
        await prefs.setString(truenasUsername, _usernameController.text.trim());
        await prefs.setString(truenasPassword, _passwordController.text.trim());
        await prefs.setBool(isConfiguredKey, true); // isConfiguredKey from main.dart

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainDashboard(title: 'TrueNAS'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save credentials: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure TrueNAS Connection'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please enter your TrueNAS server details.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'TrueNAS URL',
                    hintText: 'e.g., http://192.168.1.100',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.http, color: theme.colorScheme.primary),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the TrueNAS URL';
                    }
                    final trimmedValue = value.trim();
                    final Uri? uri = Uri.tryParse(trimmedValue);

                    if (uri == null || uri.host.isEmpty) {
                      return 'Please enter a valid URL (e.g., http://server or https://server)';
                    }
                    if (!uri.isScheme('HTTP') && !uri.isScheme('HTTPS')) {
                      return 'URL must start with http:// or https://';
                    }
                    if (!uri.isAbsolute) {
                        return 'Please enter an absolute URL (e.g., http://server)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your TrueNAS Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Username';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your TrueNAS Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt_outlined),
                        label: const Text('Save and Connect'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: theme.textTheme.labelLarge,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )
                        ),
                        onPressed: _saveCredentialsAndProceed,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
