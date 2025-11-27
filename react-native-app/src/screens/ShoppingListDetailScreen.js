import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
  Alert,
  TextInput,
  Modal,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { GlassCard, CustomButton } from '../components';
import { colors, typography, spacing, borderRadius } from '../theme';
import { supabaseService } from '../services/supabaseService';

export const ShoppingListDetailScreen = ({ navigation, route }) => {
  const { listId, listName } = route.params;
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [items, setItems] = useState([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [newItemName, setNewItemName] = useState('');
  const [newItemQuantity, setNewItemQuantity] = useState('1');
  const [creating, setCreating] = useState(false);

  const loadItems = useCallback(async () => {
    try {
      const itemsData = await supabaseService.getShoppingItems(listId);
      setItems(itemsData);
    } catch (error) {
      console.error('Error loading items:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [listId]);

  useEffect(() => {
    loadItems();
  }, [loadItems]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    loadItems();
  }, [loadItems]);

  const handleAddItem = async () => {
    if (!newItemName.trim()) {
      Alert.alert('Error', 'Please enter an item name');
      return;
    }

    setCreating(true);
    try {
      await supabaseService.createShoppingItem(
        listId, 
        newItemName.trim(), 
        parseInt(newItemQuantity) || 1
      );
      setNewItemName('');
      setNewItemQuantity('1');
      setModalVisible(false);
      loadItems();
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to add item');
    } finally {
      setCreating(false);
    }
  };

  const handleToggleItem = async (item) => {
    try {
      await supabaseService.toggleItemBought(item.id, !item.is_bought);
      setItems(prev => prev.map(i => 
        i.id === item.id ? { ...i, is_bought: !i.is_bought } : i
      ));
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to update item');
    }
  };

  const handleDeleteItem = (item) => {
    Alert.alert(
      'Delete Item',
      `Are you sure you want to delete "${item.name}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await supabaseService.deleteShoppingItem(item.id);
              loadItems();
            } catch (error) {
              Alert.alert('Error', error.message || 'Failed to delete item');
            }
          },
        },
      ]
    );
  };

  const completedCount = items.filter(item => item.is_bought).length;
  const progress = items.length > 0 ? Math.round((completedCount / items.length) * 100) : 0;

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.emeraldGlow} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="arrow-back" size={24} color={colors.emeraldGlow} />
        </TouchableOpacity>
        <Text style={styles.headerTitle} numberOfLines={1}>{listName}</Text>
        <TouchableOpacity 
          style={styles.addButton}
          onPress={() => setModalVisible(true)}
        >
          <LinearGradient
            colors={colors.gradients.emeraldPurple}
            style={styles.addButtonGradient}
          >
            <Ionicons name="add" size={24} color={colors.white} />
          </LinearGradient>
        </TouchableOpacity>
      </View>

      <View style={styles.progressSection}>
        <View style={styles.progressInfo}>
          <Text style={styles.progressText}>{completedCount} of {items.length} items</Text>
          <Text style={styles.progressPercent}>{progress}%</Text>
        </View>
        <View style={styles.progressBar}>
          <LinearGradient
            colors={colors.gradients.emeraldPurple}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={[styles.progressFill, { width: `${progress}%` }]}
          />
        </View>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.emeraldGlow}
          />
        }
      >
        {items.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Ionicons name="basket-outline" size={64} color={colors.textMuted} />
            <Text style={styles.emptyText}>No items in this list</Text>
            <Text style={styles.emptySubtext}>
              Tap the + button to add items
            </Text>
          </GlassCard>
        ) : (
          <>
            {items.filter(item => !item.is_bought).map((item) => (
              <TouchableOpacity
                key={item.id}
                onPress={() => handleToggleItem(item)}
                onLongPress={() => handleDeleteItem(item)}
              >
                <GlassCard style={styles.itemCard}>
                  <View style={styles.itemContent}>
                    <View style={styles.checkbox}>
                      <Ionicons 
                        name="square-outline" 
                        size={24} 
                        color={colors.emeraldGlow} 
                      />
                    </View>
                    <View style={styles.itemInfo}>
                      <Text style={styles.itemName}>{item.name}</Text>
                      <Text style={styles.itemQuantity}>Qty: {item.quantity}</Text>
                    </View>
                  </View>
                </GlassCard>
              </TouchableOpacity>
            ))}

            {items.some(item => item.is_bought) && (
              <>
                <Text style={styles.sectionLabel}>Completed</Text>
                {items.filter(item => item.is_bought).map((item) => (
                  <TouchableOpacity
                    key={item.id}
                    onPress={() => handleToggleItem(item)}
                    onLongPress={() => handleDeleteItem(item)}
                  >
                    <GlassCard style={[styles.itemCard, styles.itemCardCompleted]}>
                      <View style={styles.itemContent}>
                        <View style={[styles.checkbox, styles.checkboxCompleted]}>
                          <Ionicons 
                            name="checkmark-circle" 
                            size={24} 
                            color={colors.emeraldGlow} 
                          />
                        </View>
                        <View style={styles.itemInfo}>
                          <Text style={[styles.itemName, styles.itemNameCompleted]}>
                            {item.name}
                          </Text>
                          <Text style={styles.itemQuantity}>Qty: {item.quantity}</Text>
                        </View>
                      </View>
                    </GlassCard>
                  </TouchableOpacity>
                ))}
              </>
            )}
          </>
        )}
      </ScrollView>

      <Modal
        visible={modalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <GlassCard style={styles.modalContent}>
            <Text style={styles.modalTitle}>Add Item</Text>
            <TextInput
              style={styles.modalInput}
              value={newItemName}
              onChangeText={setNewItemName}
              placeholder="Item name"
              placeholderTextColor={colors.textMuted}
              autoFocus
            />
            <TextInput
              style={styles.modalInput}
              value={newItemQuantity}
              onChangeText={setNewItemQuantity}
              placeholder="Quantity"
              placeholderTextColor={colors.textMuted}
              keyboardType="numeric"
            />
            <View style={styles.modalButtons}>
              <TouchableOpacity 
                style={styles.modalCancelButton}
                onPress={() => {
                  setNewItemName('');
                  setNewItemQuantity('1');
                  setModalVisible(false);
                }}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </TouchableOpacity>
              <CustomButton
                title="Add"
                onPress={handleAddItem}
                loading={creating}
                style={styles.modalCreateButton}
              />
            </View>
          </GlassCard>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.deepSpace,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.deepSpace,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.xl,
    paddingBottom: spacing.md,
  },
  backButton: {
    padding: spacing.sm,
    backgroundColor: colors.glass,
    borderRadius: borderRadius.md,
  },
  headerTitle: {
    flex: 1,
    fontSize: typography.sizes.xl,
    color: colors.white,
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
    textAlign: 'center',
    marginHorizontal: spacing.md,
  },
  addButton: {
    borderRadius: 20,
    overflow: 'hidden',
  },
  addButtonGradient: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  progressSection: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.lg,
  },
  progressInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.xs,
  },
  progressText: {
    color: colors.textSecondary,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.body,
  },
  progressPercent: {
    color: colors.emeraldGlow,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  progressBar: {
    height: 8,
    backgroundColor: colors.midnightBlue,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  scrollContent: {
    padding: spacing.lg,
    paddingTop: 0,
    paddingBottom: 100,
  },
  emptyCard: {
    alignItems: 'center',
    paddingVertical: spacing['2xl'],
  },
  emptyText: {
    color: colors.textSecondary,
    fontSize: typography.sizes.lg,
    fontFamily: typography.fonts.bodyMedium,
    marginTop: spacing.md,
  },
  emptySubtext: {
    color: colors.textMuted,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.body,
    marginTop: spacing.xs,
  },
  sectionLabel: {
    color: colors.textSecondary,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  itemCard: {
    marginBottom: spacing.sm,
  },
  itemCardCompleted: {
    opacity: 0.6,
  },
  itemContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  checkbox: {
    marginRight: spacing.md,
  },
  checkboxCompleted: {
    opacity: 1,
  },
  itemInfo: {
    flex: 1,
  },
  itemName: {
    fontSize: typography.sizes.base,
    color: colors.white,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  itemNameCompleted: {
    textDecorationLine: 'line-through',
    color: colors.textMuted,
  },
  itemQuantity: {
    fontSize: typography.sizes.xs,
    color: colors.textMuted,
    fontFamily: typography.fonts.body,
    marginTop: 2,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.lg,
  },
  modalContent: {
    width: '100%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: typography.sizes.xl,
    color: colors.white,
    fontFamily: typography.fonts.heading,
    fontWeight: '600',
    marginBottom: spacing.lg,
    textAlign: 'center',
  },
  modalInput: {
    backgroundColor: colors.white,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    fontSize: typography.sizes.base,
    color: '#1F2937',
    marginBottom: spacing.md,
  },
  modalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.sm,
  },
  modalCancelButton: {
    flex: 1,
    padding: spacing.md,
    alignItems: 'center',
    marginRight: spacing.sm,
  },
  modalCancelText: {
    color: colors.textSecondary,
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.bodyMedium,
  },
  modalCreateButton: {
    flex: 1,
    marginLeft: spacing.sm,
  },
});
