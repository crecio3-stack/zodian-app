# Zodian Canonical Source Registry v1

## Product purpose

The canonical source registry identifies approved materials that may inform Zodian’s identity system. It establishes source identity, approval, permitted use, transformation requirements, provenance behavior, and downstream restrictions. The registry is governance and metadata, not a source-content store.

## Source traceability

Every distilled identity profile derived from canonical material should trace to one or more stable source IDs. A source ID identifies an approved source record, not a copied passage, and remains stable across downstream systems.

## Transformation boundary

Canonical sources may inform transformed editorial understanding. Raw source language must not flow directly into Identity Editorial Layer profiles, Story Engine briefs, writer prompts, generated reads, or reader-facing copy. Downstream systems may retain approved source IDs, concise independently phrased editorial distillations, and source-version metadata when needed. They must not retain copied passages, long excerpts, source-specific prose style, page-length text, or untransformed copyrighted expression.

## Suzanne White boundary

The initial approved canonical source is Suzanne White’s combined Western and Chinese identity system covering 144 identities. This registry records only its metadata, approval, coverage, and transformation policy. It does not ingest or reproduce passages, infer traits, populate identities, or encode excerpts. It does not claim permissions or licensing rights.

## Approval model

- `approved`: may inform transformed editorial profiles under its declared policy.
- `restricted`: retained for reference but not permitted for normal downstream transformation.
- `deprecated`: not used for new profiles, but remains resolvable for historical traceability.

## Replacement and versioning

Records retain stable source IDs and source versions. A replacement relationship is explicit; a new version must not silently replace historical provenance. Deprecated IDs remain resolvable for existing records.

## Coverage

v1 supports all combined Western × Chinese identities, selected combined identities, general Western signs, general Chinese signs, and reference or methodology material. It contains no identity-specific content.

## v1 boundary

This is isolated, shadow-only governance metadata. It does not ingest documents, extract traits, generate editorial profiles or prose, choose stories, connect to a provider, or connect to production, Story Engine, Identity Editorial Layer execution, the writer, database, routing, scheduling, or cron job 26.
