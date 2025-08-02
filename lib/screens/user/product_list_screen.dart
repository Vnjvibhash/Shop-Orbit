import 'package:flutter/material.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/screens/user/product_details_screen.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/common/product_filter_bar.dart';
import 'package:shoporbit/widgets/product_card.dart';

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
    _loadCategories().then((_) => _loadProducts());
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _firestoreService.getCategories();
      setState(() {
        categories = ['All', ...cats.map((c) => c.name)];
        selectedCategory =
            widget.category != null && categories.contains(widget.category!)
            ? widget.category!
            : 'All';
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => categories = ['All']);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final allProducts = await _firestoreService.getProducts();
      setState(() {
        products = allProducts.where((p) => p.isActive).toList();
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    List<ProductModel> tempProducts = products;

    if (selectedCategory != 'All') {
      tempProducts = tempProducts
          .where((p) => p.category == selectedCategory)
          .toList();
    }

    if (selectedCategory != 'All') {
      
    }

    if (searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        final q = searchQuery.toLowerCase();
        return product.name.toLowerCase().contains(q) ||
            product.description.toLowerCase().contains(q) ||
            product.category.toLowerCase().contains(q);
      }).toList();
    }

    filteredProducts = tempProducts;
    _applySorting();
  }

  void _applySorting() {
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

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      // Reset search
      searchQuery = '';
      _applyFilters();
    });
  }

  void _onStatusSelected(String status) {
    setState(() {
      selectedCategory = status;
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory == 'All' ? 'Products' : selectedCategory),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => sortBy = value);
              _applySorting();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ProductFilterBar(
            selectedCategory: selectedCategory,
            onCategorySelected: _onCategorySelected,
            categoryList: categories,
            selectedStatus: selectedCategory,
            onStatusSelected: _onStatusSelected,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadProducts();
                      setState(() {});
                    },
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
                                  textAlign: TextAlign.center,
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
