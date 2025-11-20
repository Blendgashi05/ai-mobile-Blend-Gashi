import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/supabase_service.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import 'shopping_lists_screen.dart';
import 'shopping_list_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<ShoppingList> _shoppingLists = [];
  final Map<String, List<ShoppingItem>> _itemsByList = {};
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get user email for greeting
      final user = _supabaseService.getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.email?.split('@')[0].capitalize() ?? 'User';
        });
      }

      final lists = await _supabaseService.fetchShoppingLists();
      
      // Fetch all items in parallel for better performance
      final itemFutures = lists.map((list) async {
        try {
          final items = await _supabaseService.fetchShoppingItems(list.id);
          return MapEntry(list.id, items);
        } catch (e) {
          return MapEntry(list.id, <ShoppingItem>[]);
        }
      });
      
      final itemEntries = await Future.wait(itemFutures);
      final Map<String, List<ShoppingItem>> itemsMap = Map.fromEntries(itemEntries);
      
      setState(() {
        _shoppingLists = lists;
        _itemsByList.clear();
        _itemsByList.addAll(itemsMap);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  List<ShoppingList> get _activeLists {
    return _shoppingLists.where((list) {
      final items = _itemsByList[list.id] ?? [];
      return items.any((item) => !item.isBought);
    }).toList();
  }

  int get _totalActiveItems {
    int count = 0;
    for (var list in _activeLists) {
      final items = _itemsByList[list.id] ?? [];
      count += items.where((item) => !item.isBought).length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F2A), Color(0xFF1a1f3a)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF27E8A7),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27E8A7)),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting Header
                        Text(
                          '$greeting,',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                          ).createShader(bounds),
                          child: Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.add_shopping_cart,
                                label: 'New List',
                                gradient: const [Color(0xFF27E8A7), Color(0xFF20B88A)],
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ShoppingListsScreen(),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.list_alt,
                                label: 'All Lists',
                                gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ShoppingListsScreen(),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Today's Focus
                        if (_activeLists.isEmpty)
                          _buildEmptyState()
                        else ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.today,
                                color: Color(0xFF27E8A7),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Active Shopping Lists',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_totalActiveItems items',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Active Lists
                          ..._activeLists.map((list) {
                            final items = _itemsByList[list.id] ?? [];
                            final pendingItems = items.where((item) => !item.isBought).toList();
                            
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShoppingListDetailScreen(shoppingList: list),
                                  ),
                                );
                                _loadData();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111936).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF27E8A7).withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.shopping_bag,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    list.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${pendingItems.length} items to buy',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Color(0xFF27E8A7),
                                              size: 28,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Show first 3 pending items
                                        ...pendingItems.take(3).map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                        if (pendingItems.length > 3)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '+${pendingItems.length - 3} more items',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF111936).withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Lists',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first shopping list\nand start organizing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
