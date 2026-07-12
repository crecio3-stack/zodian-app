# 043 · Capricorn × Horse

Status: complete
Source: Resources/archetypes.json#capricorn-horse
Retries: 1
QA flags: 1

## Canonical fixture

```json

```

## work

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You combine energy with discipline. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you doesn't slow down as needed",
    "uses you maintain strong forward momentum to make one standard visible before you burn out from constant motion"
  ],
  "identitySpecificRole": "the builder who turns works through effort and persistence into clear ownership",
  "recognition": "The work improves when the driven result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes driven observable before ownership is finalized.",
  "blindSpot": "You may burn out from constant motion after the work is already good enough.",
  "naturalMove": "Clarify one owner and use driven as the visible standard.",
  "sourcePaths": [
    "work.valueCreated",
    "work.problemSolvingStyle",
    "work.careerBlindSpot",
    "social.defaultRole"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "work-speaking-up",
      "date": "2026-07-11",
      "symbolicContext": "A quiet signal asks to be named before the group moves on.",
      "humanTension": "speaking up vs waiting",
      "arena": "work",
      "emotionalTone": "clear-eyed",
      "seed": "lens-01"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|work",
      "manifestationArena": "work",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by speaking up vs waiting.",
      "perception": "You combine energy with discipline. becomes visible around ownership and execution.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "names who owns the next handoff before you doesn't slow down as needed",
        "uses you maintain strong forward momentum to make one standard visible before you burn out from constant motion"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the builder who turns works through effort and persistence into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the driven result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes driven observable before ownership is finalized.",
    "blindSpot": "You may burn out from constant motion after the work is already good enough.",
    "naturalMove": "Clarify one owner and use driven as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In a work meeting, the next handoff is moving before anyone has clearly claimed it.",
  "pull_quote": "Your momentum helps the team move, but the work needs a visible owner before it leaves the room.",
  "deeper_read": "You are already turning effort into a standard people can see, which makes the unfinished ownership stand out. Rather than adding another task to keep things moving, pause long enough to attach one name to the deadline or collaboration.",
  "watch_for": "Notice whether the group leaves the meeting with a next step but no named owner.",
  "move": "Before the meeting ends, assign one person to the next handoff and state the visible standard."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the work may be ready before anyone has said who carries it next.\",\"pull_quote\":\"Your momentum helps most when it leaves behind a visible owner, not another open loop.\",\"deeper_read\":\"You are likely to keep the discussion moving by turning a loose task into a clear next step. Before the group moves on, name who owns the handoff and what standard they are carrying; that small interruption makes the progress usable without adding more effort.\",\"watch_for\":\"A deadline is mentioned, then the conversation shifts away without anyone confirming the next person.\",\"move\":\"Say, “Before we close this, who owns the next handoff and what does finished look like?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the work may be ready before anyone has said who carries it next.",
      "pull_quote": "Your momentum helps most when it leaves behind a visible owner, not another open loop.",
      "deeper_read": "You are likely to keep the discussion moving by turning a loose task into a clear next step. Before the group moves on, name who owns the handoff and what standard they are carrying; that small interruption makes the progress usable without adding more effort.",
      "watch_for": "A deadline is mentioned, then the conversation shifts away without anyone confirming the next person.",
      "move": "Say, “Before we close this, who owns the next handoff and what does finished look like?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1061,
      "input_tokens_details": {
        "cache_write_tokens": 1058,
        "cached_tokens": 0
      },
      "output_tokens": 154,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1215
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a work meeting, the next handoff is moving before anyone has clearly claimed it.\",\"pull_quote\":\"Your momentum helps the team move, but the work needs a visible owner before it leaves the room.\",\"deeper_read\":\"You are already turning effort into a standard people can see, which makes the unfinished ownership stand out. Rather than adding another task to keep things moving, pause long enough to attach one name to the deadline or collaboration.\",\"watch_for\":\"Notice whether the group leaves the meeting with a next step but no named owner.\",\"move\":\"Before the meeting ends, assign one person to the next handoff and state the visible standard.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a work meeting, the next handoff is moving before anyone has clearly claimed it.",
      "pull_quote": "Your momentum helps the team move, but the work needs a visible owner before it leaves the room.",
      "deeper_read": "You are already turning effort into a standard people can see, which makes the unfinished ownership stand out. Rather than adding another task to keep things moving, pause long enough to attach one name to the deadline or collaboration.",
      "watch_for": "Notice whether the group leaves the meeting with a next step but no named owner.",
      "move": "Before the meeting ends, assign one person to the next handoff and state the visible standard."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1193,
      "input_tokens_details": {
        "cache_write_tokens": 1190,
        "cached_tokens": 0
      },
      "output_tokens": 561,
      "output_tokens_details": {
        "reasoning_tokens": 413
      },
      "total_tokens": 1754
    }
  }
]
```

## love

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings driven to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you burn out from constant motion"
  ],
  "identitySpecificRole": "the partner who turns driven into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking driven to disappear.",
  "ordinaryLifeExpression": "Evidence of driven becomes the test beneath a reassuring message.",
  "blindSpot": "You may burn out from constant motion after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning driven.",
  "sourcePaths": [
    "relationships.attractionPattern",
    "relationships.closenessStyle",
    "relationships.healthyRelationshipCondition",
    "relationships.relationshipBlindSpot"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "love-trust",
      "date": "2026-07-12",
      "symbolicContext": "A warm exchange leaves one practical detail unresolved.",
      "humanTension": "trust vs caution",
      "arena": "love",
      "emotionalTone": "tender",
      "seed": "lens-02"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|love",
      "manifestationArena": "love",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by trust vs caution.",
      "perception": "The identity brings driven to closeness, where promises and pacing are tested.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you burn out from constant motion"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns driven into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking driven to disappear.",
    "ordinaryLifeExpression": "Evidence of driven becomes the test beneath a reassuring message.",
    "blindSpot": "You may burn out from constant motion after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning driven.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Concrete",
  "intro": "A tender exchange lands well, yet one unanswered practical detail keeps the reassurance from fully settling.",
  "pull_quote": "You do not need to slow your feelings down; you need one promise that can be seen.",
  "deeper_read": "You tend to keep moving once closeness feels available, but today the useful question is what a warm message will look like in an ordinary week. Let the plan be revised by a specific time, task, or check-in, rather than adding more reassurance to an unresolved detail.",
  "watch_for": "A sweet message ends with vague language about getting together, without naming when or how.",
  "move": "Reply with one workable follow-through detail, such as a day to call or a plan to confirm."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Concrete\",\"intro\":\"A tender exchange lands well, yet one unanswered practical detail keeps the reassurance from fully settling.\",\"pull_quote\":\"You do not need to slow your feelings down; you need one promise that can be seen.\",\"deeper_read\":\"You tend to keep moving once closeness feels available, but today the useful question is what a warm message will look like in an ordinary week. Let the plan be revised by a specific time, task, or check-in, rather than adding more reassurance to an unresolved detail.\",\"watch_for\":\"A sweet message ends with vague language about getting together, without naming when or how.\",\"move\":\"Reply with one workable follow-through detail, such as a day to call or a plan to confirm.\"}",
    "parsedResponse": {
      "title": "Make It Concrete",
      "intro": "A tender exchange lands well, yet one unanswered practical detail keeps the reassurance from fully settling.",
      "pull_quote": "You do not need to slow your feelings down; you need one promise that can be seen.",
      "deeper_read": "You tend to keep moving once closeness feels available, but today the useful question is what a warm message will look like in an ordinary week. Let the plan be revised by a specific time, task, or check-in, rather than adding more reassurance to an unresolved detail.",
      "watch_for": "A sweet message ends with vague language about getting together, without naming when or how.",
      "move": "Reply with one workable follow-through detail, such as a day to call or a plan to confirm."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1048,
      "input_tokens_details": {
        "cache_write_tokens": 1045,
        "cached_tokens": 0
      },
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1206
    }
  }
]
```

