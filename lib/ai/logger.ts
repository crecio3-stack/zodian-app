type Meta = Record<string, unknown> | undefined;

let remoteLoggerEnabled = false;
let remoteLoggerEndpoint: string | undefined;

export function configureLogger({ enabled, endpoint }: { enabled: boolean; endpoint?: string }) {
  remoteLoggerEnabled = enabled;
  remoteLoggerEndpoint = endpoint;
}

export function logInfo(message: string, meta?: Meta) {
  try {
    console.info(`[ZODIAN][INFO] ${message}`, meta || '');
    if (remoteLoggerEnabled && remoteLoggerEndpoint) {
      // Best-effort: don't await
      fetch(remoteLoggerEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ level: 'info', message, meta, ts: new Date().toISOString() }),
      }).catch(() => {});
    }
  } catch (e) {
    // swallow
  }
}

export function logError(err: unknown, meta?: Meta) {
  try {
    console.error(`[ZODIAN][ERROR]`, err, meta || '');
    if (remoteLoggerEnabled && remoteLoggerEndpoint) {
      fetch(remoteLoggerEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ level: 'error', error: String(err), meta, ts: new Date().toISOString() }),
      }).catch(() => {});
    }
  } catch (e) {
    // swallow
  }
}
