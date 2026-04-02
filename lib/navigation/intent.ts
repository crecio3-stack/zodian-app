// Simple in-memory navigation intent store.
// Used to pass ephemeral flags between screens without relying on router search params.
// This avoids compatibility issues with different expo-router versions.

type IntentValue = string | number | boolean | null | undefined;

const _intentStore: Record<string, IntentValue> = {};

export function setNavIntent(key: string, value: IntentValue) {
  _intentStore[key] = value;
}

export function consumeNavIntent(key: string): IntentValue {
  const v = _intentStore[key];
  // consume (remove) so intents are one-time
  if (key in _intentStore) {
    // eslint-disable-next-line @typescript-eslint/no-dynamic-delete
    delete _intentStore[key];
  }
  return v;
}

export function peekNavIntent(key: string): IntentValue {
  return _intentStore[key];
}
