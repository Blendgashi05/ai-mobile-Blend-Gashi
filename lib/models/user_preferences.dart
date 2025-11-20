import 'category.dart';

/// Model for user preferences and settings
class UserPreferences {
  final String id;
  final bool darkMode;
  final Category defaultCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.darkMode,
    required this.defaultCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserPreferences from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as String,
      darkMode: json['dark_mode'] as bool? ?? false,
      defaultCategory: Category.fromValue(json['default_category'] as String? ?? 'other'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserPreferences to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dark_mode': darkMode,
      'default_category': defaultCategory.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserPreferences copyWith({
    bool? darkMode,
    Category? defaultCategory,
  }) {
    return UserPreferences(
      id: id,
      darkMode: darkMode ?? this.darkMode,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
