# 060 · Aquarius × Pig

Status: complete
Source: Resources/archetypes.json#aquarius-pig
Retries: 3
QA flags: 3

## Canonical fixture

```json

```

## work

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Aquarius × Pig",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You see potential in situations. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you trust too easily",
    "uses you connect easily with others to make one standard visible before you give without boundaries"
  ],
  "identitySpecificRole": "the challenger who turns works through enthusiasm and connection into clear ownership",
  "recognition": "The work improves when the open result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes open observable before ownership is finalized.",
  "blindSpot": "You may give without boundaries after the work is already good enough.",
  "naturalMove": "Clarify one owner and use open as the visible standard.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|work",
      "manifestationArena": "work",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by speaking up vs waiting.",
      "perception": "You see potential in situations. becomes visible around ownership and execution.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "names who owns the next handoff before you trust too easily",
        "uses you connect easily with others to make one standard visible before you give without boundaries"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the challenger who turns works through enthusiasm and connection into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the open result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes open observable before ownership is finalized.",
    "blindSpot": "You may give without boundaries after the work is already good enough.",
    "naturalMove": "Clarify one owner and use open as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In the meeting, your optimism is most useful when the next handoff has a named owner.",
  "pull_quote": "Connection helps the group move, but ownership keeps a good idea from becoming an open loop.",
  "deeper_read": "You can see what the collaboration could become and make it easier for people to engage. Before that ease turns into another unclaimed task, name who carries the work after the meeting and make the expected standard visible.",
  "watch_for": "Watch for the moment everyone agrees, yet no one says who will handle the next handoff.",
  "move": "Before the meeting ends, assign one owner to the handoff and state what must be ready."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, a promising handoff stays vague until someone says who carries it next.\",\"pull_quote\":\"Connection helps the work move, but ownership keeps your optimism from becoming an open tab.\",\"deeper_read\":\"You can see what the collaboration could become and make it easier for people to engage. Before the group moves on, turn that goodwill into one visible standard: name the owner, the next handoff, and what counts as complete.\",\"watch_for\":\"Someone says, “We’ll handle it,” and the deadline passes without a named person attached.\",\"move\":\"Ask, “Who owns the next handoff, and what should be ready by the deadline?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, a promising handoff stays vague until someone says who carries it next.",
      "pull_quote": "Connection helps the work move, but ownership keeps your optimism from becoming an open tab.",
      "deeper_read": "You can see what the collaboration could become and make it easier for people to engage. Before the group moves on, turn that goodwill into one visible standard: name the owner, the next handoff, and what counts as complete.",
      "watch_for": "Someone says, “We’ll handle it,” and the deadline passes without a named person attached.",
      "move": "Ask, “Who owns the next handoff, and what should be ready by the deadline?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1054,
      "input_tokens_details": {
        "cache_write_tokens": 1051,
        "cached_tokens": 0
      },
      "output_tokens": 149,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1203
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, your optimism is most useful when the next handoff has a named owner.\",\"pull_quote\":\"Connection helps the group move, but ownership keeps a good idea from becoming an open loop.\",\"deeper_read\":\"You can see what the collaboration could become and make it easier for people to engage. Before that ease turns into another unclaimed task, name who carries the work after the meeting and make the expected standard visible.\",\"watch_for\":\"Watch for the moment everyone agrees, yet no one says who will handle the next handoff.\",\"move\":\"Before the meeting ends, assign one owner to the handoff and state what must be ready.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, your optimism is most useful when the next handoff has a named owner.",
      "pull_quote": "Connection helps the group move, but ownership keeps a good idea from becoming an open loop.",
      "deeper_read": "You can see what the collaboration could become and make it easier for people to engage. Before that ease turns into another unclaimed task, name who carries the work after the meeting and make the expected standard visible.",
      "watch_for": "Watch for the moment everyone agrees, yet no one says who will handle the next handoff.",
      "move": "Before the meeting ends, assign one owner to the handoff and state what must be ready."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1184,
      "input_tokens_details": {
        "cache_write_tokens": 1181,
        "cached_tokens": 0
      },
      "output_tokens": 447,
      "output_tokens_details": {
        "reasoning_tokens": 298
      },
      "total_tokens": 1631
    }
  }
]
```

## love

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Aquarius × Pig",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings open to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you give without boundaries"
  ],
  "identitySpecificRole": "the partner who turns open into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking open to disappear.",
  "ordinaryLifeExpression": "Evidence of open becomes the test beneath a reassuring message.",
  "blindSpot": "You may give without boundaries after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning open.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|love",
      "manifestationArena": "love",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by trust vs caution.",
      "perception": "The identity brings open to closeness, where promises and pacing are tested.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you give without boundaries"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns open into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking open to disappear.",
    "ordinaryLifeExpression": "Evidence of open becomes the test beneath a reassuring message.",
    "blindSpot": "You may give without boundaries after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning open.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Warmth With Details",
  "intro": "A tender message can stay open while you ask how its promise will show up.",
  "pull_quote": "You do not need to dim the affection to make the next step concrete.",
  "deeper_read": "The warm exchange matters, but one practical detail remains unanswered beneath it. Rather than treating reassurance as the whole plan, let the affection stand and ask what follow-through looks like during an ordinary week.",
  "watch_for": "A reassuring message arrives without a day, time, or clear plan attached.",
  "move": "Reply warmly and suggest a specific day and time for the promised call."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Warmth, With a Date\",\"intro\":\"A tender message lands well, yet one small plan still needs a shape you can both recognize.\",\"pull_quote\":\"You do not need less openness; you need one promise that can be seen in an ordinary week.\",\"deeper_read\":\"It is easy to let affectionate reassurance stand in for the practical detail, especially when the exchange already feels close. Keep the warmth, then ask what the promise looks like in follow-through: a day, a time, or a simple check-in that does not leave you carrying the plan alone.\",\"watch_for\":\"Notice whether a loving message skips over the unanswered detail about when you will talk or meet.\",\"move\":\"Reply warmly, then name one specific follow-through detail: “Would Thursday evening work for that call?”\"}",
    "parsedResponse": {
      "title": "Warmth, With a Date",
      "intro": "A tender message lands well, yet one small plan still needs a shape you can both recognize.",
      "pull_quote": "You do not need less openness; you need one promise that can be seen in an ordinary week.",
      "deeper_read": "It is easy to let affectionate reassurance stand in for the practical detail, especially when the exchange already feels close. Keep the warmth, then ask what the promise looks like in follow-through: a day, a time, or a simple check-in that does not leave you carrying the plan alone.",
      "watch_for": "Notice whether a loving message skips over the unanswered detail about when you will talk or meet.",
      "move": "Reply warmly, then name one specific follow-through detail: “Would Thursday evening work for that call?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1043,
      "input_tokens_details": {
        "cache_write_tokens": 1040,
        "cached_tokens": 0
      },
      "output_tokens": 167,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1210
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Warmth With Details\",\"intro\":\"A tender message can stay open while you ask how its promise will show up.\",\"pull_quote\":\"You do not need to dim the affection to make the next step concrete.\",\"deeper_read\":\"The warm exchange matters, but one practical detail remains unanswered beneath it. Rather than treating reassurance as the whole plan, let the affection stand and ask what follow-through looks like during an ordinary week.\",\"watch_for\":\"A reassuring message arrives without a day, time, or clear plan attached.\",\"move\":\"Reply warmly and suggest a specific day and time for the promised call.\"}",
    "parsedResponse": {
      "title": "Warmth With Details",
      "intro": "A tender message can stay open while you ask how its promise will show up.",
      "pull_quote": "You do not need to dim the affection to make the next step concrete.",
      "deeper_read": "The warm exchange matters, but one practical detail remains unanswered beneath it. Rather than treating reassurance as the whole plan, let the affection stand and ask what follow-through looks like during an ordinary week.",
      "watch_for": "A reassuring message arrives without a day, time, or clear plan attached.",
      "move": "Reply warmly and suggest a specific day and time for the promised call."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1174,
      "input_tokens_details": {
        "cache_write_tokens": 1171,
        "cached_tokens": 0
      },
      "output_tokens": 307,
      "output_tokens_details": {
        "reasoning_tokens": 176
      },
      "total_tokens": 1481
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
  "identity": "Aquarius × Pig",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for open shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you trust too easily"
  ],
  "identitySpecificRole": "the person who translates open into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after open has filled the day.",
  "ordinaryLifeExpression": "A physical change gives open somewhere to be practiced at home.",
  "blindSpot": "You may get pulled off course.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without open running the room.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|home",
      "manifestationArena": "home",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by stability vs change.",
      "perception": "The need for open shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you trust too easily"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates open into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after open has filled the day.",
    "ordinaryLifeExpression": "A physical change gives open somewhere to be practiced at home.",
    "blindSpot": "You may get pulled off course.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without open running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room to Reset",
  "intro": "A familiar room asks for a small adjustment when shared openness starts taking up your recovery space.",
  "pull_quote": "You do not need to rethink the household; you need one corner that works differently.",
  "deeper_read": "Rather than debating every shared routine, change the placement of one object or redefine one surface. A chair, lamp, basket, or clear section of a table can give you a physical place to land after a day of easy connection without turning the room into a negotiation.",
  "watch_for": "Someone treats the newly cleared corner as available space before checking whether you still need it.",
  "move": "Move one everyday object to mark a private reset spot, then name its purpose plainly at home."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room to Reset\",\"intro\":\"A familiar room asks for a small adjustment when shared openness starts taking up your recovery space.\",\"pull_quote\":\"You do not need to rethink the household; you need one corner that works differently.\",\"deeper_read\":\"Rather than debating every shared routine, change the placement of one object or redefine one surface. A chair, lamp, basket, or clear section of a table can give you a physical place to land after a day of easy connection without turning the room into a negotiation.\",\"watch_for\":\"Someone treats the newly cleared corner as available space before checking whether you still need it.\",\"move\":\"Move one everyday object to mark a private reset spot, then name its purpose plainly at home.\"}",
    "parsedResponse": {
      "title": "Room to Reset",
      "intro": "A familiar room asks for a small adjustment when shared openness starts taking up your recovery space.",
      "pull_quote": "You do not need to rethink the household; you need one corner that works differently.",
      "deeper_read": "Rather than debating every shared routine, change the placement of one object or redefine one surface. A chair, lamp, basket, or clear section of a table can give you a physical place to land after a day of easy connection without turning the room into a negotiation.",
      "watch_for": "Someone treats the newly cleared corner as available space before checking whether you still need it.",
      "move": "Move one everyday object to mark a private reset spot, then name its purpose plainly at home."
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
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1204
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
  "identity": "Aquarius × Pig",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by open.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you give without boundaries"
  ],
  "identitySpecificRole": "the friend who uses open to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's open.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around open.",
  "blindSpot": "You believe in people, ideas, and possibility.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the open dynamic.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by open.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you give without boundaries"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses open to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's open.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around open.",
    "blindSpot": "You believe in people, ideas, and possibility.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the open dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Honestly",
  "intro": "When a friend smooths things over, you notice who is still expected to keep the group open.",
  "pull_quote": "Peace lands differently when the person making room can also say what availability actually looks like.",
  "deeper_read": "You may be quick to assume everyone means well and let the usual flexible friend absorb another favor. Instead of managing the whole social tone, make one invitation that names the plan and your limits; it lets participation be chosen rather than quietly assigned.",
  "watch_for": "A friend says, “Let’s just keep it easy,” while the same person is assumed available for the favor.",
  "move": "Send one person a concrete invitation with a time, plan, and a clear answer about what you can offer."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room Honestly\",\"intro\":\"When a friend smooths things over, you notice who is still expected to keep the group open.\",\"pull_quote\":\"Peace lands differently when the person making room can also say what availability actually looks like.\",\"deeper_read\":\"You may be quick to assume everyone means well and let the usual flexible friend absorb another favor. Instead of managing the whole social tone, make one invitation that names the plan and your limits; it lets participation be chosen rather than quietly assigned.\",\"watch_for\":\"A friend says, “Let’s just keep it easy,” while the same person is assumed available for the favor.\",\"move\":\"Send one person a concrete invitation with a time, plan, and a clear answer about what you can offer.\"}",
    "parsedResponse": {
      "title": "Make Room Honestly",
      "intro": "When a friend smooths things over, you notice who is still expected to keep the group open.",
      "pull_quote": "Peace lands differently when the person making room can also say what availability actually looks like.",
      "deeper_read": "You may be quick to assume everyone means well and let the usual flexible friend absorb another favor. Instead of managing the whole social tone, make one invitation that names the plan and your limits; it lets participation be chosen rather than quietly assigned.",
      "watch_for": "A friend says, “Let’s just keep it easy,” while the same person is assumed available for the favor.",
      "move": "Send one person a concrete invitation with a time, plan, and a clear answer about what you can offer."
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
      "output_tokens": 795,
      "output_tokens_details": {
        "reasoning_tokens": 634
      },
      "total_tokens": 1853
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
  "identity": "Aquarius × Pig",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by open meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you trust too easily"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to open comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what open makes tempting.",
  "blindSpot": "You regret the choice when you give without boundaries.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a open choice.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|money",
      "manifestationArena": "money",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by open meets comfort, scarcity, status, and future options.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you trust too easily"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to open comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what open makes tempting.",
    "blindSpot": "You regret the choice when you give without boundaries.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a open choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Real Price",
  "intro": "At checkout, the small comfort expense looks harmless until you name the flexibility it quietly spends.",
  "pull_quote": "Relief can be worth buying, but only after you include the option it takes off the table.",
  "deeper_read": "You are good at seeing possibility, which can make a quick purchase feel like a friendly yes rather than a trade. Put the bill, budget line, or later plan beside the price; the decision gets more honest when comfort and future room are counted together.",
  "watch_for": "Notice if you defend a comfort purchase before checking what remains for the larger priority.",
  "move": "Before paying, write one future option this purchase preserves or removes, then choose with both prices visible."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Real Price\",\"intro\":\"At checkout, the small comfort expense looks harmless until you name the flexibility it quietly spends.\",\"pull_quote\":\"Relief can be worth buying, but only after you include the option it takes off the table.\",\"deeper_read\":\"You are good at seeing possibility, which can make a quick purchase feel like a friendly yes rather than a trade. Put the bill, budget line, or later plan beside the price; the decision gets more honest when comfort and future room are counted together.\",\"watch_for\":\"Notice if you defend a comfort purchase before checking what remains for the larger priority.\",\"move\":\"Before paying, write one future option this purchase preserves or removes, then choose with both prices visible.\"}",
    "parsedResponse": {
      "title": "The Real Price",
      "intro": "At checkout, the small comfort expense looks harmless until you name the flexibility it quietly spends.",
      "pull_quote": "Relief can be worth buying, but only after you include the option it takes off the table.",
      "deeper_read": "You are good at seeing possibility, which can make a quick purchase feel like a friendly yes rather than a trade. Put the bill, budget line, or later plan beside the price; the decision gets more honest when comfort and future room are counted together.",
      "watch_for": "Notice if you defend a comfort purchase before checking what remains for the larger priority.",
      "move": "Before paying, write one future option this purchase preserves or removes, then choose with both prices visible."
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
      "output_tokens": 154,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1212
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
  "identity": "Aquarius × Pig",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by open active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you trust too easily"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from open can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when open keeps usefulness moving.",
  "blindSpot": "Feelings are open and expressed freely, often without filtering",
  "naturalMove": "Close one open loop, then protect the remaining hour from the open maintenance loop.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by open active after the useful work is done.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you trust too easily"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from open can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when open keeps usefulness moving.",
    "blindSpot": "Feelings are open and expressed freely, often without filtering",
    "naturalMove": "Close one open loop, then protect the remaining hour from the open maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Hour Stays Yours",
  "intro": "After finishing one small maintenance task, you may notice how quickly your quiet hour tries to become another responsibility.",
  "pull_quote": "Rest begins when you stop treating an open task as evidence that you should remain available.",
  "deeper_read": "You can close one loop without scanning for the next one, even if the unfinished task is still visible. Putting your phone away gives the hour a boundary: you are not abandoning what needs doing; you are leaving it for a return that is actually useful.",
  "watch_for": "You finish a chore, reach for your phone, then start listing another small thing to handle.",
  "move": "Choose one clear stopping point, put the phone out of reach, and let the remaining hour stay unassigned."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Hour Stays Yours\",\"intro\":\"After finishing one small maintenance task, you may notice how quickly your quiet hour tries to become another responsibility.\",\"pull_quote\":\"Rest begins when you stop treating an open task as evidence that you should remain available.\",\"deeper_read\":\"You can close one loop without scanning for the next one, even if the unfinished task is still visible. Putting your phone away gives the hour a boundary: you are not abandoning what needs doing; you are leaving it for a return that is actually useful.\",\"watch_for\":\"You finish a chore, reach for your phone, then start listing another small thing to handle.\",\"move\":\"Choose one clear stopping point, put the phone out of reach, and let the remaining hour stay unassigned.\"}",
    "parsedResponse": {
      "title": "The Hour Stays Yours",
      "intro": "After finishing one small maintenance task, you may notice how quickly your quiet hour tries to become another responsibility.",
      "pull_quote": "Rest begins when you stop treating an open task as evidence that you should remain available.",
      "deeper_read": "You can close one loop without scanning for the next one, even if the unfinished task is still visible. Putting your phone away gives the hour a boundary: you are not abandoning what needs doing; you are leaving it for a return that is actually useful.",
      "watch_for": "You finish a chore, reach for your phone, then start listing another small thing to handle.",
      "move": "Choose one clear stopping point, put the phone out of reach, and let the remaining hour stay unassigned."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1056,
      "input_tokens_details": {
        "cache_write_tokens": 1053,
        "cached_tokens": 0
      },
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1217
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
  "identity": "Aquarius × Pig",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for open is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you give without boundaries"
  ],
  "identitySpecificRole": "the contributor who can accept open without performing a larger identity",
  "recognition": "Confidence settles when praise names the open contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger open performance.",
  "blindSpot": "Acts Outside, Lets Slide",
  "naturalMove": "Credit the contribution accurately, then stop before you give without boundaries.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for open is tested by praise, attribution, and visible competence.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you give without boundaries"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept open without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the open contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger open performance.",
    "blindSpot": "Acts Outside, Lets Slide",
    "naturalMove": "Credit the contribution accurately, then stop before you give without boundaries.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
  "pull_quote": "A simple, accurate “thank you” lets the result stay visible without asking you to become more visible.",
  "deeper_read": "The useful part of praise today is its precision: it points to what you contributed, not to a role you now have to keep proving. State your part plainly if needed, then let the finished work carry the rest of the conversation.",
  "watch_for": "Someone credits a specific result, and you start adding luck, disclaimers, or extra offers before they finish.",
  "move": "Say “thank you, I handled that piece,” then return to the next task without volunteering more than requested."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your work, you can accept the credit without turning the moment into a bigger performance.\",\"pull_quote\":\"A simple, accurate “thank you” lets the result stay visible without asking you to become more visible.\",\"deeper_read\":\"The useful part of praise today is its precision: it points to what you contributed, not to a role you now have to keep proving. State your part plainly if needed, then let the finished work carry the rest of the conversation.\",\"watch_for\":\"Someone credits a specific result, and you start adding luck, disclaimers, or extra offers before they finish.\",\"move\":\"Say “thank you, I handled that piece,” then return to the next task without volunteering more than requested.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
      "pull_quote": "A simple, accurate “thank you” lets the result stay visible without asking you to become more visible.",
      "deeper_read": "The useful part of praise today is its precision: it points to what you contributed, not to a role you now have to keep proving. State your part plainly if needed, then let the finished work carry the rest of the conversation.",
      "watch_for": "Someone credits a specific result, and you start adding luck, disclaimers, or extra offers before they finish.",
      "move": "Say “thank you, I handled that piece,” then return to the next task without volunteering more than requested."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1038,
      "input_tokens_details": {
        "cache_write_tokens": 1035,
        "cached_tokens": 0
      },
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1199
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
  "identity": "Aquarius × Pig",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by open is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you trust too easily"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as open reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a open working style.",
  "blindSpot": "You release the work by stoping using distance as proof of clarity.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this open rhythm.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by open is reducing friction or preserving confinement.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you trust too easily"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as open reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a open working style.",
    "blindSpot": "You release the work by stoping using distance as proof of clarity.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this open rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Keep the Useful",
  "intro": "Your usual sequence feels irritating today, especially where one repeated step sends you back to fix something later.",
  "pull_quote": "A routine does not need your loyalty when a small adjustment lets the rest of it work.",
  "deeper_read": "Notice the step that creates the most rework before treating the whole schedule as the problem. Instead of stepping away to get perspective, change that one part of the sequence and see whether the routine becomes easier to inhabit without losing what it reliably delivers.",
  "watch_for": "You may catch yourself pausing at the same task, then reopening it because the first pass creates more work.",
  "move": "Move one recurring task earlier or later today, and keep the version that removes a return trip."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Keep the Useful\",\"intro\":\"Your usual sequence feels irritating today, especially where one repeated step sends you back to fix something later.\",\"pull_quote\":\"A routine does not need your loyalty when a small adjustment lets the rest of it work.\",\"deeper_read\":\"Notice the step that creates the most rework before treating the whole schedule as the problem. Instead of stepping away to get perspective, change that one part of the sequence and see whether the routine becomes easier to inhabit without losing what it reliably delivers.\",\"watch_for\":\"You may catch yourself pausing at the same task, then reopening it because the first pass creates more work.\",\"move\":\"Move one recurring task earlier or later today, and keep the version that removes a return trip.\"}",
    "parsedResponse": {
      "title": "Keep the Useful",
      "intro": "Your usual sequence feels irritating today, especially where one repeated step sends you back to fix something later.",
      "pull_quote": "A routine does not need your loyalty when a small adjustment lets the rest of it work.",
      "deeper_read": "Notice the step that creates the most rework before treating the whole schedule as the problem. Instead of stepping away to get perspective, change that one part of the sequence and see whether the routine becomes easier to inhabit without losing what it reliably delivers.",
      "watch_for": "You may catch yourself pausing at the same task, then reopening it because the first pass creates more work.",
      "move": "Move one recurring task earlier or later today, and keep the version that removes a return trip."
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
      "output_tokens": 619,
      "output_tokens_details": {
        "reasoning_tokens": 460
      },
      "total_tokens": 1670
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
  "identity": "Aquarius × Pig",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The naive response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you give without boundaries"
  ],
  "identitySpecificRole": "the challenger who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against naive is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before naive takes over.",
  "blindSpot": "You may decide from naive instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses naive.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by directness vs patience.",
      "perception": "The naive response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you give without boundaries"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the challenger who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against naive is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before naive takes over.",
    "blindSpot": "You may decide from naive instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses naive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Shift",
  "intro": "One small disagreement sharpens when you name its impact without deciding what the other person meant.",
  "pull_quote": "Precision gives the conversation a place to return before goodwill asks you to overlook the changed tone.",
  "deeper_read": "An avoided point or tone shift can make you want to smooth things over quickly. Instead, separate the observable change from the reason you are assigning to it, then keep the discussion on what would repair that specific impact.",
  "watch_for": "Watch for yourself agreeing to move on while the other person still has not addressed the point you raised.",
  "move": "State the change you noticed and ask for a direct response before you continue the conversation."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement gets clearer when you name its impact without deciding what the other person meant.\",\"pull_quote\":\"You do not need to prove bad intent to ask for one concrete change before continuing.\",\"deeper_read\":\"The tone shift or avoided point may tempt you to fill in the motive and smooth things over quickly. Instead, stay with the evidence: say what was said or left unanswered, how it changed the exchange, and the single repair condition you need before offering more trust.\",\"watch_for\":\"Notice whether you excuse a sharp comment before the other person addresses the specific words used.\",\"move\":\"Say, “That changed the conversation for me; I need you to respond to that point directly.”\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement gets clearer when you name its impact without deciding what the other person meant.",
      "pull_quote": "You do not need to prove bad intent to ask for one concrete change before continuing.",
      "deeper_read": "The tone shift or avoided point may tempt you to fill in the motive and smooth things over quickly. Instead, stay with the evidence: say what was said or left unanswered, how it changed the exchange, and the single repair condition you need before offering more trust.",
      "watch_for": "Notice whether you excuse a sharp comment before the other person addresses the specific words used.",
      "move": "Say, “That changed the conversation for me; I need you to respond to that point directly.”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1059,
      "input_tokens_details": {
        "cache_write_tokens": 1056,
        "cached_tokens": 0
      },
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1214
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Shift\",\"intro\":\"One small disagreement sharpens when you name its impact without deciding what the other person meant.\",\"pull_quote\":\"Precision gives the conversation a place to return before goodwill asks you to overlook the changed tone.\",\"deeper_read\":\"An avoided point or tone shift can make you want to smooth things over quickly. Instead, separate the observable change from the reason you are assigning to it, then keep the discussion on what would repair that specific impact.\",\"watch_for\":\"Watch for yourself agreeing to move on while the other person still has not addressed the point you raised.\",\"move\":\"State the change you noticed and ask for a direct response before you continue the conversation.\"}",
    "parsedResponse": {
      "title": "Name the Shift",
      "intro": "One small disagreement sharpens when you name its impact without deciding what the other person meant.",
      "pull_quote": "Precision gives the conversation a place to return before goodwill asks you to overlook the changed tone.",
      "deeper_read": "An avoided point or tone shift can make you want to smooth things over quickly. Instead, separate the observable change from the reason you are assigning to it, then keep the discussion on what would repair that specific impact.",
      "watch_for": "Watch for yourself agreeing to move on while the other person still has not addressed the point you raised.",
      "move": "State the change you noticed and ask for a direct response before you continue the conversation."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1190,
      "input_tokens_details": {
        "cache_write_tokens": 1187,
        "cached_tokens": 0
      },
      "output_tokens": 639,
      "output_tokens_details": {
        "reasoning_tokens": 492
      },
      "total_tokens": 1829
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
  "identity": "Aquarius × Pig",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by open competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you trust too easily"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects open and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for open.",
  "blindSpot": "You delay when you trust too easily.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about open.",
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
    "signPair": "Aquarius × Pig",
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
      "manifestationKey": "Aquarius × Pig|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You believe in people, ideas, and possibility. Growth begins when you stop using distance as proof of clarity. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by open competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with easygoing, expressive, and optimistic. Then you connect easily with others.",
      "pressureOrGrowth": "Under pressure, you first trust too easily.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you trust too easily"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects open and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for open.",
    "blindSpot": "You delay when you trust too easily.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about open.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Departure",
  "intro": "An attractive offer can stay exciting while you ask what would make leaving your proven position worth it.",
  "pull_quote": "You do not need to dismiss the opening; you need a small test that makes its value visible.",
  "deeper_read": "The useful shift today is from liking the possibility to naming the proof you would need: a result, a timeline, or a low-risk trial. A reversible test lets you stay open without treating confidence as evidence or delay as caution.",
  "watch_for": "Notice if you agree too quickly to an offer before asking what success would look like in practice.",
  "move": "Set a short trial period and one observable result before changing anything about your current position."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An attractive offer can stay exciting while you ask what would make leaving your proven position worth it.\",\"pull_quote\":\"You do not need to dismiss the opening; you need a small test that makes its value visible.\",\"deeper_read\":\"The useful shift today is from liking the possibility to naming the proof you would need: a result, a timeline, or a low-risk trial. A reversible test lets you stay open without treating confidence as evidence or delay as caution.\",\"watch_for\":\"Notice if you agree too quickly to an offer before asking what success would look like in practice.\",\"move\":\"Set a short trial period and one observable result before changing anything about your current position.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An attractive offer can stay exciting while you ask what would make leaving your proven position worth it.",
      "pull_quote": "You do not need to dismiss the opening; you need a small test that makes its value visible.",
      "deeper_read": "The useful shift today is from liking the possibility to naming the proof you would need: a result, a timeline, or a low-risk trial. A reversible test lets you stay open without treating confidence as evidence or delay as caution.",
      "watch_for": "Notice if you agree too quickly to an offer before asking what success would look like in practice.",
      "move": "Set a short trial period and one observable result before changing anything about your current position."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1061,
      "input_tokens_details": {
        "cache_write_tokens": 1058,
        "cached_tokens": 0
      },
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1211
    }
  }
]
```
