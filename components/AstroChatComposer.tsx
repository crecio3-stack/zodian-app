import React, { useMemo, useRef } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { colors, radius, spacing } from '../styles/theme';

interface AstroChatComposerProps {
  onSendMessage: (text: string) => void;
  isLoading?: boolean;
}

export const AstroChatComposer: React.FC<AstroChatComposerProps> = ({ onSendMessage, isLoading = false }) => {
  const inputRef = useRef<TextInput>(null);
  const [text, setText] = React.useState('');
  const styles = useMemo(() => createStyles(), []);

  const handleSend = () => {
    if (text.trim() && !isLoading) {
      onSendMessage(text.trim());
      setText('');
      inputRef.current?.clear();
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.inputWrapper}>
        <TextInput
          ref={inputRef}
          style={styles.input}
          placeholder="Ask me anything about your signs..."
          placeholderTextColor={colors.textMuted}
          value={text}
          onChangeText={setText}
          editable={!isLoading}
          multiline
          maxLength={512}
        />
        <Pressable
          onPress={handleSend}
          disabled={!text.trim() || isLoading}
          style={({ pressed }) => [
            styles.sendButton,
            (!text.trim() || isLoading) && styles.sendButtonDisabled,
            pressed && { transform: [{ scale: 0.95 }] },
          ]}
        >
          <Text style={styles.sendButtonText}>↑</Text>
        </Pressable>
      </View>
    </View>
  );
};

function createStyles() {
  return StyleSheet.create({
    container: {
      paddingHorizontal: spacing.lg,
      paddingVertical: spacing.lg,
      borderTopWidth: 1,
      borderTopColor: 'rgba(216,184,107,0.1)',
    },
    inputWrapper: {
      flexDirection: 'row',
      alignItems: 'flex-end',
      gap: spacing.md,
      backgroundColor: colors.cardStrong,
      borderRadius: radius.lg,
      borderWidth: 1,
      borderColor: 'rgba(216,184,107,0.2)',
      paddingHorizontal: spacing.md,
      paddingVertical: spacing.sm,
    },
    input: {
      flex: 1,
      fontSize: 15,
      color: colors.text,
      minHeight: 40,
      maxHeight: 100,
      textAlignVertical: 'center',
    },
    sendButton: {
      width: 36,
      height: 36,
      borderRadius: 18,
      backgroundColor: colors.accent,
      justifyContent: 'center',
      alignItems: 'center',
      marginBottom: spacing.sm,
    },
    sendButtonDisabled: {
      opacity: 0.4,
    },
    sendButtonText: {
      color: colors.background,
      fontSize: 18,
      fontWeight: '700',
    },
  });
}
