import AsyncStorage from '@react-native-async-storage/async-storage';

export type LocalSnapshot = {
  version: 1;
  exportedAt: string;
  entries: Record<string, string>;
};

const EXACT_KEYS = new Set(['display_name', 'birthdate', 'dating_profile_v1']);

function isCloudSyncKey(key: string) {
  if (EXACT_KEYS.has(key)) {
    return true;
  }

  return key.startsWith('zodian');
}

export async function listCloudSyncKeys() {
  const keys = await AsyncStorage.getAllKeys();
  return keys.filter(isCloudSyncKey).sort();
}

export async function captureLocalSnapshot(): Promise<LocalSnapshot> {
  const keys = await listCloudSyncKeys();
  const pairs = await AsyncStorage.multiGet(keys);
  const entries: Record<string, string> = {};

  for (const [key, value] of pairs) {
    if (typeof value === 'string') {
      entries[key] = value;
    }
  }

  return {
    version: 1,
    exportedAt: new Date().toISOString(),
    entries,
  };
}

export async function restoreLocalSnapshot(snapshot: LocalSnapshot) {
  const currentKeys = await listCloudSyncKeys();
  if (currentKeys.length > 0) {
    await AsyncStorage.multiRemove(currentKeys);
  }

  const pairs = Object.entries(snapshot.entries);
  if (pairs.length > 0) {
    await AsyncStorage.multiSet(pairs);
  }
}