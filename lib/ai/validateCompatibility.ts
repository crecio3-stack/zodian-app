import type { CompatibilityResponse } from './types';

export function isValidCompatibilityResponse(obj: any): obj is CompatibilityResponse {
  if (!obj || typeof obj !== 'object') return false;
  if (!obj.pair || typeof obj.pair.left !== 'string' || typeof obj.pair.right !== 'string') return false;
  if (typeof obj.compatibilityScore !== 'number') return false;
  if (!Array.isArray(obj.strengths) || !Array.isArray(obj.challenges)) return false;
  if (typeof obj.advice !== 'string') return false;
  return true;
}
