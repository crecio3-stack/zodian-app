export const colors = {
  // Foundation
  background: '#030304',
  backgroundAlt: '#0B0B10',

  // Cards & surfaces
  card: '#0F0F14',
  cardStrong: '#14161D',
  surface: '#0F0F14',
  cardBorder: 'rgba(230, 183, 92, 0.16)',

  // Primary brand
  accent: '#D6B56F',
  accentSoft: '#E8D2A4',
  accentBright: '#F7E9C2',
  accentMuted: 'rgba(214, 181, 107, 0.72)',

  // Secondary
  secondaryAccent: '#8E8A72',
  secondaryAccentSoft: '#B5AA84',
  secondaryAccentGlow: 'rgba(214, 181, 107, 0.18)',

  // Text
  text: '#F8F2E7',
  textSoft: 'rgba(248, 242, 231, 0.86)',
  textMuted: 'rgba(248, 242, 231, 0.66)',
  textFaint: 'rgba(248, 242, 231, 0.42)',

  // UI
  border: 'rgba(230, 183, 92, 0.14)',
  overlay: 'rgba(0,0,0,0.64)',
  shadow: '#000000',

  // Semantic
  success: '#8DA17D',
  warning: '#B9945F',
  danger: '#B45F5F',
};

export const spacing = {
  xxs: 4,
  xs: 6,
  sm: 10,
  md: 16,
  lg: 22,
  xl: 28,
  xxl: 36,
  xxxl: 48,
  screenPadding: 24,
};

export const radius = {
  xs: 8,
  sm: 12,
  md: 18,
  lg: 24,
  xl: 32,
  xxl: 40,
  pill: 999,
};

export const typography = {
  micro: {
    fontSize: 11,
    letterSpacing: 2,
    fontWeight: '700' as const,
    textTransform: 'uppercase' as const,
  },
  label: {
    fontSize: 12,
    letterSpacing: 1.6,
    textTransform: 'uppercase' as const,
    fontWeight: '700' as const,
  },
  body: {
    fontSize: 16,
    lineHeight: 26,
  },
  bodySmall: {
    fontSize: 14,
    lineHeight: 22,
  },
  title: {
    fontSize: 28,
    lineHeight: 36,
    letterSpacing: -0.4,
    fontWeight: '700' as const,
  },
  title1: {
    fontSize: 34,
    lineHeight: 42,
    letterSpacing: -0.6,
    fontWeight: '800' as const,
  },
  title2: {
    fontSize: 24,
    lineHeight: 32,
    letterSpacing: -0.3,
    fontWeight: '700' as const,
  },
  display: {
    fontSize: 42,
    lineHeight: 50,
    letterSpacing: -0.8,
    fontWeight: '800' as const,
  },
  button: {
    fontSize: 16,
    lineHeight: 22,
    fontWeight: '700' as const,
  },
};

// Additional design tokens for premium feel
export const gradients = {
  gold: ['#D6B56F', '#F7E9C2'],
  obsidian: ['#020202', '#0B0B10'],
  subtleWarm: ['rgba(214,181,107,0.06)', 'rgba(255,255,255,0.02)'],
};

export const motion = {
  durations: {
    short: 150,
    base: 300,
    long: 520,
  },
  easing: {
    standard: 'cubic-bezier(0.2,0.9,0.3,1)',
  },
};

export const z = {
  background: 0,
  content: 100,
  modal: 500,
  overlay: 900,
};

export const shadows = {
  soft: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.18,
    shadowRadius: 18,
    elevation: 8,
  },
  medium: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.22,
    shadowRadius: 24,
    elevation: 12,
  },
  accentGlow: {
    shadowColor: 'rgba(214,181,107,0.9)',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.14,
    shadowRadius: 28,
    elevation: 12,
  },
};

export const theme = {
  colors,
  spacing,
  radius,
  typography,
  gradients,
  motion,
  z,
  shadows,
};