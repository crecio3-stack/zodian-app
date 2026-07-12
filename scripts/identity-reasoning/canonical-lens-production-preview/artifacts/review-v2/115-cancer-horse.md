# 115 · Cancer × Horse

Status: complete
Source: Resources/archetypes.json#cancer-horse
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
  "identity": "Cancer × Horse",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You adapt emotionally. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you avoid emotional depth",
    "uses you feel deeply and moves freely to make one standard visible before you pull away too quickly"
  ],
  "identitySpecificRole": "the protector who turns thrives in flexible environments into clear ownership",
  "recognition": "The work improves when the expressive result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes expressive observable before ownership is finalized.",
  "blindSpot": "You may pull away too quickly after the work is already good enough.",
  "naturalMove": "Clarify one owner and use expressive as the visible standard.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|work",
      "manifestationArena": "work",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by speaking up vs waiting.",
      "perception": "You adapt emotionally. becomes visible around ownership and execution.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "names who owns the next handoff before you avoid emotional depth",
        "uses you feel deeply and moves freely to make one standard visible before you pull away too quickly"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the protector who turns thrives in flexible environments into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the expressive result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes expressive observable before ownership is finalized.",
    "blindSpot": "You may pull away too quickly after the work is already good enough.",
    "naturalMove": "Clarify one owner and use expressive as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In the meeting, the work is taking shape before anyone has named who carries it next.",
  "pull_quote": "A clear owner can hold the standard without requiring you to stay in the conversation.",
  "deeper_read": "You may notice the draft is good enough and feel ready to step back, especially once the discussion turns toward responsibility. Instead of leaving the handoff implied, make the next owner visible and point to the one standard the team should use.",
  "watch_for": "Watch for a finished draft being discussed while the next handoff remains unnamed.",
  "move": "Before the meeting closes, assign one owner and identify the standard for the handoff."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, a useful idea hangs in the air until someone names who carries it next.\",\"pull_quote\":\"The work does not need more discussion; it needs an owner and one visible standard.\",\"deeper_read\":\"You may be ready to step back once the direction feels good enough, especially when the group seems to understand it. Before you do, turn that shared feeling into something usable: name the person responsible for the next handoff and state what the finished version should show.\",\"watch_for\":\"A colleague summarizes the idea, but no one says who will send the next draft.\",\"move\":\"Say, “Can we assign the next handoff and agree on one standard for the draft?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, a useful idea hangs in the air until someone names who carries it next.",
      "pull_quote": "The work does not need more discussion; it needs an owner and one visible standard.",
      "deeper_read": "You may be ready to step back once the direction feels good enough, especially when the group seems to understand it. Before you do, turn that shared feeling into something usable: name the person responsible for the next handoff and state what the finished version should show.",
      "watch_for": "A colleague summarizes the idea, but no one says who will send the next draft.",
      "move": "Say, “Can we assign the next handoff and agree on one standard for the draft?”"
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
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, the work is taking shape before anyone has named who carries it next.\",\"pull_quote\":\"A clear owner can hold the standard without requiring you to stay in the conversation.\",\"deeper_read\":\"You may notice the draft is good enough and feel ready to step back, especially once the discussion turns toward responsibility. Instead of leaving the handoff implied, make the next owner visible and point to the one standard the team should use.\",\"watch_for\":\"Watch for a finished draft being discussed while the next handoff remains unnamed.\",\"move\":\"Before the meeting closes, assign one owner and identify the standard for the handoff.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, the work is taking shape before anyone has named who carries it next.",
      "pull_quote": "A clear owner can hold the standard without requiring you to stay in the conversation.",
      "deeper_read": "You may notice the draft is good enough and feel ready to step back, especially once the discussion turns toward responsibility. Instead of leaving the handoff implied, make the next owner visible and point to the one standard the team should use.",
      "watch_for": "Watch for a finished draft being discussed while the next handoff remains unnamed.",
      "move": "Before the meeting closes, assign one owner and identify the standard for the handoff."
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
      "output_tokens": 560,
      "output_tokens_details": {
        "reasoning_tokens": 415
      },
      "total_tokens": 1750
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
  "identity": "Cancer × Horse",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings expressive to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you pull away too quickly"
  ],
  "identitySpecificRole": "the partner who turns expressive into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking expressive to disappear.",
  "ordinaryLifeExpression": "Evidence of expressive becomes the test beneath a reassuring message.",
  "blindSpot": "You may pull away too quickly after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning expressive.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|love",
      "manifestationArena": "love",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by trust vs caution.",
      "perception": "The identity brings expressive to closeness, where promises and pacing are tested.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you pull away too quickly"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns expressive into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking expressive to disappear.",
    "ordinaryLifeExpression": "Evidence of expressive becomes the test beneath a reassuring message.",
    "blindSpot": "You may pull away too quickly after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning expressive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Concrete",
  "intro": "A warm message lands well, but you pause at the practical detail that would make it real this week.",
  "pull_quote": "You do not need more reassurance; you need one promise stated clearly enough to recognize in follow-through.",
  "deeper_read": "The exchange can stay tender without becoming vague. Instead of retreating once affection is offered, ask what the plan looks like in an ordinary week—when you will talk, meet, or check in—and let the answer be simple rather than absolute.",
  "watch_for": "Notice if you draft a warm reply, then delay sending it because the plan still has no detail.",
  "move": "Reply with affection, then name one workable follow-through detail, such as a day to see each other or call."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Concrete\",\"intro\":\"A warm message lands well, but you pause at the practical detail that would make it real this week.\",\"pull_quote\":\"You do not need more reassurance; you need one promise stated clearly enough to recognize in follow-through.\",\"deeper_read\":\"The exchange can stay tender without becoming vague. Instead of retreating once affection is offered, ask what the plan looks like in an ordinary week—when you will talk, meet, or check in—and let the answer be simple rather than absolute.\",\"watch_for\":\"Notice if you draft a warm reply, then delay sending it because the plan still has no detail.\",\"move\":\"Reply with affection, then name one workable follow-through detail, such as a day to see each other or call.\"}",
    "parsedResponse": {
      "title": "Make It Concrete",
      "intro": "A warm message lands well, but you pause at the practical detail that would make it real this week.",
      "pull_quote": "You do not need more reassurance; you need one promise stated clearly enough to recognize in follow-through.",
      "deeper_read": "The exchange can stay tender without becoming vague. Instead of retreating once affection is offered, ask what the plan looks like in an ordinary week—when you will talk, meet, or check in—and let the answer be simple rather than absolute.",
      "watch_for": "Notice if you draft a warm reply, then delay sending it because the plan still has no detail.",
      "move": "Reply with affection, then name one workable follow-through detail, such as a day to see each other or call."
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
      "output_tokens": 162,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1213
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
  "identity": "Cancer × Horse",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for expressive shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you avoid emotional depth"
  ],
  "identitySpecificRole": "the person who translates expressive into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after expressive has filled the day.",
  "ordinaryLifeExpression": "A physical change gives expressive somewhere to be practiced at home.",
  "blindSpot": "You may struggle with consistency.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without expressive running the room.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|home",
      "manifestationArena": "home",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by stability vs change.",
      "perception": "The need for expressive shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you avoid emotional depth"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates expressive into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after expressive has filled the day.",
    "ordinaryLifeExpression": "A physical change gives expressive somewhere to be practiced at home.",
    "blindSpot": "You may struggle with consistency.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without expressive running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room to Recover",
  "intro": "A familiar room asks for one small adjustment when the day's activity starts lingering in every corner.",
  "pull_quote": "You do not need to withdraw completely when a shared space can hold both presence and pause.",
  "deeper_read": "Before discussing the whole household routine, you may shift one object or redefine a small section of the room. That physical edit gives you a place to settle after a busy stretch, without turning privacy into a closed door.",
  "watch_for": "You move a chair, lamp, or basket, then hesitate when someone asks why it changed.",
  "move": "Set one clear shared-space rule that protects a quiet corner while keeping the room usable for everyone."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room to Recover\",\"intro\":\"A familiar room asks for one small adjustment when the day's activity starts lingering in every corner.\",\"pull_quote\":\"You do not need to withdraw completely when a shared space can hold both presence and pause.\",\"deeper_read\":\"Before discussing the whole household routine, you may shift one object or redefine a small section of the room. That physical edit gives you a place to settle after a busy stretch, without turning privacy into a closed door.\",\"watch_for\":\"You move a chair, lamp, or basket, then hesitate when someone asks why it changed.\",\"move\":\"Set one clear shared-space rule that protects a quiet corner while keeping the room usable for everyone.\"}",
    "parsedResponse": {
      "title": "Room to Recover",
      "intro": "A familiar room asks for one small adjustment when the day's activity starts lingering in every corner.",
      "pull_quote": "You do not need to withdraw completely when a shared space can hold both presence and pause.",
      "deeper_read": "Before discussing the whole household routine, you may shift one object or redefine a small section of the room. That physical edit gives you a place to settle after a busy stretch, without turning privacy into a closed door.",
      "watch_for": "You move a chair, lamp, or basket, then hesitate when someone asks why it changed.",
      "move": "Set one clear shared-space rule that protects a quiet corner while keeping the room usable for everyone."
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
      "output_tokens": 146,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1202
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
  "identity": "Cancer × Horse",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by expressive.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you pull away too quickly"
  ],
  "identitySpecificRole": "the friend who uses expressive to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's expressive.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around expressive.",
  "blindSpot": "You create distance when feeling needs somewhere to move.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the expressive dynamic.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by expressive.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you pull away too quickly"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses expressive to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's expressive.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around expressive.",
    "blindSpot": "You create distance when feeling needs somewhere to move.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the expressive dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Invitation",
  "intro": "A friend may reach for a smooth ending while the unspoken part is still shaping the group’s tone.",
  "pull_quote": "One clear invitation can say more than quietly stepping back and hoping the arrangement changes.",
  "deeper_read": "You notice who keeps getting assigned the unnamed role—the organizer, the available one, the person expected to soften everything. Rather than withdrawing from the group chat or accepting the usual favor, make your availability visible with a specific plan that changes how you participate.",
  "watch_for": "A friend says, “Let’s not make this a thing,” before anyone has named who is being asked again.",
  "move": "Invite the overlooked friend to something concrete, and state what you can offer without volunteering for the whole role."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Invitation\",\"intro\":\"A friend may reach for a smooth ending while the unspoken part is still shaping the group’s tone.\",\"pull_quote\":\"One clear invitation can say more than quietly stepping back and hoping the arrangement changes.\",\"deeper_read\":\"You notice who keeps getting assigned the unnamed role—the organizer, the available one, the person expected to soften everything. Rather than withdrawing from the group chat or accepting the usual favor, make your availability visible with a specific plan that changes how you participate.\",\"watch_for\":\"A friend says, “Let’s not make this a thing,” before anyone has named who is being asked again.\",\"move\":\"Invite the overlooked friend to something concrete, and state what you can offer without volunteering for the whole role.\"}",
    "parsedResponse": {
      "title": "Name the Invitation",
      "intro": "A friend may reach for a smooth ending while the unspoken part is still shaping the group’s tone.",
      "pull_quote": "One clear invitation can say more than quietly stepping back and hoping the arrangement changes.",
      "deeper_read": "You notice who keeps getting assigned the unnamed role—the organizer, the available one, the person expected to soften everything. Rather than withdrawing from the group chat or accepting the usual favor, make your availability visible with a specific plan that changes how you participate.",
      "watch_for": "A friend says, “Let’s not make this a thing,” before anyone has named who is being asked again.",
      "move": "Invite the overlooked friend to something concrete, and state what you can offer without volunteering for the whole role."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1065,
      "input_tokens_details": {
        "cache_write_tokens": 1062,
        "cached_tokens": 0
      },
      "output_tokens": 160,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1225
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
  "identity": "Cancer × Horse",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by expressive meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you avoid emotional depth"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to expressive comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what expressive makes tempting.",
  "blindSpot": "You regret the choice when you pull away too quickly.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a expressive choice.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|money",
      "manifestationArena": "money",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by expressive meets comfort, scarcity, status, and future options.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you avoid emotional depth"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to expressive comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what expressive makes tempting.",
    "blindSpot": "You regret the choice when you pull away too quickly.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a expressive choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Price the Relief",
  "intro": "Before buying the comfort expense, you notice it also quietly narrows a future option you value.",
  "pull_quote": "The purchase may be worth it, but it deserves the same clear price as the flexibility it spends.",
  "deeper_read": "You are not just comparing a bill to your budget; you are comparing immediate relief with what that money keeps available later. The useful pause is not a retreat from deciding, but a direct naming of the option you would give up.",
  "watch_for": "You open the checkout screen, then close it without writing down what the purchase would replace.",
  "move": "List the purchase price beside one specific future option, then choose which cost you can actually accept."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Price the Relief\",\"intro\":\"Before buying the comfort expense, you notice it also quietly narrows a future option you value.\",\"pull_quote\":\"The purchase may be worth it, but it deserves the same clear price as the flexibility it spends.\",\"deeper_read\":\"You are not just comparing a bill to your budget; you are comparing immediate relief with what that money keeps available later. The useful pause is not a retreat from deciding, but a direct naming of the option you would give up.\",\"watch_for\":\"You open the checkout screen, then close it without writing down what the purchase would replace.\",\"move\":\"List the purchase price beside one specific future option, then choose which cost you can actually accept.\"}",
    "parsedResponse": {
      "title": "Price the Relief",
      "intro": "Before buying the comfort expense, you notice it also quietly narrows a future option you value.",
      "pull_quote": "The purchase may be worth it, but it deserves the same clear price as the flexibility it spends.",
      "deeper_read": "You are not just comparing a bill to your budget; you are comparing immediate relief with what that money keeps available later. The useful pause is not a retreat from deciding, but a direct naming of the option you would give up.",
      "watch_for": "You open the checkout screen, then close it without writing down what the purchase would replace.",
      "move": "List the purchase price beside one specific future option, then choose which cost you can actually accept."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1065,
      "input_tokens_details": {
        "cache_write_tokens": 1062,
        "cached_tokens": 0
      },
      "output_tokens": 151,
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
  "identity": "Cancer × Horse",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by expressive active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you avoid emotional depth"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from expressive can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when expressive keeps usefulness moving.",
  "blindSpot": "Emotions move in waves, sometimes deeply felt, sometimes avoided",
  "naturalMove": "Close one open loop, then protect the remaining hour from the expressive maintenance loop.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by expressive active after the useful work is done.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you avoid emotional depth"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from expressive can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when expressive keeps usefulness moving.",
    "blindSpot": "Emotions move in waves, sometimes deeply felt, sometimes avoided",
    "naturalMove": "Close one open loop, then protect the remaining hour from the expressive maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Remaining Hour",
  "intro": "After finishing one small task, you may feel the pull to find another instead of letting the quiet begin.",
  "pull_quote": "Rest becomes practical when you stop asking the evening to prove you were useful enough.",
  "deeper_read": "A quiet hour can turn into a maintenance loop: one more email, reset, list, or check before sleep. Closing a single unfinished task is enough; putting the phone away keeps the remaining time from becoming another assignment.",
  "watch_for": "You finish a task, reach for your phone, then start scanning for another thing to maintain.",
  "move": "Choose one open loop to close, silence the phone, and leave the rest of the hour unassigned."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Remaining Hour\",\"intro\":\"After finishing one small task, you may feel the pull to find another instead of letting the quiet begin.\",\"pull_quote\":\"Rest becomes practical when you stop asking the evening to prove you were useful enough.\",\"deeper_read\":\"A quiet hour can turn into a maintenance loop: one more email, reset, list, or check before sleep. Closing a single unfinished task is enough; putting the phone away keeps the remaining time from becoming another assignment.\",\"watch_for\":\"You finish a task, reach for your phone, then start scanning for another thing to maintain.\",\"move\":\"Choose one open loop to close, silence the phone, and leave the rest of the hour unassigned.\"}",
    "parsedResponse": {
      "title": "The Remaining Hour",
      "intro": "After finishing one small task, you may feel the pull to find another instead of letting the quiet begin.",
      "pull_quote": "Rest becomes practical when you stop asking the evening to prove you were useful enough.",
      "deeper_read": "A quiet hour can turn into a maintenance loop: one more email, reset, list, or check before sleep. Closing a single unfinished task is enough; putting the phone away keeps the remaining time from becoming another assignment.",
      "watch_for": "You finish a task, reach for your phone, then start scanning for another thing to maintain.",
      "move": "Choose one open loop to close, silence the phone, and leave the rest of the hour unassigned."
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
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1213
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
  "identity": "Cancer × Horse",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for expressive is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you pull away too quickly"
  ],
  "identitySpecificRole": "the contributor who can accept expressive without performing a larger identity",
  "recognition": "Confidence settles when praise names the expressive contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger expressive performance.",
  "blindSpot": "Looks Safe, Chases Space",
  "naturalMove": "Credit the contribution accurately, then stop before you pull away too quickly.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for expressive is tested by praise, attribution, and visible competence.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you pull away too quickly"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept expressive without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the expressive contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger expressive performance.",
    "blindSpot": "Looks Safe, Chases Space",
    "naturalMove": "Credit the contribution accurately, then stop before you pull away too quickly.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names what you did well, you do not need to turn the moment into another performance.",
  "pull_quote": "You can accept clear credit without making yourself bigger, smaller, or suddenly unavailable.",
  "deeper_read": "The praise may be specific: the presentation, the result, the piece of work that carried your contribution. Say what you did plainly, then let the finished result remain visible instead of stepping back before the acknowledgement has had time to register.",
  "watch_for": "Watch for the quick deflection—“it was nothing”—or a sudden pivot away from the conversation.",
  "move": "Reply with one accurate sentence about your role, then return to what is next."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names what you did well, you do not need to turn the moment into another performance.\",\"pull_quote\":\"You can accept clear credit without making yourself bigger, smaller, or suddenly unavailable.\",\"deeper_read\":\"The praise may be specific: the presentation, the result, the piece of work that carried your contribution. Say what you did plainly, then let the finished result remain visible instead of stepping back before the acknowledgement has had time to register.\",\"watch_for\":\"Watch for the quick deflection—“it was nothing”—or a sudden pivot away from the conversation.\",\"move\":\"Reply with one accurate sentence about your role, then return to what is next.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names what you did well, you do not need to turn the moment into another performance.",
      "pull_quote": "You can accept clear credit without making yourself bigger, smaller, or suddenly unavailable.",
      "deeper_read": "The praise may be specific: the presentation, the result, the piece of work that carried your contribution. Say what you did plainly, then let the finished result remain visible instead of stepping back before the acknowledgement has had time to register.",
      "watch_for": "Watch for the quick deflection—“it was nothing”—or a sudden pivot away from the conversation.",
      "move": "Reply with one accurate sentence about your role, then return to what is next."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1047,
      "input_tokens_details": {
        "cache_write_tokens": 1044,
        "cached_tokens": 0
      },
      "output_tokens": 572,
      "output_tokens_details": {
        "reasoning_tokens": 421
      },
      "total_tokens": 1619
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
  "identity": "Cancer × Horse",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by expressive is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you avoid emotional depth"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as expressive reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a expressive working style.",
  "blindSpot": "You release the work by leting directness do the job that retreat keeps trying to do.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this expressive rhythm.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by expressive is reducing friction or preserving confinement.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you avoid emotional depth"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as expressive reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a expressive working style.",
    "blindSpot": "You release the work by leting directness do the job that retreat keeps trying to do.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this expressive rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Change the Sequence",
  "intro": "A dependable routine feels irritating today because one repeated step keeps creating more work than it saves.",
  "pull_quote": "You do not need to abandon the routine; you need to name the step that is slowing it down.",
  "deeper_read": "Notice where you keep circling a task, postponing a reply, or adding a workaround after the same point in the sequence. Instead of quietly pulling away from the whole ritual, make one direct adjustment and see whether the result comes with less friction.",
  "watch_for": "You may catch yourself redoing the same small task or skipping it without saying why.",
  "move": "Mark the step causing rework, then swap its order with one earlier task before abandoning the routine."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Change the Sequence\",\"intro\":\"A dependable routine feels irritating today because one repeated step keeps creating more work than it saves.\",\"pull_quote\":\"You do not need to abandon the routine; you need to name the step that is slowing it down.\",\"deeper_read\":\"Notice where you keep circling a task, postponing a reply, or adding a workaround after the same point in the sequence. Instead of quietly pulling away from the whole ritual, make one direct adjustment and see whether the result comes with less friction.\",\"watch_for\":\"You may catch yourself redoing the same small task or skipping it without saying why.\",\"move\":\"Mark the step causing rework, then swap its order with one earlier task before abandoning the routine.\"}",
    "parsedResponse": {
      "title": "Change the Sequence",
      "intro": "A dependable routine feels irritating today because one repeated step keeps creating more work than it saves.",
      "pull_quote": "You do not need to abandon the routine; you need to name the step that is slowing it down.",
      "deeper_read": "Notice where you keep circling a task, postponing a reply, or adding a workaround after the same point in the sequence. Instead of quietly pulling away from the whole ritual, make one direct adjustment and see whether the result comes with less friction.",
      "watch_for": "You may catch yourself redoing the same small task or skipping it without saying why.",
      "move": "Mark the step causing rework, then swap its order with one earlier task before abandoning the routine."
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
      "output_tokens": 155,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1217
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
  "identity": "Cancer × Horse",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The restlessness response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you pull away too quickly"
  ],
  "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by directness vs patience.",
      "perception": "The restlessness response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you pull away too quickly"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
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
  "title": "Name the Missing Point",
  "intro": "A small disagreement sharpens when an avoided point matters more than the words around it.",
  "pull_quote": "You do not need to settle the motive before naming the impact and asking for repair.",
  "deeper_read": "When the tone shifts or a piece of evidence gets skipped, restlessness can make leaving feel cleaner than staying. Instead, separate what happened from why you think it happened, then set one condition that would make the conversation workable.",
  "watch_for": "Notice the moment you start ending the exchange before the avoided point has been addressed.",
  "move": "State the skipped point and ask for it to be addressed before continuing the conversation."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you notice its impact before deciding what the other person meant.\",\"pull_quote\":\"You do not need to stay in the exchange, but name what would make it workable first.\",\"deeper_read\":\"A tone shift or avoided point can make leaving feel cleaner than explaining. Keep the conflict specific: say what was said or done, how it landed, and one condition for repair, rather than arguing over a motive you cannot verify.\",\"watch_for\":\"You start drafting a final reply after one clipped message or a detail goes unaddressed.\",\"move\":\"Say, “When that point was skipped, I felt dismissed; address it directly before we continue.”\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you notice its impact before deciding what the other person meant.",
      "pull_quote": "You do not need to stay in the exchange, but name what would make it workable first.",
      "deeper_read": "A tone shift or avoided point can make leaving feel cleaner than explaining. Keep the conflict specific: say what was said or done, how it landed, and one condition for repair, rather than arguing over a motive you cannot verify.",
      "watch_for": "You start drafting a final reply after one clipped message or a detail goes unaddressed.",
      "move": "Say, “When that point was skipped, I felt dismissed; address it directly before we continue.”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1071,
      "input_tokens_details": {
        "cache_write_tokens": 1068,
        "cached_tokens": 0
      },
      "output_tokens": 151,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1222
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Missing Point\",\"intro\":\"A small disagreement sharpens when an avoided point matters more than the words around it.\",\"pull_quote\":\"You do not need to settle the motive before naming the impact and asking for repair.\",\"deeper_read\":\"When the tone shifts or a piece of evidence gets skipped, restlessness can make leaving feel cleaner than staying. Instead, separate what happened from why you think it happened, then set one condition that would make the conversation workable.\",\"watch_for\":\"Notice the moment you start ending the exchange before the avoided point has been addressed.\",\"move\":\"State the skipped point and ask for it to be addressed before continuing the conversation.\"}",
    "parsedResponse": {
      "title": "Name the Missing Point",
      "intro": "A small disagreement sharpens when an avoided point matters more than the words around it.",
      "pull_quote": "You do not need to settle the motive before naming the impact and asking for repair.",
      "deeper_read": "When the tone shifts or a piece of evidence gets skipped, restlessness can make leaving feel cleaner than staying. Instead, separate what happened from why you think it happened, then set one condition that would make the conversation workable.",
      "watch_for": "Notice the moment you start ending the exchange before the avoided point has been addressed.",
      "move": "State the skipped point and ask for it to be addressed before continuing the conversation."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1202,
      "input_tokens_details": {
        "cache_write_tokens": 1199,
        "cached_tokens": 0
      },
      "output_tokens": 213,
      "output_tokens_details": {
        "reasoning_tokens": 70
      },
      "total_tokens": 1415
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
  "identity": "Cancer × Horse",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by expressive competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you avoid emotional depth"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects expressive and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for expressive.",
  "blindSpot": "You delay when you avoid emotional depth.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about expressive.",
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
    "signPair": "Cancer × Horse",
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
      "manifestationKey": "Cancer × Horse|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You create distance when feeling needs somewhere to move. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by expressive competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with emotional, independent, and always shifting. Then you feel deeply and moves freely.",
      "pressureOrGrowth": "Under pressure, you first avoid emotional depth.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you avoid emotional depth"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects expressive and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for expressive.",
    "blindSpot": "You delay when you avoid emotional depth.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about expressive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Leaving",
  "intro": "A promising offer gets more useful today when you turn its appeal into a small, time-bound test.",
  "pull_quote": "You do not need to abandon what works before asking the new option to show its evidence.",
  "deeper_read": "The question is not whether the opening feels exciting enough to justify leaving a proven position. Ask what proof, by a specific date, would make it worth continuing, then choose a reversible step that lets the offer answer you without requiring a full exit.",
  "watch_for": "You may keep refining the pros-and-cons list instead of naming the one result you need to see.",
  "move": "Set a short trial, define one observable result, and schedule the conversation that makes the test possible."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Leaving\",\"intro\":\"A promising offer gets more useful today when you turn its appeal into a small, time-bound test.\",\"pull_quote\":\"You do not need to abandon what works before asking the new option to show its evidence.\",\"deeper_read\":\"The question is not whether the opening feels exciting enough to justify leaving a proven position. Ask what proof, by a specific date, would make it worth continuing, then choose a reversible step that lets the offer answer you without requiring a full exit.\",\"watch_for\":\"You may keep refining the pros-and-cons list instead of naming the one result you need to see.\",\"move\":\"Set a short trial, define one observable result, and schedule the conversation that makes the test possible.\"}",
    "parsedResponse": {
      "title": "Proof Before Leaving",
      "intro": "A promising offer gets more useful today when you turn its appeal into a small, time-bound test.",
      "pull_quote": "You do not need to abandon what works before asking the new option to show its evidence.",
      "deeper_read": "The question is not whether the opening feels exciting enough to justify leaving a proven position. Ask what proof, by a specific date, would make it worth continuing, then choose a reversible step that lets the offer answer you without requiring a full exit.",
      "watch_for": "You may keep refining the pros-and-cons list instead of naming the one result you need to see.",
      "move": "Set a short trial, define one observable result, and schedule the conversation that makes the test possible."
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
      "output_tokens": 156,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1223
    }
  }
]
```
