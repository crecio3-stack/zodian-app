import { EVENTS, trackAppEvent } from '../analytics/analytics';

type RouterLike = {
  push: (...args: any[]) => void;
};

export type PremiumEntrySource =
  | 'home_go_deeper'
  | 'daily_go_deeper'
  | 'daily_inline_modal'
  | 'match_unlock_more'
  | 'connections_beta'
  | 'profile_premium_card'
  | 'rewards_upsell';

export function openPremiumScreen(router: RouterLike, source: PremiumEntrySource) {
  trackAppEvent(EVENTS.PREMIUM_CTA_TAPPED, { source }).catch(() => {});
  router.push({ pathname: '/premium', params: { source } });
}