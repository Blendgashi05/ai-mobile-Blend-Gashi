import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView,
  TouchableOpacity,
  Image,
  Alert,
  ActivityIndicator,
  TextInput,
  Modal,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { GlassCard, CustomButton } from '../components';
import { colors, typography, spacing, borderRadius } from '../theme';
import { supabaseService } from '../services/supabaseService';

export const ProfileScreen = ({ onLogout }) => {
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [profile, setProfile] = useState(null);
  const [user, setUser] = useState(null);
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [newDisplayName, setNewDisplayName] = useState('');
  const [saving, setSaving] = useState(false);

  const loadProfile = useCallback(async () => {
    try {
      const { data: { user: currentUser } } = await supabaseService.getCurrentUser();
      setUser(currentUser);

      const profileData = await supabaseService.getUserProfile();
      setProfile(profileData);
      setNewDisplayName(profileData?.display_name || '');
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadProfile();
  }, [loadProfile]);

  const handlePickImage = async () => {
    try {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission needed', 'Please grant access to your photo library');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        setUploading(true);
        try {
          const photoUrl = await supabaseService.uploadProfilePhoto(result.assets[0].uri);
          await supabaseService.updateUserProfile({ photoUrl });
          loadProfile();
        } catch (error) {
          Alert.alert('Upload Error', error.message || 'Failed to upload photo');
        } finally {
          setUploading(false);
        }
      }
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to pick image');
    }
  };

  const handleUpdateDisplayName = async () => {
    if (!newDisplayName.trim()) {
      Alert.alert('Error', 'Please enter a display name');
      return;
    }

    setSaving(true);
    try {
      await supabaseService.updateUserProfile({ displayName: newDisplayName.trim() });
      setEditModalVisible(false);
      loadProfile();
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to update name');
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Sign Out',
          style: 'destructive',
          onPress: async () => {
            try {
              await supabaseService.signOut();
              if (onLogout) onLogout();
            } catch (error) {
              Alert.alert('Error', error.message || 'Failed to sign out');
            }
          },
        },
      ]
    );
  };

  const memberSince = user?.created_at 
    ? new Date(user.created_at).toLocaleDateString('en-US', { 
        month: 'long', 
        year: 'numeric' 
      })
    : 'Unknown';

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.emeraldGlow} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <LinearGradient
            colors={colors.gradients.emeraldPurple}
            style={styles.headerIcon}
          >
            <Ionicons name="person" size={24} color={colors.white} />
          </LinearGradient>
          <Text style={styles.headerTitle}>Profile</Text>
        </View>

        <View style={styles.avatarSection}>
          <TouchableOpacity onPress={handlePickImage} disabled={uploading}>
            <LinearGradient
              colors={colors.gradients.emeraldPurple}
              style={styles.avatarBorder}
            >
              {uploading ? (
                <View style={styles.avatarContainer}>
                  <ActivityIndicator color={colors.emeraldGlow} />
                </View>
              ) : profile?.photo_url ? (
                <Image 
                  source={{ uri: profile.photo_url }} 
                  style={styles.avatar}
                />
              ) : (
                <View style={styles.avatarContainer}>
                  <Ionicons name="person" size={60} color={colors.textMuted} />
                </View>
              )}
            </LinearGradient>
            <View style={styles.cameraButton}>
              <Ionicons name="camera" size={16} color={colors.white} />
            </View>
          </TouchableOpacity>

          <Text style={styles.displayName}>
            {profile?.display_name || 'No name set'}
          </Text>
          <Text style={styles.email}>{user?.email}</Text>
        </View>

        <GlassCard style={styles.infoCard}>
          <TouchableOpacity 
            style={styles.infoRow}
            onPress={() => setEditModalVisible(true)}
          >
            <View style={styles.infoLeft}>
              <Ionicons name="person-outline" size={20} color={colors.emeraldGlow} />
              <View style={styles.infoTextContainer}>
                <Text style={styles.infoLabel}>Display Name</Text>
                <Text style={styles.infoValue}>
                  {profile?.display_name || 'Not set'}
                </Text>
              </View>
            </View>
            <Ionicons name="chevron-forward" size={20} color={colors.textMuted} />
          </TouchableOpacity>

          <View style={styles.divider} />

          <View style={styles.infoRow}>
            <View style={styles.infoLeft}>
              <Ionicons name="mail-outline" size={20} color={colors.emeraldGlow} />
              <View style={styles.infoTextContainer}>
                <Text style={styles.infoLabel}>Email</Text>
                <Text style={styles.infoValue}>{user?.email}</Text>
              </View>
            </View>
          </View>

          <View style={styles.divider} />

          <View style={styles.infoRow}>
            <View style={styles.infoLeft}>
              <Ionicons name="calendar-outline" size={20} color={colors.emeraldGlow} />
              <View style={styles.infoTextContainer}>
                <Text style={styles.infoLabel}>Member Since</Text>
                <Text style={styles.infoValue}>{memberSince}</Text>
              </View>
            </View>
          </View>
        </GlassCard>

        <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
          <LinearGradient
            colors={['#EF4444', '#DC2626']}
            style={styles.logoutGradient}
          >
            <Ionicons name="log-out-outline" size={20} color={colors.white} />
            <Text style={styles.logoutText}>Sign Out</Text>
          </LinearGradient>
        </TouchableOpacity>
      </ScrollView>

      <Modal
        visible={editModalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setEditModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <GlassCard style={styles.modalContent}>
            <Text style={styles.modalTitle}>Edit Display Name</Text>
            <TextInput
              style={styles.modalInput}
              value={newDisplayName}
              onChangeText={setNewDisplayName}
              placeholder="Enter your name"
              placeholderTextColor={colors.textMuted}
              autoFocus
            />
            <View style={styles.modalButtons}>
              <TouchableOpacity 
                style={styles.modalCancelButton}
                onPress={() => setEditModalVisible(false)}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </TouchableOpacity>
              <CustomButton
                title="Save"
                onPress={handleUpdateDisplayName}
                loading={saving}
                style={styles.modalSaveButton}
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
  avatarSection: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  avatarBorder: {
    width: 132,
    height: 132,
    borderRadius: 66,
    padding: 4,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatar: {
    width: 124,
    height: 124,
    borderRadius: 62,
  },
  avatarContainer: {
    width: 124,
    height: 124,
    borderRadius: 62,
    backgroundColor: colors.midnightBlue,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cameraButton: {
    position: 'absolute',
    bottom: 4,
    right: 4,
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.emeraldGlow,
    alignItems: 'center',
    justifyContent: 'center',
  },
  displayName: {
    fontSize: typography.sizes['2xl'],
    color: colors.white,
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
    marginTop: spacing.md,
  },
  email: {
    fontSize: typography.sizes.base,
    color: colors.textSecondary,
    fontFamily: typography.fonts.body,
    marginTop: spacing.xs,
  },
  infoCard: {
    marginBottom: spacing.xl,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: spacing.sm,
  },
  infoLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  infoTextContainer: {
    marginLeft: spacing.md,
  },
  infoLabel: {
    fontSize: typography.sizes.xs,
    color: colors.textMuted,
    fontFamily: typography.fonts.body,
  },
  infoValue: {
    fontSize: typography.sizes.base,
    color: colors.white,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
    marginTop: 2,
  },
  divider: {
    height: 1,
    backgroundColor: colors.glassBorder,
    marginVertical: spacing.xs,
  },
  logoutButton: {
    borderRadius: borderRadius.lg,
    overflow: 'hidden',
  },
  logoutGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.md,
  },
  logoutText: {
    color: colors.white,
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
    marginLeft: spacing.sm,
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
  modalSaveButton: {
    flex: 1,
    marginLeft: spacing.sm,
  },
});
