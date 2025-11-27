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

export const LoginScreen = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
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
    if (!email) newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = 'Invalid email format';
    if (!password) newErrors.password = 'Password is required';
    else if (password.length < 6) newErrors.password = 'Password must be at least 6 characters';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleLogin = async () => {
    if (!validate()) return;

    setLoading(true);
    try {
      await supabaseService.signIn(email, password);
    } catch (error) {
      Alert.alert('Error', error.message || 'Failed to sign in');
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
            <View style={styles.logoContainer}>
              <LinearGradient
                colors={colors.gradients.emeraldPurple}
                style={styles.logoGradient}
              >
                <Ionicons name="cart" size={48} color={colors.white} />
              </LinearGradient>
              <Text style={styles.title}>Welcome Back</Text>
              <Text style={styles.subtitle}>Sign in to continue shopping</Text>
            </View>

            <GlassCard style={styles.card}>
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
                placeholder="Enter your password"
                secureTextEntry
                icon="lock-closed-outline"
                error={errors.password}
              />

              <CustomButton
                title="Sign In"
                onPress={handleLogin}
                loading={loading}
                style={styles.button}
              />

              <View style={styles.footer}>
                <Text style={styles.footerText}>Don't have an account? </Text>
                <TouchableOpacity onPress={() => navigation.navigate('Signup')}>
                  <Text style={styles.footerLink}>Sign Up</Text>
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
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  logoGradient: {
    width: 100,
    height: 100,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.md,
    shadowColor: colors.emeraldGlow,
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
