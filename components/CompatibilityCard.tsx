import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { colors } from '../styles/theme';
import { CompatibilityResult } from '../types/astrology';

type Props = {
  item: CompatibilityResult;
  onPress?: () => void;
};

export function CompatibilityCard({ item, onPress }: Props) {
  const content = (
    <View style={styles.card}>
      <View style={styles.accentLine} />

      <View style={styles.topRow}>
        <Text style={styles.match}>{item.match}</Text>
        <View style={styles.scorePill}>
          <Text style={styles.score}>{item.score}%</Text>
        </View>
      </View>

      <Text style={styles.summary}>
        {item.premium ? '🔒 ' : ''}
        {item.summary}
      </Text>
    </View>
  );

  if (onPress) {
    return (
      <TouchableOpacity activeOpacity={0.9} onPress={onPress}>
        {content}
      </TouchableOpacity>
    );
  }

  return content;
}

const styles = StyleSheet.create({
  card: {
    position: 'relative',
    backgroundColor: colors.cardStrong,
    borderRadius: 22,
    padding: 18,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    shadowColor: '#000',
    shadowOpacity: 0.35,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 6,
    overflow: 'hidden',
  },
  accentLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 2,
    backgroundColor: colors.accent,
    opacity: 0.8,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
    gap: 12,
  },
  match: {
    flex: 1,
    color: colors.text,
    fontSize: 16,
    fontWeight: '600',
  },
  scorePill: {
    backgroundColor: 'rgba(183, 160, 122, 0.12)',
    borderWidth: 1,
    borderColor: 'rgba(183, 160, 122, 0.22)',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
  },
  score: {
    color: colors.accent,
    fontSize: 14,
    fontWeight: '700',
  },
  summary: {
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 20,
  },
});