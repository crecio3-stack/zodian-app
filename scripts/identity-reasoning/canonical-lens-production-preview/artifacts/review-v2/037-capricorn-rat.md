# 037 · Capricorn × Rat

Status: complete
Source: Resources/archetypes.json#capricorn-rat
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
  "identity": "Capricorn × Rat",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You build progress quietly. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you hold intentions too tightly",
    "uses you see opportunities early to make one standard visible before you trust slowly"
  ],
  "identitySpecificRole": "the builder who turns works through intent and efficiency into clear ownership",
  "recognition": "The work improves when the planned result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes planned observable before ownership is finalized.",
  "blindSpot": "You may trust slowly after the work is already good enough.",
  "naturalMove": "Clarify one owner and use planned as the visible standard.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|work",
      "manifestationArena": "work",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by speaking up vs waiting.",
      "perception": "You build progress quietly. becomes visible around ownership and execution.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "names who owns the next handoff before you hold intentions too tightly",
        "uses you see opportunities early to make one standard visible before you trust slowly"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the builder who turns works through intent and efficiency into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the planned result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes planned observable before ownership is finalized.",
    "blindSpot": "You may trust slowly after the work is already good enough.",
    "naturalMove": "Clarify one owner and use planned as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Ownership Visible",
  "intro": "In a meeting, the quiet signal is that the handoff still lacks a named owner.",
  "pull_quote": "A useful plan becomes easier to trust when its next responsibility has a visible owner.",
  "deeper_read": "You may have already mapped the efficient path and assumed the work will carry itself through the deadline. Before the group moves on, naming who takes the next handoff turns your careful planning into a standard others can use, rather than something they have to infer.",
  "watch_for": "Watch for the moment everyone nods at the deadline without assigning the next handoff.",
  "move": "Name one owner for the handoff and state the finished standard before the meeting ends."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In today’s meeting, the quiet gap is not the plan itself but who carries it next.\",\"pull_quote\":\"A good standard becomes useful when someone can point to the person responsible for meeting it.\",\"deeper_read\":\"You may already see the cleanest route to the deadline and assume the handoff will settle itself. Before the group moves on, name the owner and the standard they are carrying; that small interruption keeps careful work from becoming an unclaimed task.\",\"watch_for\":\"Someone summarizes the next step without saying who will send, review, or approve it.\",\"move\":\"Say, “Who owns this handoff, and what does finished look like by the deadline?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In today’s meeting, the quiet gap is not the plan itself but who carries it next.",
      "pull_quote": "A good standard becomes useful when someone can point to the person responsible for meeting it.",
      "deeper_read": "You may already see the cleanest route to the deadline and assume the handoff will settle itself. Before the group moves on, name the owner and the standard they are carrying; that small interruption keeps careful work from becoming an unclaimed task.",
      "watch_for": "Someone summarizes the next step without saying who will send, review, or approve it.",
      "move": "Say, “Who owns this handoff, and what does finished look like by the deadline?”"
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
      "output_tokens": 151,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1204
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Make Ownership Visible\",\"intro\":\"In a meeting, the quiet signal is that the handoff still lacks a named owner.\",\"pull_quote\":\"A useful plan becomes easier to trust when its next responsibility has a visible owner.\",\"deeper_read\":\"You may have already mapped the efficient path and assumed the work will carry itself through the deadline. Before the group moves on, naming who takes the next handoff turns your careful planning into a standard others can use, rather than something they have to infer.\",\"watch_for\":\"Watch for the moment everyone nods at the deadline without assigning the next handoff.\",\"move\":\"Name one owner for the handoff and state the finished standard before the meeting ends.\"}",
    "parsedResponse": {
      "title": "Make Ownership Visible",
      "intro": "In a meeting, the quiet signal is that the handoff still lacks a named owner.",
      "pull_quote": "A useful plan becomes easier to trust when its next responsibility has a visible owner.",
      "deeper_read": "You may have already mapped the efficient path and assumed the work will carry itself through the deadline. Before the group moves on, naming who takes the next handoff turns your careful planning into a standard others can use, rather than something they have to infer.",
      "watch_for": "Watch for the moment everyone nods at the deadline without assigning the next handoff.",
      "move": "Name one owner for the handoff and state the finished standard before the meeting ends."
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
      "output_tokens": 586,
      "output_tokens_details": {
        "reasoning_tokens": 436
      },
      "total_tokens": 1769
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
  "identity": "Capricorn × Rat",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings planned to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you trust slowly"
  ],
  "identitySpecificRole": "the partner who turns planned into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking planned to disappear.",
  "ordinaryLifeExpression": "Evidence of planned becomes the test beneath a reassuring message.",
  "blindSpot": "You may trust slowly after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning planned.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|love",
      "manifestationArena": "love",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by trust vs caution.",
      "perception": "The identity brings planned to closeness, where promises and pacing are tested.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you trust slowly"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns planned into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking planned to disappear.",
    "ordinaryLifeExpression": "Evidence of planned becomes the test beneath a reassuring message.",
    "blindSpot": "You may trust slowly after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning planned.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Small Detail",
  "intro": "A tender message lands well, but one unanswered practical detail keeps you from fully settling into it.",
  "pull_quote": "You do not need certainty; you need one promise to become visible in an ordinary week.",
  "deeper_read": "You are likely to read reassurance through follow-through, not just affection. Rather than holding the whole exchange at a distance, let the plan stay simple: name the detail that remains open and see whether it is handled without making closeness feel like a test.",
  "watch_for": "You may reread a warm message while waiting for them to specify when, where, or how.",
  "move": "Reply with one concrete option for the unresolved plan, then leave room for their answer."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Small Detail\",\"intro\":\"A tender message lands well, but one unanswered practical detail keeps you from fully settling into it.\",\"pull_quote\":\"You do not need certainty; you need one promise to become visible in an ordinary week.\",\"deeper_read\":\"You are likely to read reassurance through follow-through, not just affection. Rather than holding the whole exchange at a distance, let the plan stay simple: name the detail that remains open and see whether it is handled without making closeness feel like a test.\",\"watch_for\":\"You may reread a warm message while waiting for them to specify when, where, or how.\",\"move\":\"Reply with one concrete option for the unresolved plan, then leave room for their answer.\"}",
    "parsedResponse": {
      "title": "The Small Detail",
      "intro": "A tender message lands well, but one unanswered practical detail keeps you from fully settling into it.",
      "pull_quote": "You do not need certainty; you need one promise to become visible in an ordinary week.",
      "deeper_read": "You are likely to read reassurance through follow-through, not just affection. Rather than holding the whole exchange at a distance, let the plan stay simple: name the detail that remains open and see whether it is handled without making closeness feel like a test.",
      "watch_for": "You may reread a warm message while waiting for them to specify when, where, or how.",
      "move": "Reply with one concrete option for the unresolved plan, then leave room for their answer."
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
      "output_tokens": 154,
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
  "identity": "Capricorn × Rat",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for planned shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you hold intentions too tightly"
  ],
  "identitySpecificRole": "the person who translates planned into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after planned has filled the day.",
  "ordinaryLifeExpression": "A physical change gives planned somewhere to be practiced at home.",
  "blindSpot": "You may keep too much internal.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without planned running the room.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|home",
      "manifestationArena": "home",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by stability vs change.",
      "perception": "The need for planned shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you hold intentions too tightly"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates planned into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after planned has filled the day.",
    "ordinaryLifeExpression": "A physical change gives planned somewhere to be practiced at home.",
    "blindSpot": "You may keep too much internal.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without planned running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room to Reset",
  "intro": "A familiar room asks for a small adjustment when planned routines leave no place to recover.",
  "pull_quote": "You do not need to renegotiate the whole household to make one corner more livable.",
  "deeper_read": "You may start by quietly moving one object rather than raising a larger discussion about shared space. That practical edit matters because it gives recovery a physical place, instead of keeping your intentions contained behind a protected private corner.",
  "watch_for": "Notice yourself shifting a lamp, chair, or stack of belongings before mentioning the room feels crowded.",
  "move": "Clear one shared surface or seat and name its simple use: reading, resting, or leaving things down."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room to Reset\",\"intro\":\"A familiar room asks for a small adjustment when planned routines leave no place to recover.\",\"pull_quote\":\"You do not need to renegotiate the whole household to make one corner more livable.\",\"deeper_read\":\"You may start by quietly moving one object rather than raising a larger discussion about shared space. That practical edit matters because it gives recovery a physical place, instead of keeping your intentions contained behind a protected private corner.\",\"watch_for\":\"Notice yourself shifting a lamp, chair, or stack of belongings before mentioning the room feels crowded.\",\"move\":\"Clear one shared surface or seat and name its simple use: reading, resting, or leaving things down.\"}",
    "parsedResponse": {
      "title": "Room to Reset",
      "intro": "A familiar room asks for a small adjustment when planned routines leave no place to recover.",
      "pull_quote": "You do not need to renegotiate the whole household to make one corner more livable.",
      "deeper_read": "You may start by quietly moving one object rather than raising a larger discussion about shared space. That practical edit matters because it gives recovery a physical place, instead of keeping your intentions contained behind a protected private corner.",
      "watch_for": "Notice yourself shifting a lamp, chair, or stack of belongings before mentioning the room feels crowded.",
      "move": "Clear one shared surface or seat and name its simple use: reading, resting, or leaving things down."
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
      "output_tokens": 146,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1200
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
  "identity": "Capricorn × Rat",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by planned.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you trust slowly"
  ],
  "identitySpecificRole": "the friend who uses planned to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's planned.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around planned.",
  "blindSpot": "You calculate each ascent and reveal little about the plan.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the planned dynamic.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by planned.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you trust slowly"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses planned to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's planned.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around planned.",
    "blindSpot": "You calculate each ascent and reveal little about the plan.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the planned dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Clear Invitation",
  "intro": "When a friend smooths things over, you notice who is still carrying the group role nobody discussed.",
  "pull_quote": "Peace holds better when your invitation names the plan instead of leaving everyone to infer availability.",
  "deeper_read": "You tend to calculate the next social adjustment quietly, which can keep the honest part hidden behind a workable tone. Rather than correcting the whole group, make one invitation specific: say who you are asking, what the plan is, and whether the usual favor or role is part of it.",
  "watch_for": "Watch for a friend saying “whatever works” while the same person is assumed to organize everyone.",
  "move": "Ask one friend to join you at a named time, and state that you are not coordinating the rest."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Clear Invitation\",\"intro\":\"When a friend smooths things over, you notice who is still carrying the group role nobody discussed.\",\"pull_quote\":\"Peace holds better when your invitation names the plan instead of leaving everyone to infer availability.\",\"deeper_read\":\"You tend to calculate the next social adjustment quietly, which can keep the honest part hidden behind a workable tone. Rather than correcting the whole group, make one invitation specific: say who you are asking, what the plan is, and whether the usual favor or role is part of it.\",\"watch_for\":\"Watch for a friend saying “whatever works” while the same person is assumed to organize everyone.\",\"move\":\"Ask one friend to join you at a named time, and state that you are not coordinating the rest.\"}",
    "parsedResponse": {
      "title": "The Clear Invitation",
      "intro": "When a friend smooths things over, you notice who is still carrying the group role nobody discussed.",
      "pull_quote": "Peace holds better when your invitation names the plan instead of leaving everyone to infer availability.",
      "deeper_read": "You tend to calculate the next social adjustment quietly, which can keep the honest part hidden behind a workable tone. Rather than correcting the whole group, make one invitation specific: say who you are asking, what the plan is, and whether the usual favor or role is part of it.",
      "watch_for": "Watch for a friend saying “whatever works” while the same person is assumed to organize everyone.",
      "move": "Ask one friend to join you at a named time, and state that you are not coordinating the rest."
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
      "output_tokens": 569,
      "output_tokens_details": {
        "reasoning_tokens": 404
      },
      "total_tokens": 1629
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
  "identity": "Capricorn × Rat",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by planned meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to planned comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what planned makes tempting.",
  "blindSpot": "You regret the choice when you trust slowly.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a planned choice.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|money",
      "manifestationArena": "money",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by planned meets comfort, scarcity, status, and future options.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you hold intentions too tightly"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to planned comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what planned makes tempting.",
    "blindSpot": "You regret the choice when you trust slowly.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a planned choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Honest Price",
  "intro": "Before tapping pay, you weigh the comfort expense against the flexibility it quietly takes from your budget.",
  "pull_quote": "A small relief can be worth it, but only after you name what else that money must stop doing.",
  "deeper_read": "You are good at spotting the tradeoff early: the delivery order, upgrade, or quick fix is not just a price, but a future option reduced. The wry part is that restraint can become its own rigid plan, so let the numbers—not a reflex—decide whether today’s comfort belongs in it.",
  "watch_for": "You reopen your budget or bill total after seeing a tempting convenience purchase in the checkout screen.",
  "move": "Write down one future use for the amount, then choose the purchase only after comparing both plainly."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Honest Price\",\"intro\":\"Before tapping pay, you weigh the comfort expense against the flexibility it quietly takes from your budget.\",\"pull_quote\":\"A small relief can be worth it, but only after you name what else that money must stop doing.\",\"deeper_read\":\"You are good at spotting the tradeoff early: the delivery order, upgrade, or quick fix is not just a price, but a future option reduced. The wry part is that restraint can become its own rigid plan, so let the numbers—not a reflex—decide whether today’s comfort belongs in it.\",\"watch_for\":\"You reopen your budget or bill total after seeing a tempting convenience purchase in the checkout screen.\",\"move\":\"Write down one future use for the amount, then choose the purchase only after comparing both plainly.\"}",
    "parsedResponse": {
      "title": "The Honest Price",
      "intro": "Before tapping pay, you weigh the comfort expense against the flexibility it quietly takes from your budget.",
      "pull_quote": "A small relief can be worth it, but only after you name what else that money must stop doing.",
      "deeper_read": "You are good at spotting the tradeoff early: the delivery order, upgrade, or quick fix is not just a price, but a future option reduced. The wry part is that restraint can become its own rigid plan, so let the numbers—not a reflex—decide whether today’s comfort belongs in it.",
      "watch_for": "You reopen your budget or bill total after seeing a tempting convenience purchase in the checkout screen.",
      "move": "Write down one future use for the amount, then choose the purchase only after comparing both plainly."
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
      "output_tokens": 169,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1229
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
  "identity": "Capricorn × Rat",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by planned active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you hold intentions too tightly"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from planned can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when planned keeps usefulness moving.",
  "blindSpot": "Feelings are processed internally and often filtered through logic before being expressed",
  "naturalMove": "Close one open loop, then protect the remaining hour from the planned maintenance loop.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by planned active after the useful work is done.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you hold intentions too tightly"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from planned can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when planned keeps usefulness moving.",
    "blindSpot": "Feelings are processed internally and often filtered through logic before being expressed",
    "naturalMove": "Close one open loop, then protect the remaining hour from the planned maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Leave It There",
  "intro": "In a quiet hour, the unfinished task can make rest feel like another item requiring a plan.",
  "pull_quote": "You do not need another small task to prove the day was handled responsibly.",
  "deeper_read": "You are quick to spot what still needs maintaining, so ending one loop can immediately reveal another. Tonight, let the phone stay out of reach after you close the first open task; rest works better when it is not asked to justify itself.",
  "watch_for": "After finishing one chore, you reach for your phone to find the next thing needing attention.",
  "move": "Choose a sleep time, silence the phone, and leave the unfinished task exactly where it is."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Leave It There\",\"intro\":\"In a quiet hour, the unfinished task can make rest feel like another item requiring a plan.\",\"pull_quote\":\"You do not need another small task to prove the day was handled responsibly.\",\"deeper_read\":\"You are quick to spot what still needs maintaining, so ending one loop can immediately reveal another. Tonight, let the phone stay out of reach after you close the first open task; rest works better when it is not asked to justify itself.\",\"watch_for\":\"After finishing one chore, you reach for your phone to find the next thing needing attention.\",\"move\":\"Choose a sleep time, silence the phone, and leave the unfinished task exactly where it is.\"}",
    "parsedResponse": {
      "title": "Leave It There",
      "intro": "In a quiet hour, the unfinished task can make rest feel like another item requiring a plan.",
      "pull_quote": "You do not need another small task to prove the day was handled responsibly.",
      "deeper_read": "You are quick to spot what still needs maintaining, so ending one loop can immediately reveal another. Tonight, let the phone stay out of reach after you close the first open task; rest works better when it is not asked to justify itself.",
      "watch_for": "After finishing one chore, you reach for your phone to find the next thing needing attention.",
      "move": "Choose a sleep time, silence the phone, and leave the unfinished task exactly where it is."
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
      "output_tokens": 148,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1209
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
  "identity": "Capricorn × Rat",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for planned is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you trust slowly"
  ],
  "identitySpecificRole": "the contributor who can accept planned without performing a larger identity",
  "recognition": "Confidence settles when praise names the planned contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger planned performance.",
  "blindSpot": "Looks Steady, Stays Slippery",
  "naturalMove": "Credit the contribution accurately, then stop before you trust slowly.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for planned is tested by praise, attribution, and visible competence.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you trust slowly"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept planned without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the planned contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger planned performance.",
    "blindSpot": "Looks Steady, Stays Slippery",
    "naturalMove": "Credit the contribution accurately, then stop before you trust slowly.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your work, you can accept the credit without turning the moment into a performance.",
  "pull_quote": "A clear acknowledgment of what you planned and delivered is enough; you do not need to make it smaller.",
  "deeper_read": "You tend to calculate the route before the result becomes visible, so praise may catch you still holding the plan close. Let the finished work stand, name your contribution plainly, and allow the recognition to end there rather than proving you deserve it again.",
  "watch_for": "Notice if you answer specific praise with “it was nothing” or quickly redirect attention to someone else.",
  "move": "Say “thank you—I put a lot of thought into that,” then return to the next task."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your work, you can accept the credit without turning the moment into a performance.\",\"pull_quote\":\"A clear acknowledgment of what you planned and delivered is enough; you do not need to make it smaller.\",\"deeper_read\":\"You tend to calculate the route before the result becomes visible, so praise may catch you still holding the plan close. Let the finished work stand, name your contribution plainly, and allow the recognition to end there rather than proving you deserve it again.\",\"watch_for\":\"Notice if you answer specific praise with “it was nothing” or quickly redirect attention to someone else.\",\"move\":\"Say “thank you—I put a lot of thought into that,” then return to the next task.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your work, you can accept the credit without turning the moment into a performance.",
      "pull_quote": "A clear acknowledgment of what you planned and delivered is enough; you do not need to make it smaller.",
      "deeper_read": "You tend to calculate the route before the result becomes visible, so praise may catch you still holding the plan close. Let the finished work stand, name your contribution plainly, and allow the recognition to end there rather than proving you deserve it again.",
      "watch_for": "Notice if you answer specific praise with “it was nothing” or quickly redirect attention to someone else.",
      "move": "Say “thank you—I put a lot of thought into that,” then return to the next task."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1042,
      "input_tokens_details": {
        "cache_write_tokens": 1039,
        "cached_tokens": 0
      },
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1200
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
  "identity": "Capricorn × Rat",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by planned is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as planned reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a planned working style.",
  "blindSpot": "You release the work by loosening the grip before duty turns into blindness.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this planned rhythm.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by planned is reducing friction or preserving confinement.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you hold intentions too tightly"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as planned reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a planned working style.",
    "blindSpot": "You release the work by loosening the grip before duty turns into blindness.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this planned rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Adjust the Sequence",
  "intro": "A reliable routine feels irritating today because one repeated step is creating more rework than it prevents.",
  "pull_quote": "Keep the result, not every ritual that once seemed necessary to reach it.",
  "deeper_read": "You are likely to notice the snag before anyone else: the handoff, checklist item, or scheduled task that sends you back through the same work. Rather than tightening your hold on the plan, change its order once and see whether the routine still earns its place.",
  "watch_for": "You mark the same step twice, then pause before automatically repeating the usual sequence.",
  "move": "Swap one recurring task with the step after it, and note what no longer needs correcting."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Adjust the Sequence\",\"intro\":\"A reliable routine feels irritating today because one repeated step is creating more rework than it prevents.\",\"pull_quote\":\"Keep the result, not every ritual that once seemed necessary to reach it.\",\"deeper_read\":\"You are likely to notice the snag before anyone else: the handoff, checklist item, or scheduled task that sends you back through the same work. Rather than tightening your hold on the plan, change its order once and see whether the routine still earns its place.\",\"watch_for\":\"You mark the same step twice, then pause before automatically repeating the usual sequence.\",\"move\":\"Swap one recurring task with the step after it, and note what no longer needs correcting.\"}",
    "parsedResponse": {
      "title": "Adjust the Sequence",
      "intro": "A reliable routine feels irritating today because one repeated step is creating more rework than it prevents.",
      "pull_quote": "Keep the result, not every ritual that once seemed necessary to reach it.",
      "deeper_read": "You are likely to notice the snag before anyone else: the handoff, checklist item, or scheduled task that sends you back through the same work. Rather than tightening your hold on the plan, change its order once and see whether the routine still earns its place.",
      "watch_for": "You mark the same step twice, then pause before automatically repeating the usual sequence.",
      "move": "Swap one recurring task with the step after it, and note what no longer needs correcting."
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
      "output_tokens": 150,
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
  "identity": "Capricorn × Rat",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The slow to open response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you trust slowly"
  ],
  "identitySpecificRole": "the builder who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against slow to open is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before slow to open takes over.",
  "blindSpot": "You may decide from slow to open instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses slow to open.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by directness vs patience.",
      "perception": "The slow to open response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you trust slowly"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the builder who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against slow to open is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before slow to open takes over.",
    "blindSpot": "You may decide from slow to open instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses slow to open.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Repair Specific",
  "intro": "A small disagreement sharpens when you name its impact instead of filling in the other person’s motive.",
  "pull_quote": "You do not need instant trust; you need one clear condition that makes repair visible.",
  "deeper_read": "The tone shift or avoided point may be carrying more weight because you are still deciding how much to reveal. Keep the conversation precise: say what happened, what it changed for you, and the one action that would let you reopen slowly.",
  "watch_for": "Notice if you go quiet after a sharp exchange while privately treating the silence as evidence.",
  "move": "State one repair condition plainly, such as revisiting the avoided point without changing the subject."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Repair Specific\",\"intro\":\"A small disagreement sharpens when you name its impact instead of filling in the other person’s motive.\",\"pull_quote\":\"You do not need instant trust; you need one clear condition that makes repair visible.\",\"deeper_read\":\"The tone shift or avoided point may be carrying more weight because you are still deciding how much to reveal. Keep the conversation precise: say what happened, what it changed for you, and the one action that would let you reopen slowly.\",\"watch_for\":\"Notice if you go quiet after a sharp exchange while privately treating the silence as evidence.\",\"move\":\"State one repair condition plainly, such as revisiting the avoided point without changing the subject.\"}",
    "parsedResponse": {
      "title": "Make Repair Specific",
      "intro": "A small disagreement sharpens when you name its impact instead of filling in the other person’s motive.",
      "pull_quote": "You do not need instant trust; you need one clear condition that makes repair visible.",
      "deeper_read": "The tone shift or avoided point may be carrying more weight because you are still deciding how much to reveal. Keep the conversation precise: say what happened, what it changed for you, and the one action that would let you reopen slowly.",
      "watch_for": "Notice if you go quiet after a sharp exchange while privately treating the silence as evidence.",
      "move": "State one repair condition plainly, such as revisiting the avoided point without changing the subject."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1070,
      "input_tokens_details": {
        "cache_write_tokens": 1067,
        "cached_tokens": 0
      },
      "output_tokens": 148,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1218
    }
  }
]
```

## opportunity

Validator: accepted
Retries: 1

### Manifestation

```json
{
  "identity": "Capricorn × Rat",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by planned competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects planned and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for planned.",
  "blindSpot": "You delay when you hold intentions too tightly.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about planned.",
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
    "signPair": "Capricorn × Rat",
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
      "manifestationKey": "Capricorn × Rat|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You calculate each ascent and reveal little about the plan. Growth begins when you loosen the grip before duty turns into blindness. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by planned competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with calculated, observant, and efficient. Then you see opportunities early.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you hold intentions too tightly"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects planned and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for planned.",
    "blindSpot": "You delay when you hold intentions too tightly.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about planned.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Departure",
  "intro": "An offer looks promising today, but you need a way to test it without abandoning what already works.",
  "pull_quote": "The useful question is not whether the risk disappears, but what small test makes the opening measurable.",
  "deeper_read": "You are likely to ask what evidence would make the opening worth leaving a proven position. That caution becomes useful when it produces a timed, reversible test rather than keeping the offer in review until the timing has passed.",
  "watch_for": "Notice whether you define the evidence needed before treating the offer as worth leaving your proven position.",
  "move": "Set a short deadline and choose the smallest reversible step that can produce evidence."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An offer may look promising today, but you will want evidence before stepping away from what already works.\",\"pull_quote\":\"You do not need to deny the risk; you need a small test that makes it measurable.\",\"deeper_read\":\"Rather than treating the offer as an all-or-nothing leap, set a brief trial, a clear proof point, and a date to review it. That keeps your proven position in view while giving the new opening enough room to show whether its timing and upside hold up.\",\"watch_for\":\"Watch for yourself asking, “What would need to happen for this to be worth leaving my current role?”\",\"move\":\"Propose a reversible two-week test with one measurable result and a specific check-in date.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An offer may look promising today, but you will want evidence before stepping away from what already works.",
      "pull_quote": "You do not need to deny the risk; you need a small test that makes it measurable.",
      "deeper_read": "Rather than treating the offer as an all-or-nothing leap, set a brief trial, a clear proof point, and a date to review it. That keeps your proven position in view while giving the new opening enough room to show whether its timing and upside hold up.",
      "watch_for": "Watch for yourself asking, “What would need to happen for this to be worth leaving my current role?”",
      "move": "Propose a reversible two-week test with one measurable result and a specific check-in date."
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "watch_for must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1065,
      "input_tokens_details": {
        "cache_write_tokens": 1062,
        "cached_tokens": 0
      },
      "output_tokens": 481,
      "output_tokens_details": {
        "reasoning_tokens": 317
      },
      "total_tokens": 1546
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An offer looks promising today, but you need a way to test it without abandoning what already works.\",\"pull_quote\":\"The useful question is not whether the risk disappears, but what small test makes the opening measurable.\",\"deeper_read\":\"You are likely to ask what evidence would make the opening worth leaving a proven position. That caution becomes useful when it produces a timed, reversible test rather than keeping the offer in review until the timing has passed.\",\"watch_for\":\"Notice whether you define the evidence needed before treating the offer as worth leaving your proven position.\",\"move\":\"Set a short deadline and choose the smallest reversible step that can produce evidence.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An offer looks promising today, but you need a way to test it without abandoning what already works.",
      "pull_quote": "The useful question is not whether the risk disappears, but what small test makes the opening measurable.",
      "deeper_read": "You are likely to ask what evidence would make the opening worth leaving a proven position. That caution becomes useful when it produces a timed, reversible test rather than keeping the offer in review until the timing has passed.",
      "watch_for": "Notice whether you define the evidence needed before treating the offer as worth leaving your proven position.",
      "move": "Set a short deadline and choose the smallest reversible step that can produce evidence."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1200,
      "input_tokens_details": {
        "cache_write_tokens": 1197,
        "cached_tokens": 0
      },
      "output_tokens": 618,
      "output_tokens_details": {
        "reasoning_tokens": 473
      },
      "total_tokens": 1818
    }
  }
]
```
