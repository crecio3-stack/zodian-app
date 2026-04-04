/**
 * Centralized app state context
 * 
 * Replaces scattered hooks for:
 * - Premium state (no longer scattered AsyncStorage boolean)
 * - Daily ritual state (streaks, completed, etc.)
 * - User profile (name, birthdate, identity)
 * - Rewards/achievements
 * - Chat session
 * 
 * Provides:
 * - Loading state consistency
 * - Error handling
 * - Optimistic updates
 * - Persistence layer
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { createContext, useContext, useEffect, useState } from 'react';
import type { ChatSession } from '../../types/chat';
import type { DailyRitualRecord, StreakState, UserProfile } from '../../types/dailyState';
import type { MilestoneRecord } from '../../types/reward';

/**
 * App-level state shape
 */
export interface AppState {
  // Auth & Profile
  user: UserProfile | null;
  birthdate: Date | null;
  name: string | null;

  // Premium & Monetization
  premium: {
    isActive: boolean;
    purchasedAt?: number;
    expiresAt?: number;
    source?: 'trial' | 'purchase' | 'lifetime';
  };

  // Daily Ritual
  todayRitual: DailyRitualRecord | null;
  streak: StreakState | null;

  // Rewards
  rewards: MilestoneRecord[];

  // Chat
  chatSession: ChatSession | null;

  // UI State
  loading: boolean;
  error: string | null;
}

/**
 * Actions interface
 */
export interface AppStateActions {
  // User
  setUserProfile: (profile: UserProfile) => Promise<void>;
  setBirthdate: (date: Date | null) => Promise<void>;
  setName: (name: string | null) => Promise<void>;

  // Premium
  enablePremium: (source?: 'trial' | 'purchase' | 'lifetime') => Promise<void>;
  disablePremium: () => Promise<void>;
  updatePremiumExpiry: (expiresAt: number) => Promise<void>;

  // Daily Ritual
  setTodayRitual: (ritual: DailyRitualRecord) => Promise<void>;
  markTodayRevealed: () => Promise<void>;
  markTodayCompleted: () => Promise<void>;

  // Rewards
  addMilestone: (record: MilestoneRecord) => Promise<void>;
  clearRewards: () => Promise<void>;

  // Chat
  setChatSession: (session: ChatSession) => Promise<void>;
  clearChat: () => Promise<void>;

  // General
  clearError: () => void;
  refresh: () => Promise<void>;
  clearAllData: () => Promise<void>;
}

/**
 * Context type
 */
type AppContextType = {
  state: AppState;
  actions: AppStateActions;
} | null;

/**
 * Create context
 */
const AppContext = createContext<AppContextType>(null);

/**
 * Storage keys
 */
const STORAGE_KEYS = {
  USER: 'zodian:user:v1',
  BIRTHDATE: 'zodian:birthdate:v1',
  NAME: 'zodian:name:v1',
  PREMIUM: 'zodian:premium:v1',
  TODAY_RITUAL: 'zodian:today_ritual:v1',
  STREAK: 'zodian:streak:v1',
  REWARDS: 'zodian:rewards:v1',
  CHAT_SESSION: 'zodian:chat_session:v1',
};

/**
 * Provider component
 */
