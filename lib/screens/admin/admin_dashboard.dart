import 'package:flutter/material.dart';
import 'package:shoporbit/screens/admin/all_orders_screen.dart';
import 'package:shoporbit/widgets/common/custom_app_bar.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/dashboard_card.dart';
import 'package:shoporbit/screens/admin/manage_users_screen.dart';
import 'package:shoporbit/screens/admin/manage_sellers_screen.dart';
import 'package:shoporbit/screens/admin/manage_categories_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> analytics = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await _firestoreService.getAnalytics();
      setState(() {
        analytics = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showLogout: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Overview',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ManageUsersScreen(),
                            ),
                          ),
                          child: DashboardCard(
                            title: 'Total Users',
                            value: analytics['totalUsers']?.toString() ?? '0',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ManageSellersScreen(),
                            ),
                          ),
                          child: DashboardCard(
                            title: 'Total Sellers',
                            value: analytics['totalSellers']?.toString() ?? '0',
                            icon: Icons.store,
                            color: Colors.green,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageCategoriesScreen(),
                            ),
                          ),
                          child: DashboardCard(
                            title: 'Total Products',
                            value:
                                analytics['totalProducts']?.toString() ?? '0',
                            icon: Icons.inventory,
                            color: Colors.orange,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AllOrdersScreen(),
                            ),
                          ),
                          child: DashboardCard(
                            title: 'Total Orders',
                            value: analytics['totalOrders']?.toString() ?? '0',
                            icon: Icons.shopping_bag,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Management',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildManagementItem(
                      context,
                      'Manage Users',
                      'View and manage user accounts',
                      Icons.people,
                      Colors.blue,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ManageUsersScreen(),
                        ),
                      ),
                    ),
                    _buildManagementItem(
                      context,
                      'Manage Sellers',
                      'Approve/reject sellers and view their products',
                      Icons.store,
                      Colors.green,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ManageSellersScreen(),
                        ),
                      ),
                    ),
                    _buildManagementItem(
                      context,
                      'Manage Categories',
                      'Add, edit, and organize product categories',
                      Icons.category,
                      Colors.orange,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen(),
                        ),
                      ),
                    ),
                    _buildManagementItem(
                      context,
                      'View All Orders',
                      'Monitor orders from all sellers',
                      Icons.shopping_bag,
                      Colors.purple,
                      () {
                        // Navigate to all orders screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All Orders screen not implemented yet')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildManagementItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}