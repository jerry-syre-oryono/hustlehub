// lib/features/search/presentation/widgets/search_filter_bar.dart
import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final double? maxBudget;
  final Function(double?) onMaxBudgetChanged;
  final bool nearbyOnly;
  final Function(bool) onNearbyChanged;

  const SearchFilterBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.maxBudget,
    required this.onMaxBudgetChanged,
    required this.nearbyOnly,
    required this.onNearbyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(selectedCategory ?? 'All Categories'),
            selected: selectedCategory != null,
            onSelected: (_) {
              // Show category picker dialog or similar
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(maxBudget == null ? 'Any Budget' : 'Up to KES ${maxBudget!.toInt()}'),
            selected: maxBudget != null,
            onSelected: (_) {
              // Show budget picker
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Nearby'),
            selected: nearbyOnly,
            onSelected: onNearbyChanged,
          ),
        ],
      ),
    );
  }
}
