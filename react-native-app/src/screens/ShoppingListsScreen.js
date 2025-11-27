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

export const ShoppingListsScreen = ({ navigation, route }) => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [lists, setLists] = useState([]);
  const [listItems, setListItems] = useState({});
  const [modalVisible, setModalVisible] = useState(false);
  const [newListName, setNewListName] = useState('');
  const [creating, setCreating] = useState(false);

  const showBackButton = route?.params?.showBack ?? false;

  const loadLists = useCallback(async () => {
    try {
      const listsData = await supabaseService.getShoppingLists();
      setLists(listsData);

      const itemsPromises = listsData.map(async (list) => {
        try {
          const items = await supabaseService.getShoppingItems(list.id);
          return { listId: list.id, items };
        } catch {
          return { listId: list.id, items: [] };
        }
      });

      const results = await Promise.all(itemsPromises);
      const itemsMap = {};
      results.forEach(({ listId, items }) => {
        itemsMap[listId] = items;
      });
      setListItems(itemsMap);
    } catch (error) {
      console.error('Error loading lists:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadLists();
  }, [loadLists]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    loadLists();
  }, [loadLists]);

  const handleCreateList = async () => {
    if (!newListName.trim()) {
      Alert.alert('Error', 'Please enter a list name');
      return;
    }

    setCreating(true);
    try {
      await supabaseService.createShoppingList(newListName.trim());
      setNewListName('');
      setModalVisible(false);
      loadLists();
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to create list');
    } finally {
      setCreating(false);
    }
  };

  const handleDeleteList = (list) => {
    Alert.alert(
      'Delete List',
      `Are you sure you want to delete "${list.name}"?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await supabaseService.deleteShoppingList(list.id);
              loadLists();
            } catch (error) {
              Alert.alert('Error', error.message || 'Failed to delete list');
            }
          },
        },
      ]
    );
  };

  const getListProgress = (listId) => {
    const items = listItems[listId] || [];
    if (items.length === 0) return { total: 0, completed: 0, percent: 0 };
    const completed = items.filter(item => item.is_bought).length;
    return {
      total: items.length,
      completed,
      percent: Math.round((completed / items.length) * 100),
    };
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.emeraldGlow} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {showBackButton && (
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="arrow-back" size={24} color={colors.emeraldGlow} />
        </TouchableOpacity>
      )}

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
        <View style={styles.header}>
          <View style={styles.headerLeft}>
            <LinearGradient
              colors={colors.gradients.emeraldPurple}
              style={styles.headerIcon}
            >
              <Ionicons name="list" size={24} color={colors.white} />
            </LinearGradient>
            <Text style={styles.headerTitle}>Shopping Lists</Text>
          </View>
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

        {lists.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Ionicons name="cart-outline" size={64} color={colors.textMuted} />
            <Text style={styles.emptyText}>No shopping lists yet</Text>
            <Text style={styles.emptySubtext}>
              Tap the + button to create your first list
            </Text>
          </GlassCard>
        ) : (
          lists.map((list) => {
            const progress = getListProgress(list.id);
            return (
              <TouchableOpacity
                key={list.id}
                onPress={() => navigation.navigate('ShoppingListDetail', { 
                  listId: list.id, 
                  listName: list.name 
                })}
                onLongPress={() => handleDeleteList(list)}
              >
                <GlassCard style={styles.listCard}>
                  <View style={styles.listHeader}>
                    <View style={styles.listInfo}>
                      <Text style={styles.listName}>{list.name}</Text>
                      <Text style={styles.listMeta}>
                        {progress.total} items | {progress.percent}% complete
                      </Text>
                    </View>
                    <Ionicons name="chevron-forward" size={20} color={colors.emeraldGlow} />
                  </View>
                  
                  <View style={styles.progressContainer}>
                    <View style={styles.progressBar}>
                      <LinearGradient
                        colors={colors.gradients.emeraldPurple}
                        start={{ x: 0, y: 0 }}
                        end={{ x: 1, y: 0 }}
                        style={[styles.progressFill, { width: `${progress.percent}%` }]}
                      />
                    </View>
                  </View>
                </GlassCard>
              </TouchableOpacity>
            );
          })
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
            <Text style={styles.modalTitle}>New Shopping List</Text>
            <TextInput
              style={styles.modalInput}
              value={newListName}
              onChangeText={setNewListName}
              placeholder="Enter list name"
              placeholderTextColor={colors.textMuted}
              autoFocus
            />
            <View style={styles.modalButtons}>
              <TouchableOpacity 
                style={styles.modalCancelButton}
                onPress={() => {
                  setNewListName('');
                  setModalVisible(false);
                }}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </TouchableOpacity>
              <CustomButton
                title="Create"
                onPress={handleCreateList}
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
  backButton: {
    position: 'absolute',
    top: spacing.xl,
    left: spacing.lg,
    zIndex: 10,
    padding: spacing.sm,
    backgroundColor: colors.glass,
    borderRadius: borderRadius.md,
  },
  scrollContent: {
    padding: spacing.lg,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  headerTitle: {
    fontSize: typography.sizes['2xl'],
    color: colors.white,
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
  },
  addButton: {
    borderRadius: 24,
    overflow: 'hidden',
  },
  addButtonGradient: {
    width: 48,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
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
    textAlign: 'center',
  },
  listCard: {
    marginBottom: spacing.md,
  },
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  listInfo: {
    flex: 1,
  },
  listName: {
    fontSize: typography.sizes.lg,
    color: colors.white,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  listMeta: {
    fontSize: typography.sizes.xs,
    color: colors.textMuted,
    fontFamily: typography.fonts.body,
    marginTop: 4,
  },
  progressContainer: {
    marginTop: spacing.md,
  },
  progressBar: {
    height: 6,
    backgroundColor: colors.midnightBlue,
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 3,
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
    marginBottom: spacing.lg,
  },
  modalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
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
