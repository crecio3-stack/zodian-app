// Initialize AI analytics and logger with environment-safe fallbacks
import { configureAnalytics } from '../../lib/ai/analytics';
import { configureLogger } from '../../lib/ai/logger';

export function initAiConfig() {
  const env: any = typeof globalThis !== 'undefined' && (globalThis as any).process ? (globalThis as any).process.env : {};

  // Configure analytics if provided
  try {
    configureAnalytics({ amplitudeApiKey: env.AMPLITUDE_API_KEY });
  } catch (e) {
    // ignore
  }

  // Configure remote logger / Sentry
  try {
    configureLogger({ enabled: !!env.ZODIAN_LOG_ENDPOINT, endpoint: env.ZODIAN_LOG_ENDPOINT, sentryDsn: env.SENTRY_DSN });
  } catch (e) {
    // ignore
  }
}
