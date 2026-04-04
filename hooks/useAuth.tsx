import type { Session, User } from '@supabase/supabase-js';
import type { PropsWithChildren } from 'react';
import React, { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
import { captureLocalSnapshot, restoreLocalSnapshot } from '../lib/auth/localSnapshot';
import { getSupabaseClient, isSupabaseConfigured } from '../lib/auth/supabase';

type RemoteSnapshotRow = {
  user_id: string;
  updated_at: string;
  snapshot: {
    version: 1;
    exportedAt: string;
    entries: Record<string, string>;
  };
};

type AuthContextValue = {
  isConfigured: boolean;
  isLoading: boolean;
  isSyncing: boolean;
  session: Session | null;
  user: User | null;
  lastSyncedAt: string | null;
  requestEmailOtp: (email: string) => Promise<void>;
  verifyEmailOtp: (email: string, token: string) => Promise<void>;
  signOut: () => Promise<void>;
  syncToCloud: () => Promise<void>;
  autoSyncAfterMutation: () => void;
  restoreFromCloud: () => Promise<boolean>;
  refreshStatus: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

async function loadRemoteSnapshot(userId: string): Promise<RemoteSnapshotRow | null> {
  const client = getSupabaseClient();
  const { data, error } = await client
    .from('user_snapshots')
    .select('user_id, updated_at, snapshot')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return (data as RemoteSnapshotRow | null) ?? null;
}

export function AuthProvider({ children }: PropsWithChildren) {
  const [isLoading, setIsLoading] = useState(isSupabaseConfigured);
  const [isSyncing, setIsSyncing] = useState(false);
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [lastSyncedAt, setLastSyncedAt] = useState<string | null>(null);
  const autoSyncTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (!isSupabaseConfigured) {
      setIsLoading(false);
      return;
    }

    const client = getSupabaseClient();

    client.auth.getSession().then(({ data, error }) => {
      if (error) {
        console.warn('auth:getSession failed', error);
      }

      setSession(data.session ?? null);
      setUser(data.session?.user ?? null);
      setIsLoading(false);
    });

    const { data } = client.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession ?? null);
      setUser(nextSession?.user ?? null);
    });

    return () => {
      data.subscription.unsubscribe();
    };
  }, []);

  const refreshStatus = useCallback(async () => {
    if (!isSupabaseConfigured || !user) {
      setLastSyncedAt(null);
      return;
    }

    const row = await loadRemoteSnapshot(user.id);
    setLastSyncedAt(row?.updated_at ?? null);
  }, [user]);

  useEffect(() => {
    refreshStatus().catch((error) => {
      console.warn('auth:refreshStatus failed', error);
    });
  }, [refreshStatus]);

  const requestEmailOtp = async (email: string) => {
    const client = getSupabaseClient();
    const { error } = await client.auth.signInWithOtp({
      email,
      options: {
        shouldCreateUser: true,
      },
    });
    if (error) {
      throw error;
    }
  };

  const verifyEmailOtp = async (email: string, token: string) => {
    const client = getSupabaseClient();
    const { error } = await client.auth.verifyOtp({
      email,
      token,
      type: 'email',
    });
    if (error) {
      throw error;
    }
  };

  const signOut = async () => {
    const client = getSupabaseClient();
    const { error } = await client.auth.signOut();
    if (error) {
      throw error;
    }
    setLastSyncedAt(null);
  };

  const syncToCloud = useCallback(async () => {
    if (!user) {
      throw new Error('Sign in before backing up your data.');
    }

    setIsSyncing(true);
    try {
      const client = getSupabaseClient();
      const snapshot = await captureLocalSnapshot();
      const { error } = await client.from('user_snapshots').upsert(
        {
          user_id: user.id,
          snapshot,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'user_id' }
      );

      if (error) {
        throw error;
      }

      setLastSyncedAt(new Date().toISOString());
    } finally {
      setIsSyncing(false);
    }
  }, [user]);

  const autoSyncAfterMutation = useCallback(() => {
    if (!isSupabaseConfigured || !user) {
      return;
    }

    if (autoSyncTimerRef.current) {
      clearTimeout(autoSyncTimerRef.current);
    }

    // Debounce bursts of writes from rapid UI actions.
    autoSyncTimerRef.current = setTimeout(() => {
      syncToCloud().catch((error) => {
        console.warn('auth:autoSyncAfterMutation failed', error);
      });
      autoSyncTimerRef.current = null;
    }, 1800);
  }, [syncToCloud, user]);

  useEffect(() => {
    return () => {
      if (autoSyncTimerRef.current) {
        clearTimeout(autoSyncTimerRef.current);
      }
    };
  }, []);

  const restoreFromCloud = async () => {
    if (!user) {
      throw new Error('Sign in before restoring cloud data.');
    }

    setIsSyncing(true);
    try {
      const row = await loadRemoteSnapshot(user.id);
      if (!row?.snapshot) {
        return false;
      }

      await restoreLocalSnapshot(row.snapshot);
      setLastSyncedAt(row.updated_at ?? null);
      return true;
    } finally {
      setIsSyncing(false);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        isConfigured: isSupabaseConfigured,
        isLoading,
        isSyncing,
        session,
        user,
        lastSyncedAt,
        requestEmailOtp,
        verifyEmailOtp,
        signOut,
        syncToCloud,
        autoSyncAfterMutation,
        restoreFromCloud,
        refreshStatus,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const value = useContext(AuthContext);

  if (!value) {
    throw new Error('useAuth must be used within AuthProvider');
  }

  return value;
}