## home

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for driven shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you doesn't slow down as needed"
  ],
  "identitySpecificRole": "the person who translates driven into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after driven has filled the day.",
  "ordinaryLifeExpression": "A physical change gives driven somewhere to be practiced at home.",
  "blindSpot": "You may struggle with stillness.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without driven running the room.",
  "sourcePaths": [
    "core.coreNeed",
    "growth.restorationPattern",
    "perception.attentionBlindSpot"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "home-change",
      "date": "2026-07-13",
      "symbolicContext": "A familiar arrangement has started asking for more than it used to.",
      "humanTension": "stability vs change",
      "arena": "home",
      "emotionalTone": "steady",
      "seed": "lens-03"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|home",
      "manifestationArena": "home",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by stability vs change.",
      "perception": "The need for driven shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you doesn't slow down as needed"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates driven into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after driven has filled the day.",
    "ordinaryLifeExpression": "A physical change gives driven somewhere to be practiced at home.",
    "blindSpot": "You may struggle with stillness.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without driven running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room to Land",
  "intro": "At home, the familiar setup may start feeling less supportive once the day’s momentum follows you inside.",
  "pull_quote": "A small change in the room can give your pace somewhere to stop without turning the whole household upside down.",
  "deeper_read": "You may be ready to adjust a chair, clear a surface, or reclaim a private corner before discussing every shared routine. That practical shift matters because a room that makes recovery easy lets you keep your momentum without asking it to run every part of the evening.",
  "watch_for": "You move an object or straighten a shared area, then keep reorganizing instead of sitting down there.",
  "move": "Set up one spot for a quiet task or pause, and leave the rest of the room alone today."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room to Land\",\"intro\":\"At home, the familiar setup may start feeling less supportive once the day’s momentum follows you inside.\",\"pull_quote\":\"A small change in the room can give your pace somewhere to stop without turning the whole household upside down.\",\"deeper_read\":\"You may be ready to adjust a chair, clear a surface, or reclaim a private corner before discussing every shared routine. That practical shift matters because a room that makes recovery easy lets you keep your momentum without asking it to run every part of the evening.\",\"watch_for\":\"You move an object or straighten a shared area, then keep reorganizing instead of sitting down there.\",\"move\":\"Set up one spot for a quiet task or pause, and leave the rest of the room alone today.\"}",
    "parsedResponse": {
      "title": "Make Room to Land",
      "intro": "At home, the familiar setup may start feeling less supportive once the day’s momentum follows you inside.",
      "pull_quote": "A small change in the room can give your pace somewhere to stop without turning the whole household upside down.",
      "deeper_read": "You may be ready to adjust a chair, clear a surface, or reclaim a private corner before discussing every shared routine. That practical shift matters because a room that makes recovery easy lets you keep your momentum without asking it to run every part of the evening.",
      "watch_for": "You move an object or straighten a shared area, then keep reorganizing instead of sitting down there.",
      "move": "Set up one spot for a quiet task or pause, and leave the rest of the room alone today."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1054,
      "input_tokens_details": {
        "cache_write_tokens": 1051,
        "cached_tokens": 0
      },
      "output_tokens": 163,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1217
    }
  }
]
```

## friends

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by driven.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you burn out from constant motion"
  ],
  "identitySpecificRole": "the friend who uses driven to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's driven.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around driven.",
  "blindSpot": "You keep advancing before the last achievement has fully landed.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the driven dynamic.",
  "sourcePaths": [
    "social.communicationStyle",
    "social.influenceStyle",
    "social.commonMisreads",
    "relationships.loyaltyStyle"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "friends-harmony",
      "date": "2026-07-14",
      "symbolicContext": "A friend wants peace before the honest part has been said.",
      "humanTension": "harmony vs honesty",
      "arena": "friends",
      "emotionalTone": "tender",
      "seed": "lens-04"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by driven.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you burn out from constant motion"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses driven to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's driven.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around driven.",
    "blindSpot": "You keep advancing before the last achievement has fully landed.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the driven dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Clearly",
  "intro": "When a friend smooths things over, you can make your availability visible instead of letting the group guess.",
  "pull_quote": "A specific invitation can be kinder than keeping the peace with an unspoken assumption.",
  "deeper_read": "You notice who keeps getting assigned the role nobody named, including the person expected to be endlessly available. Rather than rushing past that pattern to preserve a pleasant tone, name a plan that fits your actual schedule and lets one friend respond honestly.",
  "watch_for": "Notice whether someone says “whatever works” after a favor or availability question goes unanswered.",
  "move": "Send one friend a concrete invitation with a time, place, and a clear limit on how long you can stay."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room Clearly\",\"intro\":\"When a friend smooths things over, you can make your availability visible instead of letting the group guess.\",\"pull_quote\":\"A specific invitation can be kinder than keeping the peace with an unspoken assumption.\",\"deeper_read\":\"You notice who keeps getting assigned the role nobody named, including the person expected to be endlessly available. Rather than rushing past that pattern to preserve a pleasant tone, name a plan that fits your actual schedule and lets one friend respond honestly.\",\"watch_for\":\"Notice whether someone says “whatever works” after a favor or availability question goes unanswered.\",\"move\":\"Send one friend a concrete invitation with a time, place, and a clear limit on how long you can stay.\"}",
    "parsedResponse": {
      "title": "Make Room Clearly",
      "intro": "When a friend smooths things over, you can make your availability visible instead of letting the group guess.",
      "pull_quote": "A specific invitation can be kinder than keeping the peace with an unspoken assumption.",
      "deeper_read": "You notice who keeps getting assigned the role nobody named, including the person expected to be endlessly available. Rather than rushing past that pattern to preserve a pleasant tone, name a plan that fits your actual schedule and lets one friend respond honestly.",
      "watch_for": "Notice whether someone says “whatever works” after a favor or availability question goes unanswered.",
      "move": "Send one friend a concrete invitation with a time, place, and a clear limit on how long you can stay."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1062,
      "input_tokens_details": {
        "cache_write_tokens": 1059,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1215
    }
  }
]
```

