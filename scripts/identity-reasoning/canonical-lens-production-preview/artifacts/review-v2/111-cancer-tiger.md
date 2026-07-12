# 111 · Cancer × Tiger

Status: complete
Source: Resources/archetypes.json#cancer-tiger
Retries: 4
QA flags: 4

## Canonical fixture

```json

```

## work

Validator: accepted
Retries: 2

### Manifestation

```json
{
  "identity": "Cancer × Tiger",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You feel with heat. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you overreact emotionally",
    "uses you defend what matters deeply to make one standard visible before you take things personally"
  ],
  "identitySpecificRole": "the protector who turns thrives in environments where care and action meet into clear ownership",
  "recognition": "The work improves when the protective result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes protective observable before ownership is finalized.",
  "blindSpot": "You may take things personally after the work is already good enough.",
  "naturalMove": "Clarify one owner and use protective as the visible standard.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|work",
      "manifestationArena": "work",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by speaking up vs waiting.",
      "perception": "You feel with heat. becomes visible around ownership and execution.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "names who owns the next handoff before you overreact emotionally",
        "uses you defend what matters deeply to make one standard visible before you take things personally"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the protector who turns thrives in environments where care and action meet into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the protective result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes protective observable before ownership is finalized.",
    "blindSpot": "You may take things personally after the work is already good enough.",
    "naturalMove": "Clarify one owner and use protective as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In a meeting or handoff, say who owns the next step before a small concern becomes personal.",
  "pull_quote": "A clear owner protects the standard better than carrying the concern alone.",
  "deeper_read": "You may notice a requirement slipping in the collaboration and feel ready to hold it yourself. Put the standard into plain language, then attach the next action to the person responsible for the handoff; this keeps the discussion on execution rather than on who cares most.",
  "watch_for": "Someone says, “We’ll handle it,” without naming who will send, review, or approve the next piece.",
  "move": "Before the meeting ends, ask for one name, one deliverable, and one deadline for the handoff."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a work meeting, the unfinished handoff becomes easier to protect once someone is clearly named to carry it.\",\"pull_quote\":\"Say who owns the next step before frustration turns a workable standard into a personal argument.\",\"deeper_read\":\"You may notice a gap in execution and feel ready to defend the quality of the work. Instead of waiting for the group to drift past it, make the standard concrete: identify the next handoff, its owner, and what needs to be delivered by the deadline.\",\"watch_for\":\"Someone says “we’ll handle it,” while no person is assigned the next handoff.\",\"move\":\"Ask, “Who owns this by the deadline, and what does complete look like?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a work meeting, the unfinished handoff becomes easier to protect once someone is clearly named to carry it.",
      "pull_quote": "Say who owns the next step before frustration turns a workable standard into a personal argument.",
      "deeper_read": "You may notice a gap in execution and feel ready to defend the quality of the work. Instead of waiting for the group to drift past it, make the standard concrete: identify the next handoff, its owner, and what needs to be delivered by the deadline.",
      "watch_for": "Someone says “we’ll handle it,” while no person is assigned the next handoff.",
      "move": "Ask, “Who owns this by the deadline, and what does complete look like?”"
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
      "output_tokens": 157,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1222
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, name the next handoff before a small concern turns into a personal reaction.\",\"pull_quote\":\"Your care is most useful today when it becomes a visible standard and a named owner.\",\"deeper_read\":\"You notice something in the collaboration that needs protecting, and your first impulse may be to carry it yourself. Instead, make the requirement concrete and attach it to the person handling the next step. The work can stay about execution rather than becoming a test of who cares.\",\"watch_for\":\"Watch for yourself revisiting a settled deadline after the next handoff owner has already been named.\",\"move\":\"Before the meeting ends, assign one owner and state the standard that marks the handoff complete.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, name the next handoff before a small concern turns into a personal reaction.",
      "pull_quote": "Your care is most useful today when it becomes a visible standard and a named owner.",
      "deeper_read": "You notice something in the collaboration that needs protecting, and your first impulse may be to carry it yourself. Instead, make the requirement concrete and attach it to the person handling the next step. The work can stay about execution rather than becoming a test of who cares.",
      "watch_for": "Watch for yourself revisiting a settled deadline after the next handoff owner has already been named.",
      "move": "Before the meeting ends, assign one owner and state the standard that marks the handoff complete."
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "deeper_read must be 1-2 sentences of 30-60 words"
      ]
    },
    "usage": {
      "input_tokens": 1193,
      "input_tokens_details": {
        "cache_write_tokens": 1190,
        "cached_tokens": 0
      },
      "output_tokens": 621,
      "output_tokens_details": {
        "reasoning_tokens": 462
      },
      "total_tokens": 1814
    }
  },
  {
    "attempt": 2,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a meeting or handoff, say who owns the next step before a small concern becomes personal.\",\"pull_quote\":\"A clear owner protects the standard better than carrying the concern alone.\",\"deeper_read\":\"You may notice a requirement slipping in the collaboration and feel ready to hold it yourself. Put the standard into plain language, then attach the next action to the person responsible for the handoff; this keeps the discussion on execution rather than on who cares most.\",\"watch_for\":\"Someone says, “We’ll handle it,” without naming who will send, review, or approve the next piece.\",\"move\":\"Before the meeting ends, ask for one name, one deliverable, and one deadline for the handoff.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a meeting or handoff, say who owns the next step before a small concern becomes personal.",
      "pull_quote": "A clear owner protects the standard better than carrying the concern alone.",
      "deeper_read": "You may notice a requirement slipping in the collaboration and feel ready to hold it yourself. Put the standard into plain language, then attach the next action to the person responsible for the handoff; this keeps the discussion on execution rather than on who cares most.",
      "watch_for": "Someone says, “We’ll handle it,” without naming who will send, review, or approve the next piece.",
      "move": "Before the meeting ends, ask for one name, one deliverable, and one deadline for the handoff."
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
      "output_tokens": 245,
      "output_tokens_details": {
        "reasoning_tokens": 84
      },
      "total_tokens": 1428
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
  "identity": "Cancer × Tiger",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings protective to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you take things personally"
  ],
  "identitySpecificRole": "the partner who turns protective into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking protective to disappear.",
  "ordinaryLifeExpression": "Evidence of protective becomes the test beneath a reassuring message.",
  "blindSpot": "You may take things personally after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning protective.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|love",
      "manifestationArena": "love",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by trust vs caution.",
      "perception": "The identity brings protective to closeness, where promises and pacing are tested.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you take things personally"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns protective into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking protective to disappear.",
    "ordinaryLifeExpression": "Evidence of protective becomes the test beneath a reassuring message.",
    "blindSpot": "You may take things personally after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning protective.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Small Detail",
  "intro": "A tender exchange lands well, yet one unanswered practical detail keeps you from fully settling into it.",
  "pull_quote": "You do not need certainty today; you need one promise translated into something you can actually notice.",
  "deeper_read": "The warmth is real, but you may still ask what it looks like once the ordinary week resumes. Rather than pulling back or reading the gap as personal, let directness protect the connection: name the detail that would make the reassurance feel usable.",
  "watch_for": "A sweet message ends without saying when, how, or who will follow through on the plan.",
  "move": "Reply warmly, then ask for one concrete next step, such as choosing a day or confirming a time."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Small Detail\",\"intro\":\"A tender exchange lands well, yet one unanswered practical detail keeps you from fully settling into it.\",\"pull_quote\":\"You do not need certainty today; you need one promise translated into something you can actually notice.\",\"deeper_read\":\"The warmth is real, but you may still ask what it looks like once the ordinary week resumes. Rather than pulling back or reading the gap as personal, let directness protect the connection: name the detail that would make the reassurance feel usable.\",\"watch_for\":\"A sweet message ends without saying when, how, or who will follow through on the plan.\",\"move\":\"Reply warmly, then ask for one concrete next step, such as choosing a day or confirming a time.\"}",
    "parsedResponse": {
      "title": "The Small Detail",
      "intro": "A tender exchange lands well, yet one unanswered practical detail keeps you from fully settling into it.",
      "pull_quote": "You do not need certainty today; you need one promise translated into something you can actually notice.",
      "deeper_read": "The warmth is real, but you may still ask what it looks like once the ordinary week resumes. Rather than pulling back or reading the gap as personal, let directness protect the connection: name the detail that would make the reassurance feel usable.",
      "watch_for": "A sweet message ends without saying when, how, or who will follow through on the plan.",
      "move": "Reply warmly, then ask for one concrete next step, such as choosing a day or confirming a time."
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
      "output_tokens": 156,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1208
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
  "identity": "Cancer × Tiger",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for protective shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you overreact emotionally"
  ],
  "identitySpecificRole": "the person who translates protective into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after protective has filled the day.",
  "ordinaryLifeExpression": "A physical change gives protective somewhere to be practiced at home.",
  "blindSpot": "You may struggle to regulate heat.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without protective running the room.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|home",
      "manifestationArena": "home",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by stability vs change.",
      "perception": "The need for protective shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you overreact emotionally"
      ],
      "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "stability vs change meets the identity's home mechanism.",
    "primaryArena": "home",
    "identitySpecificRole": "the person who translates protective into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after protective has filled the day.",
    "ordinaryLifeExpression": "A physical change gives protective somewhere to be practiced at home.",
    "blindSpot": "You may struggle to regulate heat.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without protective running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room First",
  "intro": "A familiar room asks more of you today, and one practical adjustment can keep the whole household from feeling crowded.",
  "pull_quote": "You do not need to defend every inch when one corner can clearly support your recovery.",
  "deeper_read": "When a shared routine or room starts pressing on your privacy, the first impulse may be to react to the whole arrangement at once. Instead, change one object’s placement or define one usable corner; a physical boundary can lower the heat without making the room a debate.",
  "watch_for": "You may move an item abruptly or claim a corner before saying what is bothering you.",
  "move": "Choose one shared-space condition to reset, then state plainly how that change makes the room workable."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room First\",\"intro\":\"A familiar room asks more of you today, and one practical adjustment can keep the whole household from feeling crowded.\",\"pull_quote\":\"You do not need to defend every inch when one corner can clearly support your recovery.\",\"deeper_read\":\"When a shared routine or room starts pressing on your privacy, the first impulse may be to react to the whole arrangement at once. Instead, change one object’s placement or define one usable corner; a physical boundary can lower the heat without making the room a debate.\",\"watch_for\":\"You may move an item abruptly or claim a corner before saying what is bothering you.\",\"move\":\"Choose one shared-space condition to reset, then state plainly how that change makes the room workable.\"}",
    "parsedResponse": {
      "title": "Make Room First",
      "intro": "A familiar room asks more of you today, and one practical adjustment can keep the whole household from feeling crowded.",
      "pull_quote": "You do not need to defend every inch when one corner can clearly support your recovery.",
      "deeper_read": "When a shared routine or room starts pressing on your privacy, the first impulse may be to react to the whole arrangement at once. Instead, change one object’s placement or define one usable corner; a physical boundary can lower the heat without making the room a debate.",
      "watch_for": "You may move an item abruptly or claim a corner before saying what is bothering you.",
      "move": "Choose one shared-space condition to reset, then state plainly how that change makes the room workable."
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
      "output_tokens": 157,
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
Retries: 1

### Manifestation

```json
{
  "identity": "Cancer × Tiger",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by protective.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you take things personally"
  ],
  "identitySpecificRole": "the friend who uses protective to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's protective.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around protective.",
  "blindSpot": "You your care arrives with enough force to fill the room.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the protective dynamic.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by protective.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you take things personally"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses protective to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's protective.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around protective.",
    "blindSpot": "You your care arrives with enough force to fill the room.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the protective dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Clearly",
  "intro": "A friend may smooth over the awkward part today, while you notice who is quietly carrying the group.",
  "pull_quote": "A specific invitation can say more honestly than a careful attempt to keep everyone comfortable.",
  "deeper_read": "You may feel your concern arrive strongly when the group’s usual helper is assumed to be available again. Rather than correcting the whole social tone or retreating from it, make one invitation that names your availability and gives that friend a place outside the favor.",
  "watch_for": "Notice whether someone accepts another favor before anyone asks what they actually have time for.",
  "move": "Text the friend who keeps doing the favors and invite them Thursday at seven."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Specific\",\"intro\":\"A friend may reach for a smooth tone today while the group keeps assigning someone the same role.\",\"pull_quote\":\"The kindest way to protect the connection is to name availability through one clear invitation.\",\"deeper_read\":\"You notice who is always asked for the favor, the lift, or the extra help, even when no one says it aloud. Rather than trying to settle everyone at once, make one plan with a real time, place, and limit so participation is no longer assumed.\",\"watch_for\":\"Watch for a vague “we should all hang out” that leaves the same person on standby.\",\"move\":\"Text the friend who keeps doing the favors: “Can you join me Thursday at seven?”\"}",
    "parsedResponse": {
      "title": "Make It Specific",
      "intro": "A friend may reach for a smooth tone today while the group keeps assigning someone the same role.",
      "pull_quote": "The kindest way to protect the connection is to name availability through one clear invitation.",
      "deeper_read": "You notice who is always asked for the favor, the lift, or the extra help, even when no one says it aloud. Rather than trying to settle everyone at once, make one plan with a real time, place, and limit so participation is no longer assumed.",
      "watch_for": "Watch for a vague “we should all hang out” that leaves the same person on standby.",
      "move": "Text the friend who keeps doing the favors: “Can you join me Thursday at seven?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1069,
      "input_tokens_details": {
        "cache_write_tokens": 1066,
        "cached_tokens": 0
      },
      "output_tokens": 674,
      "output_tokens_details": {
        "reasoning_tokens": 516
      },
      "total_tokens": 1743
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Make Room Clearly\",\"intro\":\"A friend may smooth over the awkward part today, while you notice who is quietly carrying the group.\",\"pull_quote\":\"A specific invitation can say more honestly than a careful attempt to keep everyone comfortable.\",\"deeper_read\":\"You may feel your concern arrive strongly when the group’s usual helper is assumed to be available again. Rather than correcting the whole social tone or retreating from it, make one invitation that names your availability and gives that friend a place outside the favor.\",\"watch_for\":\"Notice whether someone accepts another favor before anyone asks what they actually have time for.\",\"move\":\"Text the friend who keeps doing the favors and invite them Thursday at seven.\"}",
    "parsedResponse": {
      "title": "Make Room Clearly",
      "intro": "A friend may smooth over the awkward part today, while you notice who is quietly carrying the group.",
      "pull_quote": "A specific invitation can say more honestly than a careful attempt to keep everyone comfortable.",
      "deeper_read": "You may feel your concern arrive strongly when the group’s usual helper is assumed to be available again. Rather than correcting the whole social tone or retreating from it, make one invitation that names your availability and gives that friend a place outside the favor.",
      "watch_for": "Notice whether someone accepts another favor before anyone asks what they actually have time for.",
      "move": "Text the friend who keeps doing the favors and invite them Thursday at seven."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1198,
      "input_tokens_details": {
        "cache_write_tokens": 1195,
        "cached_tokens": 0
      },
      "output_tokens": 344,
      "output_tokens_details": {
        "reasoning_tokens": 196
      },
      "total_tokens": 1542
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
  "identity": "Cancer × Tiger",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by protective meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you overreact emotionally"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to protective comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what protective makes tempting.",
  "blindSpot": "You regret the choice when you take things personally.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a protective choice.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|money",
      "manifestationArena": "money",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by protective meets comfort, scarcity, status, and future options.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you overreact emotionally"
      ],
      "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "comfort vs restraint meets the identity's money mechanism.",
    "primaryArena": "money",
    "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
    "startingAssumption": "The visible money detail can be handled through the identity's default process.",
    "recognition": "The cost is honest when the future option tied to protective comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what protective makes tempting.",
    "blindSpot": "You regret the choice when you take things personally.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a protective choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Real Price",
  "intro": "At checkout, the small comfort expense looks different once you name the flexibility it quietly takes away.",
  "pull_quote": "The purchase is not wrong; it just deserves to sit beside the option it would remove.",
  "deeper_read": "You are already comparing relief with what remains possible after the charge clears, which makes this more than a budget line. Before reacting to the cost personally, put the comfort expense and the future option in the same sentence, then decide which one you are protecting today.",
  "watch_for": "You reopen the cart or banking app after noticing a bill, upcoming plan, or smaller remaining balance.",
  "move": "Write down the purchase amount and one specific option that amount would keep available if you wait."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Real Price\",\"intro\":\"At checkout, the small comfort expense looks different once you name the flexibility it quietly takes away.\",\"pull_quote\":\"The purchase is not wrong; it just deserves to sit beside the option it would remove.\",\"deeper_read\":\"You are already comparing relief with what remains possible after the charge clears, which makes this more than a budget line. Before reacting to the cost personally, put the comfort expense and the future option in the same sentence, then decide which one you are protecting today.\",\"watch_for\":\"You reopen the cart or banking app after noticing a bill, upcoming plan, or smaller remaining balance.\",\"move\":\"Write down the purchase amount and one specific option that amount would keep available if you wait.\"}",
    "parsedResponse": {
      "title": "The Real Price",
      "intro": "At checkout, the small comfort expense looks different once you name the flexibility it quietly takes away.",
      "pull_quote": "The purchase is not wrong; it just deserves to sit beside the option it would remove.",
      "deeper_read": "You are already comparing relief with what remains possible after the charge clears, which makes this more than a budget line. Before reacting to the cost personally, put the comfort expense and the future option in the same sentence, then decide which one you are protecting today.",
      "watch_for": "You reopen the cart or banking app after noticing a bill, upcoming plan, or smaller remaining balance.",
      "move": "Write down the purchase amount and one specific option that amount would keep available if you wait."
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

## rest

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Cancer × Tiger",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by protective active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you overreact emotionally"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from protective can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when protective keeps usefulness moving.",
  "blindSpot": "Emotions rise quickly and carry strength, especially around protection and loyalty",
  "naturalMove": "Close one open loop, then protect the remaining hour from the protective maintenance loop.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by protective active after the useful work is done.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you overreact emotionally"
      ],
      "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "responsibility vs autonomy meets the identity's rest mechanism.",
    "primaryArena": "rest",
    "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
    "startingAssumption": "The visible rest detail can be handled through the identity's default process.",
    "recognition": "Rest starts when recovery from protective can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when protective keeps usefulness moving.",
    "blindSpot": "Emotions rise quickly and carry strength, especially around protection and loyalty",
    "naturalMove": "Close one open loop, then protect the remaining hour from the protective maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Hour Stays Yours",
  "intro": "After closing one unfinished task, you may notice how quickly another small obligation tries to replace it.",
  "pull_quote": "Rest begins when you stop treating a quiet hour as space that needs to earn its keep.",
  "deeper_read": "Your care can make even downtime feel like a place to keep things running, especially after emotions rise around what needs protecting. Today, the useful choice is to end one maintenance loop and let the remaining hour be unavailable for proving you are still on top of everything.",
  "watch_for": "You finish a task, reach for your phone, then start scanning for the next thing to handle.",
  "move": "Put the phone away, name one task as complete, and keep the next hour free of follow-up."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Hour Stays Yours\",\"intro\":\"After closing one unfinished task, you may notice how quickly another small obligation tries to replace it.\",\"pull_quote\":\"Rest begins when you stop treating a quiet hour as space that needs to earn its keep.\",\"deeper_read\":\"Your care can make even downtime feel like a place to keep things running, especially after emotions rise around what needs protecting. Today, the useful choice is to end one maintenance loop and let the remaining hour be unavailable for proving you are still on top of everything.\",\"watch_for\":\"You finish a task, reach for your phone, then start scanning for the next thing to handle.\",\"move\":\"Put the phone away, name one task as complete, and keep the next hour free of follow-up.\"}",
    "parsedResponse": {
      "title": "The Hour Stays Yours",
      "intro": "After closing one unfinished task, you may notice how quickly another small obligation tries to replace it.",
      "pull_quote": "Rest begins when you stop treating a quiet hour as space that needs to earn its keep.",
      "deeper_read": "Your care can make even downtime feel like a place to keep things running, especially after emotions rise around what needs protecting. Today, the useful choice is to end one maintenance loop and let the remaining hour be unavailable for proving you are still on top of everything.",
      "watch_for": "You finish a task, reach for your phone, then start scanning for the next thing to handle.",
      "move": "Put the phone away, name one task as complete, and keep the next hour free of follow-up."
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
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1228
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
  "identity": "Cancer × Tiger",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for protective is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you take things personally"
  ],
  "identitySpecificRole": "the contributor who can accept protective without performing a larger identity",
  "recognition": "Confidence settles when praise names the protective contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger protective performance.",
  "blindSpot": "Moves Gentle, Runs Hot",
  "naturalMove": "Credit the contribution accurately, then stop before you take things personally.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for protective is tested by praise, attribution, and visible competence.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you take things personally"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept protective without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the protective contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger protective performance.",
    "blindSpot": "Moves Gentle, Runs Hot",
    "naturalMove": "Credit the contribution accurately, then stop before you take things personally.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
  "pull_quote": "A clear acknowledgment of what you did is enough; you do not need to soften it or defend it.",
  "deeper_read": "Praise may put you briefly on alert, especially when your contribution was meant to protect a result rather than draw attention. Name your part plainly, let the finished work remain visible, and resist adding explanations once the attribution has already been made.",
  "watch_for": "You may start to qualify a compliment with luck, a joke, or a quick list of everyone else involved.",
  "move": "Say, “Thank you—I handled that part,” then return the conversation to the result."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your work, you can accept the credit without turning the moment into a bigger performance.\",\"pull_quote\":\"A clear acknowledgment of what you did is enough; you do not need to soften it or defend it.\",\"deeper_read\":\"Praise may put you briefly on alert, especially when your contribution was meant to protect a result rather than draw attention. Name your part plainly, let the finished work remain visible, and resist adding explanations once the attribution has already been made.\",\"watch_for\":\"You may start to qualify a compliment with luck, a joke, or a quick list of everyone else involved.\",\"move\":\"Say, “Thank you—I handled that part,” then return the conversation to the result.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your work, you can accept the credit without turning the moment into a bigger performance.",
      "pull_quote": "A clear acknowledgment of what you did is enough; you do not need to soften it or defend it.",
      "deeper_read": "Praise may put you briefly on alert, especially when your contribution was meant to protect a result rather than draw attention. Name your part plainly, let the finished work remain visible, and resist adding explanations once the attribution has already been made.",
      "watch_for": "You may start to qualify a compliment with luck, a joke, or a quick list of everyone else involved.",
      "move": "Say, “Thank you—I handled that part,” then return the conversation to the result."
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
      "output_tokens": 157,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1204
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
  "identity": "Cancer × Tiger",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by protective is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you overreact emotionally"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as protective reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a protective working style.",
  "blindSpot": "You release the work by leting directness do the job that retreat keeps trying to do.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this protective rhythm.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by protective is reducing friction or preserving confinement.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you overreact emotionally"
      ],
      "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "consistency vs freedom meets the identity's routine mechanism.",
    "primaryArena": "routine",
    "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
    "startingAssumption": "The visible routine detail can be handled through the identity's default process.",
    "recognition": "The routine earns its place when the strength expressed as protective reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a protective working style.",
    "blindSpot": "You release the work by leting directness do the job that retreat keeps trying to do.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this protective rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Adjust the Sequence",
  "intro": "A reliable routine starts to grate when one repeated step keeps creating work you should not have to redo.",
  "pull_quote": "The useful change is not abandoning the routine; it is naming the step that keeps trapping your effort.",
  "deeper_read": "Today, treat irritation as a practical signal: mark the part of the schedule, ritual, or optimization that produces the most rework. Instead of pulling away from the whole structure, say plainly what is not working and change its order; the routine only needs to protect the result, not itself.",
  "watch_for": "You catch yourself bracing for a familiar step, then notice it has created the same correction again.",
  "move": "Move that step earlier, later, or off the list once, and compare how the rest of the routine lands."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Adjust the Sequence\",\"intro\":\"A reliable routine starts to grate when one repeated step keeps creating work you should not have to redo.\",\"pull_quote\":\"The useful change is not abandoning the routine; it is naming the step that keeps trapping your effort.\",\"deeper_read\":\"Today, treat irritation as a practical signal: mark the part of the schedule, ritual, or optimization that produces the most rework. Instead of pulling away from the whole structure, say plainly what is not working and change its order; the routine only needs to protect the result, not itself.\",\"watch_for\":\"You catch yourself bracing for a familiar step, then notice it has created the same correction again.\",\"move\":\"Move that step earlier, later, or off the list once, and compare how the rest of the routine lands.\"}",
    "parsedResponse": {
      "title": "Adjust the Sequence",
      "intro": "A reliable routine starts to grate when one repeated step keeps creating work you should not have to redo.",
      "pull_quote": "The useful change is not abandoning the routine; it is naming the step that keeps trapping your effort.",
      "deeper_read": "Today, treat irritation as a practical signal: mark the part of the schedule, ritual, or optimization that produces the most rework. Instead of pulling away from the whole structure, say plainly what is not working and change its order; the routine only needs to protect the result, not itself.",
      "watch_for": "You catch yourself bracing for a familiar step, then notice it has created the same correction again.",
      "move": "Move that step earlier, later, or off the list once, and compare how the rest of the routine lands."
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
      "output_tokens": 171,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1236
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
  "identity": "Cancer × Tiger",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The reactive response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you take things personally"
  ],
  "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against reactive is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before reactive takes over.",
  "blindSpot": "You may decide from reactive instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses reactive.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by directness vs patience.",
      "perception": "The reactive response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you take things personally"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the protector who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against reactive is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before reactive takes over.",
    "blindSpot": "You may decide from reactive instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses reactive.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Shift",
  "intro": "A small disagreement sharpens when you name the changed behavior before assigning a reason to it.",
  "pull_quote": "You can be direct without making the other person's motive the evidence.",
  "deeper_read": "The tone shift or avoided point may be real, but deciding what it meant can turn a repairable exchange into an escalation. Start with the impact you can point to, then set one condition for continuing the conversation.",
  "watch_for": "Watch for yourself responding to a sharp tone with a conclusion about why it happened.",
  "move": "State the behavior, describe its impact, and name the one repair you need before continuing."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you name what changed in the exchange before deciding what it meant.\",\"pull_quote\":\"You do not need to soften the point; you need to make the next repair specific.\",\"deeper_read\":\"The tone shift may feel like the whole issue, but begin with the observable impact: what was said, what was interrupted, or what agreement changed. Then set one condition for continuing the conversation, so your response protects the point without turning an assumption into evidence.\",\"watch_for\":\"Notice if you start answering an implied motive instead of the words or action actually in front of you.\",\"move\":\"Say, “When that changed, it affected me this way; I can continue if we address this first.”\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you name what changed in the exchange before deciding what it meant.",
      "pull_quote": "You do not need to soften the point; you need to make the next repair specific.",
      "deeper_read": "The tone shift may feel like the whole issue, but begin with the observable impact: what was said, what was interrupted, or what agreement changed. Then set one condition for continuing the conversation, so your response protects the point without turning an assumption into evidence.",
      "watch_for": "Notice if you start answering an implied motive instead of the words or action actually in front of you.",
      "move": "Say, “When that changed, it affected me this way; I can continue if we address this first.”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1068,
      "input_tokens_details": {
        "cache_write_tokens": 1065,
        "cached_tokens": 0
      },
      "output_tokens": 161,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1229
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Shift\",\"intro\":\"A small disagreement sharpens when you name the changed behavior before assigning a reason to it.\",\"pull_quote\":\"You can be direct without making the other person's motive the evidence.\",\"deeper_read\":\"The tone shift or avoided point may be real, but deciding what it meant can turn a repairable exchange into an escalation. Start with the impact you can point to, then set one condition for continuing the conversation.\",\"watch_for\":\"Watch for yourself responding to a sharp tone with a conclusion about why it happened.\",\"move\":\"State the behavior, describe its impact, and name the one repair you need before continuing.\"}",
    "parsedResponse": {
      "title": "Name the Shift",
      "intro": "A small disagreement sharpens when you name the changed behavior before assigning a reason to it.",
      "pull_quote": "You can be direct without making the other person's motive the evidence.",
      "deeper_read": "The tone shift or avoided point may be real, but deciding what it meant can turn a repairable exchange into an escalation. Start with the impact you can point to, then set one condition for continuing the conversation.",
      "watch_for": "Watch for yourself responding to a sharp tone with a conclusion about why it happened.",
      "move": "State the behavior, describe its impact, and name the one repair you need before continuing."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1201,
      "input_tokens_details": {
        "cache_write_tokens": 1198,
        "cached_tokens": 0
      },
      "output_tokens": 577,
      "output_tokens_details": {
        "reasoning_tokens": 438
      },
      "total_tokens": 1778
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
  "identity": "Cancer × Tiger",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by protective competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you overreact emotionally"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects protective and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for protective.",
  "blindSpot": "You delay when you overreact emotionally.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about protective.",
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
    "signPair": "Cancer × Tiger",
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
      "manifestationKey": "Cancer × Tiger|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You your care arrives with enough force to fill the room. Growth begins when you let directness do the job that retreat keeps trying to do. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by protective competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with protective, expressive, and bold when it matters. Then you defend what matters deeply.",
      "pressureOrGrowth": "Under pressure, you first overreact emotionally.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you overreact emotionally"
      ],
      "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "security vs expansion meets the identity's opportunity mechanism.",
    "primaryArena": "opportunity",
    "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
    "startingAssumption": "The visible opportunity detail can be handled through the identity's default process.",
    "recognition": "The opening is real when the next action reflects protective and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for protective.",
    "blindSpot": "You delay when you overreact emotionally.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about protective.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Leap",
  "intro": "A promising offer may ask you to loosen your grip on what already works, without abandoning caution.",
  "pull_quote": "You do not need to make the risk feel harmless before taking a small, measurable step.",
  "deeper_read": "Instead of treating the offer as a choice between safety and ambition, ask what evidence would justify leaving the proven position. Give the opening a boundary: a deadline, a trial scope, or one concrete proof point that lets you respond directly rather than retreat into an emotional first reaction.",
  "watch_for": "Notice if you keep rereading the offer or asking for reassurance without naming the evidence you need.",
  "move": "Set up a reversible test with a clear end date and one result you can evaluate."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Leap\",\"intro\":\"A promising offer may ask you to loosen your grip on what already works, without abandoning caution.\",\"pull_quote\":\"You do not need to make the risk feel harmless before taking a small, measurable step.\",\"deeper_read\":\"Instead of treating the offer as a choice between safety and ambition, ask what evidence would justify leaving the proven position. Give the opening a boundary: a deadline, a trial scope, or one concrete proof point that lets you respond directly rather than retreat into an emotional first reaction.\",\"watch_for\":\"Notice if you keep rereading the offer or asking for reassurance without naming the evidence you need.\",\"move\":\"Set up a reversible test with a clear end date and one result you can evaluate.\"}",
    "parsedResponse": {
      "title": "Proof Before Leap",
      "intro": "A promising offer may ask you to loosen your grip on what already works, without abandoning caution.",
      "pull_quote": "You do not need to make the risk feel harmless before taking a small, measurable step.",
      "deeper_read": "Instead of treating the offer as a choice between safety and ambition, ask what evidence would justify leaving the proven position. Give the opening a boundary: a deadline, a trial scope, or one concrete proof point that lets you respond directly rather than retreat into an emotional first reaction.",
      "watch_for": "Notice if you keep rereading the offer or asking for reassurance without naming the evidence you need.",
      "move": "Set up a reversible test with a clear end date and one result you can evaluate."
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
      "output_tokens": 157,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1227
    }
  }
]
```
