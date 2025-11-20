/// Model representing an item in a shopping list
class ShoppingItem {
  final String id;
  final String listId;
  final String name;
  final String? quantity;
  final String? notes;
  final bool isBought;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity,
    this.notes,
    this.isBought = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ShoppingItem from JSON
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      notes: json['notes'] as String?,
      isBought: json['is_bought'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert ShoppingItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'name': name,
      'quantity': quantity,
      'notes': notes,
      'is_bought': isBought,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ShoppingItem copyWith({
    String? id,
    String? listId,
    String? name,
    String? quantity,
    String? notes,
    bool? isBought,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isBought: isBought ?? this.isBought,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
