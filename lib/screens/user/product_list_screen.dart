import 'package:flutter/material.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';
import 'package:shoporbit/widgets/product_card.dart';
import 'package:shoporbit/screens/user/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = '';
  String sortBy = 'name';
  List<String> categories = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories().then((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    try {
      final allProducts = await _firestoreService.getProducts();
      setState(() {
        products = allProducts.where((product) => product.isActive).toList();
        filteredProducts = (selectedCategory == 'All')
            ? products
            : products
                  .where((product) => product.category == selectedCategory)
                  .toList();
        isLoading = false;
      });
      _sortProducts();
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _firestoreService.getCategories();
      setState(() {
        categories = ['All', ...cats.map((c) => c.name)];
        selectedCategory = 'All';
      });
    } catch (e) {
      print('Error loading categories: $e');
      categories = ['All'];
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      List<ProductModel> baseList = selectedCategory == 'All'
          ? products
          : products.where((p) => p.category == selectedCategory).toList();
      if (query.isEmpty) {
        filteredProducts = baseList;
      } else {
        filteredProducts = baseList.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
    _sortProducts();
  }

  void _sortProducts() {
    setState(() {
      switch (sortBy) {
        case 'name':
          filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price_low':
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          filteredProducts.sort(
            (a, b) => b.averageRating.compareTo(a.averageRating),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? 'Products'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortBy = value;
              });
              _sortProducts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_low',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward),
                    SizedBox(width: 8),
                    Text('Price: Low to High'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward),
                    SizedBox(width: 8),
                    Text('Price: High to Low'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text('Sort by Rating'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _filterProducts('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No products found for "$searchQuery"'
                                      : 'No products available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or check back later',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(
                                            product: product,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
