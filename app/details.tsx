import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useMemo, useRef } from 'react';
import { Animated, Easing, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GlassCard } from '../components/GlassCard';
import { getDailyRitual } from '../data/dailyRitual';
import { getDailyReading } from '../data/readings';
import { useStoredBirthdate } from '../hooks/useStoredBirthdate';
import { useStoredName } from '../hooks/useStoredName';
import { colors, spacing } from '../styles/theme';
import { radius, type } from '../styles/tokens';
import { formatLongDate, getChineseSign, getWesternSign } from '../utils/astrology';

export default function DetailsScreen() {
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();
  const params = useLocalSearchParams();
  const {
    westernSign: paramWestern,
    chineseSign: paramChinese,
    ritualHeadline: paramHeadline,
    ritualCoreMessage: paramCore,
    focusLabel: paramFocusLabel,
    focusBody: paramFocusBody,
  } = (params as any) || {};

  const westernSign = useMemo(() => String(paramWestern || getWesternSign(selectedDate)), [paramWestern, selectedDate]);
  const chineseSign = useMemo(() => String(paramChinese || getChineseSign(selectedDate)), [paramChinese, selectedDate]);

  const fallbackRitual = useMemo(() => getDailyRitual(westernSign as any, chineseSign as any), [westernSign, chineseSign]);
  const fallbackReading = useMemo(() => getDailyReading(westernSign as any, chineseSign as any, new Date()), [westernSign, chineseSign]);

  const ritualHeadline = String(paramHeadline || (fallbackRitual as any)?.headline || (fallbackRitual as any)?.title || 'Your Daily Signature');
  const ritualCore = String(paramCore || (fallbackRitual as any)?.coreMessage || (fallbackRitual as any)?.subtitle || fallbackReading.overall || 'Your energy is asking for clarity and intention today.');
  const focusLabel = String(paramFocusLabel || 'Today\'s focus');
  const focusBody = String(paramFocusBody || (fallbackRitual as any)?.advice || fallbackReading.love || 'Choose one meaningful next move and stay close to it.');

  const deepHoroscope = useMemo(() => {
    const paragraphOne = `${name ? `${name}, ` : ''}today's deeper pattern around ${westernSign} x ${chineseSign} is about alignment over noise. Your main ritual theme, "${ritualHeadline}", is asking you to reduce scattered attention and return to what actually matters. ${ritualCore} The energy is not about doing more, it is about doing the right thing with full presence.`;

    const paragraphTwo = `Your practical next layer is simple: live your ${focusLabel.toLowerCase()} in one concrete moment today. ${focusBody} If emotions rise, treat that as information rather than interruption. The day opens most when you choose one clear intention, express it honestly, and let consistency carry the rest.`;

    return {
      paragraphOne,
      paragraphTwo,
    };
  }, [name, westernSign, chineseSign, ritualHeadline, ritualCore, focusLabel, focusBody]);

  const headerAnim = useRef(new Animated.Value(0)).current;
  const contentAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.timing(headerAnim, { toValue: 1, duration: 420, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
      Animated.timing(contentAnim, { toValue: 1, duration: 420, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
    ]).start();
  }, [headerAnim, contentAnim]);

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Animated.View style={[styles.header, { opacity: headerAnim, transform: [{ translateY: headerAnim.interpolate({ inputRange: [0,1], outputRange: [10,0] }) }] }] }>
          <Text style={styles.sign}>{westernSign} × {chineseSign}</Text>
          <Text style={styles.headline}>{ritualHeadline}</Text>
          <Text style={styles.date}>{formatLongDate(new Date())}</Text>
        </Animated.View>

        <Animated.View style={{ opacity: contentAnim, transform: [{ translateY: contentAnim.interpolate({ inputRange: [0,1], outputRange: [10,0] }) }] }}>
          <GlassCard style={styles.card}>
            <Text style={styles.label}>DEEP HOROSCOPE</Text>
            <Text style={styles.bodyText}>{deepHoroscope.paragraphOne}</Text>
            <Text style={styles.bodyTextSecondary}>{deepHoroscope.paragraphTwo}</Text>
          </GlassCard>

          <View style={styles.actions}>
            <Pressable
              onPress={() =>
                router.push({
                  pathname: '/blueprint',
                  params: { source: 'details', westernSign, chineseSign },
                })
              }
              style={({ pressed }) => [styles.blueprintButton, pressed && { opacity: 0.9 }]}
            >
              <Text style={styles.blueprintButtonText}>Open Cosmic Blueprint</Text>
            </Pressable>

            <Pressable onPress={() => router.back()} style={({ pressed }) => [{ padding: 12, borderRadius: 12, opacity: pressed ? 0.85 : 1 }] }>
              <Text style={styles.closeText}>Back</Text>
            </Pressable>
          </View>
        </Animated.View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.background },
  container: { padding: spacing.lg, paddingBottom: 120 },
  header: { marginBottom: 14 },
  sign: { ...type.title2, color: colors.accentBright, fontWeight: '800' },
  headline: { ...type.title, color: colors.text, marginTop: 6, fontWeight: '700' },
  date: { ...type.bodySmall, color: colors.textMuted, marginTop: 6 },
  card: { marginTop: 12, padding: 18, borderRadius: radius.lg },
  label: { ...type.label, color: colors.accent, marginBottom: 10 },
  bodyText: { ...type.body, color: colors.text, lineHeight: 22 },
  bodyTextSecondary: { ...type.body, color: colors.textSoft, lineHeight: 22, marginTop: 14 },
  actions: { marginTop: 18, alignItems: 'flex-start' },
  blueprintButton: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    marginBottom: 10,
  },
  blueprintButtonText: {
    ...type.label,
    color: colors.accent,
  },
  closeText: { color: colors.accentSoft, ...type.label },
});