import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../components';
import { colors, typography, spacing } from '../theme';
import { supabaseService } from '../services/supabaseService';

export const DashboardScreen = ({ navigation }) => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [profile, setProfile] = useState(null);
  const [lists, setLists] = useState([]);
  const [totalItems, setTotalItems] = useState(0);
  const [completedItems, setCompletedItems] = useState(0);

  const loadData = useCallback(async () => {
    try {
      const [profileData, listsData] = await Promise.all([
        supabaseService.getUserProfile(),
        supabaseService.getShoppingLists(),
      ]);

      setProfile(profileData);
      setLists(listsData);

      let total = 0;
      let completed = 0;

      const itemPromises = listsData.map(list => 
        supabaseService.getShoppingItems(list.id)
      );
      const allItems = await Promise.all(itemPromises);
      
      allItems.forEach(items => {
        total += items.length;
        completed += items.filter(item => item.is_bought).length;
      });

      setTotalItems(total);
      setCompletedItems(completed);
    } catch (error) {
      console.error('Error loading dashboard:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    loadData();
  }, [loadData]);

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  };

  const completionRate = totalItems > 0 
    ? Math.round((completedItems / totalItems) * 100) 
    : 0;

  const StatCard = ({ title, value, icon, gradientColors }) => (
    <View style={styles.statCard}>
      <LinearGradient
        colors={gradientColors}
        style={styles.statIconContainer}
      >
        <Ionicons name={icon} size={24} color={colors.white} />
      </LinearGradient>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statTitle}>{title}</Text>
    </View>
  );

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.emeraldGlow} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
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
              <Ionicons name="home" size={24} color={colors.white} />
            </LinearGradient>
            <View>
              <Text style={styles.greeting}>{getGreeting()},</Text>
              <Text style={styles.userName}>
                {profile?.display_name || 'Shopper'}
              </Text>
            </View>
          </View>
        </View>

        <View style={styles.statsRow}>
          <StatCard 
            title="Total Lists"
            value={lists.length}
            icon="list"
            gradientColors={colors.gradients.emeraldPurple}
          />
          <StatCard 
            title="Total Items"
            value={totalItems}
            icon="cart"
            gradientColors={colors.gradients.purplePink}
          />
          <StatCard 
            title="Completed"
            value={`${completionRate}%`}
            icon="checkmark-circle"
            gradientColors={['#10B981', '#059669']}
          />
        </View>

        <Text style={styles.sectionTitle}>Quick Actions</Text>
        <View style={styles.actionsRow}>
          <TouchableOpacity 
            style={styles.actionButton}
            onPress={() => navigation.navigate('ShoppingLists')}
          >
            <LinearGradient
              colors={colors.gradients.emeraldPurple}
              style={styles.actionGradient}
            >
              <Ionicons name="add" size={28} color={colors.white} />
              <Text style={styles.actionText}>New List</Text>
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.actionButton}
            onPress={() => navigation.navigate('Analytics')}
          >
            <LinearGradient
              colors={colors.gradients.purplePink}
              style={styles.actionGradient}
            >
              <Ionicons name="analytics" size={28} color={colors.white} />
              <Text style={styles.actionText}>Analytics</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        <Text style={styles.sectionTitle}>Active Lists</Text>
        {lists.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Ionicons name="cart-outline" size={48} color={colors.textMuted} />
            <Text style={styles.emptyText}>No shopping lists yet</Text>
            <Text style={styles.emptySubtext}>Create your first list to get started</Text>
          </GlassCard>
        ) : (
          lists.slice(0, 3).map((list) => (
            <TouchableOpacity
              key={list.id}
              onPress={() => navigation.navigate('ShoppingListDetail', { listId: list.id, listName: list.name })}
            >
              <GlassCard style={styles.listCard}>
                <View style={styles.listHeader}>
                  <Text style={styles.listName}>{list.name}</Text>
                  <Ionicons name="chevron-forward" size={20} color={colors.emeraldGlow} />
                </View>
                <Text style={styles.listDate}>
                  Created {new Date(list.created_at).toLocaleDateString()}
                </Text>
              </GlassCard>
            </TouchableOpacity>
          ))
        )}

        {lists.length > 3 && (
          <TouchableOpacity 
            style={styles.viewAllButton}
            onPress={() => navigation.navigate('ShoppingLists')}
          >
            <Text style={styles.viewAllText}>View All Lists</Text>
            <Ionicons name="arrow-forward" size={16} color={colors.emeraldGlow} />
          </TouchableOpacity>
        )}
      </ScrollView>
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
  greeting: {
    fontSize: typography.sizes.sm,
    color: colors.textSecondary,
    fontFamily: typography.fonts.body,
  },
  userName: {
    fontSize: typography.sizes['2xl'],
    color: colors.white,
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.xl,
  },
  statCard: {
    flex: 1,
    backgroundColor: colors.glass,
    borderRadius: 20,
    padding: spacing.md,
    marginHorizontal: 4,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  statIconContainer: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.sm,
  },
  statValue: {
    fontSize: typography.sizes['2xl'],
    color: colors.white,
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
  },
  statTitle: {
    fontSize: typography.sizes.xs,
    color: colors.textSecondary,
    fontFamily: typography.fonts.body,
    marginTop: 2,
  },
  sectionTitle: {
    fontSize: typography.sizes.lg,
    color: colors.white,
    fontFamily: typography.fonts.heading,
    fontWeight: '600',
    marginBottom: spacing.md,
  },
  actionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.xl,
  },
  actionButton: {
    flex: 1,
    marginHorizontal: 4,
    borderRadius: 16,
    overflow: 'hidden',
  },
  actionGradient: {
    padding: spacing.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  actionText: {
    color: colors.white,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
    marginTop: spacing.xs,
  },
  emptyCard: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
  },
  emptyText: {
    color: colors.textSecondary,
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.bodyMedium,
    marginTop: spacing.md,
  },
  emptySubtext: {
    color: colors.textMuted,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.body,
    marginTop: spacing.xs,
  },
  listCard: {
    marginBottom: spacing.sm,
  },
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  listName: {
    fontSize: typography.sizes.base,
    color: colors.white,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  listDate: {
    fontSize: typography.sizes.xs,
    color: colors.textMuted,
    fontFamily: typography.fonts.body,
    marginTop: spacing.xs,
  },
  viewAllButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.md,
  },
  viewAllText: {
    color: colors.emeraldGlow,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    marginRight: spacing.xs,
  },
});
