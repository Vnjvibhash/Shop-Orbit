import 'package:flutter/material.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/screens/user/product_list_screen.dart';
import 'package:shoporbit/screens/user/product_details_screen.dart';
import 'package:shoporbit/widgets/product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  final List<ProductModel> featuredProducts;
  const FeaturedProductsSection({required this.featuredProducts, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProductListScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        if (featuredProducts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No products available'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
