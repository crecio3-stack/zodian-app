// filepath: /Users/christianrecio/zodian/components/RewardItem.tsx
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors } from '../styles/theme';

type Props = {
  id?: string;
  streak: number;
  label?: string;
  dateKey?: string;
  createdAt?: string;
};

export default function RewardItem({ streak, label, dateKey }: Props) {
  return (
    <View style={styles.wrap}>
      <View style={styles.left}>
        <Text style={styles.streak}>{streak}🔥</Text>
      </View>
      <View style={styles.right}>
        <Text style={styles.label}>{label ?? `${streak}-day streak`}</Text>
        <Text style={styles.meta}>{dateKey}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.02)',
    borderWidth: 1,
    borderColor: 'rgba(216,184,107,0.06)',
    marginBottom: 10,
  },
  left: {
    width: 56,
    height: 56,
    borderRadius: 12,
    backgroundColor: 'rgba(216,184,107,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  streak: {
    color: colors.text,
    fontWeight: '800',
    fontSize: 18,
  },
  right: {
    flex: 1,
  },
  label: {
    color: colors.text,
    fontWeight: '700',
    fontSize: 15,
    marginBottom: 4,
  },
  meta: {
    color: colors.textMuted,
    fontSize: 12,
  },
});
