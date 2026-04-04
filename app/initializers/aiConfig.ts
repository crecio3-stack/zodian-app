// Initialize AI analytics and logger with environment-safe fallbacks
import { configureLogger } from '../../lib/ai/logger';
import { initAnalytics } from '../../lib/analytics/analytics';
import { initSentry } from '../../lib/telemetry/sentry';

export function initAiConfig() {
  const env: any = typeof globalThis !== 'undefined' && (globalThis as any).process ? (globalThis as any).process.env : {};

  // Wire up global analytics queue to Amplitude
  try {
    if (env.AMPLITUDE_API_KEY) {
      initAnalytics(env.AMPLITUDE_API_KEY);
    }
  } catch (e) {
    // ignore
  }

  // Configure remote logger
  try {
    configureLogger({ enabled: !!env.ZODIAN_LOG_ENDPOINT, endpoint: env.ZODIAN_LOG_ENDPOINT });
  } catch (e) {
    // ignore
  }

  // Initialize Sentry for crash reporting
  try {
    if (env.SENTRY_DSN) {
      initSentry(env.SENTRY_DSN);
    }
  } catch (e) {
    // ignore
  }
}
