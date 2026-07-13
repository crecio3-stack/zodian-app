import { PCV1_PRODUCER_VERSION } from "./producer_contract.ts";

export const CANDIDATE_VERSION = "pcv1" as const;
export const readableCandidateVersions = [
  CANDIDATE_VERSION,
  PCV1_PRODUCER_VERSION,
] as const;
export type ReadableCandidateVersion = typeof readableCandidateVersions[number];

export function isReadableCandidateVersion(
  value: string,
): value is ReadableCandidateVersion {
  return readableCandidateVersions.includes(value as ReadableCandidateVersion);
}

export const candidateStatuses = [
  "RUNNING",
  "ACCEPTED",
  "BLOCKED",
  "WRITER_REJECTED",
  "VALIDATOR_REJECTED",
  "TRANSPORT_FAILED",
  "REPETITION_HOLD",
] as const;
export type CandidateStatus = typeof candidateStatuses[number];

export type CandidateRecord = {
  candidate_version: string;
  candidate_date: string;
  western_sign: string;
  eastern_sign: string;
  source_context: string;
  status: CandidateStatus;
  candidate_title: string | null;
  candidate_read: string | null;
};

export type InternalCandidateResponse =
  | {
    version: ReadableCandidateVersion;
    status: "accepted";
    title: string;
    read: string;
  }
  | {
    version: ReadableCandidateVersion;
    status:
      | "blocked"
      | "writer_rejected"
      | "validator_rejected"
      | "transport_failed"
      | "repetition_hold"
      | "running";
    reason_code?: string;
  };

const terminalReasonCodes: Partial<Record<CandidateStatus, string>> = {
  BLOCKED: "evidence_insufficient",
  WRITER_REJECTED: "writer_rejected",
  VALIDATOR_REJECTED: "validator_rejected",
  TRANSPORT_FAILED: "transport_failed",
  REPETITION_HOLD: "repetition_hold",
};

export function nonblank(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

export function candidateKey(
  input: Pick<
    CandidateRecord,
    | "candidate_version"
    | "candidate_date"
    | "western_sign"
    | "eastern_sign"
    | "source_context"
  >,
): string {
  return [
    input.candidate_version,
    input.candidate_date,
    input.western_sign,
    input.eastern_sign,
    input.source_context,
  ].map((value) => value.trim().toLowerCase()).join("|");
}

export function candidateRecordErrors(record: CandidateRecord): string[] {
  const errors: string[] = [];
  if (!candidateStatuses.includes(record.status)) errors.push("invalid status");
  for (
    const field of [
      "candidate_version",
      "candidate_date",
      "western_sign",
      "eastern_sign",
      "source_context",
    ] as const
  ) {
    if (!nonblank(record[field])) errors.push(`${field} must be nonblank`);
  }
  if (record.status === "ACCEPTED") {
    if (!nonblank(record.candidate_title)) {
      errors.push("accepted candidate requires a title");
    }
    if (!nonblank(record.candidate_read)) {
      errors.push("accepted candidate requires a read");
    }
  } else if (
    record.candidate_title !== null || record.candidate_read !== null
  ) {
    errors.push(
      "non-accepted candidate must not store partial or fallback copy",
    );
  }
  return errors;
}

export function resumeDisposition(
  status: CandidateStatus,
  leaseExpired = false,
):
  | "claim"
  | "resume_transport"
  | "wait"
  | "return_existing" {
  if (status === "TRANSPORT_FAILED") return "resume_transport";
  if (status === "RUNNING") return leaseExpired ? "claim" : "wait";
  return "return_existing";
}

export function internalCandidateResponse(
  record: CandidateRecord,
): InternalCandidateResponse {
  if (!isReadableCandidateVersion(record.candidate_version)) {
    throw new Error("candidate version is not readable through the internal endpoint");
  }
  const version = record.candidate_version;
  if (record.status === "ACCEPTED") {
    if (!nonblank(record.candidate_title) || !nonblank(record.candidate_read)) {
      throw new Error(
        "accepted candidate is missing complete title/read content",
      );
    }
    return {
      version,
      status: "accepted",
      title: record.candidate_title,
      read: record.candidate_read,
    };
  }
  const status = record.status.toLowerCase() as Exclude<
    InternalCandidateResponse["status"],
    "accepted"
  >;
  const reason_code = terminalReasonCodes[record.status];
  return reason_code
    ? { version, status, reason_code }
    : { version, status };
}
