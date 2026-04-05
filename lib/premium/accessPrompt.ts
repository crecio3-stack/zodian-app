import { Alert } from 'react-native';
import { EVENTS, trackAppEvent } from '../analytics/analytics';

type PremiumAccessPromptParams = {
  title: string;
  message: string;
  onUseStarDust: () => void;
  onPremium: () => void;
  cancelText?: string;
  source?: string;
};

export function showPremiumAccessPrompt({
  title,
  message,
  onUseStarDust,
  onPremium,
  cancelText = 'Not now',
  source = 'unknown',
}: PremiumAccessPromptParams) {
  trackAppEvent(EVENTS.PREMIUM_PROMPT_VIEWED, { source, title }).catch(() => {});

  Alert.alert(title, message, [
    {
      text: 'Use Star Dust',
      onPress: () => {
        trackAppEvent(EVENTS.PREMIUM_PROMPT_ACTION, { source, title, action: 'use_star_dust' }).catch(() => {});
        onUseStarDust();
      },
    },
    {
      text: 'Upgrade to Premium',
      onPress: () => {
        trackAppEvent(EVENTS.PREMIUM_PROMPT_ACTION, { source, title, action: 'upgrade' }).catch(() => {});
        onPremium();
      },
    },
    {
      text: cancelText,
      style: 'cancel',
      onPress: () => {
        trackAppEvent(EVENTS.PREMIUM_PROMPT_ACTION, { source, title, action: 'cancel' }).catch(() => {});
      },
    },
  ]);
}

export function showGoDeeperAccessPrompt(params: {
  onUseStarDust: () => void;
  onPremium: () => void;
  source?: string;
}) {
  showPremiumAccessPrompt({
    title: 'Go Deeper locked',
    message: 'Use Star Dust now for a 24-hour Go Deeper pass, or upgrade to Premium for always-on access.',
    onUseStarDust: params.onUseStarDust,
    onPremium: params.onPremium,
    source: params.source ?? 'go_deeper_prompt',
  });
}

export function showSwipeLimitPrompt(params: {
  onUseStarDust: () => void;
  onPremium: () => void;
  source?: string;
}) {
  showPremiumAccessPrompt({
    title: 'No swipes left today',
    message: 'Use Star Dust now for a +10 swipe pack, or upgrade to Premium for unlimited swipes.',
    onUseStarDust: params.onUseStarDust,
    onPremium: params.onPremium,
    source: params.source ?? 'swipe_limit_prompt',
  });
}

export function hasGoDeeperAccess(isPremium: boolean, hasGoDeeperPass: boolean) {
  return isPremium || hasGoDeeperPass;
}