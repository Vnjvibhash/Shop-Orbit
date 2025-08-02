import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/screens/admin/admin_dashboard.dart';
import 'package:shoporbit/screens/auth/login_screen.dart';
import 'package:shoporbit/screens/seller/seller_dashboard.dart';
import 'package:shoporbit/screens/seller/seller_pending_approval_screen.dart';
import 'package:shoporbit/screens/user/user_blocked_screen.dart';
import 'package:shoporbit/screens/user/user_home_screen.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';

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

        if (user.role == 'seller' && !user.isApproved) {
          return const SellerPendingApprovalScreen();
        }

        if (user.isBlocked) {
          return const UserBlockedScreen();
        }

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
