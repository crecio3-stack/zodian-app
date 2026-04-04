import { Tabs } from 'expo-router';
import React from 'react';
import { CustomTabBar } from '../../components/CustomTabBar';

export default function TabsLayout() {
  return (
    <Tabs
      tabBar={(props) => <CustomTabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
        }}
      />
      <Tabs.Screen
        name="daily"
        options={{
          title: 'Daily',
          href: null,
        }}
      />
      <Tabs.Screen
        name="match"
        options={{
          title: 'Match',
        }}
      />
      <Tabs.Screen
        name="connections"
        options={{
          title: 'Connections',
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
        }}
      />
      <Tabs.Screen
        name="rewards"
        options={{
          title: 'Rewards',
          href: null,
        }}
      />
    </Tabs>
  );
}