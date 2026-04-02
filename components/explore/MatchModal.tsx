import React, { useEffect, useRef } from 'react';
import { Animated, Easing, Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { spacing, type } from '../../styles/tokens';

type Props = {
  visible: boolean;
  profile: any;
  onClose: () => void;
};

export default function MatchModal({ visible, profile, onClose }: Props) {
  const scale = useRef(new Animated.Value(0.6)).current;
  const glow = useRef(new Animated.Value(0)).current;

  const person = profile?.rawPerson ?? null;
  const name = person?.name ?? profile?.sign ?? 'Cosmic Match';
  const age = person?.age;
  const westernSign = person?.westernSign ?? profile?.element ?? 'Western';
  const chineseSign = person?.chineseSign ?? profile?.vibe ?? 'Eastern';
  const score = profile?.compatibility?.score ?? 88;
  const description = profile?.compatibility?.description ?? person?.bio ?? profile?.tagline ?? '';

  useEffect(() => {
    if (!visible) return;
    Animated.parallel([
      Animated.timing(scale, { toValue: 1, duration: 420, useNativeDriver: true, easing: Easing.out(Easing.exp) }),
      Animated.loop(Animated.sequence([
        Animated.timing(glow, { toValue: 1, duration: 900, useNativeDriver: false, easing: Easing.inOut(Easing.quad) }),
        Animated.timing(glow, { toValue: 0.2, duration: 900, useNativeDriver: false, easing: Easing.inOut(Easing.quad) }),
      ])),
    ]).start();
  }, [visible]);

  if (!profile) return null;

  const haloOpacity = glow.interpolate({
    inputRange: [0, 1],
    outputRange: [0.04, 0.14],
  });

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View style={styles.overlay}>
        <Animated.View pointerEvents="none" style={[styles.cardHalo, { opacity: haloOpacity }]} />
        <View style={styles.card}>
          {/* Native-driver layer: scale transform only */}
          <Animated.View style={{ transform: [{ scale }] }}>
            <Text style={styles.kicker}>A COSMIC LINK</Text>

            <Text style={styles.name}>{name}{age ? `, ${age}` : ''}</Text>

            <View style={styles.identityRow}>
              <Text style={styles.sign}>{westernSign}</Text>
              <Text style={styles.dot}>•</Text>
              <Text style={styles.sign}>{chineseSign}</Text>
            </View>

            <Text style={styles.score}>{score}% match</Text>

            <Text style={styles.copy}>{description}</Text>

            <View style={styles.actions}>
              <Pressable style={styles.primary} onPress={() => {
                onClose();
              }}>
                <Text style={styles.primaryText}>Send a Cosmic Note</Text>
              </Pressable>

              <Pressable style={styles.ghost} onPress={onClose}>
                <Text style={styles.ghostText}>Continue exploring</Text>
              </Pressable>
            </View>
          </Animated.View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(2,2,2,0.8)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.md,
  },
  cardHalo: {
    position: 'absolute',
    width: '94%',
    maxWidth: 580,
    height: 420,
    borderRadius: 24,
    backgroundColor: 'rgba(255,215,100,0.9)',
  },
  card: {
    width: '100%',
    maxWidth: 560,
    borderRadius: 20,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: 'rgba(255,215,100,0.22)',
    backgroundColor: 'rgba(10,10,14,0.96)',
  },
  kicker: { color: 'rgba(255,215,100,0.95)', marginBottom: 10, ...type.label },
  name: { color: '#fff', ...type.title2, fontWeight: '900' },
  identityRow: { flexDirection: 'row', alignItems: 'center', marginTop: 8, marginBottom: 12 },
  sign: { color: 'rgba(255,215,100,0.95)', ...type.title, marginHorizontal: 6, fontWeight: '700' },
  dot: { color: 'rgba(255,255,255,0.2)', fontSize: 18 },
  score: { color: '#fff', fontWeight: '900', fontSize: 40, marginTop: 2, marginBottom: 8 },
  copy: { color: '#d8d8de', ...type.body, lineHeight: 24, marginBottom: 18 },
  actions: { flexDirection: 'row', gap: spacing.sm },
  primary: { flex: 1, backgroundColor: 'rgba(255,215,100,0.95)', paddingVertical: 14, paddingHorizontal: 16, borderRadius: 14, alignItems: 'center' },
  primaryText: { color: '#0b0b0b', fontWeight: '800' },
  ghost: { flex: 1, paddingVertical: 14, paddingHorizontal: 14, borderRadius: 14, borderWidth: 1, borderColor: 'rgba(255,255,255,0.12)', alignItems: 'center' },
  ghostText: { color: '#d7d7dc' },
});