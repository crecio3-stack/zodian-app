import 'react-native-reanimated'; // MUST BE FIRST

import { Stack } from 'expo-router';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { ErrorBoundary } from '../components/ErrorBoundary';
import { AuthProvider } from '../hooks/useAuth';
import { AppStateProvider } from '../lib/state/appState';

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <ErrorBoundary>
        <AuthProvider>
          <AppStateProvider>
            <Stack screenOptions={{ headerShown: false }}>
              <Stack.Screen name="index" />
              <Stack.Screen name="login" />
              <Stack.Screen name="analytics-debug" />
              <Stack.Screen name="blueprint" />
              <Stack.Screen name="theory" />
              <Stack.Screen name="onboarding" />
              <Stack.Screen name="(tabs)" />
              <Stack.Screen
                name="identity"
                options={{
                  presentation: 'card',
                  gestureEnabled: true,
                }}
              />
              <Stack.Screen
                name="premium"
                options={{
                  presentation: 'modal',
                  gestureEnabled: true,
                  gestureDirection: 'vertical',
                }}
              />
            </Stack>
          </AppStateProvider>
        </AuthProvider>
      </ErrorBoundary>
    </GestureHandlerRootView>
  );
}