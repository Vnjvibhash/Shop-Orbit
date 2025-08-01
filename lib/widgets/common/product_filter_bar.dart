import 'package:flutter/material.dart';

class ProductFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final void Function(String) onCategorySelected;

  final List<String> statusList;
  final String selectedStatus;
  final void Function(String) onStatusSelected;

  const ProductFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.statusList,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Category dropdown ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) {
              if (value != null) onCategorySelected(value);
            },
          ),
        ),
        // --- Status (if desired: e.g., "All", "In Stock", "Out of Stock") ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: statusList.map((status) {
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
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