## money

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by driven meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you doesn't slow down as needed"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to driven comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what driven makes tempting.",
  "blindSpot": "You regret the choice when you burn out from constant motion.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a driven choice.",
  "sourcePaths": [
    "decision.certaintyStyle",
    "decision.evidenceThreshold",
    "decision.regretPattern",
    "core.coreNeed"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "money-comfort",
      "date": "2026-07-15",
      "symbolicContext": "A small purchase promises relief while a larger priority waits.",
      "humanTension": "comfort vs restraint",
      "arena": "money",
      "emotionalTone": "wry",
      "seed": "lens-05"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|money",
      "manifestationArena": "money",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by driven meets comfort, scarcity, status, and future options.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you doesn't slow down as needed"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to driven comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what driven makes tempting.",
    "blindSpot": "You regret the choice when you burn out from constant motion.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a driven choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Real Price",
  "intro": "Before tapping buy, you notice the comfort expense is competing with a larger option already on your list.",
  "pull_quote": "Relief can be worth paying for, but name what that payment asks you to postpone.",
  "deeper_read": "You are good at keeping things moving, which can make a small convenience feel like an efficient fix rather than a tradeoff. Put the purchase beside the bill, budget target, or future plan it affects; the choice gets simpler when both costs are visible.",
  "watch_for": "You compare prices in a cart, then quickly justify the faster delivery or upgraded version.",
  "move": "Write down one future option the purchase reduces before deciding whether today’s relief earns the cost."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Real Price\",\"intro\":\"Before tapping buy, you notice the comfort expense is competing with a larger option already on your list.\",\"pull_quote\":\"Relief can be worth paying for, but name what that payment asks you to postpone.\",\"deeper_read\":\"You are good at keeping things moving, which can make a small convenience feel like an efficient fix rather than a tradeoff. Put the purchase beside the bill, budget target, or future plan it affects; the choice gets simpler when both costs are visible.\",\"watch_for\":\"You compare prices in a cart, then quickly justify the faster delivery or upgraded version.\",\"move\":\"Write down one future option the purchase reduces before deciding whether today’s relief earns the cost.\"}",
    "parsedResponse": {
      "title": "The Real Price",
      "intro": "Before tapping buy, you notice the comfort expense is competing with a larger option already on your list.",
      "pull_quote": "Relief can be worth paying for, but name what that payment asks you to postpone.",
      "deeper_read": "You are good at keeping things moving, which can make a small convenience feel like an efficient fix rather than a tradeoff. Put the purchase beside the bill, budget target, or future plan it affects; the choice gets simpler when both costs are visible.",
      "watch_for": "You compare prices in a cart, then quickly justify the faster delivery or upgraded version.",
      "move": "Write down one future option the purchase reduces before deciding whether today’s relief earns the cost."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1063,
      "input_tokens_details": {
        "cache_write_tokens": 1060,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1216
    }
  }
]
```

## rest

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by driven active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you doesn't slow down as needed"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from driven can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when driven keeps usefulness moving.",
  "blindSpot": "Feelings are often pushed aside in favor of movement and progress",
  "naturalMove": "Close one open loop, then protect the remaining hour from the driven maintenance loop.",
  "sourcePaths": [
    "pressure.internalStory",
    "growth.restorationPattern",
    "growth.recoveryRecognition"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "rest-responsibility",
      "date": "2026-07-16",
      "symbolicContext": "The useful thing to do is not the thing everyone expects from you.",
      "humanTension": "responsibility vs autonomy",
      "arena": "rest",
      "emotionalTone": "restless",
      "seed": "lens-06"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by driven active after the useful work is done.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you doesn't slow down as needed"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from driven can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when driven keeps usefulness moving.",
    "blindSpot": "Feelings are often pushed aside in favor of movement and progress",
    "naturalMove": "Close one open loop, then protect the remaining hour from the driven maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Hour Stays Yours",
  "intro": "After finishing one necessary task, you may feel tempted to fill the quiet hour with another small fix.",
  "pull_quote": "Rest becomes practical when you stop treating every open minute as proof that you are still useful.",
  "deeper_read": "Your usual answer to an unfinished task is momentum: handle it, then scan for the next maintenance loop. Today, closing one loop and putting the phone away lets the remaining hour serve recovery rather than becoming another round of upkeep.",
  "watch_for": "You finish a small chore, reach for your phone, and immediately look for something else to organize.",
  "move": "Choose one clear stopping point, silence the phone, and keep the rest of the hour free of tasks."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Hour Stays Yours\",\"intro\":\"After finishing one necessary task, you may feel tempted to fill the quiet hour with another small fix.\",\"pull_quote\":\"Rest becomes practical when you stop treating every open minute as proof that you are still useful.\",\"deeper_read\":\"Your usual answer to an unfinished task is momentum: handle it, then scan for the next maintenance loop. Today, closing one loop and putting the phone away lets the remaining hour serve recovery rather than becoming another round of upkeep.\",\"watch_for\":\"You finish a small chore, reach for your phone, and immediately look for something else to organize.\",\"move\":\"Choose one clear stopping point, silence the phone, and keep the rest of the hour free of tasks.\"}",
    "parsedResponse": {
      "title": "The Hour Stays Yours",
      "intro": "After finishing one necessary task, you may feel tempted to fill the quiet hour with another small fix.",
      "pull_quote": "Rest becomes practical when you stop treating every open minute as proof that you are still useful.",
      "deeper_read": "Your usual answer to an unfinished task is momentum: handle it, then scan for the next maintenance loop. Today, closing one loop and putting the phone away lets the remaining hour serve recovery rather than becoming another round of upkeep.",
      "watch_for": "You finish a small chore, reach for your phone, and immediately look for something else to organize.",
      "move": "Choose one clear stopping point, silence the phone, and keep the rest of the hour free of tasks."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1060,
      "input_tokens_details": {
        "cache_write_tokens": 1057,
        "cached_tokens": 0
      },
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1215
    }
  }
]
```

