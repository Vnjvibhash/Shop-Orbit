import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/widgets/common/custom_app_bar.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/cards/dashboard_card.dart';
import 'package:shoporbit/screens/seller/seller_products_screen.dart';
import 'package:shoporbit/screens/seller/seller_orders_screen.dart';
import 'package:shoporbit/screens/seller/add_product_screen.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/models/order_model.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProductModel> products = [];
  List<OrderModel> orders = [];
  bool isLoading = true;
  double totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sellerId = authProvider.currentUser?.id;
      
      if (sellerId != null) {
        final results = await Future.wait([
          _firestoreService.getProducts(sellerId: sellerId),
          _firestoreService.getOrders(sellerId: sellerId),
        ]);
        final sellerProducts = results[0] as List<ProductModel>;
        final sellerOrders = results[1] as List<OrderModel>;
        
        setState(() {
          products = sellerProducts;
          orders = sellerOrders;
          totalEarnings = orders
              .where((order) => order.status == 'delivered')
              .fold(0.0, (sum, order) => sum + order.totalAmount);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading seller data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Seller Dashboard',
        showLogout: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSellerData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.store,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${authProvider.currentUser?.name ?? 'Seller'}!',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Manage your store and products',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
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
                        DashboardCard(
                          title: 'Total Products',
                          value: products.length.toString(),
                          icon: Icons.inventory,
                          color: Colors.blue,
                        ),
                        DashboardCard(
                          title: 'Total Orders',
                          value: orders.length.toString(),
                          icon: Icons.shopping_bag,
                          color: Colors.green,
                        ),
                        DashboardCard(
                          title: 'Pending Orders',
                          value: orders.where((order) => order.status == 'pending').length.toString(),
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        DashboardCard(
                          title: 'Total Earnings',
                          value: '\$${totalEarnings.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildActionItem(
                      context,
                      'Add New Product',
                      'Add products to your store',
                      Icons.add_box,
                      Colors.green,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      ),
                    ),
                    _buildActionItem(
                      context,
                      'Manage Products',
                      'View and edit your products',
                      Icons.inventory,
                      Colors.blue,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SellerProductsScreen(),
                        ),
                      ),
                    ),
                    _buildActionItem(
                      context,
                      'Manage Orders',
                      'View and process customer orders',
                      Icons.shopping_bag,
                      Colors.orange,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SellerOrdersScreen(),
                        ),
                      ),
                    ),
                    _buildActionItem(
                      context,
                      'View Earnings',
                      'Track your sales and earnings',
                      Icons.attach_money,
                      Colors.purple,
                      () {
                        _showEarningsDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionItem(
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

  void _showEarningsDialog() {
    final pendingEarnings = orders
        .where((order) => order.status != 'delivered' && order.status != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.totalAmount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earnings Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Earnings: \$${totalEarnings.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Pending Earnings: \$${pendingEarnings.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Total Orders: ${orders.length}'),
            const SizedBox(height: 8),
            Text('Completed Orders: ${orders.where((order) => order.status == 'delivered').length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}