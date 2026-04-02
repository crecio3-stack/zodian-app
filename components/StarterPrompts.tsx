import React, { useMemo } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';

interface StarterPromptsProps {
  prompts: Array<{ text: string; emoji: string }>;
  onSelectPrompt: (prompt: string) => void;
  disabled?: boolean;
}

export const StarterPrompts: React.FC<StarterPromptsProps> = ({
  prompts,
  onSelectPrompt,
  disabled = false,
}) => {
  const styles = useMemo(() => createStyles(), []);

  return (
    <View style={styles.container}>
      <Text style={styles.label}>Try asking something</Text>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
        style={styles.scroll}
      >
        {prompts.map((prompt, idx) => (
          <Pressable
            key={idx}
            onPress={() => onSelectPrompt(prompt.text)}
            disabled={disabled}
            style={({ pressed }) => [
              styles.chip,
              pressed && { opacity: 0.75 },
              disabled && { opacity: 0.5 },
            ]}
          >
            <Text style={styles.emoji}>{prompt.emoji}</Text>
            <Text style={styles.chipText} numberOfLines={2}>
              {prompt.text}
            </Text>
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
};

function createStyles() {
  return StyleSheet.create({
    container: {
      paddingVertical: spacing.lg,
      borderTopWidth: 1,
      borderTopColor: 'rgba(216,184,107,0.1)',
    },
    label: {
      fontSize: 13,
      letterSpacing: 0.5,
      color: colors.textMuted,
      textTransform: 'uppercase',
      fontWeight: '600',
      paddingHorizontal: spacing.lg,
      marginBottom: spacing.md,
    },
    scroll: {
      flex: 0,
    },
    scrollContent: {
      paddingHorizontal: spacing.lg,
      gap: spacing.md,
    },
    chip: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: 'rgba(216,184,107,0.08)',
      borderWidth: 1,
      borderColor: 'rgba(216,184,107,0.24)',
      borderRadius: radius.pill,
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.sm,
      gap: spacing.md,
      minHeight: 44,
    },
    emoji: {
      fontSize: 18,
    },
    chipText: {
      fontSize: 13,
      fontWeight: '500',
      color: colors.text,
      maxWidth: 120,
    },
  });
}
