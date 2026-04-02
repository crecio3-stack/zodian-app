// filepath: /Users/christianrecio/zodian/lib/telemetry/sentry.ts
// Lightweight Sentry wrapper. Initialize by importing this module early in app startup.

let Sentry: any = null;
try {
  // Require lazily to avoid native dependency during web bundling if not installed
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  Sentry = require('@sentry/react-native');
} catch (e) {
  Sentry = null;
}

export function initSentry(dsn?: string) {
  try {
    if (!Sentry || !dsn) return;
    Sentry.init({ dsn, enableAutoSessionTracking: true });
  } catch (e) {
    // ignore init errors in dev
    // eslint-disable-next-line no-console
    console.warn('Sentry init failed', e);
  }
}

export function captureException(err: any, ctx?: Record<string, any>) {
  try {
    if (Sentry) {
      Sentry.captureException(err, { extra: ctx });
    } else {
      console.error('Captured exception', err, ctx);
    }
  } catch (e) {}
}

export function captureMessage(msg: string, ctx?: Record<string, any>) {
  try {
    if (Sentry) {
      Sentry.captureMessage(msg, { extra: ctx });
    } else {
      console.debug('Captured message', msg, ctx);
    }
  } catch (e) {}
}
