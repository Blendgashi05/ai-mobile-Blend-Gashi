/// Enum for shopping item categories
enum Category {
  produce('produce', 'Produce', '🥬'),
  dairy('dairy', 'Dairy', '🥛'),
  meat('meat', 'Meat', '🥩'),
  bakery('bakery', 'Bakery', '🍞'),
  frozen('frozen', 'Frozen', '🧊'),
  beverages('beverages', 'Beverages', '🥤'),
  snacks('snacks', 'Snacks', '🍿'),
  household('household', 'Household', '🧹'),
  personalCare('personal_care', 'Personal Care', '🧴'),
  other('other', 'Other', '📦');

  final String value;
  final String label;
  final String emoji;

  const Category(this.value, this.label, this.emoji);

  /// Get category from string value
  static Category fromValue(String value) {
    return Category.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => Category.other,
    );
  }

  /// Get all categories as a list for dropdowns
  static List<Category> get all => Category.values;
}
