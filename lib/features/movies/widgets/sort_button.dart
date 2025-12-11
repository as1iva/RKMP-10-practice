import 'package:flutter/material.dart';

import 'package:movie_catalog/features/movies/models/sort_option.dart';

class SortButton extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortButton({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Сортировка',
      initialValue: currentSort,
      onSelected: onSortChanged,
      itemBuilder: (context) => SortOption.values.map((option) {
        return PopupMenuItem<SortOption>(
          value: option,
          child: Row(
            children: [
              if (option == currentSort)
                const Icon(Icons.check, size: 18, color: Colors.blue)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(option.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}
