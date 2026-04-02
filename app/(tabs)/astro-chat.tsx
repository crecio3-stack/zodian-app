import React, { useEffect, useMemo, useRef } from 'react';
import { ActivityIndicator, FlatList, KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { AstroChatComposer } from '../../components/AstroChatComposer';
import { AstroChatEmpty } from '../../components/AstroChatEmpty';
import { AstroChatMessage } from '../../components/AstroChatMessage';
import { StarterPrompts } from '../../components/StarterPrompts';
import { useAstrologerChat } from '../../hooks/useAstrologerChat';
import { useStoredBirthdate } from '../../hooks/useStoredBirthdate';
import { useStoredName } from '../../hooks/useStoredName';
import { STARTER_PROMPTS } from '../../lib/ai/astrologerService';
import { colors, radius, spacing } from '../../styles/theme';
import { getChineseSign, getWesternSign } from '../../utils/astrology';

const TAB_BAR_CLEARANCE = 96;

export default function AstroChatScreen() {
  const insets = useSafeAreaInsets();
  const { selectedDate } = useStoredBirthdate(new Date());
  const { name } = useStoredName();
  const westernSign = useMemo(() => getWesternSign(selectedDate), [selectedDate]);
  const chineseSign = useMemo(() => getChineseSign(selectedDate), [selectedDate]);

  const { messages, isLoading, error, sendMessage, clearError } = useAstrologerChat({
    westernSign,
    chineseSign,
    birthdate: selectedDate,
    name,
  });

  const flatListRef = useRef<FlatList>(null);
  const styles = useMemo(() => createStyles(), []);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    if (messages.length > 0) {
      setTimeout(() => {
        flatListRef.current?.scrollToEnd({ animated: true });
      }, 100);
    }
  }, [messages]);

  const handleStarterPrompt = (prompt: string) => {
    sendMessage(prompt);
  };

  const isEmpty = messages.length === 0;

  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'left', 'right']}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 10 : 0}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.headerTitle}>{name ? `${name}'s Astrology Chat` : 'Astrology Chat'}</Text>
          <Text style={styles.headerSubtitle}>
            {westernSign} × {chineseSign}
          </Text>
        </View>

        {/* Messages Area */}
        {isEmpty ? (
          <AstroChatEmpty westernSign={westernSign} chineseSign={chineseSign} name={name} />
        ) : (
          <FlatList
            ref={flatListRef}
            data={messages}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => <AstroChatMessage message={item} />}
            contentContainerStyle={styles.messagesList}
            showsVerticalScrollIndicator={false}
            scrollEnabled
          />
        )}

        {/* Error State */}
        {error && (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>Couldn't generate response. Give it another shot.</Text>
            <Pressable onPress={clearError} style={styles.errorDismiss}>
              <Text style={styles.errorDismissText}>Got it</Text>
            </Pressable>
          </View>
        )}

        {/* Loading Indicator */}
        {isLoading && (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="small" color={colors.accent} />
          </View>
        )}

        {/* Starter Prompts */}
        {isEmpty && !isLoading && (
          <View style={{ paddingBottom: 8 }}>
            <StarterPrompts
              prompts={STARTER_PROMPTS}
              onSelectPrompt={handleStarterPrompt}
              disabled={isLoading}
            />
          </View>
        )}

        {/* Composer */}
        <View style={{ paddingBottom: Math.max(insets.bottom, 20) + TAB_BAR_CLEARANCE }}>
          <AstroChatComposer onSendMessage={sendMessage} isLoading={isLoading} />
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

function createStyles() {
  return StyleSheet.create({
    safeArea: {
      flex: 1,
      backgroundColor: colors.background,
    },
    container: {
      flex: 1,
      backgroundColor: colors.background,
    },
    header: {
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.md,
      borderBottomWidth: 1,
      borderBottomColor: 'rgba(216,184,107,0.1)',
    },
    headerTitle: {
      fontSize: 24,
      fontWeight: '800',
      color: colors.text,
      marginBottom: spacing.xs,
    },
    headerSubtitle: {
      fontSize: 13,
      color: colors.accent,
      fontWeight: '600',
      letterSpacing: 0.5,
      textTransform: 'uppercase',
    },
    messagesList: {
      paddingTop: spacing.md,
      paddingBottom: spacing.lg,
    },
    loadingContainer: {
      paddingVertical: spacing.lg,
      alignItems: 'center',
    },
    errorContainer: {
      marginHorizontal: spacing.lg,
      marginVertical: spacing.md,
      backgroundColor: 'rgba(216,184,107,0.1)',
      borderWidth: 1,
      borderColor: 'rgba(216,184,107,0.3)',
      borderRadius: radius.lg,
      padding: spacing.md,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
    },
    errorText: {
      flex: 1,
      fontSize: 13,
      color: colors.text,
      lineHeight: 18,
      marginRight: spacing.md,
    },
    errorDismiss: {
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
    },
    errorDismissText: {
      fontSize: 12,
      fontWeight: '600',
      color: colors.accent,
    },
  });
}
