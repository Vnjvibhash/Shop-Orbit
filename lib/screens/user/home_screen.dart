import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/widgets/sections/category_section.dart';
import 'package:shoporbit/widgets/common/custom_app_bar.dart';
import 'package:shoporbit/models/category_model.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/sections/featured_products_section.dart';
import 'package:shoporbit/screens/user/product_list_screen.dart';
import 'package:shoporbit/screens/user/cart_screen.dart';
import 'package:shoporbit/screens/user/order_history_screen.dart';
import 'package:shoporbit/screens/user/wishlist_screen.dart';
import 'package:shoporbit/widgets/sections/welcome_section.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CategoryModel> categories = [];
  List<ProductModel> featuredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait([
        _firestoreService.getCategories(),
        _firestoreService.getProducts(),
      ]);
      final cats = results[0] as List<CategoryModel>;
      final products = results[1] as List<ProductModel>;

      setState(() {
        categories = cats;
        featuredProducts = products.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ShopOrbit',
        showCart: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'orders') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              } else if (value == 'cart') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              } else if (value == 'wishlist') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WishlistScreen(),
                  ),
                );
              } else if (value == 'logout') {
                context.read<AuthProvider>().signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'wishlist',
                child: Row(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(width: 8),
                    Text('Wish List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Order History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeSection(),
                    CategorySection(categories: categories),
                    FeaturedProductsSection(featuredProducts: featuredProducts),
                  ],
                ),
              ),
            ),
    );
  }
}
