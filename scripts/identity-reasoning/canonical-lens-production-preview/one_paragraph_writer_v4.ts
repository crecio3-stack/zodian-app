import { type OneParagraphLens, type OneParagraphValidation, validateOneParagraphLens } from "./one_paragraph_writer.ts";

export type { OneParagraphLens, OneParagraphValidation };
export { validateOneParagraphLens };

export type OneParagraphWritingInputV4 = {
  caseId: string;
  clarityStatus: "CLEAR" | "PARTIAL";
  plainInsight: string;
  plainAction: string | null;
  goldExamples: OneParagraphLens[];
};

export function buildOneParagraphPromptV4(input: OneParagraphWritingInputV4): string {
  const examples = input.goldExamples.map((example, index) => `${index + 1}. Title: ${example.title}\nRead: ${example.read}`).join("\n\n");
  const action = input.plainAction ? `\n\nOptional supported action:\n${input.plainAction}` : "\n\nThere is no supported action. Do not invent one.";
  return `You write a short Today’s Lens in normal conversational English.\n\nReturn JSON only with exactly two string fields: title and read.\n\nPlain insight — this is the only source of meaning and wording for the pattern:\n${input.plainInsight}${action}\n\nThe clarity status is ${input.clarityStatus}. ${input.clarityStatus === "PARTIAL" ? "Stay with the narrow observed pattern. Do not explain why it happens. Use the action only if supplied." : "Do not add any claim beyond the insight and optional action."}\n\nTitle: use common words. Describe the pattern or useful direction. It must never sound like an instruction to continue the unwanted behavior.\nRead: write one flowing paragraph. Two sentences are acceptable. Do not add sentences just to make it longer.\n\nDo not restate the insight in different words. If the insight and optional action already make a complete read, stop. Use explicit subjects and actions, common everyday words, and obvious cause and effect.\n\nDo not use metaphors, literary language, abstract causal language, workplace jargon, therapy-speak, personality-model terminology, semicolons, hidden psychological explanations, or unsupported advice.\n\nBefore returning, silently read every sentence aloud as if speaking to a friend. Replace anything that sounds like internal model language, workplace jargon, literary prose, or translated reasoning with ordinary spoken English.\n\nThese approved examples show the target simplicity. Do not copy their structure or wording:\n\n${examples}`;
}
