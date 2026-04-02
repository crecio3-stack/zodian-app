import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { Dimensions, ImageBackground, Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors } from '../../styles/theme';
import { radius, spacing, type } from '../../styles/tokens';
import { ZodiacProfile } from '../../types/zodiac';

type Props = {
  visible: boolean;
  profile: ZodiacProfile;
  onClose: () => void;
};

export default function DetailModal({ visible, profile, onClose }: Props) {
  const insets = useSafeAreaInsets();
  const raw = (profile as any)?.rawPerson;
  const name = raw?.name || profile.sign;
  const age = raw?.age;
  const photo = raw?.photo;
  const bio = raw?.bio || profile.tagline;
  const interests: string[] = Array.isArray(raw?.interests) && raw.interests.length ? raw.interests : profile.traits || [];
  const emotionalNeeds: string[] = Array.isArray(raw?.emotionalNeeds) && raw.emotionalNeeds.length ? raw.emotionalNeeds : profile.emotionalNeeds || [];
  const westernSign = raw?.westernSign || profile.element;
  const chineseSign = raw?.chineseSign || profile.vibe;

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="fullScreen" onRequestClose={onClose}>
      <View style={styles.container}>
        <ScrollView contentContainerStyle={[styles.content, { paddingTop: Math.max(insets.top + 8, 18) }]}>
          <View style={styles.heroWrap}>
            {photo ? (
              <ImageBackground source={photo} style={styles.heroImage} imageStyle={styles.heroImageRadius}>
                <LinearGradient
                  colors={['rgba(0,0,0,0.08)', 'rgba(0,0,0,0.32)', 'rgba(0,0,0,0.84)']}
                  locations={[0, 0.52, 1]}
                  style={StyleSheet.absoluteFill}
                />
              </ImageBackground>
            ) : (
              <LinearGradient colors={['#191A22', '#12141C', '#0B0C12']} style={styles.heroImage}>
                <Text style={styles.fallbackSymbol}>{profile.symbol}</Text>
              </LinearGradient>
            )}

            <Pressable onPress={onClose} style={styles.closeButton} accessibilityRole="button" accessibilityLabel="Close profile details">
              <Text style={styles.closeButtonText}>Close</Text>
            </Pressable>

            <View style={styles.heroMeta}>
              <Text style={styles.name}>{name}{age ? `, ${age}` : ''}</Text>
              <Text style={styles.signs}>{westernSign} • {chineseSign}</Text>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>About</Text>
            <Text style={styles.body}>{bio}</Text>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Astrological identity</Text>
            <View style={styles.rowWrap}>
              <View style={styles.tag}><Text style={styles.tagText}>Western: {westernSign}</Text></View>
              <View style={styles.tag}><Text style={styles.tagText}>Eastern: {chineseSign}</Text></View>
              <View style={styles.tag}><Text style={styles.tagText}>Archetype: {profile.archetype}</Text></View>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Compatibility</Text>
            <View style={styles.hintCard}>
              <Text style={styles.hintText}>{profile.compatibilityHint}</Text>
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Interests</Text>
            <View style={styles.rowWrap}>
              {interests.map((interest) => (
                <View key={interest} style={styles.tag}>
                  <Text style={styles.tagText}>{interest}</Text>
                </View>
              ))}
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Dating style</Text>
            <Text style={styles.body}>{profile.datingStyle || 'Intentional and relationship-minded.'}</Text>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Emotional needs</Text>
            <View style={styles.rowWrap}>
              {emotionalNeeds.map((need) => (
                <View key={need} style={styles.tag}>
                  <Text style={styles.tagText}>{need}</Text>
                </View>
              ))}
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>Best matches</Text>
            <Text style={styles.body}>
              {profile.bestMatches && profile.bestMatches.length ? profile.bestMatches.join(' • ') : 'Discover matches through swipes and connection energy.'}
            </Text>
          </View>

          <View style={{ height: 60 }} />
        </ScrollView>
      </View>
    </Modal>
  );
}

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#06070B',
  },
  content: {
    paddingHorizontal: spacing.lg,
    paddingBottom: Math.min(240, SCREEN_HEIGHT * 0.35),
  },
  heroWrap: {
    marginBottom: 18,
    borderRadius: radius.xl,
    overflow: 'hidden',
    backgroundColor: '#11131A',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  heroImage: {
    height: Math.min(510, SCREEN_HEIGHT * 0.56),
    justifyContent: 'flex-end',
  },
  heroImageRadius: {
    borderRadius: radius.xl,
  },
  fallbackSymbol: {
    ...type.title1,
    color: colors.accent,
    textAlign: 'center',
    marginTop: 90,
    opacity: 0.85,
  },
  closeButton: {
    position: 'absolute',
    top: 14,
    right: 14,
    backgroundColor: 'rgba(0,0,0,0.55)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
    borderRadius: radius.pill,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  closeButtonText: {
    ...type.label,
    color: '#FFFFFF',
  },
  heroMeta: {
    position: 'absolute',
    left: 16,
    right: 16,
    bottom: 16,
  },
  name: {
    ...type.title,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  signs: {
    ...type.body,
    color: 'rgba(255,255,255,0.9)',
  },
  section: {
    marginTop: spacing.md,
  },
  label: {
    ...type.label,
    color: colors.accent,
    marginBottom: 8,
  },
  body: {
    ...type.body,
    color: '#E9EBF2',
    lineHeight: 22,
  },
  rowWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  tag: {
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
    backgroundColor: 'rgba(255,255,255,0.04)',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  tagText: {
    color: '#F1F2F7',
    fontSize: 12,
    fontWeight: '600',
  },
  hintCard: {
    marginTop: 6,
    padding: 14,
    borderRadius: radius.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
  },
  hintText: {
    ...type.body,
    color: '#EEF0F6',
  },
});