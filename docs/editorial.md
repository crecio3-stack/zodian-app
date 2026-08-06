# Today’s Lens editorial constitution

The verified standard in the current prompts, amendments, fixtures, and tests is horoscope-first: astrology is the framing and timing lens, while the reader’s ordinary life is the subject. The intended experience is recognition (“this sounds like my day”) with a gentle, usable shift in perspective—not diagnosis, treatment, instruction, or mystification.

Use direct second-person language, everyday vocabulary, approximately eighth-grade readability, natural personality, and identity-specific relevance. Ground the read in observable choices, messages, conversations, plans, social situations, and small tensions. Keep one recognizable thread. A longer sentence can be natural when it carries a real thought; tangled overlong sentences and compressed fragments are rejected by applicable versioned rules.

Open with a concrete hook or ordinary situation. Establish a central tension, then offer a perspective shift that still feels like a horoscope. Land with an emotionally specific observation or gentle suggestion. A suggestion may invite awareness or a small choice; it must not become a procedural or managerial command.

Avoid therapy, coaching, behavioral-clinical, corporate, management, academic, and generic mystical language. Reject staged time-of-day scaffolding when it is used as a mechanical structure. Isolated natural references such as “today” or “tonight” are version-specific and may be allowed by the active rules; do not generalize from an experiment. Avoid repetitive answer-shaped templates, repeated openings/endings, and corpus-level sameness. Opening-family assignment and ending diversity exist in the sky-led path; applicability is version-specific.

Titles are version-specific. The verified canonical shadow shape requires a 2–4 word title without terminal punctuation; the production generator prompt also asks for a natural, emotionally specific title and no sign pair. JSON output is contractual where the writer specifies it: the canonical shadow validator requires exactly `title`, `intro`, `pull_quote`, `deeper_read`, `watch_for`, and `move`; other writers have different envelopes.

## Verified examples

Examples are quoted only from repository evidence:

- Rejected output diagnostics include `title must be 2-4 words without terminal punctuation` and `watch_for and move must differ` (`supabase/functions/generate-canonical-lens-shadow/index.ts`).
- The production prompt says `Return only valid JSON. No markdown. No explanation.` and requires exactly named fields (`supabase/functions/generate-daily-rituals/index.ts:2901`, `:3100`).
- The scheduler/writer test corpus includes the approved natural-reader fixtures and opening-family assignment cases (`supabase/functions/_shared/todays-lens-sky-led-production-candidate-v1_test.ts`, `scripts/dev/sky_led_production_assignment_wiring_v1_test.ts`). These are source references rather than invented copy examples.

Experimental, shadow, preview, and pilot rules are not automatically production-approved. The active writer version, prompt version, and validator version must be named before promotion.

## Editorial review before promotion

- Is the astrology framing present without exposition taking over?
- Does the opening catch one ordinary, recognizable situation?
- Is the voice direct, warm, natural, and second-person?
- Is the language everyday and readable without becoming generic?
- Is the observation identity-specific and grounded in the approved input?
- Does the read move through tension, perspective shift, and a satisfying landing?
- Is any suggestion gentle rather than procedural or managerial?
- Are time-of-day scaffolding and answer-shaped repetition absent under the active rules?
- Does the output satisfy the exact active JSON/title/length contract?
- Has the matching prompt, validator, test, and version been reviewed together?

Evidence includes `supabase/functions/generate-daily-rituals/zodian-editorial-voice-v2.1.md`, its amendment, `todays-lens-horoscope-writer-v2.md`, and related writer tests. No invented gold-standard examples are included here; consult those files and fixtures for exact examples. Experimental artifacts and previews are not automatically approved production standards.
