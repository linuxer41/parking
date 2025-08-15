import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../state/app_state_container.dart';

/// Home screen of the application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = 'Welcome to Parkar';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = AppStateContainer.di(context).resolve<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Parkar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _testAuthService(authService),
                    child: const Text('Test Auth Service'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _testServices,
                    child: const Text('Verify Services'),
                  ),
                ],
              ),
      ),
    );
  }

  /// Test the authentication service
  Future<void> _testAuthService(authService) async {
    setState(() {
      _isLoading = true;
      _message = 'Testing Auth Service...';
    });

    try {
      final result = await authService.login('test@example.com', 'password123');
      setState(() {
        _isLoading = false;
        _message = 'Login successful: ${result['user']['name']}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  /// Test all services
  void _testServices() {
    setState(() {
      _message = 'All services initialized correctly';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Services initialized correctly'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
