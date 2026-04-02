// filepath: /Users/christianrecio/zodian/lib/storage/rewardsService.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { MilestoneRecord } from '../../types/reward';

const KEY = 'zodian:milestones:v1';

const nowIso = () => new Date().toISOString();

function toDateKey(d: Date | string = new Date()): string {
  const date = typeof d === 'string' ? new Date(d) : d;
  const yyyy = date.getFullYear();
  const mm = `${date.getMonth() + 1}`.padStart(2, '0');
  const dd = `${date.getDate()}`.padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

function safeParse<T>(raw: string | null, fallback: T): T {
  if (!raw) return fallback;
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.warn('rewardsService.safeParse failed', err);
    return fallback;
  }
}

/**
 * Lightweight analytics hook if present
 */
function trackEvent(name: string, payload?: Record<string, any>) {
  try {
    // @ts-ignore
    if (globalThis?.analytics?.track) {
      // @ts-ignore
      globalThis.analytics.track(name, payload);
    } else {
      console.debug(`[analytics] ${name}`, payload ?? {});
    }
  } catch {}
}

export async function loadMilestoneHistory(): Promise<MilestoneRecord[]> {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    return safeParse<MilestoneRecord[]>(raw, []);
  } catch (err) {
    console.error('loadMilestoneHistory error', err);
    return [];
  }
}

export async function addMilestoneRecord(input: {
  streak: number;
  label?: string;
  date?: Date | string;
}): Promise<MilestoneRecord> {
  try {
    const list = await loadMilestoneHistory();
    const dateKey = toDateKey(input.date);
    const createdAt = nowIso();
    const id = `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
    const rec: MilestoneRecord = {
      id,
      streak: input.streak,
      label: input.label ?? `${input.streak}-day`,
      dateKey,
      createdAt,
    };
    // avoid duplicates for same streak & date
    const duplicate = list.find((r) => r.streak === rec.streak && r.dateKey === rec.dateKey);
    if (!duplicate) {
      list.unshift(rec); // newest first
      // cap history to a reasonable number (e.g., 200)
      if (list.length > 200) list.length = 200;
      await AsyncStorage.setItem(KEY, JSON.stringify(list));
      trackEvent('rewards.milestone_earned', { streak: rec.streak, id: rec.id });
    } else {
      // keep duplicate reference
      return duplicate;
    }
    return rec;
  } catch (err) {
    console.error('addMilestoneRecord error', err);
    throw err;
  }
}

export async function clearMilestoneHistory(): Promise<void> {
  try {
    await AsyncStorage.removeItem(KEY);
    trackEvent('rewards.history_cleared');
  } catch (err) {
    console.error('clearMilestoneHistory error', err);
  }
}
