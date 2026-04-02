export type AnalyticsPayload = Record<string, unknown>;

export function trackEvent(eventName: string, payload?: AnalyticsPayload) {
  try {
    // Wire to analytics providers here (Amplitude, Firebase, etc.)
    // For now, just console.log so hooks are available in prod builds.
    console.log('[ZODIAN][ANALYTICS]', eventName, payload || {});
  } catch (e) {
    // swallow
  }
}
