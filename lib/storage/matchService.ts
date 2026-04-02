import AsyncStorage from '@react-native-async-storage/async-storage';

const MATCHES_KEY = 'zodian:matches:v1';

type MatchRecord = {
  id: string;
  savedAt: number;
  profile: any;
};

export async function addMatch(profile: any): Promise<void> {
  try {
    const raw = await AsyncStorage.getItem(MATCHES_KEY);
    const existing: MatchRecord[] = raw ? JSON.parse(raw) : [];
    if (existing.find((m) => m.id === profile.id)) return;
    const next: MatchRecord[] = [{ id: profile.id, savedAt: Date.now(), profile }, ...existing];
    await AsyncStorage.setItem(MATCHES_KEY, JSON.stringify(next));
  } catch (err) {
    // swallow but keep non-blocking
    console.warn('addMatch error', err);
  }
}

export async function getMatches(): Promise<MatchRecord[]> {
  try {
    const raw = await AsyncStorage.getItem(MATCHES_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch (err) {
    return [];
  }
}

export async function clearMatches(): Promise<void> {
  try {
    await AsyncStorage.removeItem(MATCHES_KEY);
  } catch {}
}
