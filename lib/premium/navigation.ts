import { EVENTS, trackAppEvent } from '../analytics/analytics';

type RouterLike = {
  push: (href: '/premium') => void;
};

export type PremiumEntrySource =
  | 'home_go_deeper'
  | 'daily_go_deeper'
  | 'match_unlock_more'
  | 'profile_premium_card'
  | 'rewards_upsell';

export function openPremiumScreen(router: RouterLike, source: PremiumEntrySource) {
  trackAppEvent(EVENTS.PREMIUM_VIEWED, { source }).catch(() => {});
  router.push('/premium');
}