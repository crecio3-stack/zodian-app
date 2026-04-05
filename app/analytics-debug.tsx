import * as Haptics from 'expo-haptics';
import { router } from 'expo-router';
import React, { useCallback, useEffect, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { clearQueue, EVENTS, flushQueue, getQueuedEvents, getQueueSize, trackScreenView, type AnalyticsEvent } from '../lib/analytics/analytics';
import { colors } from '../styles/theme';

const CORE_METRICS = [
  {
    title: 'Onboarding completion',
    formula: 'onboarding_complete / onboarding_start',
  },
  {
    title: 'Blueprint open rate',
    formula: 'blueprint_viewed / ritual_revealed',
  },
  {
    title: 'Premium conversion',
    formula: 'premium_purchased / premium_viewed',
  },
  {
    title: 'Streak save rate',
    formula: 'ritual_completed when streak_at_risk / streak_at_risk',
  },
] as const;

function countEvents(events: AnalyticsEvent[], eventName: string) {
  return events.filter((event) => event.name === eventName).length;
}

export default function AnalyticsDebugScreen() {
  const [queueSize, setQueueSize] = useState(0);
  const [events, setEvents] = useState<AnalyticsEvent[]>([]);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadSnapshot = useCallback(async () => {
    setIsRefreshing(true);
    try {
      const [nextQueueSize, nextEvents] = await Promise.all([getQueueSize(), getQueuedEvents(40)]);
      setQueueSize(nextQueueSize);
      setEvents(nextEvents);
    } finally {
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    trackScreenView('analytics_debug').catch(() => {});
    loadSnapshot().catch(() => {});
  }, [loadSnapshot]);

  const handleRefresh = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    await loadSnapshot();
  };

  const handleFlush = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    await flushQueue();
    await loadSnapshot();
  };

  const handleClear = async () => {
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    await clearQueue();
    await loadSnapshot();
  };

  const queuedSnapshot = [
    { label: 'Starts', value: countEvents(events, EVENTS.ONBOARDING_START) },
    { label: 'Completes', value: countEvents(events, EVENTS.ONBOARDING_COMPLETE) },
    { label: 'Blueprint', value: countEvents(events, EVENTS.BLUEPRINT_VIEWED) },
    { label: 'Paywalls', value: countEvents(events, EVENTS.PREMIUM_VIEWED) },
    { label: 'Purchases', value: countEvents(events, EVENTS.PREMIUM_PURCHASED) },
    { label: 'At risk', value: countEvents(events, EVENTS.STREAK_AT_RISK) },
  ];

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <ScrollView style={styles.container} contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={styles.eyebrow}>DEV TOOLS</Text>
          <Text style={styles.title}>Analytics Debug</Text>
          <Text style={styles.subtitle}>Inspect the local analytics queue before events are flushed upstream.</Text>
        </View>

        <View style={styles.summaryCard}>
          <Text style={styles.summaryLabel}>Queued events</Text>
          <Text style={styles.summaryValue}>{queueSize}</Text>
          <Text style={styles.summaryHint}>{isRefreshing ? 'Refreshing…' : 'Latest 40 events shown below'}</Text>
        </View>

        <View style={styles.metricGrid}>
          {queuedSnapshot.map((item) => (
            <View key={item.label} style={styles.metricCard}>
              <Text style={styles.metricLabel}>{item.label}</Text>
              <Text style={styles.metricValue}>{item.value}</Text>
            </View>
          ))}
        </View>

        <View style={styles.referenceCard}>
          <Text style={styles.referenceTitle}>Core metrics</Text>
          {CORE_METRICS.map((metric) => (
            <View key={metric.title} style={styles.referenceRow}>
              <Text style={styles.referenceMetric}>{metric.title}</Text>
              <Text style={styles.referenceFormula}>{metric.formula}</Text>
            </View>
          ))}
        </View>

        <View style={styles.actionRow}>
          <Pressable style={styles.actionButton} onPress={handleRefresh}>
            <Text style={styles.actionButtonText}>Refresh</Text>
          </Pressable>
          <Pressable style={styles.actionButton} onPress={handleFlush}>
            <Text style={styles.actionButtonText}>Flush</Text>
          </Pressable>
          <Pressable style={[styles.actionButton, styles.dangerButton]} onPress={handleClear}>
            <Text style={styles.actionButtonText}>Clear</Text>
          </Pressable>
        </View>

        <Pressable style={styles.backButton} onPress={() => router.back()}>
          <Text style={styles.backButtonText}>Back</Text>
        </Pressable>

        {events.length === 0 ? (
          <View style={styles.emptyCard}>
            <Text style={styles.emptyTitle}>No queued events</Text>
            <Text style={styles.emptyBody}>Trigger a few flows in the app, then come back here to inspect the payloads.</Text>
          </View>
        ) : (
          events.map((event, index) => (
            <View key={`${event.name}-${event.timestamp ?? index}-${index}`} style={styles.eventCard}>
              <View style={styles.eventHeader}>
                <Text style={styles.eventName}>{event.name}</Text>
                <Text style={styles.eventTime}>{event.timestamp ? new Date(event.timestamp).toLocaleTimeString() : 'pending'}</Text>
              </View>
              <Text style={styles.eventBody}>{JSON.stringify(event.properties ?? {}, null, 2)}</Text>
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
  },
  content: {
    padding: 20,
    paddingBottom: 120,
    gap: 14,
  },
  header: {
    gap: 8,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.6,
  },
  title: {
    color: colors.text,
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '800',
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 15,
    lineHeight: 22,
  },
  summaryCard: {
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 18,
    gap: 6,
  },
  summaryLabel: {
    color: colors.accent,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1,
  },
  summaryValue: {
    color: colors.text,
    fontSize: 36,
    fontWeight: '800',
  },
  summaryHint: {
    color: colors.textMuted,
    fontSize: 13,
  },
  metricGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  metricCard: {
    width: '31%',
    minWidth: 92,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingHorizontal: 12,
    paddingVertical: 14,
    gap: 4,
  },
  metricLabel: {
    color: colors.textMuted,
    fontSize: 11,
    fontWeight: '700',
  },
  metricValue: {
    color: colors.text,
    fontSize: 24,
    fontWeight: '800',
  },
  referenceCard: {
    borderRadius: 22,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 18,
    gap: 12,
  },
  referenceTitle: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '700',
  },
  referenceRow: {
    gap: 4,
  },
  referenceMetric: {
    color: colors.accentSoft,
    fontSize: 13,
    fontWeight: '700',
  },
  referenceFormula: {
    color: colors.textSoft,
    fontSize: 12,
    lineHeight: 18,
  },
  actionRow: {
    flexDirection: 'row',
    gap: 10,
  },
  actionButton: {
    flex: 1,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    paddingVertical: 12,
    alignItems: 'center',
  },
  dangerButton: {
    borderColor: 'rgba(180,96,96,0.35)',
  },
  actionButtonText: {
    color: colors.accentSoft,
    fontSize: 13,
    fontWeight: '700',
  },
  backButton: {
    alignSelf: 'flex-start',
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
  },
  backButtonText: {
    color: colors.textSoft,
    fontSize: 12,
    fontWeight: '700',
  },
  emptyCard: {
    borderRadius: 22,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 18,
    gap: 6,
  },
  emptyTitle: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '700',
  },
  emptyBody: {
    color: colors.textSoft,
    fontSize: 14,
    lineHeight: 21,
  },
  eventCard: {
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 16,
    gap: 10,
  },
  eventHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 10,
  },
  eventName: {
    flex: 1,
    color: colors.text,
    fontSize: 14,
    fontWeight: '700',
  },
  eventTime: {
    color: colors.textMuted,
    fontSize: 12,
  },
  eventBody: {
    color: colors.textSoft,
    fontSize: 12,
    lineHeight: 18,
    fontFamily: 'Courier',
  },
});