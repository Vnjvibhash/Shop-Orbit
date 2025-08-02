import 'package:flutter/material.dart';
import 'package:shoporbit/models/category_model.dart';
import 'package:shoporbit/screens/user/product_list_screen.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/category_card.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CategoryModel> categories = [];
  bool isLoading = true;
  String? error;

  String? selectedCategoryName;
  List<String> subcategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final cats = await _firestoreService.getCategories();
      setState(() {
        categories = cats.where((c) => c.isActive).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        categories = [];
        isLoading = false;
        error = 'Failed to load categories';
      });
    }
  }

  void _onCategoryTap(CategoryModel category) {
    setState(() {
      selectedCategoryName = category.name;
      subcategories = category.subcategories;
    });

    // Navigate directly to product list for that category if desired:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(category: category.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : categories.isEmpty
          ? const Center(child: Text('No categories found!'))
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories grid
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryItemWidget(
                            category: category,
                            index: index,
                            onTap: () => _onCategoryTap(category),
                          );
                        },
                      ),
                    ),

                    // Subcategory tags
                    if (selectedCategoryName != null &&
                        subcategories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subcategories of "$selectedCategoryName"',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: subcategories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final subcat = subcategories[index];
                                  final color =
                                      Colors.primaries[index %
                                          Colors.primaries.length];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      subcat,
                                      style: TextStyle(
                                        color: color.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