## confidence

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for driven is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you burn out from constant motion"
  ],
  "identitySpecificRole": "the contributor who can accept driven without performing a larger identity",
  "recognition": "Confidence settles when praise names the driven contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger driven performance.",
  "blindSpot": "Looks Strong, Needs Air",
  "naturalMove": "Credit the contribution accurately, then stop before you burn out from constant motion.",
  "sourcePaths": [
    "core.matureExpression",
    "evidence.observableBehaviors",
    "social.commonMisreads"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "confidence-recognition",
      "date": "2026-07-17",
      "symbolicContext": "Someone notices work you were prepared to let speak for itself.",
      "humanTension": "recognition vs humility",
      "arena": "confidence",
      "emotionalTone": "encouraging",
      "seed": "lens-07"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for driven is tested by praise, attribution, and visible competence.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you burn out from constant motion"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept driven without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the driven contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger driven performance.",
    "blindSpot": "Looks Strong, Needs Air",
    "naturalMove": "Credit the contribution accurately, then stop before you burn out from constant motion.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your work today, you can accept the credit without turning it into another performance.",
  "pull_quote": "A clear “thank you” lets the result stand without asking you to immediately prove yourself again.",
  "deeper_read": "You are used to keeping momentum after a finished result, but precise praise gives you a reason to pause. State what you contributed plainly, then let the attribution belong to the work rather than expanding it into a larger claim about who you have to be.",
  "watch_for": "Someone compliments a result, and you begin explaining the next task before acknowledging what they noticed.",
  "move": "Say what you handled, thank them, and wait one beat before reopening your task list."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your work today, you can accept the credit without turning it into another performance.\",\"pull_quote\":\"A clear “thank you” lets the result stand without asking you to immediately prove yourself again.\",\"deeper_read\":\"You are used to keeping momentum after a finished result, but precise praise gives you a reason to pause. State what you contributed plainly, then let the attribution belong to the work rather than expanding it into a larger claim about who you have to be.\",\"watch_for\":\"Someone compliments a result, and you begin explaining the next task before acknowledging what they noticed.\",\"move\":\"Say what you handled, thank them, and wait one beat before reopening your task list.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your work today, you can accept the credit without turning it into another performance.",
      "pull_quote": "A clear “thank you” lets the result stand without asking you to immediately prove yourself again.",
      "deeper_read": "You are used to keeping momentum after a finished result, but precise praise gives you a reason to pause. State what you contributed plainly, then let the attribution belong to the work rather than expanding it into a larger claim about who you have to be.",
      "watch_for": "Someone compliments a result, and you begin explaining the next task before acknowledging what they noticed.",
      "move": "Say what you handled, thank them, and wait one beat before reopening your task list."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1043,
      "input_tokens_details": {
        "cache_write_tokens": 1040,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1196
    }
  }
]
```

## routine

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by driven is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you doesn't slow down as needed"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as driven reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a driven working style.",
  "blindSpot": "You release the work by leting reality revise the plan.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this driven rhythm.",
  "sourcePaths": [
    "work.relationshipToStructure",
    "work.completionSignal",
    "work.releasePattern"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "routine-freedom",
      "date": "2026-07-18",
      "symbolicContext": "A reliable routine has become harder to inhabit without irritation.",
      "humanTension": "consistency vs freedom",
      "arena": "routine",
      "emotionalTone": "restless",
      "seed": "lens-08"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by driven is reducing friction or preserving confinement.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you doesn't slow down as needed"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as driven reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a driven working style.",
    "blindSpot": "You release the work by leting reality revise the plan.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this driven rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Revise the Repeat",
  "intro": "A familiar routine starts to grate when one repeated step creates more rework than progress.",
  "pull_quote": "You do not need to abandon the routine; you need to stop defending the part that slows it down.",
  "deeper_read": "Your first instinct may be to push through the irritation and keep the sequence moving. Instead, use the friction as evidence: if one step keeps sending you back to fix something, let the actual result revise the order rather than asking yourself to tolerate it.",
  "watch_for": "Notice the moment you redo a task because an earlier step was completed too quickly.",
  "move": "Change one step in the sequence today, then keep the version that removes the most backtracking."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Revise the Repeat\",\"intro\":\"A familiar routine starts to grate when one repeated step creates more rework than progress.\",\"pull_quote\":\"You do not need to abandon the routine; you need to stop defending the part that slows it down.\",\"deeper_read\":\"Your first instinct may be to push through the irritation and keep the sequence moving. Instead, use the friction as evidence: if one step keeps sending you back to fix something, let the actual result revise the order rather than asking yourself to tolerate it.\",\"watch_for\":\"Notice the moment you redo a task because an earlier step was completed too quickly.\",\"move\":\"Change one step in the sequence today, then keep the version that removes the most backtracking.\"}",
    "parsedResponse": {
      "title": "Revise the Repeat",
      "intro": "A familiar routine starts to grate when one repeated step creates more rework than progress.",
      "pull_quote": "You do not need to abandon the routine; you need to stop defending the part that slows it down.",
      "deeper_read": "Your first instinct may be to push through the irritation and keep the sequence moving. Instead, use the friction as evidence: if one step keeps sending you back to fix something, let the actual result revise the order rather than asking yourself to tolerate it.",
      "watch_for": "Notice the moment you redo a task because an earlier step was completed too quickly.",
      "move": "Change one step in the sequence today, then keep the version that removes the most backtracking."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1052,
      "input_tokens_details": {
        "cache_write_tokens": 1049,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1205
    }
  }
]
```

