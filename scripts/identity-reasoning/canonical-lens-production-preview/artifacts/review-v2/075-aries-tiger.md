# 075 · Aries × Tiger

Status: complete
Source: Resources/archetypes.json#aries-tiger
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
  "identity": "Aries × Tiger",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You bring energy into stagnant situations. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you jump before thinking",
    "uses you act without fear of failure to make one standard visible before you escalate situations quickly"
  ],
  "identitySpecificRole": "the initiator who turns works through energy and instinct into clear ownership",
  "recognition": "The work improves when the bold result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes bold observable before ownership is finalized.",
  "blindSpot": "You may escalate situations quickly after the work is already good enough.",
  "naturalMove": "Clarify one owner and use bold as the visible standard.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|work",
      "manifestationArena": "work",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by speaking up vs waiting.",
      "perception": "You bring energy into stagnant situations. becomes visible around ownership and execution.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "names who owns the next handoff before you jump before thinking",
        "uses you act without fear of failure to make one standard visible before you escalate situations quickly"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the initiator who turns works through energy and instinct into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the bold result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes bold observable before ownership is finalized.",
    "blindSpot": "You may escalate situations quickly after the work is already good enough.",
    "naturalMove": "Clarify one owner and use bold as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In a meeting that starts to drift, you notice the next handoff is still unnamed.",
  "pull_quote": "Your momentum helps most when everyone can point to the person carrying the next step.",
  "deeper_read": "You may be ready to push the work forward as soon as a workable standard appears. Instead of adding force to the discussion, make the result usable by tying it to one person’s responsibility before the group turns to the next item.",
  "watch_for": "Watch for yourself volunteering a solution while no one has been assigned the follow-through.",
  "move": "Before leaving the meeting, identify the owner of the next handoff and its deadline."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a work meeting, your push to get things moving lands better when the next owner is named.\",\"pull_quote\":\"Make the standard visible, then give it a person’s name before adding more urgency.\",\"deeper_read\":\"You may spot the stalled handoff and instinctively raise the stakes to break the pause. The useful interruption is simpler: say what needs to happen, who carries it next, and what “done” looks like before the conversation moves on.\",\"watch_for\":\"Notice whether you add another forceful point after someone has already agreed to take the deadline.\",\"move\":\"Before leaving the meeting, ask one direct question: “Who owns the next handoff, and by when?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a work meeting, your push to get things moving lands better when the next owner is named.",
      "pull_quote": "Make the standard visible, then give it a person’s name before adding more urgency.",
      "deeper_read": "You may spot the stalled handoff and instinctively raise the stakes to break the pause. The useful interruption is simpler: say what needs to happen, who carries it next, and what “done” looks like before the conversation moves on.",
      "watch_for": "Notice whether you add another forceful point after someone has already agreed to take the deadline.",
      "move": "Before leaving the meeting, ask one direct question: “Who owns the next handoff, and by when?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
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
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a meeting that starts to drift, you notice the next handoff is still unnamed.\",\"pull_quote\":\"Your momentum helps most when everyone can point to the person carrying the next step.\",\"deeper_read\":\"You may be ready to push the work forward as soon as a workable standard appears. Instead of adding force to the discussion, make the result usable by tying it to one person’s responsibility before the group turns to the next item.\",\"watch_for\":\"Watch for yourself volunteering a solution while no one has been assigned the follow-through.\",\"move\":\"Before leaving the meeting, identify the owner of the next handoff and its deadline.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a meeting that starts to drift, you notice the next handoff is still unnamed.",
      "pull_quote": "Your momentum helps most when everyone can point to the person carrying the next step.",
      "deeper_read": "You may be ready to push the work forward as soon as a workable standard appears. Instead of adding force to the discussion, make the result usable by tying it to one person’s responsibility before the group turns to the next item.",
      "watch_for": "Watch for yourself volunteering a solution while no one has been assigned the follow-through.",
      "move": "Before leaving the meeting, identify the owner of the next handoff and its deadline."
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
      "output_tokens": 638,
      "output_tokens_details": {
        "reasoning_tokens": 493
      },
      "total_tokens": 1831
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
  "identity": "Aries × Tiger",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings bold to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you escalate situations quickly"
  ],
  "identitySpecificRole": "the partner who turns bold into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking bold to disappear.",
  "ordinaryLifeExpression": "Evidence of bold becomes the test beneath a reassuring message.",
  "blindSpot": "You may escalate situations quickly after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning bold.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|love",
      "manifestationArena": "love",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by trust vs caution.",
      "perception": "The identity brings bold to closeness, where promises and pacing are tested.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you escalate situations quickly"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns bold into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking bold to disappear.",
    "ordinaryLifeExpression": "Evidence of bold becomes the test beneath a reassuring message.",
    "blindSpot": "You may escalate situations quickly after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning bold.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Concrete",
  "intro": "A tender message lands well, but one unanswered practical detail keeps the promise from feeling fully settled.",
  "pull_quote": "You do not need more intensity; you need one clear detail that can still be true on Thursday.",
  "deeper_read": "Your instinct may be to press for certainty while the warmth is still present, turning a small gap into a bigger conversation. Instead, let the reassurance stand and ask what the plan looks like in follow-through: a time, a message, or a simple next step.",
  "watch_for": "Notice whether you draft a sharper reply after receiving affection without the practical answer.",
  "move": "Send one direct question about the unresolved detail, then leave room for a specific response."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Concrete\",\"intro\":\"A tender message lands well, but one unanswered practical detail keeps the promise from feeling fully settled.\",\"pull_quote\":\"You do not need more intensity; you need one clear detail that can still be true on Thursday.\",\"deeper_read\":\"Your instinct may be to press for certainty while the warmth is still present, turning a small gap into a bigger conversation. Instead, let the reassurance stand and ask what the plan looks like in follow-through: a time, a message, or a simple next step.\",\"watch_for\":\"Notice whether you draft a sharper reply after receiving affection without the practical answer.\",\"move\":\"Send one direct question about the unresolved detail, then leave room for a specific response.\"}",
    "parsedResponse": {
      "title": "Make It Concrete",
      "intro": "A tender message lands well, but one unanswered practical detail keeps the promise from feeling fully settled.",
      "pull_quote": "You do not need more intensity; you need one clear detail that can still be true on Thursday.",
      "deeper_read": "Your instinct may be to press for certainty while the warmth is still present, turning a small gap into a bigger conversation. Instead, let the reassurance stand and ask what the plan looks like in follow-through: a time, a message, or a simple next step.",
      "watch_for": "Notice whether you draft a sharper reply after receiving affection without the practical answer.",
      "move": "Send one direct question about the unresolved detail, then leave room for a specific response."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1046,
      "input_tokens_details": {
        "cache_write_tokens": 1043,
        "cached_tokens": 0
      },
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1199
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
  "identity": "Aries × Tiger",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for bold shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you jump before thinking"
  ],
  "identitySpecificRole": "the person who translates bold into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after bold has filled the day.",
  "ordinaryLifeExpression": "A physical change gives bold somewhere to be practiced at home.",
  "blindSpot": "You may burn out from constant charge.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without bold running the room.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|home",
      "manifestationArena": "home",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by stability vs change.",
      "perception": "The need for bold shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you jump before thinking"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates bold into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after bold has filled the day.",
    "ordinaryLifeExpression": "A physical change gives bold somewhere to be practiced at home.",
    "blindSpot": "You may burn out from constant charge.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without bold running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room to Reset",
  "intro": "A familiar room may ask more of you today, especially when shared space starts carrying everyone’s momentum.",
  "pull_quote": "Changing one object’s place can give your boldness somewhere to land without taking over the room.",
  "deeper_read": "You may be quick to fix the feeling by acting first: shifting a chair, clearing a surface, claiming a corner. Let that instinct take a smaller instruction—make one shared-space condition easier to recover in, rather than redesigning the whole household at once.",
  "watch_for": "You move something in a common room before asking whether anyone else uses that spot.",
  "move": "Set up one private, usable corner with what you need to pause there after the day’s push."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room to Reset\",\"intro\":\"A familiar room may ask more of you today, especially when shared space starts carrying everyone’s momentum.\",\"pull_quote\":\"Changing one object’s place can give your boldness somewhere to land without taking over the room.\",\"deeper_read\":\"You may be quick to fix the feeling by acting first: shifting a chair, clearing a surface, claiming a corner. Let that instinct take a smaller instruction—make one shared-space condition easier to recover in, rather than redesigning the whole household at once.\",\"watch_for\":\"You move something in a common room before asking whether anyone else uses that spot.\",\"move\":\"Set up one private, usable corner with what you need to pause there after the day’s push.\"}",
    "parsedResponse": {
      "title": "Make Room to Reset",
      "intro": "A familiar room may ask more of you today, especially when shared space starts carrying everyone’s momentum.",
      "pull_quote": "Changing one object’s place can give your boldness somewhere to land without taking over the room.",
      "deeper_read": "You may be quick to fix the feeling by acting first: shifting a chair, clearing a surface, claiming a corner. Let that instinct take a smaller instruction—make one shared-space condition easier to recover in, rather than redesigning the whole household at once.",
      "watch_for": "You move something in a common room before asking whether anyone else uses that spot.",
      "move": "Set up one private, usable corner with what you need to pause there after the day’s push."
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
      "output_tokens": 157,
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
  "identity": "Aries × Tiger",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by bold.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you escalate situations quickly"
  ],
  "identitySpecificRole": "the friend who uses bold to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's bold.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around bold.",
  "blindSpot": "You meet resistance with more force than the moment expects.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the bold dynamic.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by bold.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you escalate situations quickly"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses bold to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's bold.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around bold.",
    "blindSpot": "You meet resistance with more force than the moment expects.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the bold dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Clearly",
  "intro": "When a friend reaches for peace early, notice who is quietly being assigned the same group role again.",
  "pull_quote": "A specific invitation can say more honestly than a louder attempt to reset the whole mood.",
  "deeper_read": "You may be ready to push back against the social tone, especially if someone’s availability is being assumed. Instead of taking over the conversation, make one clear invitation that names the plan and leaves room for an honest answer.",
  "watch_for": "Someone says “whatever works” while another friend is automatically expected to handle the favor.",
  "move": "Text one person directly with a concrete plan, time, and an easy option to decline."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room Clearly\",\"intro\":\"When a friend reaches for peace early, notice who is quietly being assigned the same group role again.\",\"pull_quote\":\"A specific invitation can say more honestly than a louder attempt to reset the whole mood.\",\"deeper_read\":\"You may be ready to push back against the social tone, especially if someone’s availability is being assumed. Instead of taking over the conversation, make one clear invitation that names the plan and leaves room for an honest answer.\",\"watch_for\":\"Someone says “whatever works” while another friend is automatically expected to handle the favor.\",\"move\":\"Text one person directly with a concrete plan, time, and an easy option to decline.\"}",
    "parsedResponse": {
      "title": "Make Room Clearly",
      "intro": "When a friend reaches for peace early, notice who is quietly being assigned the same group role again.",
      "pull_quote": "A specific invitation can say more honestly than a louder attempt to reset the whole mood.",
      "deeper_read": "You may be ready to push back against the social tone, especially if someone’s availability is being assumed. Instead of taking over the conversation, make one clear invitation that names the plan and leaves room for an honest answer.",
      "watch_for": "Someone says “whatever works” while another friend is automatically expected to handle the favor.",
      "move": "Text one person directly with a concrete plan, time, and an easy option to decline."
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
      "output_tokens": 145,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1207
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
  "identity": "Aries × Tiger",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by bold meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you jump before thinking"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to bold comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what bold makes tempting.",
  "blindSpot": "You regret the choice when you escalate situations quickly.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a bold choice.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|money",
      "manifestationArena": "money",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by bold meets comfort, scarcity, status, and future options.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you jump before thinking"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to bold comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what bold makes tempting.",
    "blindSpot": "You regret the choice when you escalate situations quickly.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a bold choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Comfort Price",
  "intro": "Before buying the quick fix, you notice the larger option your budget would lose today.",
  "pull_quote": "Relief is still a cost when it quietly spends the freedom you wanted for something bolder.",
  "deeper_read": "The tempting purchase may be small enough to feel harmless, especially when it promises an immediate reset. Put its price beside the bill, budget cushion, or future plan it would narrow; that comparison gives your first impulse something concrete to answer to.",
  "watch_for": "You add the item to your cart, then rush toward checkout before checking what remains after upcoming bills.",
  "move": "Write down one future option the purchase reduces, then wait until you can compare both prices."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Comfort Price\",\"intro\":\"Before buying the quick fix, you notice the larger option your budget would lose today.\",\"pull_quote\":\"Relief is still a cost when it quietly spends the freedom you wanted for something bolder.\",\"deeper_read\":\"The tempting purchase may be small enough to feel harmless, especially when it promises an immediate reset. Put its price beside the bill, budget cushion, or future plan it would narrow; that comparison gives your first impulse something concrete to answer to.\",\"watch_for\":\"You add the item to your cart, then rush toward checkout before checking what remains after upcoming bills.\",\"move\":\"Write down one future option the purchase reduces, then wait until you can compare both prices.\"}",
    "parsedResponse": {
      "title": "The Comfort Price",
      "intro": "Before buying the quick fix, you notice the larger option your budget would lose today.",
      "pull_quote": "Relief is still a cost when it quietly spends the freedom you wanted for something bolder.",
      "deeper_read": "The tempting purchase may be small enough to feel harmless, especially when it promises an immediate reset. Put its price beside the bill, budget cushion, or future plan it would narrow; that comparison gives your first impulse something concrete to answer to.",
      "watch_for": "You add the item to your cart, then rush toward checkout before checking what remains after upcoming bills.",
      "move": "Write down one future option the purchase reduces, then wait until you can compare both prices."
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
      "output_tokens": 151,
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
  "identity": "Aries × Tiger",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by bold active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you jump before thinking"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from bold can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when bold keeps usefulness moving.",
  "blindSpot": "Feelings rise quickly and translate directly into action, often without pause",
  "naturalMove": "Close one open loop, then protect the remaining hour from the bold maintenance loop.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by bold active after the useful work is done.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you jump before thinking"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from bold can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when bold keeps usefulness moving.",
    "blindSpot": "Feelings rise quickly and translate directly into action, often without pause",
    "naturalMove": "Close one open loop, then protect the remaining hour from the bold maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Remaining Hour",
  "intro": "A quiet hour can disappear when one finished task immediately becomes a search for the next.",
  "pull_quote": "Rest begins when you stop treating every open minute like evidence you should stay useful.",
  "deeper_read": "You may close one maintenance loop, then reach for your phone or scan the room for another small thing to fix. The restless part is not the unfinished task; it is the quick jump from completing something to proving you can keep going.",
  "watch_for": "After finishing a small chore, notice whether your hand goes to the phone before you choose what happens next.",
  "move": "Set the phone aside, name the one loop you closed, and leave the remaining hour unassigned."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Remaining Hour\",\"intro\":\"A quiet hour can disappear when one finished task immediately becomes a search for the next.\",\"pull_quote\":\"Rest begins when you stop treating every open minute like evidence you should stay useful.\",\"deeper_read\":\"You may close one maintenance loop, then reach for your phone or scan the room for another small thing to fix. The restless part is not the unfinished task; it is the quick jump from completing something to proving you can keep going.\",\"watch_for\":\"After finishing a small chore, notice whether your hand goes to the phone before you choose what happens next.\",\"move\":\"Set the phone aside, name the one loop you closed, and leave the remaining hour unassigned.\"}",
    "parsedResponse": {
      "title": "The Remaining Hour",
      "intro": "A quiet hour can disappear when one finished task immediately becomes a search for the next.",
      "pull_quote": "Rest begins when you stop treating every open minute like evidence you should stay useful.",
      "deeper_read": "You may close one maintenance loop, then reach for your phone or scan the room for another small thing to fix. The restless part is not the unfinished task; it is the quick jump from completing something to proving you can keep going.",
      "watch_for": "After finishing a small chore, notice whether your hand goes to the phone before you choose what happens next.",
      "move": "Set the phone aside, name the one loop you closed, and leave the remaining hour unassigned."
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

## confidence

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Aries × Tiger",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for bold is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you escalate situations quickly"
  ],
  "identitySpecificRole": "the contributor who can accept bold without performing a larger identity",
  "recognition": "Confidence settles when praise names the bold contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger bold performance.",
  "blindSpot": "Moves Quick, Hits Hard",
  "naturalMove": "Credit the contribution accurately, then stop before you escalate situations quickly.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for bold is tested by praise, attribution, and visible competence.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you escalate situations quickly"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept bold without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the bold contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger bold performance.",
    "blindSpot": "Moves Quick, Hits Hard",
    "naturalMove": "Credit the contribution accurately, then stop before you escalate situations quickly.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
  "pull_quote": "A clear acknowledgment of what you did is enough; you do not need to prove the boldness twice.",
  "deeper_read": "Praise may put your competence in full view, especially when the result was strong and specific. State your contribution plainly, without calling it luck, then let the finished work carry the rest instead of rushing to add another decisive move.",
  "watch_for": "After a compliment, notice the urge to immediately pitch more, volunteer more, or raise the stakes.",
  "move": "Say, “Thank you—I handled that part,” then pause long enough for the acknowledgment to stand."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your work, you can accept the credit without turning the moment into a bigger performance.\",\"pull_quote\":\"A clear acknowledgment of what you did is enough; you do not need to prove the boldness twice.\",\"deeper_read\":\"Praise may put your competence in full view, especially when the result was strong and specific. State your contribution plainly, without calling it luck, then let the finished work carry the rest instead of rushing to add another decisive move.\",\"watch_for\":\"After a compliment, notice the urge to immediately pitch more, volunteer more, or raise the stakes.\",\"move\":\"Say, “Thank you—I handled that part,” then pause long enough for the acknowledgment to stand.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
      "pull_quote": "A clear acknowledgment of what you did is enough; you do not need to prove the boldness twice.",
      "deeper_read": "Praise may put your competence in full view, especially when the result was strong and specific. State your contribution plainly, without calling it luck, then let the finished work carry the rest instead of rushing to add another decisive move.",
      "watch_for": "After a compliment, notice the urge to immediately pitch more, volunteer more, or raise the stakes.",
      "move": "Say, “Thank you—I handled that part,” then pause long enough for the acknowledgment to stand."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1041,
      "input_tokens_details": {
        "cache_write_tokens": 1038,
        "cached_tokens": 0
      },
      "output_tokens": 155,
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
  "identity": "Aries × Tiger",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by bold is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you jump before thinking"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as bold reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a bold working style.",
  "blindSpot": "You release the work by leting force take instruction instead of the lead.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this bold rhythm.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by bold is reducing friction or preserving confinement.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you jump before thinking"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as bold reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a bold working style.",
    "blindSpot": "You release the work by leting force take instruction instead of the lead.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this bold rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Change the Order",
  "intro": "A familiar routine feels abrasive today because one repeated step is creating more rework than it saves.",
  "pull_quote": "Freedom may come from revising the sequence, not from abandoning the routine altogether.",
  "deeper_read": "You may be ready to push through the irritation, skip ahead, or make a bigger change before checking the process itself. Mark the step that keeps sending you back, then let the result—not impatience—tell you what belongs first.",
  "watch_for": "Notice the moment you repeat a task, correct it, and reach for a faster workaround.",
  "move": "Change one step in the sequence once, then keep the rest of the routine intact."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Change the Order\",\"intro\":\"A familiar routine feels abrasive today because one repeated step is creating more rework than it saves.\",\"pull_quote\":\"Freedom may come from revising the sequence, not from abandoning the routine altogether.\",\"deeper_read\":\"You may be ready to push through the irritation, skip ahead, or make a bigger change before checking the process itself. Mark the step that keeps sending you back, then let the result—not impatience—tell you what belongs first.\",\"watch_for\":\"Notice the moment you repeat a task, correct it, and reach for a faster workaround.\",\"move\":\"Change one step in the sequence once, then keep the rest of the routine intact.\"}",
    "parsedResponse": {
      "title": "Change the Order",
      "intro": "A familiar routine feels abrasive today because one repeated step is creating more rework than it saves.",
      "pull_quote": "Freedom may come from revising the sequence, not from abandoning the routine altogether.",
      "deeper_read": "You may be ready to push through the irritation, skip ahead, or make a bigger change before checking the process itself. Mark the step that keeps sending you back, then let the result—not impatience—tell you what belongs first.",
      "watch_for": "Notice the moment you repeat a task, correct it, and reach for a faster workaround.",
      "move": "Change one step in the sequence once, then keep the rest of the routine intact."
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
      "output_tokens": 146,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1201
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
  "identity": "Aries × Tiger",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The impulsive response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you escalate situations quickly"
  ],
  "identitySpecificRole": "the initiator who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against impulsive is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before impulsive takes over.",
  "blindSpot": "You may decide from impulsive instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses impulsive.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by directness vs patience.",
      "perception": "The impulsive response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you escalate situations quickly"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the initiator who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against impulsive is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before impulsive takes over.",
    "blindSpot": "You may decide from impulsive instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses impulsive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Repairable",
  "intro": "A small disagreement sharpens when you name its impact without deciding what the other person meant.",
  "pull_quote": "The point is not to soften your directness, but to give it one clear job.",
  "deeper_read": "You may be ready to answer a tone shift or avoided point immediately, especially when it feels like the facts are being sidestepped. Before the exchange gathers speed, separate what was said or done from the motive you are tempted to assign, then make the next step concrete.",
  "watch_for": "Notice if you start building a case from one clipped reply, interruption, or missing acknowledgment.",
  "move": "Say what changed for you, then name one repair condition: address the point directly before continuing."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you name its impact without deciding what the other person meant.\",\"pull_quote\":\"The point is not to soften your directness, but to give it one clear job.\",\"deeper_read\":\"You may be ready to answer a tone shift or avoided point immediately, especially when it feels like the facts are being sidestepped. Before the exchange gathers speed, separate what was said or done from the motive you are tempted to assign, then make the next step concrete.\",\"watch_for\":\"Notice if you start building a case from one clipped reply, interruption, or missing acknowledgment.\",\"move\":\"Say what changed for you, then name one repair condition: address the point directly before continuing.\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you name its impact without deciding what the other person meant.",
      "pull_quote": "The point is not to soften your directness, but to give it one clear job.",
      "deeper_read": "You may be ready to answer a tone shift or avoided point immediately, especially when it feels like the facts are being sidestepped. Before the exchange gathers speed, separate what was said or done from the motive you are tempted to assign, then make the next step concrete.",
      "watch_for": "Notice if you start building a case from one clipped reply, interruption, or missing acknowledgment.",
      "move": "Say what changed for you, then name one repair condition: address the point directly before continuing."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1068,
      "input_tokens_details": {
        "cache_write_tokens": 1065,
        "cached_tokens": 0
      },
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1226
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
  "identity": "Aries × Tiger",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by bold competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you jump before thinking"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects bold and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for bold.",
  "blindSpot": "You delay when you jump before thinking.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about bold.",
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
    "signPair": "Aries × Tiger",
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
      "manifestationKey": "Aries × Tiger|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You meet resistance with more force than the moment expects. Growth begins when you let force take instruction instead of the lead. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by bold competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with fast, fearless, and instinctive. Then you act without fear of failure.",
      "pressureOrGrowth": "Under pressure, you first jump before thinking.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you jump before thinking"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects bold and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for bold.",
    "blindSpot": "You delay when you jump before thinking.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about bold.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Leap",
  "intro": "An attractive offer may ask you to leave what works, but today you can make the risk measurable first.",
  "pull_quote": "You do not need to erase uncertainty; you need one small test that gives your boldness something concrete to answer.",
  "deeper_read": "Your first impulse may be to decide quickly, either by taking the opening outright or dismissing it to protect the proven position. Instead, put a boundary around the next step: a trial period, a defined conversation, or one proof point that shows whether the offer holds up.",
  "watch_for": "Notice if you start speaking as though the choice must be a total yes or a total no.",
  "move": "Ask what evidence would justify leaving, then set a timed reversible test to gather it."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Leap\",\"intro\":\"An attractive offer may ask you to leave what works, but today you can make the risk measurable first.\",\"pull_quote\":\"You do not need to erase uncertainty; you need one small test that gives your boldness something concrete to answer.\",\"deeper_read\":\"Your first impulse may be to decide quickly, either by taking the opening outright or dismissing it to protect the proven position. Instead, put a boundary around the next step: a trial period, a defined conversation, or one proof point that shows whether the offer holds up.\",\"watch_for\":\"Notice if you start speaking as though the choice must be a total yes or a total no.\",\"move\":\"Ask what evidence would justify leaving, then set a timed reversible test to gather it.\"}",
    "parsedResponse": {
      "title": "Proof Before Leap",
      "intro": "An attractive offer may ask you to leave what works, but today you can make the risk measurable first.",
      "pull_quote": "You do not need to erase uncertainty; you need one small test that gives your boldness something concrete to answer.",
      "deeper_read": "Your first impulse may be to decide quickly, either by taking the opening outright or dismissing it to protect the proven position. Instead, put a boundary around the next step: a trial period, a defined conversation, or one proof point that shows whether the offer holds up.",
      "watch_for": "Notice if you start speaking as though the choice must be a total yes or a total no.",
      "move": "Ask what evidence would justify leaving, then set a timed reversible test to gather it."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1064,
      "input_tokens_details": {
        "cache_write_tokens": 1061,
        "cached_tokens": 0
      },
      "output_tokens": 164,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1228
    }
  }
]
```
