export type HumanLanguageStatus = "NATURAL" | "REVIEW";

export type HumanLanguageFlag = {
  phrase: string;
  source: "plain_insight" | "plain_action";
  category:
    | "internal_reasoning_terminology"
    | "behavioral_analysis_language"
    | "process_or_workflow_language"
    | "abstract_framework_language";
};

const engineeredPhrases: Array<{
  phrase: string;
  expression: RegExp;
  category: HumanLanguageFlag["category"];
}> = [
  {
    phrase: "observable impact",
    expression: /\bobservable impact\b/i,
    category: "internal_reasoning_terminology",
  },
  {
    phrase: "separate the assumption",
    expression: /\bseparate the assumption\b/i,
    category: "behavioral_analysis_language",
  },
  {
    phrase: "repeated step",
    expression: /\brepeated step\b/i,
    category: "process_or_workflow_language",
  },
  {
    phrase: "reversible test",
    expression: /\breversible test\b/i,
    category: "internal_reasoning_terminology",
  },
  {
    phrase: "future option",
    expression: /\bfuture option\b/i,
    category: "abstract_framework_language",
  },
  {
    phrase: "finished work stand",
    expression: /\bfinished work stand\b/i,
    category: "abstract_framework_language",
  },
  {
    phrase: "next handoff",
    expression: /\bnext handoff\b/i,
    category: "process_or_workflow_language",
  },
  {
    phrase: "follow-through detail",
    expression: /\bfollow-through detail\b/i,
    category: "process_or_workflow_language",
  },
  {
    phrase: "group role",
    expression: /\bgroup role\b/i,
    category: "behavioral_analysis_language",
  },
];

export function assessHumanLanguage(
  plainInsight: string,
  plainAction: string | null,
): { status: HumanLanguageStatus; flags: HumanLanguageFlag[] } {
  const fields: ReadonlyArray<readonly [HumanLanguageFlag["source"], string]> =
    [
      ["plain_insight", plainInsight],
      ...(plainAction === null ? [] : [["plain_action", plainAction] as const]),
    ];
  const flags = fields.flatMap(([source, value]) =>
    engineeredPhrases
      .filter((candidate) => candidate.expression.test(value))
      .map((candidate) => ({
        phrase: candidate.phrase,
        source,
        category: candidate.category,
      }))
  );
  return { status: flags.length === 0 ? "NATURAL" : "REVIEW", flags };
}
