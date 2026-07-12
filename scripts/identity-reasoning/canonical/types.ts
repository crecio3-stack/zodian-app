export type IdentityStatus = "draft" | "reviewed" | "frozen";
export type IdentitySourceType = "editorial" | "generated" | "hybrid";
export type DecisionPace =
  | "immediate"
  | "fast"
  | "measured"
  | "deliberate"
  | "slow";
export type SocialRole =
  | "initiator"
  | "mediator"
  | "observer"
  | "stabilizer"
  | "challenger"
  | "protector"
  | "strategist"
  | "builder"
  | "explorer"
  | "caretaker"
  | "amplifier"
  | "organizer";

export interface IdentityCore {
  centralParadox: string;
  coreDrive: string;
  coreNeed: string;
  coreFear: string;
  matureExpression: string;
  recurringThemes: string[];
}

export interface IdentitySourceReasoning {
  westernContribution: string;
  chineseContribution: string;
  emergentSynthesis: string;
}

export interface IdentityPerceptionModel {
  noticesFirst: string;
  noticesInPeople: string[];
  noticesInSituations: string[];
  readsAsThreat: string[];
  readsAsOpportunity: string[];
  interpretationBias: string;
  attentionBlindSpot: string;
}

export interface IdentityDecisionModel {
  decisionPace: DecisionPace;
  defaultProcess: string;
  evidenceThreshold: string;
  actionTrigger: string;
  delayPattern: string;
  reversalPattern: string;
  regretPattern: string;
  certaintyStyle: string;
}

export interface IdentitySocialModel {
  defaultRole: SocialRole;
  communicationStyle: string;
  conflictStyle: string;
  influenceStyle: string;
  boundaryStyle: string;
  commonMisreads: string[];
  responseToGroupUncertainty: string;
  responseToAuthority: string;
}

export interface IdentityRelationshipModel {
  attractionPattern: string;
  trustBuilders: string[];
  trustBreakers: string[];
  closenessStyle: string;
  loyaltyStyle: string;
  forgivenessPattern: string;
  relationshipBlindSpot: string;
  healthyRelationshipCondition: string;
  withdrawalTrigger: string;
}

export interface IdentityWorkModel {
  valueCreated: string;
  problemSolvingStyle: string;
  teamRole: string;
  leadershipStyle: string;
  idealConditions: string[];
  drainingConditions: string[];
  relationshipToStructure: string;
  relationshipToAutonomy: string;
  careerBlindSpot: string;
  completionSignal: string;
  releasePattern: string;
}

export interface IdentityPressureModel {
  firstShift: string;
  overextendedStrength: string;
  visibleBehaviors: string[];
  internalStory: string;
  emotionalCost: string;
  relationalCost: string;
  decisionDistortion: string;
  shadowRole: string;
  escalationPattern: string;
}

export interface IdentityGrowthModel {
  restorationPattern: string;
  helpfulConditions: string[];
  helpfulPeople: string[];
  groundingBehaviors: string[];
  recurringLesson: string;
  growthEdge: string;
  recoveryRecognition: string;
  matureReturn: string;
}

export interface IdentityEvidenceModel {
  observableBehaviors: string[];
  everydaySituations: string[];
  signatureContrasts: string[];
  signatureObservations: string[];
  prohibitedGenericClaims: string[];
}

export interface CanonicalIdentityModel {
  signPair: string;
  westernSign: string;
  chineseSign: string;
  archetypeName: string;
  version: "1.0.0";
  status: IdentityStatus;
  sourceType: IdentitySourceType;
  core: IdentityCore;
  sourceReasoning: IdentitySourceReasoning;
  perception: IdentityPerceptionModel;
  decision: IdentityDecisionModel;
  social: IdentitySocialModel;
  relationships: IdentityRelationshipModel;
  work: IdentityWorkModel;
  pressure: IdentityPressureModel;
  growth: IdentityGrowthModel;
  evidence: IdentityEvidenceModel;
}

export type CanonicalIdentitySection =
  | "centralParadox"
  | "primaryMisunderstanding"
  | "trustPattern"
  | "pressureLoop"
  | "restorationPattern"
  | "loveLogic"
  | "workLogic";

export interface IdentityTraceabilityEntry {
  semanticArea: CanonicalIdentitySection;
  editorialSection: string;
  proseSignal: string;
  canonicalPaths: string[];
  coverageNote: string;
}

export interface IdentityTraceabilityArtifact {
  signPair: string;
  sourceArtifact: string;
  entries: IdentityTraceabilityEntry[];
}
