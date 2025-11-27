import React, { useState, useEffect, useRef } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  KeyboardAvoidingView, 
  Platform,
  ScrollView,
  Animated,
  Alert,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { GradientBackground, GlassCard, CustomButton, CustomTextField } from '../components';
import { colors, typography, spacing } from '../theme';
import { supabaseService } from '../services/supabaseService';

export const SignupScreen = ({ navigation }) => {
  const [displayName, setDisplayName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 600,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const validate = () => {
    const newErrors = {};
    if (!displayName) newErrors.displayName = 'Display name is required';
    if (!email) newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = 'Invalid email format';
    if (!password) newErrors.password = 'Password is required';
    else if (password.length < 6) newErrors.password = 'Password must be at least 6 characters';
    if (!confirmPassword) newErrors.confirmPassword = 'Please confirm your password';
    else if (password !== confirmPassword) newErrors.confirmPassword = 'Passwords do not match';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSignup = async () => {
    if (!validate()) return;

    setLoading(true);
    try {
      await supabaseService.signUp(email, password, displayName);
      Alert.alert(
        'Success',
        'Account created! Please check your email to verify your account.',
        [{ text: 'OK', onPress: () => navigation.navigate('Login') }]
      );
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to create account');
    } finally {
      setLoading(false);
    }
  };

  return (
    <GradientBackground showOrbs={true}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.container}
      >
        <ScrollView 
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <Animated.View 
            style={[
              styles.content,
              { opacity: fadeAnim, transform: [{ translateY: slideAnim }] }
            ]}
          >
            <TouchableOpacity 
              style={styles.backButton}
              onPress={() => navigation.goBack()}
            >
              <Ionicons name="arrow-back" size={24} color={colors.emeraldGlow} />
            </TouchableOpacity>

            <View style={styles.logoContainer}>
              <LinearGradient
                colors={colors.gradients.purpleEmerald}
                style={styles.logoGradient}
              >
                <Ionicons name="person-add" size={48} color={colors.white} />
              </LinearGradient>
              <Text style={styles.title}>Create Account</Text>
              <Text style={styles.subtitle}>Join us and start shopping smart</Text>
            </View>

            <GlassCard style={styles.card}>
              <CustomTextField
                label="Display Name"
                value={displayName}
                onChangeText={setDisplayName}
                placeholder="Enter your name"
                autoCapitalize="words"
                icon="person-outline"
                error={errors.displayName}
              />

              <CustomTextField
                label="Email"
                value={email}
                onChangeText={setEmail}
                placeholder="Enter your email"
                keyboardType="email-address"
                icon="mail-outline"
                error={errors.email}
              />

              <CustomTextField
                label="Password"
                value={password}
                onChangeText={setPassword}
                placeholder="Create a password"
                secureTextEntry
                icon="lock-closed-outline"
                error={errors.password}
              />

              <CustomTextField
                label="Confirm Password"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                placeholder="Confirm your password"
                secureTextEntry
                icon="lock-closed-outline"
                error={errors.confirmPassword}
              />

              <CustomButton
                title="Create Account"
                onPress={handleSignup}
                loading={loading}
                variant="secondary"
                style={styles.button}
              />

              <View style={styles.footer}>
                <Text style={styles.footerText}>Already have an account? </Text>
                <TouchableOpacity onPress={() => navigation.navigate('Login')}>
                  <Text style={styles.footerLink}>Sign In</Text>
                </TouchableOpacity>
              </View>
            </GlassCard>

            <View style={styles.bottomFooter}>
              <View style={styles.footerLinks}>
                <TouchableOpacity>
                  <Text style={styles.linkText}>About</Text>
                </TouchableOpacity>
                <Text style={styles.linkDivider}>|</Text>
                <TouchableOpacity>
                  <Text style={styles.linkText}>Privacy</Text>
                </TouchableOpacity>
                <Text style={styles.linkDivider}>|</Text>
                <TouchableOpacity>
                  <Text style={styles.linkText}>Help</Text>
                </TouchableOpacity>
              </View>
              <Text style={styles.copyright}>Shopping List App</Text>
            </View>
          </Animated.View>
        </ScrollView>
      </KeyboardAvoidingView>
    </GradientBackground>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: spacing.lg,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  backButton: {
    position: 'absolute',
    top: 0,
    left: 0,
    padding: spacing.sm,
    backgroundColor: colors.glass,
    borderRadius: 12,
    zIndex: 10,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing.xl,
    marginTop: spacing.xl,
  },
  logoGradient: {
    width: 100,
    height: 100,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.md,
    shadowColor: colors.purpleAccent,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.4,
    shadowRadius: 20,
    elevation: 10,
  },
  title: {
    fontSize: typography.sizes['3xl'],
    fontFamily: typography.fonts.headingBold,
    fontWeight: '700',
    color: colors.white,
    marginBottom: spacing.xs,
  },
  subtitle: {
    fontSize: typography.sizes.base,
    fontFamily: typography.fonts.body,
    color: colors.textSecondary,
  },
  card: {
    marginBottom: spacing.xl,
  },
  button: {
    marginTop: spacing.md,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: spacing.lg,
  },
  footerText: {
    color: colors.textSecondary,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.body,
  },
  footerLink: {
    color: colors.emeraldGlow,
    fontSize: typography.sizes.sm,
    fontFamily: typography.fonts.bodyMedium,
    fontWeight: '500',
  },
  bottomFooter: {
    alignItems: 'center',
    paddingTop: spacing.lg,
  },
  footerLinks: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  linkText: {
    color: colors.emeraldGlow,
    fontSize: typography.sizes.sm,
  },
  linkDivider: {
    color: colors.textMuted,
    marginHorizontal: spacing.sm,
  },
  copyright: {
    color: colors.textMuted,
    fontSize: typography.sizes.xs,
  },
});
