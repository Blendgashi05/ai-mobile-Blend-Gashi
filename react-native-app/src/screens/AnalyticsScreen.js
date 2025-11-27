import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../components';
import { colors, typography, spacing } from '../theme';
import { supabaseService } from '../services/supabaseService';

export const AnalyticsScreen = () => {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [stats, setStats] = useState({
    totalItems: 0,
    completedItems: 0,
    pendingItems: 0,
    completionRate: 0,
  });
  const [topItems, setTopItems] = useState([]);
  const [listOverviews, setListOverviews] = useState([]);

  const loadAnalytics = useCallback(async () => {
    try {
      const lists = await supabaseService.getShoppingLists();
      
      const itemPromises = lists.map(list => 
        supabaseService.getShoppingItems(list.id)
          .then(items => ({ list, items }))
          .catch(() => ({ list, items: [] }))
      );
      
      const results = await Promise.all(itemPromises);
      
      let totalItems = 0;
      let completedItems = 0;
      const itemCounts = {};
      const overviews = [];

      results.forEach(({ list, items }) => {
        totalItems += items.length;
        const completed = items.filter(item => item.is_bought).length;
        completedItems += completed;

        items.forEach(item => {
          const name = item.name.toLowerCase();
          itemCounts[name] = (itemCounts[name] || 0) + 1;
        });

        if (items.length > 0) {
          overviews.push({
            name: list.name,
            total: items.length,
            completed,
            percent: Math.round((completed / items.length) * 100),
          });
        }
      });

      const pendingItems = totalItems - completedItems;
      const completionRate = totalItems > 0 
        ? Math.round((completedItems / totalItems) * 100) 
        : 0;

      setStats({ totalItems, completedItems, pendingItems, completionRate });

      const sortedItems = Object.entries(itemCounts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([name, count]) => ({ name, count }));
      
      setTopItems(sortedItems);
      setListOverviews(overviews);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadAnalytics();
  }, [loadAnalytics]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    loadAnalytics();
  }, [loadAnalytics]);

  const StatCard = ({ title, value, icon, gradientColors }) => (
    <View style={styles.statCard}>
      <LinearGradient
        colors={gradientColors}
        style={styles.statIconContainer}
      >
        <Ionicons name={icon} size={20} color={colors.white} />
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
          <LinearGradient
            colors={colors.gradients.purplePink}
            style={styles.headerIcon}
          >
            <Ionicons name="analytics" size={24} color={colors.white} />
          </LinearGradient>
          <Text style={styles.headerTitle}>Analytics</Text>
        </View>

        <View style={styles.statsGrid}>
          <StatCard 
            title="Total Items"
            value={stats.totalItems}
            icon="cart"
            gradientColors={colors.gradients.purplePink}
          />
          <StatCard 
            title="Completed"
            value={stats.completedItems}
            icon="checkmark-circle"
            gradientColors={['#10B981', '#059669']}
          />
          <StatCard 
            title="Pending"
            value={stats.pendingItems}
            icon="time"
            gradientColors={colors.gradients.pinkGold}
          />
          <StatCard 
            title="Rate"
            value={`${stats.completionRate}%`}
            icon="trending-up"
            gradientColors={colors.gradients.emeraldPurple}
          />
        </View>

        <Text style={styles.sectionTitle}>Most Common Items</Text>
        {topItems.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Text style={styles.emptyText}>No item data yet</Text>
          </GlassCard>
        ) : (
          <GlassCard>
            {topItems.map((item, index) => (
              <View key={item.name} style={styles.topItemRow}>
                <View style={styles.topItemRank}>
                  <Text style={styles.topItemRankText}>{index + 1}</Text>
                </View>
                <Text style={styles.topItemName}>{item.name}</Text>
                <Text style={styles.topItemCount}>{item.count}x</Text>
              </View>
            ))}
          </GlassCard>
        )}

        <Text style={styles.sectionTitle}>Lists Overview</Text>
        {listOverviews.length === 0 ? (
          <GlassCard style={styles.emptyCard}>
            <Text style={styles.emptyText}>No lists with items yet</Text>
          </GlassCard>
        ) : (
          listOverviews.map((list, index) => (
            <GlassCard key={index} style={styles.listOverviewCard}>
              <View style={styles.listOverviewHeader}>
                <Text style={styles.listOverviewName}>{list.name}</Text>
                <Text style={styles.listOverviewPercent}>{list.percent}%</Text>
              </View>
              <Text style={styles.listOverviewMeta}>
                {list.completed} of {list.total} items completed
              </Text>
              <View style={styles.progressBar}>
                <LinearGradient
                  colors={colors.gradients.purplePink}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={[styles.progressFill, { width: `${list.percent}%` }]}
                />
              </View>
            </GlassCard>
          ))
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
    alignItems: 'center',
    marginBottom: spacing.xl,
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
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: spacing.xl,
  },
  statCard: {
    width: '48%',
    backgroundColor: colors.glass,
    borderRadius: 20,
    padding: spacing.md,
    marginBottom: spacing.sm,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  statIconContainer: {
    width: 40,
    height: 40,
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
  emptyCard: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
    marginBottom: spacing.lg,
  },
  emptyText: {
    color: colors.textMuted,
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.body,
  },
  topItemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  topItemRank: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.midnightBlue,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  topItemRankText: {
    color: colors.emeraldGlow,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  topItemName: {
    flex: 1,
    color: colors.white,
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.body,
    textTransform: 'capitalize',
  },
  topItemCount: {
    color: colors.textMuted,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
  },
  listOverviewCard: {
    marginBottom: spacing.md,
  },
  listOverviewHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  listOverviewName: {
    fontSize: typography.sizes.base,
    color: colors.white,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  listOverviewPercent: {
    fontSize: typography.sizes.base,
    color: colors.purpleAccent,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  listOverviewMeta: {
    fontSize: typography.sizes.xs,
    color: colors.textMuted,
    fontFamily: typography.fonts.body,
    marginTop: 4,
    marginBottom: spacing.sm,
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
});
