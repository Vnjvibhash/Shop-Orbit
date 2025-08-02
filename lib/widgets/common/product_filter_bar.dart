import 'package:flutter/material.dart';

class ProductFilterBar extends StatelessWidget {
  final String selectedCategory;
  final void Function(String) onCategorySelected;

  final List<String> categoryList;
  final String selectedStatus;
  final void Function(String) onStatusSelected;

  const ProductFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categoryList,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categoryList.map((status) {
          final isSelected = status == selectedStatus;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status[0].toUpperCase() + status.substring(1)),
              selected: isSelected,
              onSelected: (_) => onStatusSelected(status),
            ),
          );
        }).toList(),
      ),
    );
  }
}