## conflict

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The restlessness response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you burn out from constant motion"
  ],
  "identitySpecificRole": "the builder who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against restlessness is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before restlessness takes over.",
  "blindSpot": "You may decide from restlessness instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses restlessness.",
  "sourcePaths": [
    "social.conflictStyle",
    "social.boundaryStyle",
    "pressure.decisionDistortion"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "conflict-directness",
      "date": "2026-07-19",
      "symbolicContext": "A small disagreement is carrying more weight than its words suggest.",
      "humanTension": "directness vs patience",
      "arena": "conflict",
      "emotionalTone": "clear-eyed",
      "seed": "lens-09"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by directness vs patience.",
      "perception": "The restlessness response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you burn out from constant motion"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the builder who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against restlessness is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before restlessness takes over.",
    "blindSpot": "You may decide from restlessness instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses restlessness.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Repairable",
  "intro": "A small disagreement sharpens when you name its actual impact instead of chasing the tone behind it.",
  "pull_quote": "You do not need to settle every implication before stating what would make this exchange usable again.",
  "deeper_read": "The point you have avoided may be less about proving what someone meant than identifying what changed in the conversation. Separate the evidence from the motive you are assigning, then give the conflict one concrete condition for repair before your urge to move on makes the decision for you.",
  "watch_for": "A tone shift or loaded phrase pulls you into responding to what you think they meant.",
  "move": "Say what happened, name its effect, and ask for one specific change before continuing the discussion."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you name its actual impact instead of chasing the tone behind it.\",\"pull_quote\":\"You do not need to settle every implication before stating what would make this exchange usable again.\",\"deeper_read\":\"The point you have avoided may be less about proving what someone meant than identifying what changed in the conversation. Separate the evidence from the motive you are assigning, then give the conflict one concrete condition for repair before your urge to move on makes the decision for you.\",\"watch_for\":\"A tone shift or loaded phrase pulls you into responding to what you think they meant.\",\"move\":\"Say what happened, name its effect, and ask for one specific change before continuing the discussion.\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you name its actual impact instead of chasing the tone behind it.",
      "pull_quote": "You do not need to settle every implication before stating what would make this exchange usable again.",
      "deeper_read": "The point you have avoided may be less about proving what someone meant than identifying what changed in the conversation. Separate the evidence from the motive you are assigning, then give the conflict one concrete condition for repair before your urge to move on makes the decision for you.",
      "watch_for": "A tone shift or loaded phrase pulls you into responding to what you think they meant.",
      "move": "Say what happened, name its effect, and ask for one specific change before continuing the discussion."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1067,
      "input_tokens_details": {
        "cache_write_tokens": 1064,
        "cached_tokens": 0
      },
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1222
    }
  }
]
```

## opportunity

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Capricorn × Horse",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by driven competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you doesn't slow down as needed"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects driven and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for driven.",
  "blindSpot": "You delay when you doesn't slow down as needed.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about driven.",
  "sourcePaths": [
    "perception.readsAsOpportunity",
    "decision.actionTrigger",
    "decision.delayPattern"
  ]
}
```

