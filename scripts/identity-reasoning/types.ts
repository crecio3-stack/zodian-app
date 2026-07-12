export const SECTION_KEYS = [
  "character_portrait",
  "what_people_get_wrong",
  "what_youre_actually_looking_for",
  "when_life_works_against_you",
  "what_helps_you_find_yourself_again",
  "love_and_relationships",
  "work_and_career",
] as const;

export type IdentitySectionKey = typeof SECTION_KEYS[number];

export interface IdentitySectionPlan {
  section: IdentitySectionKey;
  question: string;
  plain_language_thesis: string;
  new_insight: string;
  behavioral_evidence: string[];
  signature_detail: string;
  themes_to_develop: string[];
  themes_to_avoid_repeating: string[];
  idea_to_leave_out: string;
  desired_rhythm: string;
}

export interface IdentityReasoningPlan {
  sign_pair: string;
  central_paradox: string;
  western_contribution: string;
  chinese_contribution: string;
  emergent_identity: string;
  what_they_notice: string[];
  decision_process: string;
  trust_process: string;
  recurring_misunderstanding: string;
  core_need: string;
  strength_in_balance: string;
  strength_overextended: string;
  restoration_pattern: string;
  love_pattern: string;
  work_pattern: string;
  recurring_themes: string[];
  identity_rhythm: string;
  one_sentence_identity_thesis: string;
  central_behavioral_proof: string;
  plain_language_guardrails: string[];
  section_plans: IdentitySectionPlan[];
}

export interface IdentityGenerationRequest {
  western_sign: string;
  chinese_sign: string;
  archetype_name?: string;
  source_notes?: string[];
  debug_reasoning?: boolean;
}

export interface IdentityGenerationResult {
  sign_pair: string;
  archetype_name?: string;
  character_portrait: string;
  what_people_get_wrong: string;
  what_youre_actually_looking_for: string;
  when_life_works_against_you: string;
  what_helps_you_find_yourself_again: string;
  love_and_relationships: string;
  work_and_career: string;
  generation_metadata: {
    engine_version: "identity-reasoning-v1";
    generated_at: string;
    reasoning_model: string;
    writing_model: string;
    development_only: true;
    audit: IdentityQualityAudit;
    reasoning_plan?: IdentityReasoningPlan;
  };
}

export interface IdentityQualityAudit {
  passed: boolean;
  issues: string[];
  section_word_counts: Record<IdentitySectionKey, number>;
  observable_behavior_hits: Record<IdentitySectionKey, number>;
  clarity_flags: Record<IdentitySectionKey, string[]>;
}
