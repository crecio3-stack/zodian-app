import { Stack } from 'expo-router';
import 'react-native-gesture-handler';
import { colors } from '../../styles/theme';

export default function OnboardingLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        animation: 'fade_from_bottom',
        animationDuration: 360,
        contentStyle: {
          backgroundColor: colors.background,
        },
        gestureEnabled: true,
        fullScreenGestureEnabled: true,
      }}
    >
      <Stack.Screen
        name="welcome"
        options={{
          animation: 'fade',
          animationDuration: 320,
        }}
      />
      <Stack.Screen
        name="name"
        options={{
          animation: 'fade_from_bottom',
          presentation: 'card',
          animationDuration: 360,
        }}
      />
      <Stack.Screen
        name="birthdate"
        options={{
          animation: 'fade_from_bottom',
          presentation: 'card',
          animationDuration: 360,
        }}
      />
      <Stack.Screen
        name="reveal"
        options={{
          animation: 'fade_from_bottom',
          presentation: 'card',
          animationDuration: 420,
        }}
      />
      <Stack.Screen
        name="theory"
        options={{
          animation: 'fade_from_bottom',
          presentation: 'card',
          animationDuration: 360,
        }}
      />
    </Stack>
  );
}