import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { colors } from '../theme';

const { width, height } = Dimensions.get('window');

const FloatingOrb = ({ size, color, initialX, initialY, duration }) => {
  const translateX = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(0)).current;
  const opacity = useRef(new Animated.Value(0.3)).current;

  useEffect(() => {
    const animateOrb = () => {
      Animated.loop(
        Animated.parallel([
          Animated.sequence([
            Animated.timing(translateX, {
              toValue: 30,
              duration: duration,
              useNativeDriver: true,
            }),
            Animated.timing(translateX, {
              toValue: -30,
              duration: duration,
              useNativeDriver: true,
            }),
          ]),
          Animated.sequence([
            Animated.timing(translateY, {
              toValue: -20,
              duration: duration * 0.8,
              useNativeDriver: true,
            }),
            Animated.timing(translateY, {
              toValue: 20,
              duration: duration * 0.8,
              useNativeDriver: true,
            }),
          ]),
          Animated.sequence([
            Animated.timing(opacity, {
              toValue: 0.6,
              duration: duration * 0.5,
              useNativeDriver: true,
            }),
            Animated.timing(opacity, {
              toValue: 0.3,
              duration: duration * 0.5,
              useNativeDriver: true,
            }),
          ]),
        ])
      ).start();
    };
    animateOrb();
  }, []);

  return (
    <Animated.View
      style={[
        styles.orb,
        {
          width: size,
          height: size,
          backgroundColor: color,
          left: initialX,
          top: initialY,
          opacity,
          transform: [{ translateX }, { translateY }],
        },
      ]}
    />
  );
};

export const GradientBackground = ({ children, showOrbs = true }) => {
  return (
    <View style={styles.container}>
      <LinearGradient
        colors={[colors.deepSpace, '#0D1233', colors.deepSpace]}
        style={styles.gradient}
      />
      
      {showOrbs && (
        <>
          <FloatingOrb 
            size={200} 
            color={`${colors.emeraldGlow}40`} 
            initialX={-50} 
            initialY={height * 0.1} 
            duration={4000} 
          />
          <FloatingOrb 
            size={150} 
            color={`${colors.purpleAccent}40`} 
            initialX={width - 100} 
            initialY={height * 0.3} 
            duration={5000} 
          />
          <FloatingOrb 
            size={120} 
            color={`${colors.emeraldGlow}30`} 
            initialX={width * 0.3} 
            initialY={height * 0.6} 
            duration={3500} 
          />
        </>
      )}
      
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.deepSpace,
  },
  gradient: {
    ...StyleSheet.absoluteFillObject,
  },
  orb: {
    position: 'absolute',
    borderRadius: 1000,
  },
});
