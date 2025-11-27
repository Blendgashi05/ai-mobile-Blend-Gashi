import React from 'react';
import { View, StyleSheet } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { DashboardScreen } from './DashboardScreen';
import { AnalyticsScreen } from './AnalyticsScreen';
import { ProfileScreen } from './ProfileScreen';
import { colors } from '../theme';

const Tab = createBottomTabNavigator();

const TabBarBackground = () => (
  <BlurView intensity={30} tint="dark" style={StyleSheet.absoluteFill}>
    <View style={styles.tabBarOverlay} />
  </BlurView>
);

export const HomeHubScreen = ({ navigation, onLogout }) => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: styles.tabBar,
        tabBarBackground: () => <TabBarBackground />,
        tabBarActiveTintColor: colors.emeraldGlow,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarLabelStyle: styles.tabBarLabel,
        tabBarIcon: ({ focused, color }) => {
          let iconName;

          switch (route.name) {
            case 'Dashboard':
              iconName = focused ? 'home' : 'home-outline';
              break;
            case 'Analytics':
              iconName = focused ? 'analytics' : 'analytics-outline';
              break;
            case 'Profile':
              iconName = focused ? 'person' : 'person-outline';
              break;
            default:
              iconName = 'ellipse';
          }

          if (focused) {
            return (
              <View style={styles.activeTabIcon}>
                <LinearGradient
                  colors={colors.gradients.emeraldPurple}
                  style={styles.activeTabGradient}
                >
                  <Ionicons name={iconName} size={22} color={colors.white} />
                </LinearGradient>
              </View>
            );
          }

          return <Ionicons name={iconName} size={22} color={color} />;
        },
      })}
    >
      <Tab.Screen 
        name="Dashboard" 
        options={{ tabBarLabel: 'Home' }}
      >
        {(props) => <DashboardScreen {...props} navigation={navigation} />}
      </Tab.Screen>
      <Tab.Screen 
        name="Analytics" 
        component={AnalyticsScreen}
        options={{ tabBarLabel: 'Analytics' }}
      />
      <Tab.Screen 
        name="Profile"
        options={{ tabBarLabel: 'Profile' }}
      >
        {(props) => <ProfileScreen {...props} onLogout={onLogout} />}
      </Tab.Screen>
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabBar: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
    height: 70,
    borderRadius: 25,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    backgroundColor: 'transparent',
    elevation: 0,
    shadowColor: colors.emeraldGlow,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
  },
  tabBarOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: colors.glass,
    borderRadius: 25,
  },
  tabBarLabel: {
    fontSize: 11,
    fontWeight: '500',
    marginBottom: 8,
  },
  activeTabIcon: {
    marginTop: 8,
  },
  activeTabGradient: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: colors.emeraldGlow,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
    elevation: 8,
  },
});
