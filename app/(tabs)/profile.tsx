import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import React from 'react';
import {
    ActivityIndicator,
    Alert,
    Pressable,
    ScrollView,
    StyleSheet,
    Switch,
    Text,
    TextInput,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { usePremium } from '../../hooks/usePremium';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { useStoredName } from '../../hooks/useStoredName';
import { computeHomeSummary, setTodayHeroStateForDev } from '../../lib/storage/dailyStateService';
import { colors } from '../../styles/theme';
import { formatLongDate, getChineseSign, getWesternSign } from '../../utils/astrology';

const DATING_PROFILE_KEY = 'dating_profile_v1';

const INTEREST_OPTIONS = [
  'Coffee dates',
  'Fitness',
  'Travel',
  'Art',
  'Live music',
  'Foodie spots',
  'Books',
  'Hiking',
  'Spirituality',
  'Night drives',
];

const AVATAR_EMOJIS = ['✨', '🌙', '🔥', '🌊', '🪐', '🌹'];

type DatingProfileState = {
  avatarEmoji: string;
  aboutMe: string;
  lookingFor: string;
  prompt: string;
  interests: string[];
  showAge: boolean;
  showSigns: boolean;
  showDistance: boolean;
  pushNotifications: boolean;
  matchAlerts: boolean;
  profileVisible: boolean;
};

const DEFAULT_DATING_PROFILE: DatingProfileState = {
  avatarEmoji: AVATAR_EMOJIS[0],
  aboutMe: '',
  lookingFor: '',
  prompt: '',
  interests: [],
  showAge: true,
  showSigns: true,
  showDistance: true,
  pushNotifications: true,
  matchAlerts: true,
  profileVisible: true,
};

export default function ProfileScreen() {
  const { selectedDate, clearBirthdate } = useStoredBirthdate(new Date());
  const { name, clearName } = useStoredName();
  const { isPremium, hasLoaded, enablePremium, disablePremium } = usePremium();

  const [profileState, setProfileState] = React.useState<DatingProfileState>(DEFAULT_DATING_PROFILE);
  const [hasLoadedProfile, setHasLoadedProfile] = React.useState(false);
  const [isSaving, setIsSaving] = React.useState(false);
  const [devHomeRevealed, setDevHomeRevealed] = React.useState(false);

  const western = getWesternSign(selectedDate);
  const chinese = getChineseSign(selectedDate);

  React.useEffect(() => {
    (async () => {
      try {
        const raw = await AsyncStorage.getItem(DATING_PROFILE_KEY);
        if (raw) {
          const parsed = JSON.parse(raw) as Partial<DatingProfileState>;
          setProfileState({ ...DEFAULT_DATING_PROFILE, ...parsed });
        }
      } catch {
        // no-op
      } finally {
        setHasLoadedProfile(true);
      }
    })();
  }, []);

  React.useEffect(() => {
    if (!__DEV__) return;

    (async () => {
      try {
        const summary = await computeHomeSummary();
        setDevHomeRevealed(Boolean(summary.revealed));
      } catch {
        // no-op
      }
    })();
  }, []);

  const displayName = name?.trim() ? name.trim() : 'You';

  const toggleInterest = (interest: string) => {
    setProfileState((prev) => {
      const hasIt = prev.interests.includes(interest);
      return {
        ...prev,
        interests: hasIt
          ? prev.interests.filter((item) => item !== interest)
          : [...prev.interests, interest],
      };
    });
  };

  const cycleAvatar = async () => {
    await Haptics.selectionAsync();
    setProfileState((prev) => {
      const currentIndex = AVATAR_EMOJIS.indexOf(prev.avatarEmoji);
      const nextIndex = currentIndex >= 0 ? (currentIndex + 1) % AVATAR_EMOJIS.length : 0;
      return { ...prev, avatarEmoji: AVATAR_EMOJIS[nextIndex] };
    });
  };

  const saveDatingProfile = async () => {
    try {
      setIsSaving(true);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      await AsyncStorage.setItem(DATING_PROFILE_KEY, JSON.stringify(profileState));
      Alert.alert('Saved', 'Your dating profile updates are live.');
    } catch {
      Alert.alert('Save failed', 'Could not save profile changes right now.');
    } finally {
      setIsSaving(false);
    }
  };

  const handlePremiumToggle = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (isPremium) {
      await disablePremium();
      return;
    }
    await enablePremium();
  };

  const handleReset = () => {
    Alert.alert(
      'Reset profile?',
      'This clears your onboarding identity and dating profile setup, then returns you to onboarding.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: async () => {
            await clearName();
            await clearBirthdate();
            await AsyncStorage.removeItem(DATING_PROFILE_KEY);
            router.replace('/onboarding/welcome');
          },
        },
      ]
    );
  };

  const handleDevHomeRevealToggle = async () => {
    if (!__DEV__) return;

    const next = !devHomeRevealed;
    try {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      await setTodayHeroStateForDev({
        revealed: next,
        completed: next,
      });
      setDevHomeRevealed(next);
    } catch {
      Alert.alert('Dev toggle failed', 'Could not update Home hero state.');
    }
  };

  if (!hasLoadedProfile) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <LinearGradient colors={[colors.background, '#09090F', colors.background]} style={StyleSheet.absoluteFill} />
        <View style={styles.loadingWrap}>
          <ActivityIndicator size="small" color={colors.accent} />
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <LinearGradient colors={[colors.background, '#09090F', colors.background]} style={StyleSheet.absoluteFill} />

      <ScrollView style={styles.container} contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.heroCard}>
          <View style={styles.heroRow}>
            <Pressable style={styles.avatarButton} onPress={cycleAvatar}>
              <Text style={styles.avatarText}>{profileState.avatarEmoji}</Text>
            </Pressable>
            <View style={styles.heroMeta}>
              <Text style={styles.title}>{displayName}</Text>
              <Text style={styles.subtitle}>{western} / {chinese}</Text>
            </View>
          </View>
        </View>

        <View style={styles.sectionCard}>
          <Text style={styles.sectionTitle}>About Me</Text>
          <TextInput
            value={profileState.aboutMe}
            onChangeText={(text) => setProfileState((prev) => ({ ...prev, aboutMe: text }))}
            placeholder="Write a short intro..."
            placeholderTextColor={colors.textMuted}
            multiline
            textAlignVertical="top"
            maxLength={220}
            style={[styles.input, styles.inputLarge]}
          />

          <Text style={styles.fieldLabel}>Looking for</Text>
          <TextInput
            value={profileState.lookingFor}
            onChangeText={(text) => setProfileState((prev) => ({ ...prev, lookingFor: text }))}
            placeholder="Relationship, long-term, open to meeting..."
            placeholderTextColor={colors.textMuted}
            maxLength={120}
            style={styles.input}
          />

          <Text style={styles.fieldLabel}>Prompt: My ideal first date is...</Text>
          <TextInput
            value={profileState.prompt}
            onChangeText={(text) => setProfileState((prev) => ({ ...prev, prompt: text }))}
            placeholder="Coffee walk, rooftop dinner, museum date..."
            placeholderTextColor={colors.textMuted}
            maxLength={140}
            style={styles.input}
          />
        </View>

        <View style={styles.sectionCard}>
          <Text style={styles.sectionTitle}>Interests</Text>
          <View style={styles.chipsWrap}>
            {INTEREST_OPTIONS.map((interest) => {
              const selected = profileState.interests.includes(interest);
              return (
                <Pressable
                  key={interest}
                  onPress={() => toggleInterest(interest)}
                  style={[styles.chip, selected ? styles.chipOn : styles.chipOff]}
                >
                  <Text style={[styles.chipText, selected ? styles.chipTextOn : styles.chipTextOff]}>{interest}</Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        <View style={styles.sectionCard}>
          <Text style={styles.sectionTitle}>Profile Visibility</Text>
          <SettingsRow
            label="Profile visible in Match"
            value={profileState.profileVisible}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, profileVisible: value }))}
          />
          <SettingsRow
            label="Show age"
            value={profileState.showAge}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, showAge: value }))}
          />
          <SettingsRow
            label="Show astrological signs"
            value={profileState.showSigns}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, showSigns: value }))}
          />
          <SettingsRow
            label="Show distance"
            value={profileState.showDistance}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, showDistance: value }))}
          />
        </View>

        <View style={styles.sectionCard}>
          <Text style={styles.sectionTitle}>Notifications</Text>
          <SettingsRow
            label="Push notifications"
            value={profileState.pushNotifications}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, pushNotifications: value }))}
          />
          <SettingsRow
            label="Match and like alerts"
            value={profileState.matchAlerts}
            onValueChange={(value) => setProfileState((prev) => ({ ...prev, matchAlerts: value }))}
          />
        </View>

        <Pressable style={styles.primaryButton} onPress={saveDatingProfile} disabled={isSaving}>
          <Text style={styles.primaryButtonText}>{isSaving ? 'Saving...' : 'Save Dating Profile'}</Text>
        </Pressable>

        {__DEV__ ? (
          <View style={styles.sectionCard}>
            <Text style={styles.sectionTitle}>Dev Only</Text>
            <Pressable style={styles.secondaryButton} onPress={handleDevHomeRevealToggle}>
              <Text style={styles.secondaryButtonText}>Home Hero Reveal: {devHomeRevealed ? 'ON' : 'OFF'}</Text>
            </Pressable>

            <View style={[styles.rowBetween, { marginTop: 12 }]}>
              <Text style={styles.fieldLabel}>Premium status</Text>
              {hasLoaded ? (
                <View style={[styles.statusPill, isPremium ? styles.statusPillOn : styles.statusPillOff]}>
                  <Text style={[styles.statusPillText, isPremium ? styles.statusTextOn : styles.statusTextOff]}>
                    {isPremium ? 'ON' : 'OFF'}
                  </Text>
                </View>
              ) : (
                <ActivityIndicator size="small" color={colors.accent} />
              )}
            </View>

            <Pressable style={styles.secondaryButton} onPress={handlePremiumToggle}>
              <Text style={styles.secondaryButtonText}>{isPremium ? 'Turn Premium Off' : 'Turn Premium On'}</Text>
            </Pressable>

            <Pressable
              style={styles.dangerButton}
              onPress={async () => {
                await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
                handleReset();
              }}
            >
              <Text style={styles.dangerButtonText}>Reset Onboarding</Text>
            </Pressable>
          </View>
        ) : null}

        <View style={styles.sectionCard}>
          <Text style={styles.sectionTitle}>Account</Text>
          <View style={styles.detailPill}>
            <Text style={styles.fieldLabel}>Birthdate</Text>
            <Text style={styles.valueText}>{formatLongDate(selectedDate)}</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function SettingsRow({
  label,
  value,
  onValueChange,
}: {
  label: string;
  value: boolean;
  onValueChange: (next: boolean) => void;
}) {
  return (
    <View style={styles.settingsRow}>
      <Text style={styles.settingsLabel}>{label}</Text>
      <Switch
        value={value}
        onValueChange={onValueChange}
        trackColor={{ false: 'rgba(255,255,255,0.2)', true: 'rgba(214,181,107,0.45)' }}
        thumbColor={value ? colors.accent : '#C9CDD7'}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  loadingWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  container: {
    flex: 1,
    backgroundColor: 'transparent',
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 140,
    gap: 14,
  },
  heroCard: {
    borderRadius: 24,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 16,
  },
  heroRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  avatarButton: {
    width: 72,
    height: 72,
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  avatarText: {
    fontSize: 32,
  },
  heroMeta: {
    flex: 1,
  },
  title: {
    color: colors.text,
    fontSize: 28,
    lineHeight: 32,
    fontWeight: '800',
    marginBottom: 4,
  },
  subtitle: {
    color: colors.textSoft,
    fontSize: 14,
  },
  sectionCard: {
    borderRadius: 22,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: colors.card,
    padding: 16,
  },
  sectionTitle: {
    color: colors.text,
    fontSize: 19,
    fontWeight: '700',
    marginBottom: 10,
  },
  fieldLabel: {
    color: colors.textMuted,
    fontSize: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.8,
    marginBottom: 6,
  },
  input: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.16)',
    backgroundColor: 'rgba(255,255,255,0.02)',
    color: colors.text,
    fontSize: 15,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 12,
  },
  inputLarge: {
    minHeight: 108,
  },
  chipsWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  chip: {
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  chipOn: {
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.06)',
  },
  chipOff: {
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  chipText: {
    fontSize: 13,
    fontWeight: '600',
  },
  chipTextOn: {
    color: colors.accent,
  },
  chipTextOff: {
    color: colors.textSoft,
  },
  settingsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'rgba(255,255,255,0.08)',
  },
  settingsLabel: {
    color: colors.text,
    fontSize: 15,
    flex: 1,
    paddingRight: 10,
  },
  primaryButton: {
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    backgroundColor: colors.accent,
  },
  primaryButtonText: {
    color: '#111111',
    fontSize: 16,
    fontWeight: '800',
  },
  secondaryButton: {
    marginTop: 8,
    borderRadius: 999,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  secondaryButtonText: {
    color: colors.text,
    fontSize: 15,
    fontWeight: '700',
  },
  rowBetween: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 10,
  },
  statusPill: {
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  statusPillOn: {
    borderColor: colors.secondaryAccentGlow,
    backgroundColor: 'rgba(125,141,107,0.12)',
  },
  statusPillOff: {
    borderColor: colors.cardBorder,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  statusPillText: {
    fontSize: 11,
    fontWeight: '800',
    letterSpacing: 0.8,
  },
  statusTextOn: {
    color: colors.secondaryAccent,
  },
  statusTextOff: {
    color: colors.textMuted,
  },
  detailPill: {
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(214,181,107,0.14)',
    backgroundColor: 'rgba(255,255,255,0.02)',
    padding: 12,
    marginBottom: 8,
  },
  valueText: {
    color: colors.text,
    fontSize: 17,
    fontWeight: '700',
  },
  dangerButton: {
    marginTop: 8,
    borderRadius: 999,
    alignItems: 'center',
    paddingVertical: 13,
    borderWidth: 1,
    borderColor: 'rgba(255,120,120,0.36)',
    backgroundColor: 'rgba(255,120,120,0.08)',
  },
  dangerButtonText: {
    color: '#FFB3B3',
    fontSize: 15,
    fontWeight: '700',
  },
});
