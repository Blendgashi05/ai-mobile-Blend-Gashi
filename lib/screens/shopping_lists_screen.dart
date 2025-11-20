import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'shopping_list_detail_screen.dart';
import 'login_screen.dart';

/// Screen displaying all shopping lists with dashboard stats
class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  final _supabaseService = SupabaseService();
  List<ShoppingList> _shoppingLists = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalItems = 0;
  int _completedItems = 0;

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
  }

  /// Load all shopping lists and calculate stats
  Future<void> _loadShoppingLists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lists = await _supabaseService.fetchShoppingLists();
      
      // Calculate total and completed items across all lists
      int total = 0;
      int completed = 0;
      
      for (var list in lists) {
        final items = await _supabaseService.fetchShoppingItems(list.id);
        total += items.length;
        completed += items.where((item) => item.isBought).length;
      }
      
      setState(() {
        _shoppingLists = lists;
        _totalItems = total;
        _completedItems = completed;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show dialog to create or edit a shopping list
  Future<void> _showListDialog({ShoppingList? list}) async {
    final nameController = TextEditingController(text: list?.name ?? '');
    final descController = TextEditingController(text: list?.description ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111936).withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFF27E8A7).withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                list == null ? Icons.add_shopping_cart : Icons.edit,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              list == null ? 'New Shopping List' : 'Edit Shopping List',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'List Name',
                prefixIcon: Icons.list_alt,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description (optional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF27E8A7)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  if (list == null) {
                    await _supabaseService.createShoppingList(
                      name: nameController.text.trim(),
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                    );
                  } else {
                    await _supabaseService.updateShoppingList(
                      id: list.id,
                      name: nameController.text.trim(),
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadShoppingLists();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                list == null ? 'Create' : 'Update',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Delete a shopping list with confirmation
  Future<void> _deleteList(ShoppingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111936).withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete List', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${list.name}"?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF27E8A7)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteShoppingList(list.id);
        _loadShoppingLists();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111936).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = _totalItems > 0 
        ? (_completedItems / _totalItems * 100).toStringAsFixed(0) 
        : '0';
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF27E8A7)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadShoppingLists,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadShoppingLists,
                  color: const Color(0xFF27E8A7),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF27E8A7).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.dashboard_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Manage your shopping lists',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF27E8A7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Stats Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildStatsCard(
                              'Total Lists',
                              '${_shoppingLists.length}',
                              Icons.list_alt_rounded,
                              const Color(0xFF27E8A7),
                            ),
                            _buildStatsCard(
                              'Total Items',
                              '$_totalItems',
                              Icons.shopping_cart_rounded,
                              const Color(0xFF8B5CF6),
                            ),
                            _buildStatsCard(
                              'Completed',
                              '$_completedItems',
                              Icons.check_circle_rounded,
                              const Color(0xFF22D3EE),
                            ),
                            _buildStatsCard(
                              'Progress',
                              '$completionRate%',
                              Icons.trending_up_rounded,
                              const Color(0xFFEC4899),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Lists Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Shopping Lists',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27E8A7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF27E8A7).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${_shoppingLists.length} ${_shoppingLists.length == 1 ? 'list' : 'lists'}',
                                style: const TextStyle(
                                  color: Color(0xFF27E8A7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Shopping Lists
                        _shoppingLists.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111936).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF27E8A7).withOpacity(0.2),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF27E8A7).withOpacity(0.2),
                                            const Color(0xFF8B5CF6).withOpacity(0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 60,
                                        color: Color(0xFF27E8A7),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'No shopping lists yet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap the + button to create your first list',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _shoppingLists.length,
                                itemBuilder: (context, index) {
                                  final list = _shoppingLists[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF111936).withOpacity(0.6),
                                          const Color(0xFF111936).withOpacity(0.4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF27E8A7).withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF27E8A7).withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ShoppingListDetailScreen(
                                                shoppingList: list,
                                              ),
                                            ),
                                          ).then((_) => _loadShoppingLists());
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: const Icon(
                                                  Icons.list_alt_rounded,
                                                  color: Colors.white,
                                                  size: 28,
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
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    if (list.description != null) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        list.description!,
                                                        style: TextStyle(
                                                          color: Colors.grey[400],
                                                          fontSize: 13,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: const Icon(
                                                  Icons.more_vert_rounded,
                                                  color: Color(0xFF27E8A7),
                                                ),
                                                color: const Color(0xFF111936),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  side: BorderSide(
                                                    color: const Color(0xFF27E8A7).withOpacity(0.3),
                                                  ),
                                                ),
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, size: 20, color: Color(0xFF27E8A7)),
                                                        SizedBox(width: 12),
                                                        Text('Edit', style: TextStyle(color: Colors.white)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                                        SizedBox(width: 12),
                                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showListDialog(list: list);
                                                  } else if (value == 'delete') {
                                                    _deleteList(list);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF27E8A7), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF27E8A7).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showListDialog(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}
