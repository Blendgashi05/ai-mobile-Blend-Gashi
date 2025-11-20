import 'category.dart';

/// Model representing an item in a shopping list
class ShoppingItem {
  final String id;
  final String listId;
  final String name;
  final String? quantity;
  final String? notes;
  final Category category;
  final double? price;
  final bool isBought;
  final int boughtCount;
  final DateTime? lastBoughtAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity,
    this.notes,
    this.category = Category.other,
    this.price,
    this.isBought = false,
    this.boughtCount = 0,
    this.lastBoughtAt,
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
      category: Category.fromValue(json['category'] as String? ?? 'other'),
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      isBought: json['is_bought'] as bool? ?? false,
      boughtCount: json['bought_count'] as int? ?? 0,
      lastBoughtAt: json['last_bought_at'] != null 
          ? DateTime.parse(json['last_bought_at'] as String)
          : null,
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
      'category': category.value,
      'price': price,
      'is_bought': isBought,
      'bought_count': boughtCount,
      'last_bought_at': lastBoughtAt?.toIso8601String(),
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
    Category? category,
    double? price,
    bool? isBought,
    int? boughtCount,
    DateTime? lastBoughtAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      price: price ?? this.price,
      isBought: isBought ?? this.isBought,
      boughtCount: boughtCount ?? this.boughtCount,
      lastBoughtAt: lastBoughtAt ?? this.lastBoughtAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
