import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class CategoryRow extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int>? onCategorySelected; // Optional

  const CategoryRow({
    super.key,
    required this.categories,
    this.onCategorySelected, // Use only when needed
  });

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.categories.length, (index) {
          final category = widget.categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 0),
            child: CategoryButton(
              text: category['text'],
              icon: category['icon'],
              isFilled: category['isFilled'],
              isSelected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                // Only call if defined (TravelPage only)
                if (widget.onCategorySelected != null) {
                  widget.onCategorySelected!(index);
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
