# 108 · Gemini × Pig

Status: complete
Source: Resources/archetypes.json#gemini-pig
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
  "identity": "Gemini × Pig",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You communicate openly. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you avoid difficulty",
    "uses you create easy connection to make one standard visible before you overextend emotionally"
  ],
  "identitySpecificRole": "the explorer who turns thrives in collaborative spaces into clear ownership",
  "recognition": "The work improves when the warmth result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes warmth observable before ownership is finalized.",
  "blindSpot": "You may overextend emotionally after the work is already good enough.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|work",
      "manifestationArena": "work",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by speaking up vs waiting.",
      "perception": "You communicate openly. becomes visible around ownership and execution.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "names who owns the next handoff before you avoid difficulty",
        "uses you create easy connection to make one standard visible before you overextend emotionally"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the explorer who turns thrives in collaborative spaces into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the warmth result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes warmth observable before ownership is finalized.",
    "blindSpot": "You may overextend emotionally after the work is already good enough.",
    "naturalMove": "Clarify one owner and use warmth as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In today’s meeting, the friendly momentum needs one clear owner before everyone leaves the room.",
  "pull_quote": "Connection helps the work move, but ownership keeps the next step from quietly drifting.",
  "deeper_read": "You make collaboration easier by keeping the exchange open, which can let a handoff feel settled before anyone has finalized it. Rather than adding more reassurance or taking on the follow-up yourself, make the standard visible and attach it to one person’s next step.",
  "watch_for": "Watch for the moment a deadline is mentioned but nobody names who sends the finished version.",
  "move": "Before the meeting ends, state the owner, the handoff deadline, and the visible standard."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the friendly momentum needs one person’s name beside the next handoff.\",\"pull_quote\":\"Connection helps the work move, but ownership keeps it from becoming another shared assumption.\",\"deeper_read\":\"You may make the exchange feel easy by checking in, offering help, or smoothing a pause before the group moves on. The useful interruption is simpler: name who carries the next piece and let the standard be visible without taking on extra emotional labor.\",\"watch_for\":\"A deadline is mentioned, everyone agrees, and no one says who will send the next draft.\",\"move\":\"Before the meeting ends, ask, “Who owns this handoff, and what should the finished version include?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the friendly momentum needs one person’s name beside the next handoff.",
      "pull_quote": "Connection helps the work move, but ownership keeps it from becoming another shared assumption.",
      "deeper_read": "You may make the exchange feel easy by checking in, offering help, or smoothing a pause before the group moves on. The useful interruption is simpler: name who carries the next piece and let the standard be visible without taking on extra emotional labor.",
      "watch_for": "A deadline is mentioned, everyone agrees, and no one says who will send the next draft.",
      "move": "Before the meeting ends, ask, “Who owns this handoff, and what should the finished version include?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1050,
      "input_tokens_details": {
        "cache_write_tokens": 1047,
        "cached_tokens": 0
      },
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1205
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the friendly momentum needs one clear owner before everyone leaves the room.\",\"pull_quote\":\"Connection helps the work move, but ownership keeps the next step from quietly drifting.\",\"deeper_read\":\"You make collaboration easier by keeping the exchange open, which can let a handoff feel settled before anyone has finalized it. Rather than adding more reassurance or taking on the follow-up yourself, make the standard visible and attach it to one person’s next step.\",\"watch_for\":\"Watch for the moment a deadline is mentioned but nobody names who sends the finished version.\",\"move\":\"Before the meeting ends, state the owner, the handoff deadline, and the visible standard.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the friendly momentum needs one clear owner before everyone leaves the room.",
      "pull_quote": "Connection helps the work move, but ownership keeps the next step from quietly drifting.",
      "deeper_read": "You make collaboration easier by keeping the exchange open, which can let a handoff feel settled before anyone has finalized it. Rather than adding more reassurance or taking on the follow-up yourself, make the standard visible and attach it to one person’s next step.",
      "watch_for": "Watch for the moment a deadline is mentioned but nobody names who sends the finished version.",
      "move": "Before the meeting ends, state the owner, the handoff deadline, and the visible standard."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1183,
      "input_tokens_details": {
        "cache_write_tokens": 1180,
        "cached_tokens": 0
      },
      "output_tokens": 669,
      "output_tokens_details": {
        "reasoning_tokens": 516
      },
      "total_tokens": 1852
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
  "identity": "Gemini × Pig",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings warmth to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you overextend emotionally"
  ],
  "identitySpecificRole": "the partner who turns warmth into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking warmth to disappear.",
  "ordinaryLifeExpression": "Evidence of warmth becomes the test beneath a reassuring message.",
  "blindSpot": "You may overextend emotionally after closeness is already possible.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|love",
      "manifestationArena": "love",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by trust vs caution.",
      "perception": "The identity brings warmth to closeness, where promises and pacing are tested.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you overextend emotionally"
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
    "blindSpot": "You may overextend emotionally after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning warmth.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Warmth, With Details",
  "intro": "A tender message lands well, yet one practical part of the promise still needs an answer.",
  "pull_quote": "You do not have to cool the affection to ask what follow-through will look like this week.",
  "deeper_read": "It is easy to keep the exchange light once you feel close, especially when the unresolved detail might make things feel heavier. Let the warmth stay in the message, then name one concrete point: when you will talk, meet, or check back in.",
  "watch_for": "Notice if you reply warmly but skip the question about timing, plans, or the promised follow-up.",
  "move": "Send one affectionate response that also confirms a specific next step before the conversation drifts onward."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Warmth, With Details\",\"intro\":\"A tender message lands well, yet one practical part of the promise still needs an answer.\",\"pull_quote\":\"You do not have to cool the affection to ask what follow-through will look like this week.\",\"deeper_read\":\"It is easy to keep the exchange light once you feel close, especially when the unresolved detail might make things feel heavier. Let the warmth stay in the message, then name one concrete point: when you will talk, meet, or check back in.\",\"watch_for\":\"Notice if you reply warmly but skip the question about timing, plans, or the promised follow-up.\",\"move\":\"Send one affectionate response that also confirms a specific next step before the conversation drifts onward.\"}",
    "parsedResponse": {
      "title": "Warmth, With Details",
      "intro": "A tender message lands well, yet one practical part of the promise still needs an answer.",
      "pull_quote": "You do not have to cool the affection to ask what follow-through will look like this week.",
      "deeper_read": "It is easy to keep the exchange light once you feel close, especially when the unresolved detail might make things feel heavier. Let the warmth stay in the message, then name one concrete point: when you will talk, meet, or check back in.",
      "watch_for": "Notice if you reply warmly but skip the question about timing, plans, or the promised follow-up.",
      "move": "Send one affectionate response that also confirms a specific next step before the conversation drifts onward."
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
      "output_tokens": 156,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1200
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
  "identity": "Gemini × Pig",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for warmth shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you avoid difficulty"
  ],
  "identitySpecificRole": "the person who translates warmth into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after warmth has filled the day.",
  "ordinaryLifeExpression": "A physical change gives warmth somewhere to be practiced at home.",
  "blindSpot": "You may struggle with boundaries.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|home",
      "manifestationArena": "home",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by stability vs change.",
      "perception": "The need for warmth shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you avoid difficulty"
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
    "blindSpot": "You may struggle with boundaries.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without warmth running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room to Reset",
  "intro": "A familiar room asks for one small adjustment when shared warmth starts taking up all the space.",
  "pull_quote": "You do not need a household debate to give yourself a place where the day can settle.",
  "deeper_read": "You may begin by shifting a chair, lamp, basket, or other shared object instead of naming what feels difficult. That practical change matters: when a private corner is physically protected, connection can stay easy without requiring you to remain available throughout the room.",
  "watch_for": "You move an object around the room, then stop short of explaining why the arrangement needs to change.",
  "move": "Set one clear condition for a private corner, such as keeping a chair, surface, or time there undisturbed."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room to Reset\",\"intro\":\"A familiar room asks for one small adjustment when shared warmth starts taking up all the space.\",\"pull_quote\":\"You do not need a household debate to give yourself a place where the day can settle.\",\"deeper_read\":\"You may begin by shifting a chair, lamp, basket, or other shared object instead of naming what feels difficult. That practical change matters: when a private corner is physically protected, connection can stay easy without requiring you to remain available throughout the room.\",\"watch_for\":\"You move an object around the room, then stop short of explaining why the arrangement needs to change.\",\"move\":\"Set one clear condition for a private corner, such as keeping a chair, surface, or time there undisturbed.\"}",
    "parsedResponse": {
      "title": "Room to Reset",
      "intro": "A familiar room asks for one small adjustment when shared warmth starts taking up all the space.",
      "pull_quote": "You do not need a household debate to give yourself a place where the day can settle.",
      "deeper_read": "You may begin by shifting a chair, lamp, basket, or other shared object instead of naming what feels difficult. That practical change matters: when a private corner is physically protected, connection can stay easy without requiring you to remain available throughout the room.",
      "watch_for": "You move an object around the room, then stop short of explaining why the arrangement needs to change.",
      "move": "Set one clear condition for a private corner, such as keeping a chair, surface, or time there undisturbed."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1050,
      "input_tokens_details": {
        "cache_write_tokens": 1047,
        "cached_tokens": 0
      },
      "output_tokens": 159,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1209
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
  "identity": "Gemini × Pig",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by warmth.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you overextend emotionally"
  ],
  "identitySpecificRole": "the friend who uses warmth to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's warmth.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around warmth.",
  "blindSpot": "You make connection easy and concentration harder to protect.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by warmth.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you overextend emotionally"
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
    "blindSpot": "You make connection easy and concentration harder to protect.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the warmth dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "A Clear Invitation",
  "intro": "A friend may smooth over what matters today, while the group quietly assumes who will be available.",
  "pull_quote": "Warmth works better when it names the plan instead of quietly absorbing everyone else's expectations.",
  "deeper_read": "You notice who keeps getting handed the unnamed role: organizer, listener, last-minute helper. Rather than carrying the social tone for everyone, make one invitation concrete; it lets a friend answer honestly without turning the moment into a group-wide reckoning.",
  "watch_for": "Someone says “whatever works” after being asked for a favor, leaving their actual availability unclear.",
  "move": "Text one person a specific plan, including the time and what you can realistically offer."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"A Clear Invitation\",\"intro\":\"A friend may smooth over what matters today, while the group quietly assumes who will be available.\",\"pull_quote\":\"Warmth works better when it names the plan instead of quietly absorbing everyone else's expectations.\",\"deeper_read\":\"You notice who keeps getting handed the unnamed role: organizer, listener, last-minute helper. Rather than carrying the social tone for everyone, make one invitation concrete; it lets a friend answer honestly without turning the moment into a group-wide reckoning.\",\"watch_for\":\"Someone says “whatever works” after being asked for a favor, leaving their actual availability unclear.\",\"move\":\"Text one person a specific plan, including the time and what you can realistically offer.\"}",
    "parsedResponse": {
      "title": "A Clear Invitation",
      "intro": "A friend may smooth over what matters today, while the group quietly assumes who will be available.",
      "pull_quote": "Warmth works better when it names the plan instead of quietly absorbing everyone else's expectations.",
      "deeper_read": "You notice who keeps getting handed the unnamed role: organizer, listener, last-minute helper. Rather than carrying the social tone for everyone, make one invitation concrete; it lets a friend answer honestly without turning the moment into a group-wide reckoning.",
      "watch_for": "Someone says “whatever works” after being asked for a favor, leaving their actual availability unclear.",
      "move": "Text one person a specific plan, including the time and what you can realistically offer."
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
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1209
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
  "identity": "Gemini × Pig",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by warmth meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you avoid difficulty"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to warmth comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what warmth makes tempting.",
  "blindSpot": "You regret the choice when you overextend emotionally.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|money",
      "manifestationArena": "money",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by warmth meets comfort, scarcity, status, and future options.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you avoid difficulty"
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
    "blindSpot": "You regret the choice when you overextend emotionally.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a warmth choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Comfort Receipt",
  "intro": "Before tapping to buy, you notice the small relief comes with one less flexible option later.",
  "pull_quote": "Name what the purchase replaces, and the comfort expense becomes an honest choice instead of an easy escape.",
  "deeper_read": "A warm, easygoing choice can make a comfort expense feel minor, especially when it smooths out the moment. Put the bill, budget, or future plan beside it and compare both costs: the immediate relief and the option you would be giving up.",
  "watch_for": "You keep the item in your cart while reopening your budget or checking an upcoming bill.",
  "move": "Write down one future option the purchase would remove, then decide whether tonight’s relief is worth it."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Comfort Receipt\",\"intro\":\"Before tapping to buy, you notice the small relief comes with one less flexible option later.\",\"pull_quote\":\"Name what the purchase replaces, and the comfort expense becomes an honest choice instead of an easy escape.\",\"deeper_read\":\"A warm, easygoing choice can make a comfort expense feel minor, especially when it smooths out the moment. Put the bill, budget, or future plan beside it and compare both costs: the immediate relief and the option you would be giving up.\",\"watch_for\":\"You keep the item in your cart while reopening your budget or checking an upcoming bill.\",\"move\":\"Write down one future option the purchase would remove, then decide whether tonight’s relief is worth it.\"}",
    "parsedResponse": {
      "title": "The Comfort Receipt",
      "intro": "Before tapping to buy, you notice the small relief comes with one less flexible option later.",
      "pull_quote": "Name what the purchase replaces, and the comfort expense becomes an honest choice instead of an easy escape.",
      "deeper_read": "A warm, easygoing choice can make a comfort expense feel minor, especially when it smooths out the moment. Put the bill, budget, or future plan beside it and compare both costs: the immediate relief and the option you would be giving up.",
      "watch_for": "You keep the item in your cart while reopening your budget or checking an upcoming bill.",
      "move": "Write down one future option the purchase would remove, then decide whether tonight’s relief is worth it."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1058,
      "input_tokens_details": {
        "cache_write_tokens": 1055,
        "cached_tokens": 0
      },
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1213
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
  "identity": "Gemini × Pig",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by warmth active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you avoid difficulty"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from warmth can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when warmth keeps usefulness moving.",
  "blindSpot": "Emotions are open but guided by comfort",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by warmth active after the useful work is done.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you avoid difficulty"
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
    "blindSpot": "Emotions are open but guided by comfort",
    "naturalMove": "Close one open loop, then protect the remaining hour from the warmth maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "After the Last Task",
  "intro": "A quiet hour feels unsettled when one finished chore immediately makes room for another small obligation.",
  "pull_quote": "Rest begins when you stop treating every open minute as a chance to stay useful.",
  "deeper_read": "You may finish a maintenance loop, glance at your phone, and feel pulled to answer, tidy, or check what else needs attention. The useful choice is to let the unfinished task remain unfinished for this hour, so warmth does not keep extending the workday.",
  "watch_for": "After completing one small task, you reach for your phone before deciding whether the quiet hour can stay quiet.",
  "move": "Put the phone out of reach, name the next task for tomorrow, and keep the remaining hour unscheduled."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"After the Last Task\",\"intro\":\"A quiet hour feels unsettled when one finished chore immediately makes room for another small obligation.\",\"pull_quote\":\"Rest begins when you stop treating every open minute as a chance to stay useful.\",\"deeper_read\":\"You may finish a maintenance loop, glance at your phone, and feel pulled to answer, tidy, or check what else needs attention. The useful choice is to let the unfinished task remain unfinished for this hour, so warmth does not keep extending the workday.\",\"watch_for\":\"After completing one small task, you reach for your phone before deciding whether the quiet hour can stay quiet.\",\"move\":\"Put the phone out of reach, name the next task for tomorrow, and keep the remaining hour unscheduled.\"}",
    "parsedResponse": {
      "title": "After the Last Task",
      "intro": "A quiet hour feels unsettled when one finished chore immediately makes room for another small obligation.",
      "pull_quote": "Rest begins when you stop treating every open minute as a chance to stay useful.",
      "deeper_read": "You may finish a maintenance loop, glance at your phone, and feel pulled to answer, tidy, or check what else needs attention. The useful choice is to let the unfinished task remain unfinished for this hour, so warmth does not keep extending the workday.",
      "watch_for": "After completing one small task, you reach for your phone before deciding whether the quiet hour can stay quiet.",
      "move": "Put the phone out of reach, name the next task for tomorrow, and keep the remaining hour unscheduled."
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
      "output_tokens": 159,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1212
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
  "identity": "Gemini × Pig",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for warmth is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you overextend emotionally"
  ],
  "identitySpecificRole": "the contributor who can accept warmth without performing a larger identity",
  "recognition": "Confidence settles when praise names the warmth contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger warmth performance.",
  "blindSpot": "Talks Light, Gives Lots",
  "naturalMove": "Credit the contribution accurately, then stop before you overextend emotionally.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for warmth is tested by praise, attribution, and visible competence.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you overextend emotionally"
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
    "blindSpot": "Talks Light, Gives Lots",
    "naturalMove": "Credit the contribution accurately, then stop before you overextend emotionally.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone credits your work, you can receive it without turning the moment into another performance.",
  "pull_quote": "Name what you contributed, then let the finished result carry the rest of the conversation.",
  "deeper_read": "Praise may put your warmth, competence, or visible contribution in focus today. Rather than brushing it off as luck or adding extra reassurance to keep things easy, state your part plainly and allow the acknowledgment to end there.",
  "watch_for": "You may answer a compliment with a quick joke, a disclaimer, or an offer to do more.",
  "move": "Say “thank you,” name one specific contribution, and return your attention to the next task."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone credits your work, you can receive it without turning the moment into another performance.\",\"pull_quote\":\"Name what you contributed, then let the finished result carry the rest of the conversation.\",\"deeper_read\":\"Praise may put your warmth, competence, or visible contribution in focus today. Rather than brushing it off as luck or adding extra reassurance to keep things easy, state your part plainly and allow the acknowledgment to end there.\",\"watch_for\":\"You may answer a compliment with a quick joke, a disclaimer, or an offer to do more.\",\"move\":\"Say “thank you,” name one specific contribution, and return your attention to the next task.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone credits your work, you can receive it without turning the moment into another performance.",
      "pull_quote": "Name what you contributed, then let the finished result carry the rest of the conversation.",
      "deeper_read": "Praise may put your warmth, competence, or visible contribution in focus today. Rather than brushing it off as luck or adding extra reassurance to keep things easy, state your part plainly and allow the acknowledgment to end there.",
      "watch_for": "You may answer a compliment with a quick joke, a disclaimer, or an offer to do more.",
      "move": "Say “thank you,” name one specific contribution, and return your attention to the next task."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1040,
      "input_tokens_details": {
        "cache_write_tokens": 1037,
        "cached_tokens": 0
      },
      "output_tokens": 146,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1186
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
  "identity": "Gemini × Pig",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by warmth is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you avoid difficulty"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as warmth reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a warmth working style.",
  "blindSpot": "You release the work by stoping moving the exchange to avoid the weight of it.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by warmth is reducing friction or preserving confinement.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you avoid difficulty"
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
    "blindSpot": "You release the work by stoping moving the exchange to avoid the weight of it.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this warmth rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Keep the Useful Part",
  "intro": "A familiar routine feels cramped today, especially where one repeated step keeps creating unnecessary rework.",
  "pull_quote": "You do not need to abandon the routine; you need to stop sidestepping the part that makes it heavier.",
  "deeper_read": "Notice where you make the process friendlier, lighter, or easier to share, then ask whether that actually reduces friction. If you keep rearranging the sequence to avoid one awkward exchange or task, the routine starts serving the avoidance rather than the result.",
  "watch_for": "You may reorder a recurring task again instead of naming the step that keeps sending work back around.",
  "move": "Change one repeated step before the next run, and keep the rest of the schedule intact long enough to compare."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Keep the Useful Part\",\"intro\":\"A familiar routine feels cramped today, especially where one repeated step keeps creating unnecessary rework.\",\"pull_quote\":\"You do not need to abandon the routine; you need to stop sidestepping the part that makes it heavier.\",\"deeper_read\":\"Notice where you make the process friendlier, lighter, or easier to share, then ask whether that actually reduces friction. If you keep rearranging the sequence to avoid one awkward exchange or task, the routine starts serving the avoidance rather than the result.\",\"watch_for\":\"You may reorder a recurring task again instead of naming the step that keeps sending work back around.\",\"move\":\"Change one repeated step before the next run, and keep the rest of the schedule intact long enough to compare.\"}",
    "parsedResponse": {
      "title": "Keep the Useful Part",
      "intro": "A familiar routine feels cramped today, especially where one repeated step keeps creating unnecessary rework.",
      "pull_quote": "You do not need to abandon the routine; you need to stop sidestepping the part that makes it heavier.",
      "deeper_read": "Notice where you make the process friendlier, lighter, or easier to share, then ask whether that actually reduces friction. If you keep rearranging the sequence to avoid one awkward exchange or task, the routine starts serving the avoidance rather than the result.",
      "watch_for": "You may reorder a recurring task again instead of naming the step that keeps sending work back around.",
      "move": "Change one repeated step before the next run, and keep the rest of the schedule intact long enough to compare."
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
      "output_tokens": 162,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1216
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
  "identity": "Gemini × Pig",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The indulgent response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you overextend emotionally"
  ],
  "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against indulgent is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before indulgent takes over.",
  "blindSpot": "You may decide from indulgent instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses indulgent.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by directness vs patience.",
      "perception": "The indulgent response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you overextend emotionally"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against indulgent is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before indulgent takes over.",
    "blindSpot": "You may decide from indulgent instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses indulgent.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Shift",
  "intro": "A small disagreement asks for less smoothing over and more attention to the moment the tone changed.",
  "pull_quote": "The repair starts when you describe the impact without deciding what the other person meant.",
  "deeper_read": "You may be tempted to keep the exchange easy by stepping around the avoided point. Instead, separate what was said or done from the motive you are assigning, then name one condition that would let the conversation continue without asking you to overextend.",
  "watch_for": "Notice whether you soften the point after a tone shift or start explaining the other person's intent.",
  "move": "State the observable change and require a direct response before you keep repairing the exchange."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Keep It Specific\",\"intro\":\"A small disagreement gets clearer when you name the tone shift without assigning a reason for it.\",\"pull_quote\":\"You do not need to soften the point; you need to keep it tied to what actually happened.\",\"deeper_read\":\"You may be tempted to make the exchange easy again before the avoided point is addressed. Instead, separate the impact from the motive you are assuming: name the comment or tone shift, say what changed for you, and set one condition for repair.\",\"watch_for\":\"Notice if you start filling the silence with reassurance before the other person responds to the specific issue.\",\"move\":\"Say, “When the conversation shifted there, I pulled back; I need us to address that directly before continuing.”\"}",
    "parsedResponse": {
      "title": "Keep It Specific",
      "intro": "A small disagreement gets clearer when you name the tone shift without assigning a reason for it.",
      "pull_quote": "You do not need to soften the point; you need to keep it tied to what actually happened.",
      "deeper_read": "You may be tempted to make the exchange easy again before the avoided point is addressed. Instead, separate the impact from the motive you are assuming: name the comment or tone shift, say what changed for you, and set one condition for repair.",
      "watch_for": "Notice if you start filling the silence with reassurance before the other person responds to the specific issue.",
      "move": "Say, “When the conversation shifted there, I pulled back; I need us to address that directly before continuing.”"
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
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1223
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Shift\",\"intro\":\"A small disagreement asks for less smoothing over and more attention to the moment the tone changed.\",\"pull_quote\":\"The repair starts when you describe the impact without deciding what the other person meant.\",\"deeper_read\":\"You may be tempted to keep the exchange easy by stepping around the avoided point. Instead, separate what was said or done from the motive you are assigning, then name one condition that would let the conversation continue without asking you to overextend.\",\"watch_for\":\"Notice whether you soften the point after a tone shift or start explaining the other person's intent.\",\"move\":\"State the observable change and require a direct response before you keep repairing the exchange.\"}",
    "parsedResponse": {
      "title": "Name the Shift",
      "intro": "A small disagreement asks for less smoothing over and more attention to the moment the tone changed.",
      "pull_quote": "The repair starts when you describe the impact without deciding what the other person meant.",
      "deeper_read": "You may be tempted to keep the exchange easy by stepping around the avoided point. Instead, separate what was said or done from the motive you are assigning, then name one condition that would let the conversation continue without asking you to overextend.",
      "watch_for": "Notice whether you soften the point after a tone shift or start explaining the other person's intent.",
      "move": "State the observable change and require a direct response before you keep repairing the exchange."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1199,
      "input_tokens_details": {
        "cache_write_tokens": 1196,
        "cached_tokens": 0
      },
      "output_tokens": 557,
      "output_tokens_details": {
        "reasoning_tokens": 410
      },
      "total_tokens": 1756
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
  "identity": "Gemini × Pig",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by warmth competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you avoid difficulty"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects warmth and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for warmth.",
  "blindSpot": "You delay when you avoid difficulty.",
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
    "signPair": "Gemini × Pig",
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
      "manifestationKey": "Gemini × Pig|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You make connection easy and concentration harder to protect. Growth begins when you stop moving the exchange to avoid the weight of it. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by warmth competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with open, expressive, and easygoing. Then you create easy connection.",
      "pressureOrGrowth": "Under pressure, you first avoid difficulty.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you avoid difficulty"
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
    "blindSpot": "You delay when you avoid difficulty.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about warmth.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Departure",
  "intro": "An appealing offer may be worth exploring today, but you do not need to abandon what already works.",
  "pull_quote": "Let the opening stay warm while you ask for enough evidence to make its risk concrete.",
  "deeper_read": "You may first smooth over the hard part of an offer—timing, proof, or what you would leave behind—because keeping the exchange easy is familiar. Instead, suggest a reversible test with a clear end date and one observable result; it lets you meet the possibility without treating uncertainty as settled.",
  "watch_for": "Watch for yourself postponing the question about timing or proof so the offer can remain pleasant.",
  "move": "Propose a small trial, name its end date, and decide which result would justify a fuller conversation."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An appealing offer may be worth exploring today, but you do not need to abandon what already works.\",\"pull_quote\":\"Let the opening stay warm while you ask for enough evidence to make its risk concrete.\",\"deeper_read\":\"You may first smooth over the hard part of an offer—timing, proof, or what you would leave behind—because keeping the exchange easy is familiar. Instead, suggest a reversible test with a clear end date and one observable result; it lets you meet the possibility without treating uncertainty as settled.\",\"watch_for\":\"Watch for yourself postponing the question about timing or proof so the offer can remain pleasant.\",\"move\":\"Propose a small trial, name its end date, and decide which result would justify a fuller conversation.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An appealing offer may be worth exploring today, but you do not need to abandon what already works.",
      "pull_quote": "Let the opening stay warm while you ask for enough evidence to make its risk concrete.",
      "deeper_read": "You may first smooth over the hard part of an offer—timing, proof, or what you would leave behind—because keeping the exchange easy is familiar. Instead, suggest a reversible test with a clear end date and one observable result; it lets you meet the possibility without treating uncertainty as settled.",
      "watch_for": "Watch for yourself postponing the question about timing or proof so the offer can remain pleasant.",
      "move": "Propose a small trial, name its end date, and decide which result would justify a fuller conversation."
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
      "output_tokens": 648,
      "output_tokens_details": {
        "reasoning_tokens": 481
      },
      "total_tokens": 1708
    }
  }
]
```
