// filepath: /Users/christianrecio/zodian/lib/config/milestones.ts
// Defines milestone thresholds for streak celebrations.
// Can be customized here or via ZODIAN_MILESTONES env var (comma-separated numbers).

const DEFAULT_MILESTONES = [3, 5, 7, 14, 30];

export function parseEnvMilestones(env?: string | null): number[] {
  if (!env) return DEFAULT_MILESTONES;
  try {
    const parts = env.split(',').map((p) => Number(p.trim())).filter((n) => !Number.isNaN(n) && n > 0);
    if (parts.length === 0) return DEFAULT_MILESTONES;
    // unique & sorted
    return Array.from(new Set(parts)).sort((a, b) => a - b);
  } catch (err) {
    return DEFAULT_MILESTONES;
  }
}

export const MILESTONE_THRESHOLDS: number[] = parseEnvMilestones(
  typeof process !== 'undefined' && (process as any).env && (process as any).env.ZODIAN_MILESTONES
    ? (process as any).env.ZODIAN_MILESTONES
    : null
);

export default MILESTONE_THRESHOLDS;
