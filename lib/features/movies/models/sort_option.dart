enum SortOption {
  dateAddedNewest,
  dateAddedOldest,
  titleAZ,
  titleZA,
  ratingHighLow,
  ratingLowHigh,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dateAddedNewest:
        return 'Новые сверху';
      case SortOption.dateAddedOldest:
        return 'Старые сверху';
      case SortOption.titleAZ:
        return 'Название (А–Я)';
      case SortOption.titleZA:
        return 'Название (Я–А)';
      case SortOption.ratingHighLow:
        return 'Рейтинг ↓';
      case SortOption.ratingLowHigh:
        return 'Рейтинг ↑';
    }
  }
}
