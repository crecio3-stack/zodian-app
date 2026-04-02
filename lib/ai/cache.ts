import AsyncStorage from '@react-native-async-storage/async-storage';

const DEFAULT_TTL = 1000 * 60 * 60 * 24; // 24h

export async function getCached<T = any>(key: string): Promise<T | null> {
  try {
    const raw = await AsyncStorage.getItem(key);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!parsed || !parsed.ts) return null;
    if (Date.now() - parsed.ts > (parsed.ttl ?? DEFAULT_TTL)) {
      await AsyncStorage.removeItem(key);
      return null;
    }
    return parsed.value as T;
  } catch (e) {
    return null;
  }
}

export async function setCached(key: string, value: any, ttl = DEFAULT_TTL): Promise<void> {
  try {
    const payload = JSON.stringify({ ts: Date.now(), ttl, value });
    await AsyncStorage.setItem(key, payload);
  } catch (e) {
    // ignore cache failures
  }
}
