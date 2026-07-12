import type { IdentityTraceabilityArtifact } from "./types.ts";

export const libraSnakeTraceability: IdentityTraceabilityArtifact = {
  signPair: "Libra × Snake",
  sourceArtifact: "../fixtures/libra-snake.editorial-benchmark.json",
  entries: [
    {
      semanticArea: "centralParadox",
      editorialSection: "Character Portrait",
      proseSignal:
        "Keeps the picture open longer than others, then becomes quietly firm.",
      canonicalPaths: ["core.centralParadox", "decision.certaintyStyle"],
      coverageNote:
        "Captures openness plus the need to trust a privately earned conclusion.",
    },
    {
      semanticArea: "primaryMisunderstanding",
      editorialSection: "What People Often Get Wrong About You",
      proseSignal:
        "Deliberate observation is misread as hesitation or passivity.",
      canonicalPaths: [
        "social.commonMisreads",
        "perception.interpretationBias",
      ],
      coverageNote: "Separates visible delay from active pattern-reading.",
    },
    {
      semanticArea: "trustPattern",
      editorialSection: "What You're Actually Looking For",
      proseSignal: "Trust gathers through repeated conduct on ordinary days.",
      canonicalPaths: [
        "relationships.trustBuilders",
        "decision.evidenceThreshold",
      ],
      coverageNote:
        "Represents recurrence rather than promises or isolated moments.",
    },
    {
      semanticArea: "pressureLoop",
      editorialSection: "When Life Starts Working Against You",
      proseSignal:
        "One more review creates less peace and less access to self-trust.",
      canonicalPaths: [
        "pressure.escalationPattern",
        "pressure.decisionDistortion",
      ],
      coverageNote: "Explains how discernment becomes circular postponement.",
    },
    {
      semanticArea: "restorationPattern",
      editorialSection: "What Helps You Find Yourself Again",
      proseSignal:
        "Life moves when they decide which questions no longer need answers.",
      canonicalPaths: [
        "growth.restorationPattern",
        "growth.recoveryRecognition",
      ],
      coverageNote:
        "Recovery is selective closure, not additional information.",
    },
    {
      semanticArea: "loveLogic",
      editorialSection: "Love & Relationships",
      proseSignal:
        "Ordinary consistency creates safety; generosity can excuse repeated evidence.",
      canonicalPaths: [
        "relationships.healthyRelationshipCondition",
        "relationships.relationshipBlindSpot",
      ],
      coverageNote:
        "Connects attraction, loyalty, and the overextension of understanding.",
    },
    {
      semanticArea: "workLogic",
      editorialSection: "Work & Career",
      proseSignal:
        "They improve the decision by finding missing context but can polish past completion.",
      canonicalPaths: [
        "work.valueCreated",
        "work.careerBlindSpot",
        "work.completionSignal",
      ],
      coverageNote:
        "The same discernment drives contribution and overextension.",
    },
  ],
};

export const taurusHorseTraceability: IdentityTraceabilityArtifact = {
  signPair: "Taurus × Horse",
  sourceArtifact: "../previews/taurus-horse.editorial-review.json",
  entries: [
    {
      semanticArea: "centralParadox",
      editorialSection: "Character Portrait",
      proseSignal:
        "Builds by returning but moves decisively once the next step is worth leaving proven ground.",
      canonicalPaths: ["core.centralParadox", "decision.actionTrigger"],
      coverageNote:
        "Captures stability and freedom as interdependent rather than opposing trait labels.",
    },
    {
      semanticArea: "primaryMisunderstanding",
      editorialSection: "What People Often Get Wrong About You",
      proseSignal:
        "Private reevaluation makes a deliberate decision look sudden.",
      canonicalPaths: ["social.commonMisreads", "decision.defaultProcess"],
      coverageNote:
        "Accounts for stubbornness, availability, silence, and suddenness misreads.",
    },
    {
      semanticArea: "trustPattern",
      editorialSection: "What You're Actually Looking For",
      proseSignal:
        "Trust comes from follow-through, respected time, and independence that is supported rather than questioned.",
      canonicalPaths: [
        "relationships.trustBuilders",
        "relationships.healthyRelationshipCondition",
      ],
      coverageNote: "Defines stable commitment that remains freely chosen.",
    },
    {
      semanticArea: "pressureLoop",
      editorialSection: "When Life Starts Working Against You",
      proseSignal:
        "A temporary compromise accumulates until adjustment becomes escape.",
      canonicalPaths: [
        "pressure.firstShift",
        "pressure.escalationPattern",
        "pressure.relationalCost",
      ],
      coverageNote:
        "Preserves the hidden duration and visible abruptness of the loop.",
    },
    {
      semanticArea: "restorationPattern",
      editorialSection: "What Helps You Find Yourself Again",
      proseSignal:
        "Physical movement and a smaller practical question restore flexibility.",
      canonicalPaths: [
        "growth.groundingBehaviors",
        "growth.recoveryRecognition",
      ],
      coverageNote:
        "Represents recovery through workable adjustment rather than reinvention.",
    },
    {
      semanticArea: "loveLogic",
      editorialSection: "Love & Relationships",
      proseSignal:
        "Tangible care builds a shared life, but loyalty also needs words and room for two complete people.",
      canonicalPaths: [
        "relationships.loyaltyStyle",
        "relationships.relationshipBlindSpot",
        "relationships.closenessStyle",
      ],
      coverageNote:
        "Derives love from practical continuity plus voluntary closeness.",
    },
    {
      semanticArea: "workLogic",
      editorialSection: "Work & Career",
      proseSignal:
        "They make ideas last by thinking about maintenance after excitement fades.",
      canonicalPaths: [
        "work.valueCreated",
        "work.completionSignal",
        "work.careerBlindSpot",
      ],
      coverageNote:
        "Connects endurance to value creation and inertia to career risk.",
    },
  ],
};
