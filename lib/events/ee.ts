type Listener = (...args: any[]) => void;

const listeners: Record<string, Listener[]> = {};

export function on(event: string, cb: Listener) {
  listeners[event] = listeners[event] || [];
  listeners[event].push(cb);
  return () => off(event, cb);
}

export function off(event: string, cb: Listener) {
  listeners[event] = (listeners[event] || []).filter((l) => l !== cb);
}

export function emit(event: string, ...args: any[]) {
  (listeners[event] || []).slice().forEach((l) => {
    try {
      l(...args);
    } catch (e) {
      // swallow
    }
  });
}
