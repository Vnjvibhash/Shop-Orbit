import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/main.dart'; // To access AuthWrapper
import 'package:shoporbit/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.microtask(() {});

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.wait([
      _waitForAuthProvider(authProvider),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }
  
  Future<void> _waitForAuthProvider(AuthProvider provider) async {
    while (provider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120),
            const SizedBox(height: 16),
            Text(
              'ShopOrbit\nMulti Role Shopping App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
