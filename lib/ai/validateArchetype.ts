import type { ArchetypeResponse } from './types';

export function isValidArchetypeResponse(obj: any): obj is ArchetypeResponse {
  if (!obj || typeof obj !== 'object') return false;
  if (typeof obj.archetypeName !== 'string') return false;
  if (typeof obj.description !== 'string') return false;
  if (obj.rituals !== undefined && !Array.isArray(obj.rituals)) return false;
  return true;
}
