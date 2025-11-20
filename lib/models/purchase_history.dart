import 'category.dart';

/// Model for purchase history analytics
class PurchaseHistory {
  final String id;
  final String userId;
  final String? itemId;
  final String itemName;
  final Category? category;
  final double? price;
  final String? quantity;
  final DateTime boughtAt;
  final String? listName;

  PurchaseHistory({
    required this.id,
    required this.userId,
    this.itemId,
    required this.itemName,
    this.category,
    this.price,
    this.quantity,
    required this.boughtAt,
    this.listName,
  });

  /// Create PurchaseHistory from JSON
  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemId: json['item_id'] as String?,
      itemName: json['item_name'] as String,
      category: json['category'] != null 
          ? Category.fromValue(json['category'] as String)
          : null,
      price: json['price'] != null 
          ? double.parse(json['price'].toString())
          : null,
      quantity: json['quantity'] as String?,
      boughtAt: DateTime.parse(json['bought_at'] as String),
      listName: json['list_name'] as String?,
    );
  }

  /// Convert PurchaseHistory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'item_name': itemName,
      'category': category?.value,
      'price': price,
      'quantity': quantity,
      'bought_at': boughtAt.toIso8601String(),
      'list_name': listName,
    };
  }
}
