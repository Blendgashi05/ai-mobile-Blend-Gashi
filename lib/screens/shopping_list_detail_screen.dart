import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_text_field.dart';

/// Screen showing items in a specific shopping list
class ShoppingListDetailScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({
    super.key,
    required this.shoppingList,
  });

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final _supabaseService = SupabaseService();
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  /// Load all items for this shopping list
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _supabaseService.fetchShoppingItems(widget.shoppingList.id);
      setState(() {
        _items = items;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Show dialog to add or edit an item
  Future<void> _showItemDialog({ShoppingItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController = TextEditingController(text: item?.quantity ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'New Item' : 'Edit Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Item Name',
                  prefixIcon: Icons.shopping_basket,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: quantityController,
                  label: 'Quantity (optional)',
                  prefixIcon: Icons.numbers,
                  hintText: 'e.g., 2, 1kg, 500ml',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: notesController,
                  label: 'Notes (optional)',
                  prefixIcon: Icons.note_outlined,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                if (item == null) {
                  await _supabaseService.createShoppingItem(
                    listId: widget.shoppingList.id,
                    name: nameController.text.trim(),
                    quantity: quantityController.text.trim().isEmpty
                        ? null
                        : quantityController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await _supabaseService.updateShoppingItem(
                    id: item.id,
                    name: nameController.text.trim(),
                    quantity: quantityController.text.trim().isEmpty
                        ? null
                        : quantityController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadItems();
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
            child: Text(item == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  /// Toggle item bought status
  Future<void> _toggleItemBought(ShoppingItem item) async {
    try {
      await _supabaseService.toggleItemBought(item.id, item.isBought);
      _loadItems();
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

  /// Delete an item with confirmation
  Future<void> _deleteItem(ShoppingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteShoppingItem(item.id);
        _loadItems();
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

  @override
  Widget build(BuildContext context) {
    // Separate items into bought and not bought
    final notBoughtItems = _items.where((item) => !item.isBought).toList();
    final boughtItems = _items.where((item) => item.isBought).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shoppingList.name),
            if (widget.shoppingList.description != null)
              Text(
                widget.shoppingList.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add items',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadItems,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Not bought items section
                          if (notBoughtItems.isNotEmpty) ...[
                            Text(
                              'TO BUY (${notBoughtItems.length})',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...notBoughtItems.map((item) => _buildItemCard(item)),
                          ],

                          // Bought items section
                          if (boughtItems.isNotEmpty) ...[
                            if (notBoughtItems.isNotEmpty) const SizedBox(height: 24),
                            Text(
                              'BOUGHT (${boughtItems.length})',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...boughtItems.map((item) => _buildItemCard(item)),
                          ],
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build an item card widget
  Widget _buildItemCard(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isBought,
          onChanged: (_) => _toggleItemBought(item),
          shape: const CircleBorder(),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
            color: item.isBought ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.quantity != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.numbers, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    item.quantity!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (item.notes != null) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.notes!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showItemDialog(item: item);
            } else if (value == 'delete') {
              _deleteItem(item);
            }
          },
        ),
      ),
    );
  }
}
