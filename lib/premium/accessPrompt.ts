import { Alert } from 'react-native';

type PremiumAccessPromptParams = {
  title: string;
  message: string;
  onUseStarDust: () => void;
  onPremium: () => void;
  cancelText?: string;
};

export function showPremiumAccessPrompt({
  title,
  message,
  onUseStarDust,
  onPremium,
  cancelText = 'Not now',
}: PremiumAccessPromptParams) {
  Alert.alert(title, message, [
    { text: 'Use Star Dust', onPress: onUseStarDust },
    { text: 'Upgrade to Premium', onPress: onPremium },
    { text: cancelText, style: 'cancel' },
  ]);
}

export function showGoDeeperAccessPrompt(params: {
  onUseStarDust: () => void;
  onPremium: () => void;
}) {
  showPremiumAccessPrompt({
    title: 'Go Deeper locked',
    message: 'Use Star Dust now for a 24-hour Go Deeper pass, or upgrade to Premium for always-on access.',
    onUseStarDust: params.onUseStarDust,
    onPremium: params.onPremium,
  });
}

export function showSwipeLimitPrompt(params: {
  onUseStarDust: () => void;
  onPremium: () => void;
}) {
  showPremiumAccessPrompt({
    title: 'No swipes left today',
    message: 'Use Star Dust now for a +10 swipe pack, or upgrade to Premium for unlimited swipes.',
    onUseStarDust: params.onUseStarDust,
    onPremium: params.onPremium,
  });
}

export function hasGoDeeperAccess(isPremium: boolean, hasGoDeeperPass: boolean) {
  return isPremium || hasGoDeeperPass;
}