export function AppStateProvider({ children }: { children: React.ReactNode }) {
  // Core state
  const [state, setState] = useState<AppState>({
    user: null,
    birthdate: null,
    name: null,
    premium: { isActive: false },
    todayRitual: null,
    streak: null,
    rewards: [],
    chatSession: null,
    loading: true,
    error: null,
  });

  // Initialize from storage
  useEffect(() => {
    let isMounted = true;

    const init = async () => {
      try {
        const [user, birthdate, name, premium, ritual, streak, rewards, chat] = await Promise.all([
          AsyncStorage.getItem(STORAGE_KEYS.USER),
          AsyncStorage.getItem(STORAGE_KEYS.BIRTHDATE),
          AsyncStorage.getItem(STORAGE_KEYS.NAME),
          AsyncStorage.getItem(STORAGE_KEYS.PREMIUM),
          AsyncStorage.getItem(STORAGE_KEYS.TODAY_RITUAL),
          AsyncStorage.getItem(STORAGE_KEYS.STREAK),
          AsyncStorage.getItem(STORAGE_KEYS.REWARDS),
          AsyncStorage.getItem(STORAGE_KEYS.CHAT_SESSION),
        ]);

        if (!isMounted) return;

        setState((prev) => ({
          ...prev,
          user: user ? JSON.parse(user) : null,
          birthdate: birthdate ? new Date(JSON.parse(birthdate)) : null,
          name: name ? JSON.parse(name) : null,
          premium: premium ? JSON.parse(premium) : { isActive: false },
          todayRitual: ritual ? JSON.parse(ritual) : null,
          streak: streak ? JSON.parse(streak) : null,
          rewards: rewards ? JSON.parse(rewards) : [],
          chatSession: chat ? JSON.parse(chat) : null,
          loading: false,
        }));
      } catch (err) {
        if (isMounted) {
          console.error('AppState init error', err);
          setState((prev) => ({ ...prev, loading: false, error: 'Failed to load app state' }));
        }
      }
    };

    init();

    return () => {
      isMounted = false;
    };
  }, []);

  // Actions
  const actions: AppStateActions = {
    // User
    setUserProfile: async (profile: UserProfile) => {
      setState((prev) => ({ ...prev, user: profile }));
      await AsyncStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(profile));
    },

    setBirthdate: async (date: Date | null) => {
      setState((prev) => ({ ...prev, birthdate: date }));
      await AsyncStorage.setItem(STORAGE_KEYS.BIRTHDATE, JSON.stringify(date?.toISOString() ?? null));
    },

    setName: async (name: string | null) => {
      setState((prev) => ({ ...prev, name }));
      await AsyncStorage.setItem(STORAGE_KEYS.NAME, JSON.stringify(name));
    },

    // Premium
    enablePremium: async (source = 'purchase') => {
      const premiumState = {
        isActive: true,
        purchasedAt: Date.now(),
        source: source as 'trial' | 'purchase' | 'lifetime',
      };
      setState((prev) => ({ ...prev, premium: premiumState }));
      await AsyncStorage.setItem(STORAGE_KEYS.PREMIUM, JSON.stringify(premiumState));
    },

    disablePremium: async () => {
      setState((prev) => ({ ...prev, premium: { isActive: false } }));
      await AsyncStorage.setItem(STORAGE_KEYS.PREMIUM, JSON.stringify({ isActive: false }));
    },

    updatePremiumExpiry: async (expiresAt: number) => {
      setState((prev) => ({
        ...prev,
        premium: { ...prev.premium, expiresAt },
      }));
      await AsyncStorage.setItem(STORAGE_KEYS.PREMIUM, JSON.stringify(state.premium));
    },

    // Daily Ritual
    setTodayRitual: async (ritual: DailyRitualRecord) => {
      setState((prev) => ({ ...prev, todayRitual: ritual }));
      await AsyncStorage.setItem(STORAGE_KEYS.TODAY_RITUAL, JSON.stringify(ritual));
    },

    markTodayRevealed: async () => {
      setState((prev) => ({
        ...prev,
        todayRitual: prev.todayRitual ? { ...prev.todayRitual, revealed: true } : null,
      }));
      if (state.todayRitual) {
        await AsyncStorage.setItem(
          STORAGE_KEYS.TODAY_RITUAL,
          JSON.stringify({ ...state.todayRitual, revealed: true })
        );
      }
    },

    markTodayCompleted: async () => {
      setState((prev) => ({
        ...prev,
        todayRitual: prev.todayRitual ? { ...prev.todayRitual, completed: true } : null,
      }));
      if (state.todayRitual) {
        await AsyncStorage.setItem(
          STORAGE_KEYS.TODAY_RITUAL,
          JSON.stringify({ ...state.todayRitual, completed: true })
        );
      }
    },

    // Rewards
    addMilestone: async (record: MilestoneRecord) => {
      setState((prev) => ({
        ...prev,
        rewards: [record, ...prev.rewards].slice(0, 200),
      }));
      const next = [record, ...state.rewards].slice(0, 200);
      await AsyncStorage.setItem(STORAGE_KEYS.REWARDS, JSON.stringify(next));
    },

    clearRewards: async () => {
      setState((prev) => ({ ...prev, rewards: [] }));
      await AsyncStorage.setItem(STORAGE_KEYS.REWARDS, JSON.stringify([]));
    },

    // Chat
    setChatSession: async (session: ChatSession) => {
      setState((prev) => ({ ...prev, chatSession: session }));
      await AsyncStorage.setItem(STORAGE_KEYS.CHAT_SESSION, JSON.stringify(session));
    },

    clearChat: async () => {
      setState((prev) => ({ ...prev, chatSession: null }));
      await AsyncStorage.removeItem(STORAGE_KEYS.CHAT_SESSION);
    },

    // General
    clearError: () => {
      setState((prev) => ({ ...prev, error: null }));
    },

    refresh: async () => {
      setState((prev) => ({ ...prev, loading: true }));
      // Re-load from storage
      try {
        const [user, birthdate, name, premium, ritual, streak, rewards, chat] = await Promise.all([
          AsyncStorage.getItem(STORAGE_KEYS.USER),
          AsyncStorage.getItem(STORAGE_KEYS.BIRTHDATE),
          AsyncStorage.getItem(STORAGE_KEYS.NAME),
          AsyncStorage.getItem(STORAGE_KEYS.PREMIUM),
          AsyncStorage.getItem(STORAGE_KEYS.TODAY_RITUAL),
          AsyncStorage.getItem(STORAGE_KEYS.STREAK),
          AsyncStorage.getItem(STORAGE_KEYS.REWARDS),
          AsyncStorage.getItem(STORAGE_KEYS.CHAT_SESSION),
        ]);

        setState((prev) => ({
          ...prev,
          user: user ? JSON.parse(user) : null,
          birthdate: birthdate ? new Date(JSON.parse(birthdate)) : null,
          name: name ? JSON.parse(name) : null,
          premium: premium ? JSON.parse(premium) : { isActive: false },
          todayRitual: ritual ? JSON.parse(ritual) : null,
          streak: streak ? JSON.parse(streak) : null,
          rewards: rewards ? JSON.parse(rewards) : [],
          chatSession: chat ? JSON.parse(chat) : null,
          loading: false,
        }));
      } catch (err) {
        setState((prev) => ({ ...prev, loading: false, error: `Refresh error: ${String(err)}` }));
      }
    },

    clearAllData: async () => {
      await AsyncStorage.multiRemove(Object.values(STORAGE_KEYS));
      setState({
        user: null,
        birthdate: null,
        name: null,
        premium: { isActive: false },
        todayRitual: null,
        streak: null,
        rewards: [],
        chatSession: null,
        loading: false,
        error: null,
      });
    },
  };

  const value = { state, actions };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

/**
 * Hook to use app state
 */
export function useAppState() {
  const ctx = useContext(AppContext);
  if (!ctx) {
    throw new Error('useAppState must be used within AppStateProvider');
  }
  return ctx;
}
