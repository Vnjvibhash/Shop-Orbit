import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/screens/auth/auth_wrapper.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
      Future.delayed(const Duration(milliseconds: 3000)),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Shimmer(
              duration: const Duration(seconds: 3),
              interval: const Duration(seconds: 0),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              colorOpacity: 0.5,
              enabled: true,
              direction: ShimmerDirection.fromLTRB(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.3),
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.2),
              duration: const Duration(milliseconds: 3000),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', width: 120),
                  const SizedBox(height: 16),
                  Text(
                    'ShopOrbit\nMulti Role Shopping App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
