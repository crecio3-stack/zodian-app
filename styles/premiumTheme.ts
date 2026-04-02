import { colors, radius, spacing, typography } from './theme';

export const premiumTheme = {
  colors: {
    background: colors.background,
    backgroundAlt: colors.backgroundAlt,
    card: colors.card,
    cardStrong: colors.cardStrong,
    border: colors.border,

    accent: colors.accent,
    accentSoft: colors.accentSoft,
    accentBright: colors.accentBright,
    accentMuted: colors.accentMuted,

    text: colors.text,
    textSoft: colors.textSoft,
    textMuted: colors.textMuted,
    textFaint: colors.textFaint,

    secondaryAccent: colors.secondaryAccent,
    secondaryAccentSoft: colors.secondaryAccentSoft,
    secondaryAccentGlow: colors.secondaryAccentGlow,

    // Legacy aliases used by explore badges and older cards.
    borderStrong: colors.cardBorder,
    likeFill: 'rgba(125, 141, 107, 0.2)',
    passFill: 'rgba(180, 95, 95, 0.2)',
  },
  radius,
  spacing,
  typography,
};