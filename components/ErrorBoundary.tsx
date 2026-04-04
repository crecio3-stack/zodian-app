/**
 * Error boundary component
 * 
 * Catches render errors and displays fallback UI
 * Logs to Sentry/telemetry
 */

import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { captureException } from '../lib/telemetry/sentry';
import { colors } from '../styles/theme';
import { spacing, typography } from '../styles/tokens';

export class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { error: Error | null; hasError: boolean }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { error: null, hasError: false };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
    captureException(error, { errorInfo, componentStack: errorInfo.componentStack });
  }

  handleReset = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      return (
        <SafeAreaView style={styles.container}>
          <ScrollView contentContainerStyle={styles.content}>
            <View style={styles.iconWrap}>
              <Ionicons name="alert-circle-outline" size={64} color={colors.accent} />
            </View>

            <Text style={styles.title}>Something went wrong</Text>

            <Text style={styles.message}>
              We encountered an error. Please try again or contact support if the problem persists.
            </Text>

            {process.env.NODE_ENV === 'development' && this.state.error && (
              <View style={styles.errorDetails}>
                <Text style={styles.errorTitle}>Debug Info:</Text>
                <Text style={styles.errorText}>{this.state.error.toString()}</Text>
              </View>
            )}

            <Pressable style={styles.button} onPress={this.handleReset}>
              <Text style={styles.buttonText}>Try Again</Text>
            </Pressable>
          </ScrollView>
        </SafeAreaView>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.screenPadding,
    paddingVertical: spacing.lg,
  },
  iconWrap: {
    marginBottom: spacing.lg,
  },
  title: {
    ...typography.title1,
    color: colors.text,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  message: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
    marginBottom: spacing.lg,
  },
  errorDetails: {
    backgroundColor: 'rgba(255,0,0,0.1)',
    borderRadius: 8,
    padding: spacing.md,
    marginBottom: spacing.lg,
    borderLeftWidth: 4,
    borderLeftColor: colors.danger,
  },
  errorTitle: {
    ...typography.bodySmall,
    color: colors.danger,
    fontWeight: '600',
    marginBottom: spacing.xs,
  },
  errorText: {
    ...typography.bodySmall,
    color: colors.danger,
    fontFamily: 'monospace',
  },
  button: {
    backgroundColor: colors.accent,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 8,
    minWidth: 200,
    alignItems: 'center',
  },
  buttonText: {
    ...typography.button,
    color: 'white',
  },
});
