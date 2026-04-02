import React, { useMemo } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';
import { ChatMessage } from '../types/chat';

interface AstroChatMessageProps {
  message: ChatMessage;
}

export const AstroChatMessage: React.FC<AstroChatMessageProps> = ({ message }) => {
  const styles = useMemo(() => createStyles(), []);
  const isUser = message.role === 'user';

  return (
    <View style={[styles.container, isUser ? styles.userContainer : styles.assistantContainer]}>
      <View style={[styles.bubble, isUser ? styles.userBubble : styles.assistantBubble]}>
        <Text style={[styles.text, isUser ? styles.userText : styles.assistantText]}>
          {message.content}
        </Text>
      </View>
    </View>
  );
};

function createStyles() {
  return StyleSheet.create({
    container: {
      flexDirection: 'row',
      marginVertical: spacing.md,
      paddingHorizontal: spacing.lg,
    },
    userContainer: {
      justifyContent: 'flex-end',
    },
    assistantContainer: {
      justifyContent: 'flex-start',
    },
    bubble: {
      borderRadius: radius.lg,
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.md,
      maxWidth: '85%',
    },
    userBubble: {
      backgroundColor: colors.accent,
      borderBottomRightRadius: radius.sm,
    },
    assistantBubble: {
      backgroundColor: 'rgba(216,184,107,0.12)',
      borderBottomLeftRadius: radius.sm,
      borderWidth: 1,
      borderColor: 'rgba(216,184,107,0.24)',
    },
    text: {
      fontSize: 15,
      lineHeight: 22,
    },
    userText: {
      color: colors.background,
      fontWeight: '500',
    },
    assistantText: {
      color: colors.text,
    },
  });
}
