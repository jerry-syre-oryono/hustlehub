import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final double? maxBudget;
  final Function(double?) onMaxBudgetChanged;

  const SearchFilterBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.maxBudget,
    required this.onMaxBudgetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            selectedCategory ?? 'All Categories',
            selectedCategory != null,
            Icons.category_outlined,
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            context,
            maxBudget == null ? 'Any Budget' : 'Up to KES ${maxBudget!.toInt()}',
            maxBudget != null,
            Icons.payments_outlined,
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            context,
            'Top Rated',
            false,
            Icons.star_outline_rounded,
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            context,
            'Near Me',
            false,
            Icons.near_me_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
