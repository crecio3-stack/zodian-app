Integration notes for telemetry and caching

1) Sentry
- The logger module will call global Sentry.captureException if a Sentry SDK is installed and attached to global.Sentry. To enable Sentry in the app, install @sentry/react-native and initialize it in app entry (e.g., App.tsx):

import * as Sentry from '@sentry/react-native';
Sentry.init({ dsn: 'your-dsn' });

2) Amplitude
- The analytics module can forward events via Amplitude HTTP API if you configure an API key:

import { configureAnalytics } from './lib/ai/analytics';
configureAnalytics({ amplitudeApiKey: 'YOUR_KEY' });

- For robust integration prefer amplitude-js or @amplitude/react-native packages.

3) Caching
- Uses @react-native-async-storage/async-storage. Ensure it is installed in the project.
- getCached/setCached are best-effort and will not block generation if failing.

4) Notes
- Keep keys out of source; use environment variables or secure storage for production.
