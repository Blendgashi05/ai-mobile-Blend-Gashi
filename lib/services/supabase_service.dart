import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

/// Service for all Supabase database operations
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ============================================
  // Authentication Methods
  // ============================================

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in an existing user with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Get the current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================
  // Shopping List CRUD Operations
  // ============================================

  /// Fetch all shopping lists for the current user
  Future<List<ShoppingList>> fetchShoppingLists() async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('shopping_lists')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ShoppingList.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch shopping lists: ${e.toString()}');
    }
  }

  /// Create a new shopping list
  Future<ShoppingList> createShoppingList({
    required String name,
    String? description,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('shopping_lists').insert({
        'user_id': user.id,
        'name': name,
        'description': description,
      }).select().single();

      return ShoppingList.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create shopping list: ${e.toString()}');
    }
  }

  /// Update an existing shopping list
  Future<ShoppingList> updateShoppingList({
    required String id,
    String? name,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('shopping_lists')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return ShoppingList.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update shopping list: ${e.toString()}');
    }
  }

  /// Delete a shopping list
  Future<void> deleteShoppingList(String id) async {
    try {
      await _client.from('shopping_lists').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete shopping list: ${e.toString()}');
    }
  }

  // ============================================
  // Shopping Item CRUD Operations
  // ============================================

  /// Fetch all items for a specific shopping list
  Future<List<ShoppingItem>> fetchShoppingItems(String listId) async {
    try {
      final response = await _client
          .from('shopping_items')
          .select()
          .eq('list_id', listId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ShoppingItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch shopping items: ${e.toString()}');
    }
  }

  /// Create a new shopping item
  Future<ShoppingItem> createShoppingItem({
    required String listId,
    required String name,
    String? quantity,
    String? notes,
  }) async {
    try {
      final response = await _client.from('shopping_items').insert({
        'list_id': listId,
        'name': name,
        'quantity': quantity,
        'notes': notes,
        'is_bought': false,
      }).select().single();

      return ShoppingItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create shopping item: ${e.toString()}');
    }
  }

  /// Update an existing shopping item
  Future<ShoppingItem> updateShoppingItem({
    required String id,
    String? name,
    String? quantity,
    String? notes,
    bool? isBought,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (quantity != null) updateData['quantity'] = quantity;
      if (notes != null) updateData['notes'] = notes;
      if (isBought != null) updateData['is_bought'] = isBought;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('shopping_items')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return ShoppingItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update shopping item: ${e.toString()}');
    }
  }

  /// Toggle the bought status of a shopping item
  Future<ShoppingItem> toggleItemBought(String id, bool currentStatus) async {
    return updateShoppingItem(id: id, isBought: !currentStatus);
  }

  /// Delete a shopping item
  Future<void> deleteShoppingItem(String id) async {
    try {
      await _client.from('shopping_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete shopping item: ${e.toString()}');
    }
  }
}
