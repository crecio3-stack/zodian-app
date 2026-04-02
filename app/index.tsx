import { Redirect } from 'expo-router';
import React from 'react';
import { ActivityIndicator, View } from 'react-native';
import { useStoredBirthdate } from '../hooks/useStoredBirthdate';
import { useStoredName } from '../hooks/useStoredName';
import { colors } from '../styles/theme';

export default function Index() {
  const { hasLoaded, hasSavedBirthdate } = useStoredBirthdate(new Date());
  const { hasLoaded: hasLoadedName, hasSavedName } = useStoredName();

  if (!hasLoaded || !hasLoadedName) {
    return (
      <View
        style={{
          flex: 1,
          backgroundColor: colors.background,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <ActivityIndicator />
      </View>
    );
  }

  if (!hasSavedBirthdate || !hasSavedName) {
    return <Redirect href="/onboarding/welcome" />;
  }

  return <Redirect href="/(tabs)" />;
}