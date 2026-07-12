# 120 · Cancer × Pig

Status: complete
Source: Resources/archetypes.json#cancer-pig
Retries: 2
QA flags: 2

## Canonical fixture

```json

```

## work

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Cancer × Pig",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You expresse emotion openly. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you give too much",
    "uses you create connection easily to make one standard visible before you avoid hard boundaries"
  ],
  "identitySpecificRole": "the protector who turns thrives in collaborative spaces into clear ownership",
  "recognition": "The work improves when the warmth result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes warmth observable before ownership is finalized.",
  "blindSpot": "You may avoid hard boundaries after the work is already good enough.",
  "naturalMove": "Clarify one owner and use warmth as the visible standard.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|work",
      "manifestationArena": "work",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by speaking up vs waiting.",
      "perception": "You expresse emotion openly. becomes visible around ownership and execution.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "names who owns the next handoff before you give too much",
        "uses you create connection easily to make one standard visible before you avoid hard boundaries"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the protector who turns thrives in collaborative spaces into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the warmth result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes warmth observable before ownership is finalized.",
    "blindSpot": "You may avoid hard boundaries after the work is already good enough.",
    "naturalMove": "Clarify one owner and use warmth as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In a work meeting, your easy warmth can keep a handoff moving before anyone names its owner.",
  "pull_quote": "Connection helps the group, but the next step needs a name attached to it.",
  "deeper_read": "You make collaboration feel workable, especially when a deadline or standard needs attention. Today, notice the moment people seem satisfied and use it to identify who carries the next handoff, rather than supplying the missing effort yourself.",
  "watch_for": "Watch for a meeting ending with smiles while the handoff still has no named owner.",
  "move": "Before the meeting ends, name one owner and confirm the handoff deadline."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the helpful tone you set needs a named owner before the next handoff.\",\"pull_quote\":\"Connection holds longer when someone can point to who carries the work from here.\",\"deeper_read\":\"You may make the collaboration feel easy by filling gaps, smoothing the exchange, and keeping the standard warm. Before that ease turns into extra work for you, say who owns the next step and what the handoff should look like.\",\"watch_for\":\"A colleague says, “We’ll handle it,” and no one names the person or deadline.\",\"move\":\"Before the meeting ends, ask one direct question: “Who owns this handoff, and when is it due?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the helpful tone you set needs a named owner before the next handoff.",
      "pull_quote": "Connection holds longer when someone can point to who carries the work from here.",
      "deeper_read": "You may make the collaboration feel easy by filling gaps, smoothing the exchange, and keeping the standard warm. Before that ease turns into extra work for you, say who owns the next step and what the handoff should look like.",
      "watch_for": "A colleague says, “We’ll handle it,” and no one names the person or deadline.",
      "move": "Before the meeting ends, ask one direct question: “Who owns this handoff, and when is it due?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1053,
      "input_tokens_details": {
        "cache_write_tokens": 1050,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1206
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a work meeting, your easy warmth can keep a handoff moving before anyone names its owner.\",\"pull_quote\":\"Connection helps the group, but the next step needs a name attached to it.\",\"deeper_read\":\"You make collaboration feel workable, especially when a deadline or standard needs attention. Today, notice the moment people seem satisfied and use it to identify who carries the next handoff, rather than supplying the missing effort yourself.\",\"watch_for\":\"Watch for a meeting ending with smiles while the handoff still has no named owner.\",\"move\":\"Before the meeting ends, name one owner and confirm the handoff deadline.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a work meeting, your easy warmth can keep a handoff moving before anyone names its owner.",
      "pull_quote": "Connection helps the group, but the next step needs a name attached to it.",
      "deeper_read": "You make collaboration feel workable, especially when a deadline or standard needs attention. Today, notice the moment people seem satisfied and use it to identify who carries the next handoff, rather than supplying the missing effort yourself.",
      "watch_for": "Watch for a meeting ending with smiles while the handoff still has no named owner.",
      "move": "Before the meeting ends, name one owner and confirm the handoff deadline."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1187,
      "input_tokens_details": {
        "cache_write_tokens": 1184,
        "cached_tokens": 0
      },
      "output_tokens": 659,
      "output_tokens_details": {
        "reasoning_tokens": 516
      },
      "total_tokens": 1846
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
  "identity": "Cancer × Pig",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings warmth to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you avoid hard boundaries"
  ],
  "identitySpecificRole": "the partner who turns warmth into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking warmth to disappear.",
  "ordinaryLifeExpression": "Evidence of warmth becomes the test beneath a reassuring message.",
  "blindSpot": "You may avoid hard boundaries after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning warmth.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|love",
      "manifestationArena": "love",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by trust vs caution.",
      "perception": "The identity brings warmth to closeness, where promises and pacing are tested.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you avoid hard boundaries"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns warmth into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking warmth to disappear.",
    "ordinaryLifeExpression": "Evidence of warmth becomes the test beneath a reassuring message.",
    "blindSpot": "You may avoid hard boundaries after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning warmth.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Warmth, With Details",
  "intro": "A reassuring exchange feels real today, yet one small plan still needs a clear answer.",
  "pull_quote": "You do not need to cool the affection to ask what the promise looks like this week.",
  "deeper_read": "You make connection easy by responding with warmth, but the unresolved detail in a message or plan can linger after the tender part lands. Let reassurance keep its softness while you name one follow-through point: when, how, or who will confirm it.",
  "watch_for": "A sweet message ends without settling the timing, next step, or practical part of the shared plan.",
  "move": "Reply warmly, then ask one plain question that makes the promise visible in an ordinary week."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Warmth, With Details\",\"intro\":\"A reassuring exchange feels real today, yet one small plan still needs a clear answer.\",\"pull_quote\":\"You do not need to cool the affection to ask what the promise looks like this week.\",\"deeper_read\":\"You make connection easy by responding with warmth, but the unresolved detail in a message or plan can linger after the tender part lands. Let reassurance keep its softness while you name one follow-through point: when, how, or who will confirm it.\",\"watch_for\":\"A sweet message ends without settling the timing, next step, or practical part of the shared plan.\",\"move\":\"Reply warmly, then ask one plain question that makes the promise visible in an ordinary week.\"}",
    "parsedResponse": {
      "title": "Warmth, With Details",
      "intro": "A reassuring exchange feels real today, yet one small plan still needs a clear answer.",
      "pull_quote": "You do not need to cool the affection to ask what the promise looks like this week.",
      "deeper_read": "You make connection easy by responding with warmth, but the unresolved detail in a message or plan can linger after the tender part lands. Let reassurance keep its softness while you name one follow-through point: when, how, or who will confirm it.",
      "watch_for": "A sweet message ends without settling the timing, next step, or practical part of the shared plan.",
      "move": "Reply warmly, then ask one plain question that makes the promise visible in an ordinary week."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1044,
      "input_tokens_details": {
        "cache_write_tokens": 1041,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1197
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
  "identity": "Cancer × Pig",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for warmth shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you give too much"
  ],
  "identitySpecificRole": "the person who translates warmth into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after warmth has filled the day.",
  "ordinaryLifeExpression": "A physical change gives warmth somewhere to be practiced at home.",
  "blindSpot": "You may trust too quickly.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without warmth running the room.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|home",
      "manifestationArena": "home",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by stability vs change.",
      "perception": "The need for warmth shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you give too much"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates warmth into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after warmth has filled the day.",
    "ordinaryLifeExpression": "A physical change gives warmth somewhere to be practiced at home.",
    "blindSpot": "You may trust too quickly.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without warmth running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room to Reset",
  "intro": "A familiar shared space may feel demanding today, not because anyone is wrong, but because it leaves no place to recover.",
  "pull_quote": "You can keep the household warm without making yourself available in every corner of it.",
  "deeper_read": "Instead of debating the whole routine, notice the small condition that keeps drawing you back into maintenance: a chair, countertop, open door, or pile of shared things. Changing one placement can make the room easier to inhabit after you have spent the day making others feel accommodated.",
  "watch_for": "You move someone else's items aside, then pause before automatically taking on the next household task.",
  "move": "Claim one private corner and set it up for a ten-minute reset before returning to shared space."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room to Reset\",\"intro\":\"A familiar shared space may feel demanding today, not because anyone is wrong, but because it leaves no place to recover.\",\"pull_quote\":\"You can keep the household warm without making yourself available in every corner of it.\",\"deeper_read\":\"Instead of debating the whole routine, notice the small condition that keeps drawing you back into maintenance: a chair, countertop, open door, or pile of shared things. Changing one placement can make the room easier to inhabit after you have spent the day making others feel accommodated.\",\"watch_for\":\"You move someone else's items aside, then pause before automatically taking on the next household task.\",\"move\":\"Claim one private corner and set it up for a ten-minute reset before returning to shared space.\"}",
    "parsedResponse": {
      "title": "Make Room to Reset",
      "intro": "A familiar shared space may feel demanding today, not because anyone is wrong, but because it leaves no place to recover.",
      "pull_quote": "You can keep the household warm without making yourself available in every corner of it.",
      "deeper_read": "Instead of debating the whole routine, notice the small condition that keeps drawing you back into maintenance: a chair, countertop, open door, or pile of shared things. Changing one placement can make the room easier to inhabit after you have spent the day making others feel accommodated.",
      "watch_for": "You move someone else's items aside, then pause before automatically taking on the next household task.",
      "move": "Claim one private corner and set it up for a ten-minute reset before returning to shared space."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1051,
      "input_tokens_details": {
        "cache_write_tokens": 1048,
        "cached_tokens": 0
      },
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1212
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
  "identity": "Cancer × Pig",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by warmth.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you avoid hard boundaries"
  ],
  "identitySpecificRole": "the friend who uses warmth to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's warmth.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around warmth.",
  "blindSpot": "You make others feel held before noticing what you absorbed.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the warmth dynamic.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by warmth.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you avoid hard boundaries"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses warmth to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's warmth.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around warmth.",
    "blindSpot": "You make others feel held before noticing what you absorbed.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the warmth dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "A Clear Invitation",
  "intro": "A friend may smooth over the honest part today, and you can keep warmth without carrying the whole exchange.",
  "pull_quote": "Your kindness lands better when your availability is stated, not quietly assumed by everyone else.",
  "deeper_read": "Notice who keeps taking on the group role nobody named, including you. Instead of adjusting your plans to preserve a pleasant tone, let one clear invitation show what you can offer and what you are not taking on.",
  "watch_for": "A friend says \"it’s fine\" quickly while the plan, favor, or group task remains unresolved.",
  "move": "Send one specific invitation that names the time, the plan, and what you are available to do."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"A Clear Invitation\",\"intro\":\"A friend may smooth over the honest part today, and you can keep warmth without carrying the whole exchange.\",\"pull_quote\":\"Your kindness lands better when your availability is stated, not quietly assumed by everyone else.\",\"deeper_read\":\"Notice who keeps taking on the group role nobody named, including you. Instead of adjusting your plans to preserve a pleasant tone, let one clear invitation show what you can offer and what you are not taking on.\",\"watch_for\":\"A friend says \\\"it’s fine\\\" quickly while the plan, favor, or group task remains unresolved.\",\"move\":\"Send one specific invitation that names the time, the plan, and what you are available to do.\"}",
    "parsedResponse": {
      "title": "A Clear Invitation",
      "intro": "A friend may smooth over the honest part today, and you can keep warmth without carrying the whole exchange.",
      "pull_quote": "Your kindness lands better when your availability is stated, not quietly assumed by everyone else.",
      "deeper_read": "Notice who keeps taking on the group role nobody named, including you. Instead of adjusting your plans to preserve a pleasant tone, let one clear invitation show what you can offer and what you are not taking on.",
      "watch_for": "A friend says \"it’s fine\" quickly while the plan, favor, or group task remains unresolved.",
      "move": "Send one specific invitation that names the time, the plan, and what you are available to do."
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
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1210
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
  "identity": "Cancer × Pig",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by warmth meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you give too much"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to warmth comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what warmth makes tempting.",
  "blindSpot": "You regret the choice when you avoid hard boundaries.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a warmth choice.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|money",
      "manifestationArena": "money",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by warmth meets comfort, scarcity, status, and future options.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you give too much"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to warmth comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what warmth makes tempting.",
    "blindSpot": "You regret the choice when you avoid hard boundaries.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a warmth choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Full Price",
  "intro": "At checkout, the small comfort expense looks different once you name the flexibility it would take.",
  "pull_quote": "Relief can be worth buying, but it should not quietly spend tomorrow’s options.",
  "deeper_read": "You naturally notice how a purchase might soften the day, especially when it feels like a caring response to yourself or someone else. Before saying yes, put the bill or budget beside the future option it narrows; the tradeoff becomes clearer without turning comfort into a crime.",
  "watch_for": "You compare prices repeatedly, then hesitate when the larger bill or planned expense comes to mind.",
  "move": "Write down one future option the purchase affects, then decide whether today’s relief still earns its cost."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Full Price\",\"intro\":\"At checkout, the small comfort expense looks different once you name the flexibility it would take.\",\"pull_quote\":\"Relief can be worth buying, but it should not quietly spend tomorrow’s options.\",\"deeper_read\":\"You naturally notice how a purchase might soften the day, especially when it feels like a caring response to yourself or someone else. Before saying yes, put the bill or budget beside the future option it narrows; the tradeoff becomes clearer without turning comfort into a crime.\",\"watch_for\":\"You compare prices repeatedly, then hesitate when the larger bill or planned expense comes to mind.\",\"move\":\"Write down one future option the purchase affects, then decide whether today’s relief still earns its cost.\"}",
    "parsedResponse": {
      "title": "The Full Price",
      "intro": "At checkout, the small comfort expense looks different once you name the flexibility it would take.",
      "pull_quote": "Relief can be worth buying, but it should not quietly spend tomorrow’s options.",
      "deeper_read": "You naturally notice how a purchase might soften the day, especially when it feels like a caring response to yourself or someone else. Before saying yes, put the bill or budget beside the future option it narrows; the tradeoff becomes clearer without turning comfort into a crime.",
      "watch_for": "You compare prices repeatedly, then hesitate when the larger bill or planned expense comes to mind.",
      "move": "Write down one future option the purchase affects, then decide whether today’s relief still earns its cost."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1059,
      "input_tokens_details": {
        "cache_write_tokens": 1056,
        "cached_tokens": 0
      },
      "output_tokens": 156,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1215
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
  "identity": "Cancer × Pig",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by warmth active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you give too much"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from warmth can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when warmth keeps usefulness moving.",
  "blindSpot": "Emotions are open and easily shared",
  "naturalMove": "Close one open loop, then protect the remaining hour from the warmth maintenance loop.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by warmth active after the useful work is done.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you give too much"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from warmth can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when warmth keeps usefulness moving.",
    "blindSpot": "Emotions are open and easily shared",
    "naturalMove": "Close one open loop, then protect the remaining hour from the warmth maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "After the Last Task",
  "intro": "In a quiet hour, finishing one small task can feel like an invitation to find another.",
  "pull_quote": "Rest begins when you stop turning warmth into one more proof that you are useful.",
  "deeper_read": "You may close a maintenance loop, glance at the unfinished task, then reach for your phone as if someone still needs an answer. The useful choice is not to extend the shift: put the phone away and let the remaining hour belong to sleep or stillness.",
  "watch_for": "After completing one chore, you open your phone and begin checking for another person’s need.",
  "move": "Choose a clear stopping point, silence the phone, and leave the unfinished task for tomorrow."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"After the Last Task\",\"intro\":\"In a quiet hour, finishing one small task can feel like an invitation to find another.\",\"pull_quote\":\"Rest begins when you stop turning warmth into one more proof that you are useful.\",\"deeper_read\":\"You may close a maintenance loop, glance at the unfinished task, then reach for your phone as if someone still needs an answer. The useful choice is not to extend the shift: put the phone away and let the remaining hour belong to sleep or stillness.\",\"watch_for\":\"After completing one chore, you open your phone and begin checking for another person’s need.\",\"move\":\"Choose a clear stopping point, silence the phone, and leave the unfinished task for tomorrow.\"}",
    "parsedResponse": {
      "title": "After the Last Task",
      "intro": "In a quiet hour, finishing one small task can feel like an invitation to find another.",
      "pull_quote": "Rest begins when you stop turning warmth into one more proof that you are useful.",
      "deeper_read": "You may close a maintenance loop, glance at the unfinished task, then reach for your phone as if someone still needs an answer. The useful choice is not to extend the shift: put the phone away and let the remaining hour belong to sleep or stillness.",
      "watch_for": "After completing one chore, you open your phone and begin checking for another person’s need.",
      "move": "Choose a clear stopping point, silence the phone, and leave the unfinished task for tomorrow."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1053,
      "input_tokens_details": {
        "cache_write_tokens": 1050,
        "cached_tokens": 0
      },
      "output_tokens": 152,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1205
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
  "identity": "Cancer × Pig",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for warmth is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you avoid hard boundaries"
  ],
  "identitySpecificRole": "the contributor who can accept warmth without performing a larger identity",
  "recognition": "Confidence settles when praise names the warmth contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger warmth performance.",
  "blindSpot": "Looks Kind, Takes All",
  "naturalMove": "Credit the contribution accurately, then stop before you avoid hard boundaries.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for warmth is tested by praise, attribution, and visible competence.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you avoid hard boundaries"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept warmth without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the warmth contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger warmth performance.",
    "blindSpot": "Looks Kind, Takes All",
    "naturalMove": "Credit the contribution accurately, then stop before you avoid hard boundaries.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Be Named",
  "intro": "When someone praises your work today, you can receive the credit without turning it into another act of generosity.",
  "pull_quote": "A clear thank-you lets the result stand without asking you to become more available afterward.",
  "deeper_read": "The useful detail is not whether the praise feels big; it is that someone noticed what you contributed. Name your part plainly—especially the care or warmth that shaped the result—then let the exchange end there instead of offering extra time, reassurance, or access.",
  "watch_for": "You may hear yourself soften credit into luck or immediately ask what else the person needs.",
  "move": "Say, “Thank you—I put a lot of care into that,” and return to the next task."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Be Named\",\"intro\":\"When someone praises your work today, you can receive the credit without turning it into another act of generosity.\",\"pull_quote\":\"A clear thank-you lets the result stand without asking you to become more available afterward.\",\"deeper_read\":\"The useful detail is not whether the praise feels big; it is that someone noticed what you contributed. Name your part plainly—especially the care or warmth that shaped the result—then let the exchange end there instead of offering extra time, reassurance, or access.\",\"watch_for\":\"You may hear yourself soften credit into luck or immediately ask what else the person needs.\",\"move\":\"Say, “Thank you—I put a lot of care into that,” and return to the next task.\"}",
    "parsedResponse": {
      "title": "Let It Be Named",
      "intro": "When someone praises your work today, you can receive the credit without turning it into another act of generosity.",
      "pull_quote": "A clear thank-you lets the result stand without asking you to become more available afterward.",
      "deeper_read": "The useful detail is not whether the praise feels big; it is that someone noticed what you contributed. Name your part plainly—especially the care or warmth that shaped the result—then let the exchange end there instead of offering extra time, reassurance, or access.",
      "watch_for": "You may hear yourself soften credit into luck or immediately ask what else the person needs.",
      "move": "Say, “Thank you—I put a lot of care into that,” and return to the next task."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1039,
      "input_tokens_details": {
        "cache_write_tokens": 1036,
        "cached_tokens": 0
      },
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1197
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
  "identity": "Cancer × Pig",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by warmth is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you give too much"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as warmth reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a warmth working style.",
  "blindSpot": "You release the work by stoping waiting to be understood without speaking plainly.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this warmth rhythm.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by warmth is reducing friction or preserving confinement.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you give too much"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as warmth reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a warmth working style.",
    "blindSpot": "You release the work by stoping waiting to be understood without speaking plainly.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this warmth rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Loosen the Loop",
  "intro": "A dependable part of your routine starts to feel irritating when it creates more work than it prevents.",
  "pull_quote": "You do not need to abandon the routine; you need to stop treating its most frustrating step as fixed.",
  "deeper_read": "Notice the repeated step that sends you back to correct, explain, or redo something later. Instead of quietly absorbing that extra effort, name the snag plainly and adjust the sequence so the routine supports the result rather than demanding loyalty to itself.",
  "watch_for": "You catch yourself repeating a task after an earlier step left something unclear or unfinished.",
  "move": "Change one step in the sequence today, then see whether the next pass requires less explanation or repair."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Loosen the Loop\",\"intro\":\"A dependable part of your routine starts to feel irritating when it creates more work than it prevents.\",\"pull_quote\":\"You do not need to abandon the routine; you need to stop treating its most frustrating step as fixed.\",\"deeper_read\":\"Notice the repeated step that sends you back to correct, explain, or redo something later. Instead of quietly absorbing that extra effort, name the snag plainly and adjust the sequence so the routine supports the result rather than demanding loyalty to itself.\",\"watch_for\":\"You catch yourself repeating a task after an earlier step left something unclear or unfinished.\",\"move\":\"Change one step in the sequence today, then see whether the next pass requires less explanation or repair.\"}",
    "parsedResponse": {
      "title": "Loosen the Loop",
      "intro": "A dependable part of your routine starts to feel irritating when it creates more work than it prevents.",
      "pull_quote": "You do not need to abandon the routine; you need to stop treating its most frustrating step as fixed.",
      "deeper_read": "Notice the repeated step that sends you back to correct, explain, or redo something later. Instead of quietly absorbing that extra effort, name the snag plainly and adjust the sequence so the routine supports the result rather than demanding loyalty to itself.",
      "watch_for": "You catch yourself repeating a task after an earlier step left something unclear or unfinished.",
      "move": "Change one step in the sequence today, then see whether the next pass requires less explanation or repair."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1053,
      "input_tokens_details": {
        "cache_write_tokens": 1050,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1206
    }
  }
]
```

## conflict

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Cancer × Pig",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The overgiving response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you avoid hard boundaries"
  ],
  "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against overgiving is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before overgiving takes over.",
  "blindSpot": "You may decide from overgiving instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses overgiving.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by directness vs patience.",
      "perception": "The overgiving response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you avoid hard boundaries"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against overgiving is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before overgiving takes over.",
    "blindSpot": "You may decide from overgiving instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses overgiving.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Repairable",
  "intro": "A small disagreement gets clearer when you name its impact instead of filling the silence with extra patience.",
  "pull_quote": "You can stay kind without carrying the whole repair before the avoided point is addressed.",
  "deeper_read": "Notice the tone shift or piece of evidence without deciding why it happened. When you separate what changed for you from the motive you are assuming, the disagreement has a practical next step: one condition that shows repair is being shared rather than supplied by you.",
  "watch_for": "Watch for yourself softening the issue after someone skips the point you raised or changes the subject.",
  "move": "State the observable impact, then name the one change needed before you continue the conversation."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Repair Specific\",\"intro\":\"A small disagreement sharpens when you name its impact instead of carrying both sides of the repair.\",\"pull_quote\":\"You do not need to prove their intent to ask for a change in how this is handled.\",\"deeper_read\":\"The tone shift or avoided point may tempt you to smooth things over before the actual issue is addressed. Stay with what happened, what it changed for you, and one condition that would make the conversation repairable without asking you to give more.\",\"watch_for\":\"Notice if you start explaining their side before they have responded to the specific impact you named.\",\"move\":\"Say, “I can continue this when we address the point that was avoided and agree on what changes.”\"}",
    "parsedResponse": {
      "title": "Make Repair Specific",
      "intro": "A small disagreement sharpens when you name its impact instead of carrying both sides of the repair.",
      "pull_quote": "You do not need to prove their intent to ask for a change in how this is handled.",
      "deeper_read": "The tone shift or avoided point may tempt you to smooth things over before the actual issue is addressed. Stay with what happened, what it changed for you, and one condition that would make the conversation repairable without asking you to give more.",
      "watch_for": "Notice if you start explaining their side before they have responded to the specific impact you named.",
      "move": "Say, “I can continue this when we address the point that was avoided and agree on what changes.”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1065,
      "input_tokens_details": {
        "cache_write_tokens": 1062,
        "cached_tokens": 0
      },
      "output_tokens": 154,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1219
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement gets clearer when you name its impact instead of filling the silence with extra patience.\",\"pull_quote\":\"You can stay kind without carrying the whole repair before the avoided point is addressed.\",\"deeper_read\":\"Notice the tone shift or piece of evidence without deciding why it happened. When you separate what changed for you from the motive you are assuming, the disagreement has a practical next step: one condition that shows repair is being shared rather than supplied by you.\",\"watch_for\":\"Watch for yourself softening the issue after someone skips the point you raised or changes the subject.\",\"move\":\"State the observable impact, then name the one change needed before you continue the conversation.\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement gets clearer when you name its impact instead of filling the silence with extra patience.",
      "pull_quote": "You can stay kind without carrying the whole repair before the avoided point is addressed.",
      "deeper_read": "Notice the tone shift or piece of evidence without deciding why it happened. When you separate what changed for you from the motive you are assuming, the disagreement has a practical next step: one condition that shows repair is being shared rather than supplied by you.",
      "watch_for": "Watch for yourself softening the issue after someone skips the point you raised or changes the subject.",
      "move": "State the observable impact, then name the one change needed before you continue the conversation."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1197,
      "input_tokens_details": {
        "cache_write_tokens": 1194,
        "cached_tokens": 0
      },
      "output_tokens": 446,
      "output_tokens_details": {
        "reasoning_tokens": 293
      },
      "total_tokens": 1643
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
  "identity": "Cancer × Pig",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by warmth competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you give too much"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects warmth and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for warmth.",
  "blindSpot": "You delay when you give too much.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about warmth.",
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
    "signPair": "Cancer × Pig",
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
      "manifestationKey": "Cancer × Pig|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You make others feel held before noticing what you absorbed. Growth begins when you stop waiting to be understood without speaking plainly. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by warmth competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with kind, expressive, and emotionally open. Then you create connection easily.",
      "pressureOrGrowth": "Under pressure, you first give too much.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you give too much"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects warmth and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for warmth.",
    "blindSpot": "You delay when you give too much.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about warmth.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof With Warmth",
  "intro": "An appealing offer may deserve your attention today, but not the kind of commitment that leaves no room to reassess.",
  "pull_quote": "You do not need to dismiss the opening; you need a small test that lets its real conditions show.",
  "deeper_read": "You may find yourself asking what evidence would make leaving a proven position worthwhile. Keep the conversation open, then set a timed, reversible step—a trial scope, a follow-up call, or a clear proof point—before offering more time or access than the opportunity has earned.",
  "watch_for": "Notice if you start volunteering extra help before the offer’s timeline, scope, or next decision point is named.",
  "move": "Ask for one concrete proof point, then choose a small reversible action that can produce it."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof With Warmth\",\"intro\":\"An appealing offer may deserve your attention today, but not the kind of commitment that leaves no room to reassess.\",\"pull_quote\":\"You do not need to dismiss the opening; you need a small test that lets its real conditions show.\",\"deeper_read\":\"You may find yourself asking what evidence would make leaving a proven position worthwhile. Keep the conversation open, then set a timed, reversible step—a trial scope, a follow-up call, or a clear proof point—before offering more time or access than the opportunity has earned.\",\"watch_for\":\"Notice if you start volunteering extra help before the offer’s timeline, scope, or next decision point is named.\",\"move\":\"Ask for one concrete proof point, then choose a small reversible action that can produce it.\"}",
    "parsedResponse": {
      "title": "Proof With Warmth",
      "intro": "An appealing offer may deserve your attention today, but not the kind of commitment that leaves no room to reassess.",
      "pull_quote": "You do not need to dismiss the opening; you need a small test that lets its real conditions show.",
      "deeper_read": "You may find yourself asking what evidence would make leaving a proven position worthwhile. Keep the conversation open, then set a timed, reversible step—a trial scope, a follow-up call, or a clear proof point—before offering more time or access than the opportunity has earned.",
      "watch_for": "Notice if you start volunteering extra help before the offer’s timeline, scope, or next decision point is named.",
      "move": "Ask for one concrete proof point, then choose a small reversible action that can produce it."
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
      "output_tokens": 168,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1230
    }
  }
]
```
