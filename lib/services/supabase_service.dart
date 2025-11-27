import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/category.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../models/purchase_history.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

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
    Category? category,
    double? price,
  }) async {
    try {
      final response = await _client.from('shopping_items').insert({
        'list_id': listId,
        'name': name,
        'quantity': quantity,
        'notes': notes,
        'category': category?.value ?? 'other',
        'price': price,
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
    Category? category,
    double? price,
    bool? isBought,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (quantity != null) updateData['quantity'] = quantity;
      if (notes != null) updateData['notes'] = notes;
      if (category != null) updateData['category'] = category.value;
      if (price != null) updateData['price'] = price;
      if (isBought != null) updateData['is_bought'] = isBought;

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

  // ============================================
  // User Profile Operations
  // ============================================

  /// Get or create user profile
  Future<UserProfile> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserProfile.fromJson(response);
      }

      final newProfile = await _client.from('user_profiles').insert({
        'id': user.id,
      }).select().single();

      return UserProfile.fromJson(newProfile);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['display_name'] = displayName;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Convert profile photo to Base64 and store in database (no storage bucket needed)
  Future<String> uploadProfilePhoto(Uint8List fileBytes, String fileName) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      // Determine mime type from file extension
      String mimeType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      // Convert to Base64 data URL directly (no resizing on web for compatibility)
      final base64String = base64Encode(fileBytes);
      final dataUrl = 'data:$mimeType;base64,$base64String';

      return dataUrl;
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  // ============================================
  // User Preferences Operations
  // ============================================

  /// Get or create user preferences
  Future<UserPreferences> getUserPreferences() async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_preferences')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserPreferences.fromJson(response);
      }

      final newPrefs = await _client.from('user_preferences').insert({
        'id': user.id,
        'dark_mode': false,
        'default_category': 'other',
      }).select().single();

      return UserPreferences.fromJson(newPrefs);
    } catch (e) {
      throw Exception('Failed to get user preferences: ${e.toString()}');
    }
  }

  /// Update user preferences
  Future<UserPreferences> updateUserPreferences({
    bool? darkMode,
    Category? defaultCategory,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (darkMode != null) updateData['dark_mode'] = darkMode;
      if (defaultCategory != null) updateData['default_category'] = defaultCategory.value;

      final response = await _client
          .from('user_preferences')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserPreferences.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }

  // ============================================
  // Purchase History & Analytics Operations
  // ============================================

  /// Fetch purchase history for the current user
  Future<List<PurchaseHistory>> fetchPurchaseHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      dynamic query = _client
          .from('purchase_history')
          .select()
          .eq('user_id', user.id);

      if (startDate != null) {
        query = query.gte('bought_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('bought_at', endDate.toIso8601String());
      }

      query = query.order('bought_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => PurchaseHistory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch purchase history: ${e.toString()}');
    }
  }

  /// Get most frequently bought items
  Future<List<Map<String, dynamic>>> getMostBoughtItems({int limit = 10}) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final listIds = await _client
          .from('shopping_lists')
          .select('id')
          .eq('user_id', user.id);

      final ids = (listIds as List).map((item) => item['id'] as String).toList();

      if (ids.isEmpty) {
        return [];
      }

      final response = await _client
          .from('shopping_items')
          .select('id, name, category, bought_count')
          .inFilter('list_id', ids)
          .gt('bought_count', 0)
          .order('bought_count', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get most bought items: ${e.toString()}');
    }
  }

  /// Get category spending breakdown
  Future<Map<String, double>> getCategorySpending() async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('purchase_history')
          .select('category, price')
          .eq('user_id', user.id)
          .not('price', 'is', null);

      final categoryTotals = <String, double>{};
      
      for (final item in response as List) {
        final category = item['category'] as String? ?? 'other';
        final price = double.parse(item['price'].toString());
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + price;
      }

      return categoryTotals;
    } catch (e) {
      throw Exception('Failed to get category spending: ${e.toString()}');
    }
  }
}
