import {
  CANDIDATE_VERSION,
  isReadableCandidateVersion,
  candidateKey,
  type CandidateRecord,
  candidateRecordErrors,
  type CandidateStatus,
  internalCandidateResponse,
  resumeDisposition,
} from "./candidate_contract.ts";
import { PCV1_PRODUCER_VERSION } from "./producer_contract.ts";

function candidate(
  status: CandidateStatus,
  overrides: Partial<CandidateRecord> = {},
): CandidateRecord {
  const accepted = status === "ACCEPTED";
  return {
    candidate_version: CANDIDATE_VERSION,
    candidate_date: "2026-07-13",
    western_sign: "Scorpio",
    eastern_sign: "Dragon",
    source_context: "recognition-public-credit-neutral",
    status,
    candidate_title: accepted ? "Let It Land" : null,
    candidate_read: accepted
      ? "You can let the work be finished after you receive credit for it."
      : null,
    ...overrides,
  };
}

Deno.test("only accepted candidates may contain complete title and read", () => {
  if (candidateRecordErrors(candidate("ACCEPTED")).length !== 0) {
    throw new Error("A complete accepted candidate should validate.");
  }
  const missingRead = candidateRecordErrors(candidate("ACCEPTED", {
    candidate_read: null,
  }));
  if (!missingRead.includes("accepted candidate requires a read")) {
    throw new Error("Accepted candidates must require complete content.");
  }
  const partialBlocked = candidateRecordErrors(candidate("BLOCKED", {
    candidate_title: "Partial",
  }));
  if (
    !partialBlocked.includes(
      "non-accepted candidate must not store partial or fallback copy",
    )
  ) {
    throw new Error("Non-accepted candidates must reject partial copy.");
  }
});

Deno.test("all terminal states remain explicit and contain no candidate copy", () => {
  const statuses: CandidateStatus[] = [
    "BLOCKED",
    "WRITER_REJECTED",
    "VALIDATOR_REJECTED",
    "TRANSPORT_FAILED",
    "REPETITION_HOLD",
  ];
  for (const status of statuses) {
    const record = candidate(status);
    if (candidateRecordErrors(record).length !== 0) {
      throw new Error(
        `${status} should permit an explicit no-copy terminal state.`,
      );
    }
    const response = internalCandidateResponse(record);
    if ("title" in response || "read" in response) {
      throw new Error(`${status} must not expose partial or fallback content.`);
    }
    if (!response.reason_code) {
      throw new Error(
        `${status} should expose only its safe fixed reason code.`,
      );
    }
  }
});

Deno.test("internal endpoint projection excludes traces and returns exactly title/read for accepted", () => {
  const response = internalCandidateResponse(candidate("ACCEPTED"));
  if (
    JSON.stringify(Object.keys(response).sort()) !==
      JSON.stringify(["read", "status", "title", "version"])
  ) {
    throw new Error(
      "Accepted endpoint response must expose only version, status, title, and read.",
    );
  }
  if (response.status !== "accepted" || !response.title || !response.read) {
    throw new Error("Accepted endpoint response is incomplete.");
  }
});

Deno.test("internal endpoint reads only the explicit version allowlist and returns the stored version", () => {
  if (!isReadableCandidateVersion(CANDIDATE_VERSION)) {
    throw new Error("Historical pcv1 must remain internally readable.");
  }
  if (!isReadableCandidateVersion(PCV1_PRODUCER_VERSION)) {
    throw new Error("Current frozen-input candidate version must be internally readable.");
  }
  if (isReadableCandidateVersion("pcv1-unapproved-version")) {
    throw new Error("Unknown candidate versions must not be readable.");
  }
  const response = internalCandidateResponse(candidate("ACCEPTED", {
    candidate_version: PCV1_PRODUCER_VERSION,
  }));
  if (response.version !== PCV1_PRODUCER_VERSION) {
    throw new Error("Endpoint response must return the stored candidate version.");
  }
});

Deno.test("idempotency key is deterministic and case-insensitive", () => {
  const first = candidateKey(candidate("ACCEPTED"));
  const second = candidateKey(candidate("ACCEPTED", {
    western_sign: "scorpio",
    eastern_sign: "dragon",
  }));
  if (first !== second) {
    throw new Error("Equivalent candidate keys must match.");
  }
  const changedContext = candidateKey(candidate("ACCEPTED", {
    source_context: "different-neutral-situation",
  }));
  if (first === changedContext) {
    throw new Error("Source context must participate in idempotency.");
  }
});

Deno.test("only transport failures and expired running leases can resume", () => {
  if (resumeDisposition("TRANSPORT_FAILED") !== "resume_transport") {
    throw new Error("Transport failure must be resumable.");
  }
  if (resumeDisposition("RUNNING") !== "wait") {
    throw new Error("Active work must not be duplicated.");
  }
  if (resumeDisposition("RUNNING", true) !== "claim") {
    throw new Error("An expired running lease must be reclaimable.");
  }
  for (
    const status of [
      "ACCEPTED",
      "BLOCKED",
      "WRITER_REJECTED",
      "VALIDATOR_REJECTED",
      "REPETITION_HOLD",
    ] as CandidateStatus[]
  ) {
    if (resumeDisposition(status) !== "return_existing") {
      throw new Error(`${status} must remain immutable on repeat request.`);
    }
  }
});
