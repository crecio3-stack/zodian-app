# 107 · Gemini × Dog

Status: complete
Source: Resources/archetypes.json#gemini-dog
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
  "identity": "Gemini × Dog",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You build trust through honesty. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you overthink situations",
    "uses you speak truth clearly to make one standard visible before you become defensive"
  ],
  "identitySpecificRole": "the explorer who turns thrives in honest environments into clear ownership",
  "recognition": "The work improves when the honest result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes honest observable before ownership is finalized.",
  "blindSpot": "You may become defensive after the work is already good enough.",
  "naturalMove": "Clarify one owner and use honest as the visible standard.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|work",
      "manifestationArena": "work",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by speaking up vs waiting.",
      "perception": "You build trust through honesty. becomes visible around ownership and execution.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "names who owns the next handoff before you overthink situations",
        "uses you speak truth clearly to make one standard visible before you become defensive"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the explorer who turns thrives in honest environments into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the honest result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes honest observable before ownership is finalized.",
    "blindSpot": "You may become defensive after the work is already good enough.",
    "naturalMove": "Clarify one owner and use honest as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "Before the meeting closes, you notice the honest update still lacks a named person for the next handoff.",
  "pull_quote": "A clear result becomes usable when someone can point to who carries it next.",
  "deeper_read": "You tend to read the room quickly, then hesitate while your thoughts multiply around the details. In this collaboration, honesty is not only saying what is unfinished; it is making the standard and the next owner visible before the group shifts topics.",
  "watch_for": "Watch for yourself adding another explanation after the team has already agreed on the work.",
  "move": "Before the meeting ends, name the next owner and define what completion requires by the deadline."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the useful thing may be naming who carries the next step before the conversation drifts onward.\",\"pull_quote\":\"Honesty becomes practical when the next handoff has a name, a deadline, and a visible standard.\",\"deeper_read\":\"You may notice a gap in the collaboration before anyone else says it aloud. Rather than replaying how the group might receive it, state the result plainly, assign the next owner, and make the standard concrete enough that the handoff cannot blur.\",\"watch_for\":\"Someone says, “We’ll handle it,” without naming who will send the final version or when.\",\"move\":\"Ask one direct question: “Who owns this next, and what does complete look like by the deadline?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the useful thing may be naming who carries the next step before the conversation drifts onward.",
      "pull_quote": "Honesty becomes practical when the next handoff has a name, a deadline, and a visible standard.",
      "deeper_read": "You may notice a gap in the collaboration before anyone else says it aloud. Rather than replaying how the group might receive it, state the result plainly, assign the next owner, and make the standard concrete enough that the handoff cannot blur.",
      "watch_for": "Someone says, “We’ll handle it,” without naming who will send the final version or when.",
      "move": "Ask one direct question: “Who owns this next, and what does complete look like by the deadline?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1049,
      "input_tokens_details": {
        "cache_write_tokens": 1046,
        "cached_tokens": 0
      },
      "output_tokens": 164,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1213
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"Before the meeting closes, you notice the honest update still lacks a named person for the next handoff.\",\"pull_quote\":\"A clear result becomes usable when someone can point to who carries it next.\",\"deeper_read\":\"You tend to read the room quickly, then hesitate while your thoughts multiply around the details. In this collaboration, honesty is not only saying what is unfinished; it is making the standard and the next owner visible before the group shifts topics.\",\"watch_for\":\"Watch for yourself adding another explanation after the team has already agreed on the work.\",\"move\":\"Before the meeting ends, name the next owner and define what completion requires by the deadline.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "Before the meeting closes, you notice the honest update still lacks a named person for the next handoff.",
      "pull_quote": "A clear result becomes usable when someone can point to who carries it next.",
      "deeper_read": "You tend to read the room quickly, then hesitate while your thoughts multiply around the details. In this collaboration, honesty is not only saying what is unfinished; it is making the standard and the next owner visible before the group shifts topics.",
      "watch_for": "Watch for yourself adding another explanation after the team has already agreed on the work.",
      "move": "Before the meeting ends, name the next owner and define what completion requires by the deadline."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1181,
      "input_tokens_details": {
        "cache_write_tokens": 1178,
        "cached_tokens": 0
      },
      "output_tokens": 616,
      "output_tokens_details": {
        "reasoning_tokens": 467
      },
      "total_tokens": 1797
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
  "identity": "Gemini × Dog",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings honest to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you become defensive"
  ],
  "identitySpecificRole": "the partner who turns honest into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking honest to disappear.",
  "ordinaryLifeExpression": "Evidence of honest becomes the test beneath a reassuring message.",
  "blindSpot": "You may become defensive after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning honest.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|love",
      "manifestationArena": "love",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by trust vs caution.",
      "perception": "The identity brings honest to closeness, where promises and pacing are tested.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you become defensive"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns honest into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking honest to disappear.",
    "ordinaryLifeExpression": "Evidence of honest becomes the test beneath a reassuring message.",
    "blindSpot": "You may become defensive after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning honest.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Missing Detail",
  "intro": "A tender message lands well, yet one practical part of the promise still has no shape.",
  "pull_quote": "You do not need more reassurance; you need to know what the care looks like on Tuesday.",
  "deeper_read": "You can feel the honesty in the exchange and still pause before trusting its momentum. Rather than letting that pause turn defensive, ask what the plan means in follow-through: a time, a check-in, or the next shared hour.",
  "watch_for": "Notice if you reread an affectionate message while avoiding the unanswered question about when you will meet.",
  "move": "Reply warmly, then name one concrete detail that would make the promise easy to keep."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Missing Detail\",\"intro\":\"A tender message lands well, yet one practical part of the promise still has no shape.\",\"pull_quote\":\"You do not need more reassurance; you need to know what the care looks like on Tuesday.\",\"deeper_read\":\"You can feel the honesty in the exchange and still pause before trusting its momentum. Rather than letting that pause turn defensive, ask what the plan means in follow-through: a time, a check-in, or the next shared hour.\",\"watch_for\":\"Notice if you reread an affectionate message while avoiding the unanswered question about when you will meet.\",\"move\":\"Reply warmly, then name one concrete detail that would make the promise easy to keep.\"}",
    "parsedResponse": {
      "title": "The Missing Detail",
      "intro": "A tender message lands well, yet one practical part of the promise still has no shape.",
      "pull_quote": "You do not need more reassurance; you need to know what the care looks like on Tuesday.",
      "deeper_read": "You can feel the honesty in the exchange and still pause before trusting its momentum. Rather than letting that pause turn defensive, ask what the plan means in follow-through: a time, a check-in, or the next shared hour.",
      "watch_for": "Notice if you reread an affectionate message while avoiding the unanswered question about when you will meet.",
      "move": "Reply warmly, then name one concrete detail that would make the promise easy to keep."
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
      "output_tokens": 148,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1188
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
  "identity": "Gemini × Dog",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for honest shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you overthink situations"
  ],
  "identitySpecificRole": "the person who translates honest into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after honest has filled the day.",
  "ordinaryLifeExpression": "A physical change gives honest somewhere to be practiced at home.",
  "blindSpot": "You may struggle to relax.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without honest running the room.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|home",
      "manifestationArena": "home",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by stability vs change.",
      "perception": "The need for honest shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you overthink situations"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates honest into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after honest has filled the day.",
    "ordinaryLifeExpression": "A physical change gives honest somewhere to be practiced at home.",
    "blindSpot": "You may struggle to relax.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without honest running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room to Settle",
  "intro": "A familiar room may ask for one small adjustment before you try to explain why it feels crowded.",
  "pull_quote": "You do not need to solve the household mood before giving yourself a place to come down.",
  "deeper_read": "You tend to read the situation quickly, then keep turning it over in your head. Today, move one object or reset one shared-space condition first; a chair, lamp, basket, or clear surface can make privacy and recovery practical without turning the room into a discussion.",
  "watch_for": "You pause over a cluttered corner, mentally rehearsing a household conversation instead of touching anything.",
  "move": "Create a private landing spot in the shared room, then state one simple boundary if someone asks about it."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room to Settle\",\"intro\":\"A familiar room may ask for one small adjustment before you try to explain why it feels crowded.\",\"pull_quote\":\"You do not need to solve the household mood before giving yourself a place to come down.\",\"deeper_read\":\"You tend to read the situation quickly, then keep turning it over in your head. Today, move one object or reset one shared-space condition first; a chair, lamp, basket, or clear surface can make privacy and recovery practical without turning the room into a discussion.\",\"watch_for\":\"You pause over a cluttered corner, mentally rehearsing a household conversation instead of touching anything.\",\"move\":\"Create a private landing spot in the shared room, then state one simple boundary if someone asks about it.\"}",
    "parsedResponse": {
      "title": "Room to Settle",
      "intro": "A familiar room may ask for one small adjustment before you try to explain why it feels crowded.",
      "pull_quote": "You do not need to solve the household mood before giving yourself a place to come down.",
      "deeper_read": "You tend to read the situation quickly, then keep turning it over in your head. Today, move one object or reset one shared-space condition first; a chair, lamp, basket, or clear surface can make privacy and recovery practical without turning the room into a discussion.",
      "watch_for": "You pause over a cluttered corner, mentally rehearsing a household conversation instead of touching anything.",
      "move": "Create a private landing spot in the shared room, then state one simple boundary if someone asks about it."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1049,
      "input_tokens_details": {
        "cache_write_tokens": 1046,
        "cached_tokens": 0
      },
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1210
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
  "identity": "Gemini × Dog",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by honest.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you become defensive"
  ],
  "identitySpecificRole": "the friend who uses honest to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's honest.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around honest.",
  "blindSpot": "You understand people quickly and trust them slowly.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the honest dynamic.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by honest.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you become defensive"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses honest to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's honest.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around honest.",
    "blindSpot": "You understand people quickly and trust them slowly.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the honest dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Invitation",
  "intro": "A friend may smooth over the awkward part today, while you notice who keeps carrying the unnamed group role.",
  "pull_quote": "Peace can wait long enough for one clear invitation to show what everyone is actually available for.",
  "deeper_read": "You may understand why someone wants the social tone to stay easy, then spend too long sorting every possible reaction. Instead of managing the whole group, make one direct invitation that includes the honest part: who is needed, for what, and whether they can do it.",
  "watch_for": "Watch for a friend saying “it’s fine” while the same person is assumed to handle the favor again.",
  "move": "Text one person a specific invitation, naming the task and asking plainly whether they are available."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Invitation\",\"intro\":\"A friend may smooth over the awkward part today, while you notice who keeps carrying the unnamed group role.\",\"pull_quote\":\"Peace can wait long enough for one clear invitation to show what everyone is actually available for.\",\"deeper_read\":\"You may understand why someone wants the social tone to stay easy, then spend too long sorting every possible reaction. Instead of managing the whole group, make one direct invitation that includes the honest part: who is needed, for what, and whether they can do it.\",\"watch_for\":\"Watch for a friend saying “it’s fine” while the same person is assumed to handle the favor again.\",\"move\":\"Text one person a specific invitation, naming the task and asking plainly whether they are available.\"}",
    "parsedResponse": {
      "title": "Name the Invitation",
      "intro": "A friend may smooth over the awkward part today, while you notice who keeps carrying the unnamed group role.",
      "pull_quote": "Peace can wait long enough for one clear invitation to show what everyone is actually available for.",
      "deeper_read": "You may understand why someone wants the social tone to stay easy, then spend too long sorting every possible reaction. Instead of managing the whole group, make one direct invitation that includes the honest part: who is needed, for what, and whether they can do it.",
      "watch_for": "Watch for a friend saying “it’s fine” while the same person is assumed to handle the favor again.",
      "move": "Text one person a specific invitation, naming the task and asking plainly whether they are available."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1055,
      "input_tokens_details": {
        "cache_write_tokens": 1052,
        "cached_tokens": 0
      },
      "output_tokens": 669,
      "output_tokens_details": {
        "reasoning_tokens": 506
      },
      "total_tokens": 1724
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
  "identity": "Gemini × Dog",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by honest meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you overthink situations"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to honest comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what honest makes tempting.",
  "blindSpot": "You regret the choice when you become defensive.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a honest choice.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|money",
      "manifestationArena": "money",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by honest meets comfort, scarcity, status, and future options.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you overthink situations"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to honest comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what honest makes tempting.",
    "blindSpot": "You regret the choice when you become defensive.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a honest choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Real Price",
  "intro": "At checkout, the small comfort expense looks simple until you name the flexibility it quietly spends.",
  "pull_quote": "Relief can be worth buying, but it is easier to choose when you include what it postpones.",
  "deeper_read": "You tend to make the tradeoff visible rather than pretending a purchase is either responsible or reckless. Before defending the cost, put the bill, budget, or future option beside it; the honest comparison gives the decision its actual price.",
  "watch_for": "You reopen the cart or banking app, comparing the quick relief with what the money could keep available.",
  "move": "Write down one future option this purchase reduces, then decide whether today’s comfort still earns the cost."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Real Price\",\"intro\":\"At checkout, the small comfort expense looks simple until you name the flexibility it quietly spends.\",\"pull_quote\":\"Relief can be worth buying, but it is easier to choose when you include what it postpones.\",\"deeper_read\":\"You tend to make the tradeoff visible rather than pretending a purchase is either responsible or reckless. Before defending the cost, put the bill, budget, or future option beside it; the honest comparison gives the decision its actual price.\",\"watch_for\":\"You reopen the cart or banking app, comparing the quick relief with what the money could keep available.\",\"move\":\"Write down one future option this purchase reduces, then decide whether today’s comfort still earns the cost.\"}",
    "parsedResponse": {
      "title": "The Real Price",
      "intro": "At checkout, the small comfort expense looks simple until you name the flexibility it quietly spends.",
      "pull_quote": "Relief can be worth buying, but it is easier to choose when you include what it postpones.",
      "deeper_read": "You tend to make the tradeoff visible rather than pretending a purchase is either responsible or reckless. Before defending the cost, put the bill, budget, or future option beside it; the honest comparison gives the decision its actual price.",
      "watch_for": "You reopen the cart or banking app, comparing the quick relief with what the money could keep available.",
      "move": "Write down one future option this purchase reduces, then decide whether today’s comfort still earns the cost."
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
      "output_tokens": 154,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1210
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
  "identity": "Gemini × Dog",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by honest active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you overthink situations"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from honest can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when honest keeps usefulness moving.",
  "blindSpot": "Emotions are tied to trust and truth",
  "naturalMove": "Close one open loop, then protect the remaining hour from the honest maintenance loop.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by honest active after the useful work is done.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you overthink situations"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from honest can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when honest keeps usefulness moving.",
    "blindSpot": "Emotions are tied to trust and truth",
    "naturalMove": "Close one open loop, then protect the remaining hour from the honest maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "After the Last Task",
  "intro": "A quiet hour feels unsettled when you keep finding small maintenance loops to prove the day is handled.",
  "pull_quote": "Rest becomes practical when you stop treating one more useful thing as the price of sleep.",
  "deeper_read": "You understand what still needs attention quickly, so an unfinished task can keep your mind juggling long after the useful work is done. Close one clear loop, then let the feeling of incompletion finish without opening another tab, message, or reminder.",
  "watch_for": "You finish a small task, reach for your phone, and immediately scan for the next thing to fix.",
  "move": "Put the phone away after one deliberate closeout, and keep the remaining hour free of maintenance."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"After the Last Task\",\"intro\":\"A quiet hour feels unsettled when you keep finding small maintenance loops to prove the day is handled.\",\"pull_quote\":\"Rest becomes practical when you stop treating one more useful thing as the price of sleep.\",\"deeper_read\":\"You understand what still needs attention quickly, so an unfinished task can keep your mind juggling long after the useful work is done. Close one clear loop, then let the feeling of incompletion finish without opening another tab, message, or reminder.\",\"watch_for\":\"You finish a small task, reach for your phone, and immediately scan for the next thing to fix.\",\"move\":\"Put the phone away after one deliberate closeout, and keep the remaining hour free of maintenance.\"}",
    "parsedResponse": {
      "title": "After the Last Task",
      "intro": "A quiet hour feels unsettled when you keep finding small maintenance loops to prove the day is handled.",
      "pull_quote": "Rest becomes practical when you stop treating one more useful thing as the price of sleep.",
      "deeper_read": "You understand what still needs attention quickly, so an unfinished task can keep your mind juggling long after the useful work is done. Close one clear loop, then let the feeling of incompletion finish without opening another tab, message, or reminder.",
      "watch_for": "You finish a small task, reach for your phone, and immediately scan for the next thing to fix.",
      "move": "Put the phone away after one deliberate closeout, and keep the remaining hour free of maintenance."
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
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1207
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
  "identity": "Gemini × Dog",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for honest is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you become defensive"
  ],
  "identitySpecificRole": "the contributor who can accept honest without performing a larger identity",
  "recognition": "Confidence settles when praise names the honest contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger honest performance.",
  "blindSpot": "Looks Open, Holds Lines",
  "naturalMove": "Credit the contribution accurately, then stop before you become defensive.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for honest is tested by praise, attribution, and visible competence.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you become defensive"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept honest without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the honest contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger honest performance.",
    "blindSpot": "Looks Open, Holds Lines",
    "naturalMove": "Credit the contribution accurately, then stop before you become defensive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Count",
  "intro": "When someone notices your work, you can name your part without turning the moment into a performance.",
  "pull_quote": "Accepting accurate credit does not require adding disclaimers, jokes, or a case for why it should not matter.",
  "deeper_read": "Praise can make you start sorting through how it was earned, whether it was fully deserved, and what someone might expect next. Let the finished result stand first; a simple acknowledgment keeps the attention on the contribution rather than on defending your right to receive it.",
  "watch_for": "When a colleague credits your result, notice the urge to immediately call it luck or mention every caveat.",
  "move": "Say, “Thank you—I handled that part,” then return to the work without explaining yourself further."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Count\",\"intro\":\"When someone notices your work, you can name your part without turning the moment into a performance.\",\"pull_quote\":\"Accepting accurate credit does not require adding disclaimers, jokes, or a case for why it should not matter.\",\"deeper_read\":\"Praise can make you start sorting through how it was earned, whether it was fully deserved, and what someone might expect next. Let the finished result stand first; a simple acknowledgment keeps the attention on the contribution rather than on defending your right to receive it.\",\"watch_for\":\"When a colleague credits your result, notice the urge to immediately call it luck or mention every caveat.\",\"move\":\"Say, “Thank you—I handled that part,” then return to the work without explaining yourself further.\"}",
    "parsedResponse": {
      "title": "Let It Count",
      "intro": "When someone notices your work, you can name your part without turning the moment into a performance.",
      "pull_quote": "Accepting accurate credit does not require adding disclaimers, jokes, or a case for why it should not matter.",
      "deeper_read": "Praise can make you start sorting through how it was earned, whether it was fully deserved, and what someone might expect next. Let the finished result stand first; a simple acknowledgment keeps the attention on the contribution rather than on defending your right to receive it.",
      "watch_for": "When a colleague credits your result, notice the urge to immediately call it luck or mention every caveat.",
      "move": "Say, “Thank you—I handled that part,” then return to the work without explaining yourself further."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1035,
      "input_tokens_details": {
        "cache_write_tokens": 1032,
        "cached_tokens": 0
      },
      "output_tokens": 163,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1198
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
  "identity": "Gemini × Dog",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by honest is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you overthink situations"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as honest reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a honest working style.",
  "blindSpot": "You release the work by leting the feeling finish before the mind starts juggling.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this honest rhythm.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by honest is reducing friction or preserving confinement.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you overthink situations"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as honest reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a honest working style.",
    "blindSpot": "You release the work by leting the feeling finish before the mind starts juggling.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this honest rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Keep What Works",
  "intro": "A dependable part of your routine starts to grate when it creates more handling than the result requires.",
  "pull_quote": "You do not need to abandon the routine; you need to stop defending its most frustrating step.",
  "deeper_read": "Notice where you mark, repeat, or correct the same part of the sequence. Before your mind turns that irritation into a larger case against the whole schedule, let the immediate reaction land and test whether one direct adjustment makes the work cleaner.",
  "watch_for": "You may catch yourself redoing a familiar step or pausing over the same unnecessary check.",
  "move": "Change the order of one repeated task today, then keep the version that reduces rework."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Keep What Works\",\"intro\":\"A dependable part of your routine starts to grate when it creates more handling than the result requires.\",\"pull_quote\":\"You do not need to abandon the routine; you need to stop defending its most frustrating step.\",\"deeper_read\":\"Notice where you mark, repeat, or correct the same part of the sequence. Before your mind turns that irritation into a larger case against the whole schedule, let the immediate reaction land and test whether one direct adjustment makes the work cleaner.\",\"watch_for\":\"You may catch yourself redoing a familiar step or pausing over the same unnecessary check.\",\"move\":\"Change the order of one repeated task today, then keep the version that reduces rework.\"}",
    "parsedResponse": {
      "title": "Keep What Works",
      "intro": "A dependable part of your routine starts to grate when it creates more handling than the result requires.",
      "pull_quote": "You do not need to abandon the routine; you need to stop defending its most frustrating step.",
      "deeper_read": "Notice where you mark, repeat, or correct the same part of the sequence. Before your mind turns that irritation into a larger case against the whole schedule, let the immediate reaction land and test whether one direct adjustment makes the work cleaner.",
      "watch_for": "You may catch yourself redoing a familiar step or pausing over the same unnecessary check.",
      "move": "Change the order of one repeated task today, then keep the version that reduces rework."
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
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1202
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
  "identity": "Gemini × Dog",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The defensiveness response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you become defensive"
  ],
  "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against defensiveness is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before defensiveness takes over.",
  "blindSpot": "You may decide from defensiveness instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses defensiveness.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by directness vs patience.",
      "perception": "The defensiveness response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you become defensive"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against defensiveness is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before defensiveness takes over.",
    "blindSpot": "You may decide from defensiveness instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses defensiveness.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Repairable",
  "intro": "A small disagreement sharpens when you name the tone shift without assigning a motive to it.",
  "pull_quote": "You do not need to solve their intention before asking for a different way to continue.",
  "deeper_read": "The avoided point may be less important than the moment the exchange changed texture: a clipped reply, a raised voice, a piece of evidence dismissed too quickly. Separate that impact from what you think they meant, then make the next step concrete enough to prevent defensiveness from taking over.",
  "watch_for": "Notice yourself building a case from one message or tone change before the other person has responded.",
  "move": "Say what happened, name its impact, and ask for one repair condition before continuing the conversation."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you name the tone shift without assigning a motive to it.\",\"pull_quote\":\"You do not need to solve their intention before asking for a different way to continue.\",\"deeper_read\":\"The avoided point may be less important than the moment the exchange changed texture: a clipped reply, a raised voice, a piece of evidence dismissed too quickly. Separate that impact from what you think they meant, then make the next step concrete enough to prevent defensiveness from taking over.\",\"watch_for\":\"Notice yourself building a case from one message or tone change before the other person has responded.\",\"move\":\"Say what happened, name its impact, and ask for one repair condition before continuing the conversation.\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you name the tone shift without assigning a motive to it.",
      "pull_quote": "You do not need to solve their intention before asking for a different way to continue.",
      "deeper_read": "The avoided point may be less important than the moment the exchange changed texture: a clipped reply, a raised voice, a piece of evidence dismissed too quickly. Separate that impact from what you think they meant, then make the next step concrete enough to prevent defensiveness from taking over.",
      "watch_for": "Notice yourself building a case from one message or tone change before the other person has responded.",
      "move": "Say what happened, name its impact, and ask for one repair condition before continuing the conversation."
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
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1220
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
  "identity": "Gemini × Dog",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by honest competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you overthink situations"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects honest and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for honest.",
  "blindSpot": "You delay when you overthink situations.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about honest.",
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
    "signPair": "Gemini × Dog",
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
      "manifestationKey": "Gemini × Dog|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You understand people quickly and trust them slowly. Growth begins when you let the feeling finish before the mind starts juggling. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by honest competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with direct, loyal, and expressive. Then you speak truth clearly.",
      "pressureOrGrowth": "Under pressure, you first overthink situations.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you overthink situations"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects honest and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for honest.",
    "blindSpot": "You delay when you overthink situations.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about honest.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Departure",
  "intro": "An appealing offer may not need an immediate yes; it needs one honest, limited way to test it.",
  "pull_quote": "You do not have to abandon the proven position to find out whether this opening can hold weight.",
  "deeper_read": "You may start by asking what evidence would make the offer worth leaving something dependable. That question is useful until it becomes another loop; set a timing choice, define one proof point, and let a reversible test show you more than further analysis can.",
  "watch_for": "Notice if you reopen the same offer details after you have already named the evidence you need.",
  "move": "Ask for a short trial, clear milestone, or concrete next step that produces useful proof this week."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An appealing offer may not need an immediate yes; it needs one honest, limited way to test it.\",\"pull_quote\":\"You do not have to abandon the proven position to find out whether this opening can hold weight.\",\"deeper_read\":\"You may start by asking what evidence would make the offer worth leaving something dependable. That question is useful until it becomes another loop; set a timing choice, define one proof point, and let a reversible test show you more than further analysis can.\",\"watch_for\":\"Notice if you reopen the same offer details after you have already named the evidence you need.\",\"move\":\"Ask for a short trial, clear milestone, or concrete next step that produces useful proof this week.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An appealing offer may not need an immediate yes; it needs one honest, limited way to test it.",
      "pull_quote": "You do not have to abandon the proven position to find out whether this opening can hold weight.",
      "deeper_read": "You may start by asking what evidence would make the offer worth leaving something dependable. That question is useful until it becomes another loop; set a timing choice, define one proof point, and let a reversible test show you more than further analysis can.",
      "watch_for": "Notice if you reopen the same offer details after you have already named the evidence you need.",
      "move": "Ask for a short trial, clear milestone, or concrete next step that produces useful proof this week."
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
      "output_tokens": 156,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1216
    }
  }
]
```
