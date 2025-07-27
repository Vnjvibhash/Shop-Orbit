import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/theme.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/providers/cart_provider.dart';
import 'package:shoporbit/screens/auth/login_screen.dart';
import 'package:shoporbit/screens/user/cart_screen.dart';
import 'package:shoporbit/screens/admin/admin_dashboard.dart';
import 'package:shoporbit/screens/seller/seller_dashboard.dart';
import 'package:shoporbit/screens/user/user_home_screen.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (context, auth, previousCart) =>
              previousCart!..update(auth),
        ),
      ],
      child: MaterialApp(
        title: 'ShopOrbit - Multi-Role Shopping App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/cart': (context) => const CartScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const LoadingWidget();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final user = authProvider.currentUser;
        if (user == null) {
          return const LoginScreen();
        }

        // Check if seller is approved
        if (user.role == 'seller' && !user.isApproved) {
          return const SellerPendingApprovalScreen();
        }

        // Check if user is blocked
        if (user.isBlocked) {
          return const UserBlockedScreen();
        }

        // Navigate based on role
        switch (user.role) {
          case 'admin':
            return const AdminDashboard();
          case 'seller':
            return const SellerDashboard();
          case 'user':
          default:
            return const UserHomeScreen();
        }
      },
    );
  }
}

class SellerPendingApprovalScreen extends StatelessWidget {
  const SellerPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pending_actions, size: 80, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Your seller account is pending approval',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Please wait for admin approval to start selling',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserBlockedScreen extends StatelessWidget {
  const UserBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Blocked'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Your account has been blocked',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Please contact support for assistance',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
