import AsyncStorage from '@react-native-async-storage/async-storage';
import { DailyRitualRecord, DailyStateSummary, StreakState, UserProfile } from '../../types/dailyState';
import type { RewardGrantResult } from '../../types/reward';
import { syncRewardsForCompletedRitual } from './rewardsService';

/**
 * Local storage keys
 */
const KEYS = {
  USER: 'zodian:userProfile:v1',
  RECORDS: 'zodian:dailyRecords:v1',
  STREAK: 'zodian:streakState:v1',
};

/**
 * Helpers
 */
const nowIso = () => new Date().toISOString();

function toDateKey(d: Date | string = new Date()): string {
  const date = typeof d === 'string' ? new Date(d) : d;
  const yyyy = date.getFullYear();
  const mm = `${date.getMonth() + 1}`.padStart(2, '0');
  const dd = `${date.getDate()}`.padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

function safeParse(input: string | null, fallback: any) {
  if (!input) return fallback;
  try {
    return JSON.parse(input);
  } catch (err) {
    console.warn('safeParse failed', err);
    return fallback;
  }
}

/**
 * Lightweight telemetry hook - if you wire an analytics provider to globalThis.analytics.track, it will be used.
 */
function trackEvent(name: string, payload?: Record<string, any>) {
  try {
    // @ts-ignore
    if ((globalThis as any)?.analytics?.track) {
      // @ts-ignore
      (globalThis as any).analytics.track(name, payload);
    } else {
      // local debug
      console.debug(`[analytics] ${name}`, payload ?? {});
    }
  } catch {
    // swallow
  }
}

/**
 * User profile
 */
export async function loadUserProfile(): Promise<UserProfile | null> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.USER);
    return safeParse(raw, null);
  } catch (err) {
    console.error('loadUserProfile error', err);
    return null;
  }
}

export async function saveUserProfile(profile: UserProfile): Promise<void> {
  try {
    const toSave = { ...profile, updatedAt: nowIso(), createdAt: profile.createdAt ?? nowIso() };
    await AsyncStorage.setItem(KEYS.USER, JSON.stringify(toSave));
    trackEvent('user.profile.saved', { id: profile.id });
  } catch (err) {
    console.error('saveUserProfile error', err);
  }
}

/**
 * Daily records map: { [dateKey]: DailyRitualRecord }
 */
type RecordMap = Record<string, DailyRitualRecord>;

async function loadRecordsMap(): Promise<RecordMap> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.RECORDS);
    return safeParse(raw, {});
  } catch (err) {
    console.error('loadRecordsMap error', err);
    return {};
  }
}

async function saveRecordsMap(map: RecordMap): Promise<void> {
  try {
    await AsyncStorage.setItem(KEYS.RECORDS, JSON.stringify(map));
  } catch (err) {
    console.error('saveRecordsMap error', err);
  }
}

/**
 * Streak state
 */
const DEFAULT_STREAK: StreakState = {
  currentStreak: 0,
  longestStreak: 0,
  lastCompletedDate: undefined,
  updatedAt: undefined,
};

export async function loadStreakState(): Promise<StreakState> {
  try {
    const raw = await AsyncStorage.getItem(KEYS.STREAK);
    return safeParse(raw, DEFAULT_STREAK);
  } catch (err) {
    console.error('loadStreakState error', err);
    return DEFAULT_STREAK;
  }
}

export async function saveStreakState(state: StreakState): Promise<void> {
  try {
    const next = { ...state, updatedAt: nowIso() };
    await AsyncStorage.setItem(KEYS.STREAK, JSON.stringify(next));
    trackEvent('streak.saved', { current: next.currentStreak });
  } catch (err) {
    console.error('saveStreakState error', err);
  }
}

/**
 * Convenience: get today record
 */
export async function getTodayKey(date?: Date | string): Promise<string> {
  return toDateKey(date);
}

export async function getTodayRecord(date?: Date | string): Promise<DailyRitualRecord | null> {
  const key = toDateKey(date);
  const map = await loadRecordsMap();
  return map[key] ?? null;
}

/**
 * Fallback generator - creates safe fallback content when AI isn't available.
 */
export function generateFallbackContent(params: {
  westernSign: string;
  chineseSign: string;
  dateISO?: string;
}) {
  const { westernSign, chineseSign, dateISO } = params;
  const summary = `${westernSign} × ${chineseSign}: A focused, ceremonial reading for ${dateISO ?? 'today'}.`;
  const ritual = {
    title: `Ritual for ${westernSign}`,
    intro: summary,
    steps: [
      'Pause for 60 seconds and breathe',
      `Set intention aligned with ${westernSign}`,
      `Offer gratitude to the ${chineseSign} energy`,
    ],
    note: 'This is fallback content generated locally.',
  };
  return { ritual, plain: summary };
}

/**
 * createTodayIfMissing
 * - safe: if exists returns existing record
 * - requires signs (lightweight validation)
 */
export async function createTodayRitualIfMissing(params: {
  westernSign: string;
  chineseSign: string;
  date?: Date | string;
  source?: 'ai' | 'fallback' | 'import';
  content?: Record<string, any> | string;
}): Promise<DailyRitualRecord> {
  const dateKey = toDateKey(params.date);
  const map = await loadRecordsMap();

  if (map[dateKey]) return map[dateKey];

  // create fallback content if none supplied
  const content = params.content ?? generateFallbackContent({ westernSign: params.westernSign, chineseSign: params.chineseSign, dateISO: dateKey });

  const record: DailyRitualRecord = {
    date: dateKey,
    westernSign: params.westernSign,
    chineseSign: params.chineseSign,
    content,
    source: params.source ?? 'fallback',
    revealed: false,
    completed: false,
    generatedAt: nowIso(),
    version: 1,
  };

  map[dateKey] = record;
  await saveRecordsMap(map);
  trackEvent('daily.record.created', { date: dateKey, source: record.source });
  return record;
}

