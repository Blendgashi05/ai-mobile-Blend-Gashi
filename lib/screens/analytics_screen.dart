import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/supabase_service.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<ShoppingList> _shoppingLists = [];
  final Map<String, List<ShoppingItem>> _itemsByList = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
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

  List<ShoppingItem> get _allItems {
    List<ShoppingItem> items = [];
    for (var itemList in _itemsByList.values) {
      items.addAll(itemList);
    }
    return items;
  }

  int get _totalItems => _allItems.length;
  
  int get _completedItems => _allItems.where((item) => item.isBought).length;
  
  double get _completionRate {
    if (_totalItems == 0) return 0;
    return (_completedItems / _totalItems) * 100;
  }

  Map<String, int> get _itemFrequency {
    final Map<String, int> frequency = {};
    for (var item in _allItems) {
      final name = item.name.toLowerCase().trim();
      frequency[name] = (frequency[name] ?? 0) + 1;
    }
    return frequency;
  }

  List<MapEntry<String, int>> get _topItems {
    final entries = _itemFrequency.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(10).toList();
  }

  Map<String, int> get _listsPerMonth {
    final Map<String, int> monthly = {};
    for (var list in _shoppingLists) {
      try {
        final monthKey = DateFormat('MMM yyyy').format(list.createdAt);
        monthly[monthKey] = (monthly[monthKey] ?? 0) + 1;
      } catch (e) {
        // Skip lists with invalid dates
        continue;
      }
    }
    return monthly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1425), Color(0xFF1a1f3a)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF8B5CF6),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights,
                              color: Color(0xFF8B5CF6),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Insights',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your shopping patterns and trends',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Overall Stats
                        _buildGlassCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_graph,
                                    color: Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Overall Statistics',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMiniStat(
                                      label: 'Total Lists',
                                      value: _shoppingLists.length.toString(),
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMiniStat(
                                      label: 'Total Items',
                                      value: _totalItems.toString(),
                                      color: const Color(0xFFE91E63),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMiniStat(
                                      label: 'Completion',
                                      value: '${_completionRate.toStringAsFixed(0)}%',
                                      color: const Color(0xFF27E8A7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Shopping Activity Timeline
                        if (_listsPerMonth.isNotEmpty) ...[
                          _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFFE91E63)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Shopping Activity',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ..._listsPerMonth.entries.take(6).map((entry) {
                                  final maxCount = _listsPerMonth.values.reduce((a, b) => a > b ? a : b);
                                  final percentage = entry.value / maxCount;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${entry.value} lists',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor: percentage,
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [Color(0xFF8B5CF6), Color(0xFFE91E63)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Most Frequent Items
                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.star, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Most Purchased Items',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (_topItems.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.shopping_basket_outlined,
                                          size: 48,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No items yet\nStart adding items to see insights!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ..._topItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final isTopThree = index < 3;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isTopThree
                                          ? const Color(0xFFFFD700).withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isTopThree
                                            ? const Color(0xFFFFD700).withOpacity(0.3)
                                            : Colors.white.withOpacity(0.1),
                                        width: isTopThree ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isTopThree
                                                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                                  : [const Color(0xFF8B5CF6), const Color(0xFFE91E63)],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: isTopThree
                                                ? Icon(
                                                    index == 0 ? Icons.emoji_events : Icons.workspace_premium,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )
                                                : Text(
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.key.capitalize(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Added ${item.value} ${item.value == 1 ? "time" : "times"}',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isTopThree)
                                          Icon(
                                            Icons.trending_up,
                                            color: const Color(0xFFFFD700),
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
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