### Focused context and reasoning

```json
{
  "context": {
    "signPair": "Capricorn × Horse",
    "scenario": {
      "id": "opportunity-expansion",
      "date": "2026-07-20",
      "symbolicContext": "A worthwhile opening would require leaving a proven position.",
      "humanTension": "security vs expansion",
      "arena": "opportunity",
      "emotionalTone": "encouraging",
      "seed": "lens-10"
    },
    "selected": {
      "manifestationKey": "Capricorn × Horse|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You keep advancing before the last achievement has fully landed. Growth begins when you let reality revise the plan. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by driven competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with driven, active, and forward-focused. Then you maintain strong forward momentum.",
      "pressureOrGrowth": "Under pressure, you first doesn't slow down as needed.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you doesn't slow down as needed"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects driven and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for driven.",
    "blindSpot": "You delay when you doesn't slow down as needed.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about driven.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Leaving",
  "intro": "An attractive offer deserves more than a quick yes, especially when a proven position is what makes it tempting to protect.",
  "pull_quote": "You do not need to erase the risk; you need one small test that makes the opportunity measurable.",
  "deeper_read": "Ask what evidence would make leaving worthwhile, then give yourself a short, bounded way to find it. A trial conversation, a defined project, or a clear timing checkpoint lets ambition act without treating uncertainty as settled.",
  "watch_for": "Notice if you keep researching the offer after you have already identified the one proof point you need.",
  "move": "Set a deadline and take the smallest reversible step that can answer your key question."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Leaving\",\"intro\":\"An attractive offer deserves more than a quick yes, especially when a proven position is what makes it tempting to protect.\",\"pull_quote\":\"You do not need to erase the risk; you need one small test that makes the opportunity measurable.\",\"deeper_read\":\"Ask what evidence would make leaving worthwhile, then give yourself a short, bounded way to find it. A trial conversation, a defined project, or a clear timing checkpoint lets ambition act without treating uncertainty as settled.\",\"watch_for\":\"Notice if you keep researching the offer after you have already identified the one proof point you need.\",\"move\":\"Set a deadline and take the smallest reversible step that can answer your key question.\"}",
    "parsedResponse": {
      "title": "Proof Before Leaving",
      "intro": "An attractive offer deserves more than a quick yes, especially when a proven position is what makes it tempting to protect.",
      "pull_quote": "You do not need to erase the risk; you need one small test that makes the opportunity measurable.",
      "deeper_read": "Ask what evidence would make leaving worthwhile, then give yourself a short, bounded way to find it. A trial conversation, a defined project, or a clear timing checkpoint lets ambition act without treating uncertainty as settled.",
      "watch_for": "Notice if you keep researching the offer after you have already identified the one proof point you need.",
      "move": "Set a deadline and take the smallest reversible step that can answer your key question."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1066,
      "input_tokens_details": {
        "cache_write_tokens": 1063,
        "cached_tokens": 0
      },
      "output_tokens": 149,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1215
    }
  }
]
```
