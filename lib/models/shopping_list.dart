/// Model representing a shopping list
class ShoppingList {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ShoppingList from JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    // Safely parse dates with fallback to current time
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value as String);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return ShoppingList(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  /// Convert ShoppingList to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ShoppingList copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
