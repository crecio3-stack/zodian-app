// filepath: /Users/christianrecio/zodian/types/reward.ts
export type MilestoneRecord = {
  id: string; // simple unique id (timestamp-based)
  streak: number;
  label?: string;
  dateKey: string; // YYYY-MM-DD
  createdAt: string; // ISO timestamp
};
