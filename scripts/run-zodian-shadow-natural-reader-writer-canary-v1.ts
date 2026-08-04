/** Local-only execution: exactly one provider request for each approved shadow canary packet. */
import {
  buildZodianShadowNaturalReaderWriterCanaryV1ProviderRequest,
  listZodianShadowNaturalReaderWriterCanaryV1Packets,
  validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest,
  validateZodianShadowNaturalReaderWriterCanaryV1Output,
} from "../supabase/functions/_shared/zodian-shadow-natural-reader-writer-canary-v1.ts";

const ARTIFACT_DIRECTORY = new URL("file:///tmp/zodian-shadow-natural-reader-writer-canary-v1/");
const APPROVED_MODEL = "gpt-5.6-terra";

function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
function redact(value: string): string { return value.replace(/sk-[A-Za-z0-9_-]+/g, "[REDACTED]"); }
function providerText(payload: Record<string, unknown>): string {
  if (typeof payload.output_text === "string") return payload.output_text;
  const output = Array.isArray(payload.output) ? payload.output : [];
  return output.flatMap((item) => typeof item === "object" && item && Array.isArray((item as { content?: unknown }).content) ? (item as { content: unknown[] }).content : [])
    .map((item) => typeof item === "object" && item && typeof (item as { text?: unknown }).text === "string" ? (item as { text: string }).text : "")
    .filter(Boolean).join("");
}

async function main() {
  const retryAttempt = Deno.args.includes("--retry-technical-2") ? 2 : Deno.args.includes("--retry-technical") ? 1 : 0;
  const technicalRetry = retryAttempt > 0;
  const apiKey = Deno.env.get("OPENAI_API_KEY")?.trim();
  const model = Deno.env.get("OPENAI_IDENTITY_EDITORIAL_MODEL")?.trim();
  assert(apiKey, "OPENAI_API_KEY must be present before the approved local canary.");
  assert(model === APPROVED_MODEL, `OPENAI_IDENTITY_EDITORIAL_MODEL must equal ${APPROVED_MODEL}.`);
  await Deno.mkdir(ARTIFACT_DIRECTORY, { recursive: true });
  const packets = listZodianShadowNaturalReaderWriterCanaryV1Packets();
  assert(packets.length === 4, "Canary must contain exactly four packets.");
  const ledger: unknown[] = [];
  for (const [index, packet] of packets.entries()) {
    const startedAt = new Date().toISOString();
    const started = performance.now();
    let httpStatus: number | null = null;
    let rawResponse: unknown = null;
    let parsed: unknown = null;
    let error: string | null = null;
    try {
      const request = buildZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(packet);
      const preflight = validateZodianShadowNaturalReaderWriterCanaryV1ProviderRequest(request);
      assert(!preflight.length, `Provider request preflight failed: ${preflight.join("; ")}`);
      const response = await fetch("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
        body: JSON.stringify(request),
      });
      httpStatus = response.status;
      const body = await response.text();
      rawResponse = JSON.parse(body);
      assert(response.ok, `OpenAI ${response.status}: ${redact(body).slice(0, 800)}`);
      parsed = JSON.parse(providerText(rawResponse as Record<string, unknown>));
    } catch (cause) { error = redact(cause instanceof Error ? cause.message : String(cause)); }
    const findings = parsed ? validateZodianShadowNaturalReaderWriterCanaryV1Output(parsed, packet) : [{ field: "output", code: "provider_or_parse_failure", severity: "error", message: error ?? "Provider returned no parseable output." }];
    const retryReason = retryAttempt === 1 ? "Initial request was technically unusable because this model rejects temperature." : retryAttempt === 2 ? "First technical retry was unusable because identity was a string instead of the required object." : null;
    const artifact = { scenarioId: packet.scenarioId, call: index + 1, attempt: technicalRetry ? `technical-retry-${retryAttempt}` : "initial", provider: "openai", model, settings: { maxOutputTokens: 500, responseFormat: "json_object" }, startedAt, elapsedMs: Math.round(performance.now() - started), httpStatus, automaticRetry: technicalRetry, retryReason, rawResponse, parsed, findings };
    const prefix = retryAttempt === 2 ? "retry-2" : technicalRetry ? "retry" : "call";
    await Deno.writeTextFile(new URL(`${prefix}-${String(index + 1).padStart(2, "0")}-${packet.scenarioId}.json`, ARTIFACT_DIRECTORY), JSON.stringify(artifact, null, 2));
    ledger.push({ scenarioId: packet.scenarioId, call: index + 1, attempt: artifact.attempt, provider: "openai", model, httpStatus, elapsedMs: artifact.elapsedMs, automaticRetry: technicalRetry, retryReason: artifact.retryReason, error, findings });
  }
  await Deno.writeTextFile(new URL(retryAttempt === 2 ? "retry-ledger-2.json" : technicalRetry ? "retry-ledger.json" : "call-ledger.json", ARTIFACT_DIRECTORY), JSON.stringify(ledger, null, 2));
  console.log(JSON.stringify({ artifactDirectory: ARTIFACT_DIRECTORY.pathname, attemptedCalls: ledger.length, ledger }, null, 2));
}

if (import.meta.main) await main();
