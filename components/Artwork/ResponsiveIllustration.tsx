import React, { useEffect, useState } from 'react';
import type { ViewStyle } from 'react-native';
import { ActivityIndicator, Image, Platform, StyleSheet, View } from 'react-native';

// NOTE: This component prefers scalable SVG illustrations for crisp visuals.
// It will attempt to fetch a remote SVG (if remotePath provided and DEV flag off),
// then fall back to a local embedded SVG string. If react-native-svg is not
// available, it falls back to a static Image placeholder.

const LOCAL_SVG = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="720" height="480" viewBox="0 0 720 480" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g" x1="0" x2="1">
      <stop offset="0" stop-color="#F7E8D6" />
      <stop offset="1" stop-color="#EADFF2" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#g)" rx="28"/>
  <g transform="translate(60,40)">
    <circle cx="120" cy="80" r="60" fill="rgba(255,255,255,0.12)" />
    <circle cx="360" cy="40" r="36" fill="rgba(255,255,255,0.06)" />
    <g transform="translate(40,160)">
      <path d="M0 80 C40 20, 240 20, 280 80" fill="rgba(255,255,255,0.08)" />
    </g>
    <text x="40" y="220" font-family="Georgia, serif" font-size="28" fill="#2D2D2D">Zodian</text>
  </g>
</svg>`;

const DEFAULT_REMOTE_TIMEOUT = 4000;
const DEFAULT_RETRIES = 2;

type Props = {
  remotePath?: string | null;
  style?: ViewStyle;
  containerStyle?: ViewStyle;
  alt?: string;
};

export default function ResponsiveIllustration({ remotePath, style, containerStyle }: Props) {
  const [svgXml, setSvgXml] = useState<string | null>(null);
  const [remoteUri, setRemoteUri] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<boolean>(false);

  const DEV_USE_LOCAL_ART =
    typeof globalThis !== 'undefined' &&
    typeof (globalThis as any).process !== 'undefined' &&
    (globalThis as any).process.env.DEV_USE_LOCAL_ART === 'true';

  useEffect(() => {
    let mounted = true;
    async function tryLoad() {
      setLoading(true);
      setError(false);

      // If remotePath is provided and dev flag isn't forcing local, try fetching it
      if (remotePath && !DEV_USE_LOCAL_ART) {
        let attempts = 0;
        while (attempts <= DEFAULT_RETRIES && mounted) {
          attempts += 1;
          try {
            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), DEFAULT_REMOTE_TIMEOUT);
            const res = await fetch(remotePath, { signal: controller.signal });
            clearTimeout(timeout);

            const contentType = res.headers.get('content-type') || '';
            if (contentType.includes('svg') || (remotePath && remotePath.endsWith('.svg'))) {
              const text = await res.text();
              if (mounted) setSvgXml(text);

              try {
                const { trackEvent } = await import('../../lib/ai/analytics');
                trackEvent('art.load', { source: 'remote', ok: true });
              } catch {}

              setLoading(false);
              return;
            }

            // Non-SVG image: use Image uri
            if (res.ok) {
              if (mounted) setRemoteUri(remotePath);
              try {
                const { trackEvent } = await import('../../lib/ai/analytics');
                trackEvent('art.load', { source: 'remote', ok: true, type: 'raster' });
              } catch {}

              setLoading(false);
              return;
            }

            throw new Error('non-ok response');
          } catch (_err) {
            if (attempts > DEFAULT_RETRIES) {
              break;
            }
            // retry
          }
        }

        // remote failed — continue to local fallback
        if (mounted) {
          setError(true);
          try {
            const { trackEvent } = await import('../../lib/ai/analytics');
            trackEvent('art.load', { source: 'remote', ok: false });
          } catch {}
        }
      }

      // Local SVG fallback (embedded)
      try {
        // prefer to render vector via react-native-svg if available
        setSvgXml(LOCAL_SVG);
        setLoading(false);
        return;
      } catch (_e) {
        if (mounted) setError(true);
      }

      if (mounted) setLoading(false);
    }

    tryLoad();
    return () => {
      mounted = false;
    };
  }, [remotePath, DEV_USE_LOCAL_ART]);

  if (loading) return (
    <View style={[styles.container, containerStyle]}>
      <ActivityIndicator />
    </View>
  );

  // Try to render SVG via react-native-svg if available
  if (svgXml) {
    try {
      // dynamic import so we don't hard-depend on native module in environments without it
       
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const { SvgXml } = require('react-native-svg');
      return (
        <View style={[styles.container, containerStyle]} pointerEvents="none">
          <SvgXml xml={svgXml} width="100%" height="100%" style={style} />
        </View>
      );
    } catch (e) {
      // react-native-svg not available — fall through to raster Image fallback
    }
  }

  if (remoteUri) {
    return (
      <View style={[styles.container, containerStyle]} pointerEvents="none">
        <Image source={{ uri: remoteUri }} style={[styles.image, style]} resizeMode="cover" />
      </View>
    );
  }

  // Prefer a local PNG asset if present — this keeps bundling predictable and fast.
  try {
     
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const local = require('../../assets/illustrations/homeHero.png');
    return (
      <View style={[styles.container, containerStyle]} pointerEvents="none">
        <Image source={local} style={[styles.image, style]} resizeMode="cover" />
      </View>
    );
  } catch (_e) {
    // Final fallback: render a tiny embedded PNG data-uri so Image rendering works
    const LOCAL_PNG_DATA_URI = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';

    return (
      <View style={[styles.container, containerStyle]} pointerEvents="none">
        <Image source={{ uri: LOCAL_PNG_DATA_URI }} style={[styles.image, style]} resizeMode="cover" />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
    height: '100%',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  fallback: {
    flex: 1,
    backgroundColor: 'rgba(255,255,255,0.02)',
    borderRadius: Platform.OS === 'ios' ? 22 : 18,
  },
});
