export const shadows = {
  soft: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.18,
    shadowRadius: 18,
    elevation: 8,
  },

  medium: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.22,
    shadowRadius: 24,
    elevation: 12,
  },

  accentGlow: {
    shadowColor: '#7E8B6D',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.16,
    shadowRadius: 22,
    elevation: 10,
  },
};

// Re-export design tokens from theme
export { radius, spacing, typography } from './theme';

// Backward-compatible alias used across legacy explore components.
export { typography as type } from './theme';
