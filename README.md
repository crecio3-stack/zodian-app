# Zodian

Zodian is a React Native and Expo app focused on astrology identity, daily ritual, compatibility, premium upsells, and retention loops.

## Local development

1. Install dependencies.

```bash
npm install
```

2. Start the app.

```bash
npx expo start
```

3. Run lint before pushing changes.

```bash
npm run lint -- --quiet
```

## Core areas

- `app/(tabs)` holds the main Home, Daily, Match, Rewards, and Profile surfaces.
- `app/onboarding` holds the first-session funnel.
- `lib/analytics` contains the local queue and typed event names.
- `lib/premium` contains paywall navigation, gating prompts, and premium state helpers.
- `lib/storage` contains daily ritual, streak, and rewards persistence.

## Analytics

Measurement notes live in [docs/analytics-playbook.md](docs/analytics-playbook.md).

For local verification during development, open the in-app analytics inspector at `app/analytics-debug.tsx` from the Profile dev section.
