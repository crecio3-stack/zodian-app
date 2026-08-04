# Zodian Shadow Natural Reader Writer Canary v1

The shadow writer turns one complete Story Engine brief into a short reader-facing daily read. It does not choose the story, analyze identity, add a second theme, or interpret astrology. The brief is authoritative; identity labels provide only context.

The reader should receive one relevant observation, immediate curiosity, a naturally developing complication, a changed perspective, and a clear landing. The copy must not become a personality description, motivational speech, therapy language, corporate coaching, mystical astrology, generic advice, or a field-by-field summary.

Use plain, current conversational English: direct, observant, confident, warm without softness, and emotionally intelligent without clinical language. Avoid decorative prose, vague abstractions, formal transitions, spiritual filler, forced slang, artificial cleverness, and moral conclusions.

## Input boundary

The provider packet contains only exact identity labels plus the six committed Story Engine brief fields: daily thread, central tension, reader question, hook direction, perspective shift, and landing direction. It excludes canonical source passages, complete identity profiles, selection reasons, provenance, source IDs, production prompts, prior reads, and astrology mechanics. The writer must not add identity traits absent from the brief.

## Output

The local-only output contract retains version, scenario ID, and identity for traceability. Reader-facing content is only `title` and `read`. Titles are short and curious. Reads address the reader as you, stay in one thread, open with tension, develop one complication, change the frame, and land without becoming instructions. Target approximately 80–130 words without padding.

## Validation and execution

The canary validator is deliberately narrow. It rejects malformed output, identity or scenario mismatches, blank or incomplete fields, sign names, astrology mechanics, fixed scenes, named workplace/app patterns, therapy/corporate language, metadata references, generic horoscope warm-ups, repeated substantial sentences, second-theme tripwires, and command-heavy prose. It warns on mechanical brief copying, hook-like titles, generic advice endings, repetitive openings/endings, and excessive rhetorical questions.

Provider execution is a local script, never imported by the shadow module. It uses an exact preflighted `gpt-5.6-terra` request: JSON-object output and `max_output_tokens: 500`, with no temperature or other generation parameters. Preflight blocks any missing structured-output setting, wrong model, missing token limit, temperature, or unexpected parameter before a provider call is possible.

The response must contain exactly `version`, `scenarioId`, `identity`, `title`, and `read`; identity is exactly `{ westernSign, chineseSign }`, never a combined label string. The prompt preserves the brief’s story, not its sentences: it forbids complete internal sentences, copied hook/perspective/landing language, and lightly synonymized clause structures. The final sentence must be newly phrased.

The read primarily observes and reinterprets rather than instructs. Dominant advice and generic command endings are errors; occasional observational language such as “you may notice” remains allowed. The prompt avoids defaulting to a mid-read “But” turn. Corpus warnings flag repeated But turns, endings, “The X is real, but…” structures, and “What happens…” endings. It writes raw responses and a call ledger only to `/tmp/zodian-shadow-natural-reader-writer-canary-v1/`; no database, deployment, publication, routing, scheduler, resolver, or production path is involved.