/**
 * markTodayRevealed: sets revealed = true and revealedAt timestamp
 */
export async function markTodayRevealed(date?: Date | string): Promise<DailyRitualRecord | null> {
  const key = toDateKey(date);
  const map = await loadRecordsMap();
  const rec = map[key];
  if (!rec) return null;
  if (rec.revealed) return rec;

  rec.revealed = true;
  rec.revealedAt = nowIso();
  map[key] = rec;
  await saveRecordsMap(map);
  trackEvent('daily.record.revealed', { date: key });
  return rec;
}

/**
 * markTodayCompleted:
 * - sets completed true and completedAt
 * - updates streak state (only increments if not already marked complete for that date)
 */
export async function markTodayCompleted(date?: Date | string): Promise<{ record: DailyRitualRecord | null; streak: StreakState; rewards: RewardGrantResult[] }> {
  const dateKey = toDateKey(date);
  const map = await loadRecordsMap();
  let rec = map[dateKey] ?? null;

  if (!rec) {
    // cannot complete a non-existing record: create one using fallback minimal info
    rec = await createTodayRitualIfMissing({ westernSign: 'Unknown', chineseSign: 'Unknown', date: dateKey, source: 'fallback' });
  }

  const wasCompleted = rec.completed === true;

  if (!wasCompleted) {
    rec.completed = true;
    rec.completedAt = nowIso();
    map[dateKey] = rec;
    await saveRecordsMap(map);
    trackEvent('daily.record.completed', { date: dateKey });
  }

  // update streak state only when a new completion happened
  const streak = await loadStreakState();
  if (!wasCompleted) {
    const updated = computeUpdatedStreak(streak, dateKey);
    await saveStreakState(updated);
    const rewards = await syncRewardsForCompletedRitual({ streak: updated.currentStreak, date: dateKey });
    return { record: rec, streak: updated, rewards };
  }

  return { record: rec, streak, rewards: [] };
}

/**
 * computeUpdatedStreak: apply business rules
 * - If lastCompletedDate equals date => no change
 * - If yesterday was completed => increment
 * - If a day was missed => reset to 1
 * - Streak increases only when the daily ritual is completed (this function is called on completion)
 */
export function computeUpdatedStreak(existing: StreakState | null | undefined, completedDate: string): StreakState {
  const prev = existing ?? { ...DEFAULT_STREAK };
  const last = prev.lastCompletedDate;
  if (last === completedDate) return prev;

  function toDate(d?: string) {
    return d ? new Date(`${d}T00:00:00`) : null;
  }

  const completed = toDate(completedDate);
  // compute yesterday relative to completed date
  const yesterday = new Date(completed!.getTime());
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayKey = toDateKey(yesterday);

  let nextCurrent = 1;
  if (last === yesterdayKey) {
    nextCurrent = prev.currentStreak + 1;
  } else {
    nextCurrent = 1;
  }

  const nextLongest = Math.max(prev.longestStreak || 0, nextCurrent);

  return {
    currentStreak: nextCurrent,
    longestStreak: nextLongest,
    lastCompletedDate: completedDate,
    updatedAt: nowIso(),
  };
}

/**
 * computeHomeSummary: returns a UI-friendly summary combining today's record and streak
 */
export async function computeHomeSummary(date?: Date | string): Promise<DailyStateSummary> {
  const dateKey = toDateKey(date);
  const rec = (await loadRecordsMap())[dateKey] ?? null;
  const streak = await loadStreakState();
  const revealed = Boolean(rec?.revealed);
  const completed = Boolean(rec?.completed);
  const canReveal = !!rec && !revealed;
  const canComplete = !!rec && !completed;
  let message: string | undefined;

  if (completed) {
    message = 'Completed — come back tomorrow for your next reading';
  } else if (revealed && !completed) {
    message = 'You revealed today — complete your ritual to keep your streak';
  } else if (!rec) {
    message = 'No ritual ready for today';
  } else {
    message = 'Ready to reveal';
  }

  return {
    todayDate: dateKey,
    revealed,
    completed,
    canReveal,
    canComplete,
    streak: {
      current: streak.currentStreak,
      longest: streak.longestStreak,
      lastCompletedDate: streak.lastCompletedDate,
    },
    message,
  };
}

/**
 * Utilities for tests / tools: clear storage (careful)
 */
export async function _purgeAllLocalState(): Promise<void> {
  try {
    await AsyncStorage.multiRemove([KEYS.USER, KEYS.RECORDS, KEYS.STREAK]);
    trackEvent('dev.purge_all');
  } catch (err) {
    console.error('purgeAll error', err);
  }
}

export async function setTodayHeroStateForDev(params: {
  revealed: boolean;
  completed?: boolean;
  date?: Date | string;
}): Promise<DailyRitualRecord | null> {
  const key = toDateKey(params.date);
  const map = await loadRecordsMap();
  const rec = map[key];
  if (!rec) return null;

  rec.revealed = params.revealed;
  if (params.revealed) {
    rec.revealedAt = nowIso();
  } else {
    delete rec.revealedAt;
  }

  if (typeof params.completed === 'boolean') {
    rec.completed = params.completed;
    if (params.completed) {
      rec.completedAt = nowIso();
    } else {
      delete rec.completedAt;
    }
  }

  map[key] = rec;
  await saveRecordsMap(map);
  trackEvent('dev.home_hero_state_set', {
    date: key,
    revealed: rec.revealed,
    completed: rec.completed,
  });

  return rec;
}
