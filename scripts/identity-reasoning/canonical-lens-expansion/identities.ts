import type { CanonicalIdentityModel } from "../canonical/types.ts";
import { libraSnakeCanonical } from "../canonical/fixtures/libra-snake.ts";
import { taurusHorseCanonical } from "../canonical/fixtures/taurus-horse.ts";

type Variant = Partial<
  Pick<
    CanonicalIdentityModel,
    | "signPair"
    | "westernSign"
    | "chineseSign"
    | "archetypeName"
    | "core"
    | "sourceReasoning"
    | "perception"
    | "decision"
    | "social"
    | "relationships"
    | "work"
    | "pressure"
    | "growth"
    | "evidence"
  >
>;

function variant(
  base: CanonicalIdentityModel,
  changes: Variant,
): CanonicalIdentityModel {
  return {
    ...base,
    ...changes,
    version: "1.0.0",
    status: "reviewed",
    sourceType: "hybrid",
  };
}

export const expansionIdentities: CanonicalIdentityModel[] = [
  variant(taurusHorseCanonical, {
    signPair: "Sagittarius × Monkey",
    westernSign: "Sagittarius",
    chineseSign: "Monkey",
    archetypeName: "The Restless Improviser",
    core: {
      centralParadox:
        "They chase possibility with a quick, playful mind but need a direction sturdy enough to keep novelty from becoming escape.",
      coreDrive:
        "To turn discovery into a larger, more interesting field of action.",
      coreNeed:
        "Freedom to experiment without being trapped by one version of the plan.",
      coreFear:
        "A clever life becoming a repetitive one before they have noticed.",
      matureExpression:
        "Curiosity disciplined into generous, useful invention.",
      recurringThemes: [
        "playful expansion",
        "strategic improvisation",
        "freedom with purpose",
        "truth through experiment",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Sagittarius contributes direct exploration, candor, appetite for distance, and belief that a wider horizon can clarify a life.",
      chineseContribution:
        "Monkey contributes wit, opportunism, social agility, and the instinct to test a rule by finding the side door.",
      emergentSynthesis:
        "Together they make a person who turns movement into intelligence, improvises in public, and needs chosen commitments to remain open enough for discovery.",
    },
    decision: {
      ...taurusHorseCanonical.decision,
      decisionPace: "fast",
      defaultProcess:
        "Try the live version, watch what responds, then revise the route without defending the first plan.",
      actionTrigger:
        "A promising opening offers both movement and a useful experiment.",
      delayPattern: "Boredom disguises itself as a need for more options.",
      certaintyStyle: "Confidence comes from having tested the idea in motion.",
    },
    social: {
      ...taurusHorseCanonical.social,
      defaultRole: "explorer",
      communicationStyle:
        "Quick, candid, humorous, and willing to say the thing that loosens a stuck room.",
      conflictStyle:
        "Uses wit to expose the assumption, then leaves if the exchange becomes a status contest.",
      influenceStyle: "Makes people curious enough to try a different route.",
      boundaryStyle:
        "Protects freedom by changing the terms rather than asking permission.",
      commonMisreads: [
        "playfulness mistaken for shallowness",
        "directness mistaken for carelessness",
        "change mistaken for unreliability",
      ],
      responseToGroupUncertainty: "Offers a test instead of another theory.",
      responseToAuthority: "Respects competence, questions unnecessary rules.",
    },
    evidence: {
      ...taurusHorseCanonical.evidence,
      observableBehaviors: [
        "turns a stalled plan into a quick experiment",
        "makes a joke that reveals the hidden assumption",
        "changes routes without losing the destination",
        "asks what happens if the rule is tested",
        "keeps several options alive until one responds",
        "returns with a better version after trying the first",
        "offers a side door when a rule blocks progress",
        "changes a proposal after seeing what people actually use",
      ],
      everydaySituations: [
        "a trip changed by a last-minute opening",
        "a group chat revived by one playful proposal",
        "a work rule bypassed through a harmless experiment",
        "a new class, tool, or route tested for a week",
        "a promise renegotiated to preserve freedom",
      ],
      signatureContrasts: [
        "playful, not careless",
        "restless, not directionless",
        "candid, not cruel",
      ],
      signatureObservations: [
        "The useful version is usually the one you can try.",
        "A rule that cannot survive a question may not deserve obedience.",
        "Freedom becomes useful when it gives discovery somewhere to go.",
      ],
      prohibitedGenericClaims: [
        "reliable",
        "independent",
        "loyal",
        "observant",
        "intuitive",
      ],
    },
  }),
  variant(libraSnakeCanonical, {
    signPair: "Scorpio × Dragon",
    westernSign: "Scorpio",
    chineseSign: "Dragon",
    archetypeName: "The Concentrated Force",
    core: {
      centralParadox:
        "They want total honesty and decisive impact, yet their intensity can make protection look like control before trust has had time to form.",
      coreDrive: "To reach the truth beneath performance and make it matter.",
      coreNeed: "Depth, loyalty, and enough power to act without dilution.",
      coreFear: "Being exposed to someone who treats their trust as leverage.",
      matureExpression:
        "Focused intensity that protects truth without needing to dominate the room.",
      recurringThemes: [
        "depth before display",
        "earned power",
        "protective intensity",
        "truth under pressure",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Scorpio contributes depth, suspicion of surfaces, emotional stamina, and a drive toward unedited truth.",
      chineseContribution:
        "Dragon contributes visible force, ambition, pride, and willingness to claim a large role.",
      emergentSynthesis:
        "Together they create someone who reads beneath the room while carrying enough presence to change its direction, often testing loyalty before revealing how much is at stake.",
    },
    perception: {
      ...libraSnakeCanonical.perception,
      noticesFirst:
        "Where power, loyalty, and fear are shaping what people say.",
      noticesInPeople: [
        "who becomes bolder when protected",
        "who changes position near authority",
        "what someone refuses to name",
        "whether confidence survives scrutiny",
      ],
      noticesInSituations: [
        "hidden leverage",
        "unequal risk",
        "the point where a disagreement becomes a test",
        "what is being protected by silence",
      ],
      interpretationBias:
        "They assume the visible account is incomplete until motive and consequence line up.",
      attentionBlindSpot:
        "They can treat ordinary ambiguity as evidence of hidden strategy.",
    },
    social: {
      ...libraSnakeCanonical.social,
      defaultRole: "challenger",
      communicationStyle:
        "Sparse, exact, and charged with more meaning than the number of words suggests.",
      conflictStyle:
        "Confronts the real issue once convinced it is present; dislikes ceremonial disagreement.",
      influenceStyle:
        "Raises the stakes by naming what others prefer to leave implicit.",
      boundaryStyle:
        "Strong, selective, and difficult to renegotiate once trust has been crossed.",
      commonMisreads: [
        "intensity mistaken for hostility",
        "privacy mistaken for manipulation",
        "confidence mistaken for control",
      ],
      responseToGroupUncertainty:
        "Finds the power question beneath the procedural one.",
      responseToAuthority:
        "Challenges authority that cannot explain its use of power.",
    },
    pressure: {
      ...libraSnakeCanonical.pressure,
      firstShift:
        "Protection begins turning every unknown into a possible threat.",
      overextendedStrength: "Discernment becomes surveillance.",
      visibleBehaviors: [
        "testing a promise instead of receiving it",
        "withholding a useful fact to see who notices",
        "reading a neutral pause as a strategic move",
        "escalating a small breach into a loyalty verdict",
      ],
      internalStory: "If I reveal less, I keep control of what can hurt me.",
      emotionalCost:
        "The vigilance that protects trust also makes trust harder to feel.",
      relationalCost:
        "People experience tests and distance where the identity experiences caution.",
      decisionDistortion:
        "Potential betrayal outweighs ordinary evidence of good faith.",
      shadowRole: "The guarded power-holder.",
      escalationPattern:
        "Question motive → test loyalty → find ambiguity → tighten control → confirm distance.",
    },
  }),
  variant(taurusHorseCanonical, {
    signPair: "Aries × Rat",
    westernSign: "Aries",
    chineseSign: "Rat",
    archetypeName: "The First Advantage",
    core: {
      centralParadox:
        "They move before the room is ready, but their best action comes from seeing the leverage others missed rather than merely moving fastest.",
      coreDrive: "To turn an opening into a concrete advantage.",
      coreNeed:
        "Momentum, autonomy, and evidence that initiative changes the outcome.",
      coreFear:
        "Being slowed into irrelevance by people who mistake delay for care.",
      matureExpression:
        "Fast initiative guided by selective attention and reciprocal effort.",
      recurringThemes: [
        "rapid initiative",
        "social leverage",
        "reciprocal momentum",
        "useful risk",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Aries contributes immediacy, courage, directness, and a preference for beginning rather than discussing beginning.",
      chineseContribution:
        "Rat contributes alertness, resourcefulness, social memory, and a talent for finding the practical opening.",
      emergentSynthesis:
        "Together they create a quick, enterprising person who enters first but is rarely unobservant, using speed to expose leverage and reciprocity.",
    },
    decision: {
      ...taurusHorseCanonical.decision,
      decisionPace: "immediate",
      defaultProcess:
        "Make the first workable move, collect the response, and adjust before the opportunity cools.",
      evidenceThreshold: "Enough evidence to make a reversible first move.",
      actionTrigger:
        "An opening has a clear next action and a possible upside.",
      delayPattern:
        "Treats other people's hesitation as information about their willingness to participate.",
      reversalPattern:
        "Drops a route quickly when it stops producing reciprocal movement.",
      regretPattern:
        "Regrets waiting for permission more than a fast experiment that taught something.",
      certaintyStyle: "Certainty is earned by contact with reality.",
    },
    social: {
      ...taurusHorseCanonical.social,
      defaultRole: "initiator",
      communicationStyle:
        "Direct, lively, and oriented toward the next concrete step.",
      conflictStyle:
        "Addresses the obstacle quickly, sometimes before others have named their concern.",
      influenceStyle: "Creates momentum people can join.",
      boundaryStyle: "Clear about time, credit, and who is carrying the work.",
      commonMisreads: [
        "speed mistaken for carelessness",
        "confidence mistaken for dominance",
        "social memory mistaken for scorekeeping",
      ],
      responseToGroupUncertainty: "Offers a test and asks who is in.",
      responseToAuthority:
        "Respects authority that clears obstacles; works around authority that only delays.",
    },
    work: {
      ...taurusHorseCanonical.work,
      valueCreated:
        "They make opportunities actionable by finding the person, resource, or first move that turns a vague opening into progress.",
      problemSolvingStyle:
        "Act quickly, inspect the result, and redirect toward the leverage point.",
      teamRole:
        "The first mover who also remembers where the useful support is.",
      leadershipStyle:
        "Visible initiative, fast feedback, and clear ownership.",
      idealConditions: [
        "autonomy",
        "quick feedback",
        "visible consequence",
        "reciprocal teammates",
      ],
      drainingConditions: [
        "permission rituals",
        "unclear ownership",
        "performative urgency",
        "effort without response",
      ],
      relationshipToStructure:
        "Uses structure as a launchpad, not a waiting room.",
      relationshipToAutonomy: "Needs room to make the first move.",
      careerBlindSpot:
        "Confuses starting more projects with increasing leverage.",
      completionSignal:
        "The work moves because another person can carry the next step.",
      releasePattern: "Hands off once the momentum is real.",
    },
  }),
  variant(libraSnakeCanonical, {
    signPair: "Pisces × Dog",
    westernSign: "Pisces",
    chineseSign: "Dog",
    archetypeName: "The Tender Guardian",
    core: {
      centralParadox:
        "They absorb the emotional weather around them and feel responsible for protecting what is vulnerable, yet need boundaries that keep care from becoming self-erasure.",
      coreDrive: "To make a human situation safer and more humane.",
      coreNeed:
        "Trustworthy belonging without having to harden their sensitivity.",
      coreFear: "Failing someone who trusted their care.",
      matureExpression:
        "Compassion with discernment, loyalty with a limit, and imagination made practical.",
      recurringThemes: [
        "porous care",
        "protective loyalty",
        "emotional truth",
        "gentle boundaries",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Pisces contributes receptivity, imagination, emotional association, and sensitivity to atmosphere.",
      chineseContribution:
        "Dog contributes loyalty, fairness, vigilance, and a protective response to broken trust.",
      emergentSynthesis:
        "Together they create a tender guardian who feels what is unspoken, remembers who was let down, and must learn that protecting a relationship sometimes requires a clear refusal.",
    },
    perception: {
      ...libraSnakeCanonical.perception,
      noticesFirst:
        "Who is carrying fear, disappointment, or an unspoken need.",
      noticesInPeople: [
        "who apologizes too quickly",
        "who is left out of the care being offered",
        "when warmth masks hurt",
        "whether loyalty is mutual",
      ],
      noticesInSituations: [
        "emotional undercurrents",
        "the person nobody is checking on",
        "where a promise creates safety",
        "when a boundary would prevent resentment",
      ],
      interpretationBias:
        "They assume feelings contain information even when the facts are incomplete.",
      attentionBlindSpot:
        "They can confuse understanding someone's pain with responsibility for resolving it.",
    },
    relationships: {
      ...libraSnakeCanonical.relationships,
      attractionPattern:
        "They are drawn to kindness that feels protective without becoming possessive.",
      trustBuilders: [
        "keeping confidences",
        "checking who is left out",
        "repairing after harm",
        "making care practical",
      ],
      trustBreakers: [
        "cruelty disguised as honesty",
        "using vulnerability as leverage",
        "abandoning a promise when it becomes inconvenient",
        "asking for endless care without reciprocity",
      ],
      closenessStyle:
        "Emotionally attentive, imaginative, and protective of ordinary tenderness.",
      loyaltyStyle:
        "Shows up quietly, remembers what hurts, and keeps defending the relationship after the dramatic moment passes.",
      forgivenessPattern:
        "Offers context and mercy, but a repeated breach eventually changes the shape of loyalty.",
      relationshipBlindSpot:
        "Staying available because someone is hurting, even after the relationship stops being safe.",
      healthyRelationshipCondition:
        "Care is mutual, direct, and bounded enough for both people to remain whole.",
      withdrawalTrigger:
        "Cruelty, contempt, or repeated use of their care without repair.",
    },
  }),
  variant(taurusHorseCanonical, {
    signPair: "Leo × Horse",
    westernSign: "Leo",
    chineseSign: "Horse",
    archetypeName: "The Open Radiance",
    core: {
      centralParadox:
        "They want to be fully seen and fully free, so admiration becomes nourishing only when it does not become a leash.",
      coreDrive:
        "To animate a room, project, or relationship with generous life.",
      coreNeed: "Recognition that leaves autonomy intact.",
      coreFear: "Being reduced to a role people applaud but do not let change.",
      matureExpression:
        "Warm visibility that invites others in without performing a fixed self.",
      recurringThemes: [
        "generous visibility",
        "chosen freedom",
        "creative momentum",
        "pride with play",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Leo contributes warmth, creative pride, expressive leadership, and a wish to make life more vivid.",
      chineseContribution:
        "Horse contributes mobility, independence, appetite for experience, and resistance to being possessed.",
      emergentSynthesis:
        "Together they create a visible, generous person who wants to lead through vitality but will leave applause that begins demanding a permanent performance.",
    },
    social: {
      ...taurusHorseCanonical.social,
      defaultRole: "amplifier",
      communicationStyle:
        "Expressive, warm, and comfortable making the moment feel larger.",
      conflictStyle:
        "Names disrespect quickly, then needs room to cool without being cornered.",
      influenceStyle: "Makes participation feel exciting and personal.",
      boundaryStyle: "Open-handed until admiration becomes entitlement.",
      commonMisreads: [
        "visibility mistaken for vanity",
        "independence mistaken for inconsistency",
        "pride mistaken for fragility",
      ],
      responseToGroupUncertainty:
        "Raises energy and gives the group a visible direction.",
      responseToAuthority:
        "Accepts guidance that respects talent; resists control disguised as mentorship.",
    },
    perception: {
      ...taurusHorseCanonical.perception,
      noticesFirst:
        "Where energy rises, who is being invited in, and who is being asked to perform.",
      noticesInPeople: [
        "who lights up when encouraged",
        "who takes attention without giving it back",
        "whether praise names real work",
        "who expects the same version forever",
      ],
      noticesInSituations: [
        "an audience's energy",
        "a role becoming a cage",
        "where confidence creates permission",
        "when fun is being managed out of a room",
      ],
      interpretationBias:
        "They read participation and enthusiasm as signs that a direction has life.",
      attentionBlindSpot:
        "They can underestimate quiet people or quiet forms of contribution.",
    },
    work: {
      ...taurusHorseCanonical.work,
      valueCreated:
        "They make work vivid, legible, and easier for other people to join.",
      problemSolvingStyle:
        "Frame the purpose, energize the room, then improvise around friction.",
      teamRole: "The visible catalyst who turns a task into a shared project.",
      leadershipStyle:
        "Generous recognition, clear direction, and enough autonomy for talent to show up.",
      idealConditions: [
        "creative ownership",
        "visible contribution",
        "room to move",
        "energized collaboration",
      ],
      drainingConditions: [
        "micromanaged performance",
        "flat work with no audience",
        "credit without autonomy",
        "roles that cannot evolve",
      ],
      relationshipToStructure: "Likes a clear stage but not a fixed script.",
      relationshipToAutonomy:
        "Needs freedom to change the expression of the work.",
      careerBlindSpot:
        "Staying in a flattering role after it stops offering growth.",
      completionSignal:
        "The result has energy beyond the person who started it.",
      releasePattern:
        "Leaves when the applause requires repetition instead of contribution.",
    },
  }),
  variant(libraSnakeCanonical, {
    signPair: "Aquarius × Snake",
    westernSign: "Aquarius",
    chineseSign: "Snake",
    archetypeName: "The Unusual Observer",
    core: {
      centralParadox:
        "They see systems and exceptions at once, but distance can make a humane insight feel like a theory about people rather than an exchange with them.",
      coreDrive:
        "To understand the hidden structure and improve the future version.",
      coreNeed:
        "Intellectual freedom, privacy, and relationships that tolerate unconventional truth.",
      coreFear:
        "Being absorbed into a group that rewards agreement over accuracy.",
      matureExpression:
        "Original systems thinking made relational enough to be useful.",
      recurringThemes: [
        "independent patterning",
        "unusual futures",
        "private precision",
        "human systems",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Aquarius contributes independence, systems thinking, social critique, and comfort with the unconventional.",
      chineseContribution:
        "Snake contributes strategic observation, discretion, and sensitivity to what lies beneath a public explanation.",
      emergentSynthesis:
        "Together they produce someone who notices the hidden pattern in a group while remaining personally difficult to categorize, often needing to translate unusual insight into human-scale action.",
    },
    social: {
      ...libraSnakeCanonical.social,
      defaultRole: "strategist",
      communicationStyle:
        "Original, measured, and occasionally startlingly precise.",
      conflictStyle:
        "Steps back to identify the system underneath the argument, then returns with a structural correction.",
      influenceStyle: "Changes the frame rather than competing inside it.",
      boundaryStyle: "Protects privacy and freedom from group expectations.",
      commonMisreads: [
        "detachment mistaken for indifference",
        "unusual ideas mistaken for contrarianism",
        "privacy mistaken for secrecy",
      ],
      responseToGroupUncertainty: "Maps the system before choosing a side.",
      responseToAuthority:
        "Questions inherited rules and looks for the incentive beneath them.",
    },
    perception: {
      ...libraSnakeCanonical.perception,
      noticesFirst:
        "The pattern connecting individual behavior to the larger system.",
      noticesInPeople: [
        "who benefits from the current rule",
        "who is allowed to be unusual",
        "where someone repeats a borrowed opinion",
        "whether privacy is being respected",
      ],
      noticesInSituations: [
        "feedback loops",
        "unspoken incentives",
        "exceptions that reveal the rule",
        "where a future problem is being normalized",
      ],
      interpretationBias:
        "They assume the surface event is an expression of a larger pattern.",
      attentionBlindSpot:
        "They can solve the system while missing the one person needing a direct answer.",
    },
    evidence: {
      ...libraSnakeCanonical.evidence,
      observableBehaviors: [
        "redesigns a process after spotting an incentive",
        "asks who benefits from a familiar rule",
        "keeps a private note of a recurring pattern",
        "offers an unconventional solution without selling it",
        "steps out of a group opinion to test the premise",
        "returns to explain an abstract insight in practical terms",
        "writes the human consequence beside the system change",
        "keeps a private hypothesis until a person can use it",
      ],
      everydaySituations: [
        "a group rule that rewards the wrong behavior",
        "a private insight brought into a team discussion",
        "a future problem visible in a small current exception",
        "a friendship asking for ordinary reassurance",
        "a routine redesigned around the real goal",
      ],
      signatureContrasts: [
        "distant, not indifferent",
        "unusual, not arbitrary",
        "private, not secretive",
      ],
      signatureObservations: [
        "The exception may be showing you the rule.",
        "A better system still has to work for a person.",
        "Privacy is part of trust, not evidence against it.",
      ],
      prohibitedGenericClaims: [
        "observant",
        "loyal",
        "independent",
        "intuitive",
        "reliable",
      ],
    },
  }),
  variant(taurusHorseCanonical, {
    signPair: "Cancer × Pig",
    westernSign: "Cancer",
    chineseSign: "Pig",
    archetypeName: "The Giving Hearth",
    core: {
      centralParadox:
        "They build safety through generous care and familiar belonging, but their warmth needs limits before giving becomes quiet depletion.",
      coreDrive:
        "To make a place or relationship feel safe enough for people to soften.",
      coreNeed:
        "Mutual care, continuity, and permission to receive as well as provide.",
      coreFear: "Discovering that the home they protected was only one-way.",
      matureExpression:
        "Generosity with discernment, warmth with a clear door.",
      recurringThemes: [
        "generous belonging",
        "protective continuity",
        "receiving care",
        "soft boundaries",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Cancer contributes memory, attachment to home, emotional protection, and instinctive caretaking.",
      chineseContribution:
        "Pig contributes generosity, pleasure, openness, and willingness to trust the good in people.",
      emergentSynthesis:
        "Together they create a warm, hospitable identity that makes belonging tangible but must learn to distinguish generous welcome from making itself responsible for everyone's comfort.",
    },
    relationships: {
      ...taurusHorseCanonical.relationships,
      attractionPattern:
        "They are drawn to people who make ordinary life feel warmer and who notice care without consuming it.",
      trustBuilders: [
        "remembering family details",
        "sharing practical comfort",
        "showing gratitude",
        "making room for their needs too",
      ],
      trustBreakers: [
        "taking generosity for granted",
        "mocking sentiment",
        "using a private confidence carelessly",
        "expecting care without return",
      ],
      closenessStyle:
        "Nurturing, sensory, familiar, and happiest when shared life feels lived rather than performed.",
      loyaltyStyle:
        "Feeds, remembers, hosts, protects, and keeps a place open long after others have stopped noticing the work.",
      forgivenessPattern:
        "Forgives generously when remorse is warm and concrete, but stores the memory of repeated entitlement.",
      relationshipBlindSpot:
        "Calling over-giving love because receiving would require asking for something.",
      healthyRelationshipCondition:
        "Care circulates in both directions and home remains a refuge rather than a duty station.",
      withdrawalTrigger:
        "Contempt for tenderness or repeated use of their hospitality without reciprocity.",
    },
    social: {
      ...taurusHorseCanonical.social,
      defaultRole: "caretaker",
      communicationStyle:
        "Warm, memory-rich, and attentive to what makes people comfortable.",
      conflictStyle:
        "Protects the emotional home first, then speaks more directly once hurt has accumulated.",
      influenceStyle: "Creates belonging through small practical acts.",
      boundaryStyle: "Soft at the door, firmer after a pattern of taking.",
      commonMisreads: [
        "generosity mistaken for endless capacity",
        "sentiment mistaken for fragility",
        "quiet withdrawal mistaken for moodiness",
      ],
      responseToGroupUncertainty:
        "Checks who needs reassurance and what practical care would help.",
      responseToAuthority:
        "Cooperates with authority that protects people; resists authority that treats care as weakness.",
    },
    work: {
      ...taurusHorseCanonical.work,
      valueCreated:
        "They make teams and spaces more humane by remembering needs, building trust, and sustaining the small care that keeps people functional.",
      problemSolvingStyle:
        "Notice who is affected, make the environment workable, then protect the solution through consistency.",
      teamRole:
        "The culture-holder who remembers the human details behind the task.",
      leadershipStyle:
        "Protective, appreciative, and strongest when care has clear limits.",
      idealConditions: [
        "trusted relationships",
        "visible human impact",
        "stable collaboration",
        "room for generosity",
      ],
      drainingConditions: [
        "cold competition",
        "care treated as invisible",
        "constant emotional extraction",
        "spaces where nobody maintains belonging",
      ],
      relationshipToStructure: "Uses structure to make care dependable.",
      relationshipToAutonomy:
        "Needs control over the environment enough to make it feel humane.",
      careerBlindSpot:
        "Becoming the unofficial emotional infrastructure without naming the role.",
      completionSignal:
        "People can function well without the identity carrying every comfort.",
      releasePattern:
        "Hands care back when the system expects endless personal sacrifice.",
    },
  }),
  variant(libraSnakeCanonical, {
    signPair: "Virgo × Dragon",
    westernSign: "Virgo",
    chineseSign: "Dragon",
    archetypeName: "The Exacting Builder",
    core: {
      centralParadox:
        "They see the flaw that will matter later and want the result to be excellent now, yet improvement can become control when no version feels ready to leave their hands.",
      coreDrive: "To make an ambitious idea reliable in the details.",
      coreNeed:
        "Competence, meaningful standards, and authority to improve what is not working.",
      coreFear:
        "A visible failure that proves the whole structure was unsound.",
      matureExpression:
        "Precision in service of a larger purpose rather than precision as protection.",
      recurringThemes: [
        "ambitious precision",
        "useful standards",
        "visible competence",
        "release through trust",
      ],
    },
    sourceReasoning: {
      westernContribution:
        "Virgo contributes diagnosis of practical flaws, craft, service, and attention to sequence.",
      chineseContribution:
        "Dragon contributes scale, confidence, visibility, and willingness to lead a consequential effort.",
      emergentSynthesis:
        "Together they make a person who can turn a grand direction into a working system, but who must learn that a standard serves the work only when the work can finally move.",
    },
    decision: {
      ...libraSnakeCanonical.decision,
      decisionPace: "measured",
      defaultProcess:
        "Define the desired result, inspect the failure points, then act once the critical—not every possible—detail is covered.",
      evidenceThreshold:
        "Enough practical evidence to prevent the known failure, not proof against every future variation.",
      actionTrigger:
        "The next improvement changes reliability rather than merely appearance.",
      delayPattern:
        "Adds a refinement whenever release would make the work visible.",
      reversalPattern:
        "Changes course when a better method improves the core outcome.",
      regretPattern:
        "Regrets shipping avoidable flaws, but also regrets holding a useful result too long.",
      certaintyStyle:
        "Confidence comes from a sound process and a visible standard.",
    },
    work: {
      ...libraSnakeCanonical.work,
      valueCreated:
        "They convert ambitious ideas into dependable systems by finding the detail that would otherwise become tomorrow's failure.",
      problemSolvingStyle:
        "Break the goal into failure points, improve the highest-leverage part, then test the result.",
      teamRole:
        "The exacting builder who protects both standards and delivery.",
      leadershipStyle:
        "Clear standards, visible ownership, and practical feedback that makes excellence attainable.",
      idealConditions: [
        "meaningful standards",
        "authority to improve",
        "ambitious but clear goals",
        "time for critical detail",
      ],
      drainingConditions: [
        "sloppy urgency",
        "status without competence",
        "endless polish with no release",
        "work where quality is cosmetic",
      ],
      relationshipToStructure: "Builds structure to make quality repeatable.",
      relationshipToAutonomy:
        "Needs authority over method and the standard of completion.",
      careerBlindSpot: "Using improvement to postpone exposure.",
      completionSignal:
        "The result works, the critical risks are covered, and another person can carry it.",
      releasePattern:
        "Ships when additional polish no longer changes reliability.",
    },
    perception: {
      ...libraSnakeCanonical.perception,
      noticesFirst:
        "The small failure point that could undermine the larger ambition.",
      noticesInPeople: [
        "who understands the standard",
        "who hides a gap behind confidence",
        "who improves without being asked",
        "whether an apology changes a process",
      ],
      noticesInSituations: [
        "sequence errors",
        "avoidable rework",
        "where polish masks a weak foundation",
        "which detail changes the outcome",
      ],
      interpretationBias:
        "They assume the visible result is only as good as the part nobody checked.",
      attentionBlindSpot:
        "They can prioritize the correct detail after the useful moment to act has passed.",
    },
    evidence: {
      ...libraSnakeCanonical.evidence,
      observableBehaviors: [
        "spots the missing step in a plan",
        "rewrites an instruction until another person can use it",
        "asks what will fail on the next repetition",
        "improves a visible result without hiding the standard",
        "keeps a checklist for a consequential task",
        "polishes a release after the critical risk is already covered",
        "asks another person to test the finished process",
        "marks the point where another improvement changes appearance only",
      ],
      everydaySituations: [
        "a team preparing a public deliverable",
        "a household process that keeps creating rework",
        "a purchase judged by maintenance rather than appearance",
        "a compliment followed by a request for the method",
        "a project held back by one final improvement",
      ],
      signatureContrasts: [
        "exact, not small-minded",
        "ambitious, not careless",
        "critical, not merely negative",
      ],
      signatureObservations: [
        "The detail nobody checks becomes tomorrow's problem.",
        "A standard is useful when another person can meet it.",
        "The work is ready when polish stops changing reliability.",
      ],
      prohibitedGenericClaims: [
        "observant",
        "loyal",
        "independent",
        "intuitive",
        "reliable",
      ],
    },
  }),
];

export const expansionIdentityByPair = Object.fromEntries(
  expansionIdentities.map((identity) => [identity.signPair, identity]),
);
