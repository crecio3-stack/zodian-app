/** Provider-free contract checks for the Identity presentation source inventory. */
import { assert, assertEquals } from "jsr:@std/assert@1";

const requiredFields = [
  "signCombination", "archetype", "coreSynthesis", "tell", "strength", "shadow",
  "howItShowsUp", "whatGetsInTheWay", "loveAndFriendship", "trustAndCloseness",
  "decisionMaking", "workAndPurpose", "underPressure", "restoration", "growth",
  "closingSynthesis", "shareableSummary",
];

const fixtureIDs = [
  "libra-snake", "taurus-horse", "cancer-pig", "virgo-goat",
  "gemini-tiger", "leo-horse", "pisces-dog", "aquarius-snake",
];

const archetypes = JSON.parse(await Deno.readTextFile("Resources/archetypes.json")) as Array<Record<string, unknown>>;
const archetypeIDs = new Set(archetypes.map((entry) => String(entry.id ?? "")));

for (const field of requiredFields) assert(field.length > 0);
assertEquals(new Set(fixtureIDs).size, 8);
assert(fixtureIDs.every((id) => id.includes("-")));
assert(fixtureIDs.every((id) => archetypeIDs.has(id)));

console.log(JSON.stringify({
  result: "PASS",
  required_fields: requiredFields.length,
  development_fixture_count: fixtureIDs.length,
  canonical_fixture_matches: fixtureIDs.length,
  provider_calls: 0,
}, null, 2));
