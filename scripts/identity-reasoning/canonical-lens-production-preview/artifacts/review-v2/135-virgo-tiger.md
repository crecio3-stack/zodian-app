# 135 · Virgo × Tiger

Status: complete
Source: Resources/archetypes.json#virgo-tiger
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
  "identity": "Virgo × Tiger",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You maintain focus under pressure. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you react too quickly",
    "uses you channel energy into action to make one standard visible before you push too hard"
  ],
  "identitySpecificRole": "the organizer who turns thrives in high-performance environments into clear ownership",
  "recognition": "The work improves when the driven result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes driven observable before ownership is finalized.",
  "blindSpot": "You may push too hard after the work is already good enough.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|work",
      "manifestationArena": "work",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by speaking up vs waiting.",
      "perception": "You maintain focus under pressure. becomes visible around ownership and execution.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "names who owns the next handoff before you react too quickly",
        "uses you channel energy into action to make one standard visible before you push too hard"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the organizer who turns thrives in high-performance environments into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the driven result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes driven observable before ownership is finalized.",
    "blindSpot": "You may push too hard after the work is already good enough.",
    "naturalMove": "Clarify one owner and use driven as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In a meeting, you notice the next handoff forming before anyone has named who owns it.",
  "pull_quote": "Useful work stays useful when its next owner is clear before the discussion gathers speed.",
  "deeper_read": "Your instinct is to turn a loose deadline or collaboration into action quickly, especially when the standard is obvious to you. Today, make the result legible first: name the owner of the next handoff, then point to one visible standard rather than refining past what the work needs.",
  "watch_for": "Watch for yourself assigning the next task in the meeting before confirming who will carry it.",
  "move": "Identify the owner for the next handoff and state the single standard that guides the finished work."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, you notice the next handoff is forming before anyone has said who owns it.\",\"pull_quote\":\"A useful interruption is not the same as taking over the whole discussion.\",\"deeper_read\":\"You are quick to turn a vague deadline or collaboration into action, especially when execution could stall. Today, make the work easier to follow by naming one owner and one visible standard, then let the group respond before refining it further.\",\"watch_for\":\"Someone says “we’ll handle it,” and you begin assigning steps before asking who will take the handoff.\",\"move\":\"Say, “Who owns the next handoff?” then state the one standard the finished work needs to meet.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, you notice the next handoff is forming before anyone has said who owns it.",
      "pull_quote": "A useful interruption is not the same as taking over the whole discussion.",
      "deeper_read": "You are quick to turn a vague deadline or collaboration into action, especially when execution could stall. Today, make the work easier to follow by naming one owner and one visible standard, then let the group respond before refining it further.",
      "watch_for": "Someone says “we’ll handle it,” and you begin assigning steps before asking who will take the handoff.",
      "move": "Say, “Who owns the next handoff?” then state the one standard the finished work needs to meet."
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
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
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In a meeting, you notice the next handoff forming before anyone has named who owns it.\",\"pull_quote\":\"Useful work stays useful when its next owner is clear before the discussion gathers speed.\",\"deeper_read\":\"Your instinct is to turn a loose deadline or collaboration into action quickly, especially when the standard is obvious to you. Today, make the result legible first: name the owner of the next handoff, then point to one visible standard rather than refining past what the work needs.\",\"watch_for\":\"Watch for yourself assigning the next task in the meeting before confirming who will carry it.\",\"move\":\"Identify the owner for the next handoff and state the single standard that guides the finished work.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In a meeting, you notice the next handoff forming before anyone has named who owns it.",
      "pull_quote": "Useful work stays useful when its next owner is clear before the discussion gathers speed.",
      "deeper_read": "Your instinct is to turn a loose deadline or collaboration into action quickly, especially when the standard is obvious to you. Today, make the result legible first: name the owner of the next handoff, then point to one visible standard rather than refining past what the work needs.",
      "watch_for": "Watch for yourself assigning the next task in the meeting before confirming who will carry it.",
      "move": "Identify the owner for the next handoff and state the single standard that guides the finished work."
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
      "output_tokens": 536,
      "output_tokens_details": {
        "reasoning_tokens": 377
      },
      "total_tokens": 1726
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
  "identity": "Virgo × Tiger",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings driven to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you push too hard"
  ],
  "identitySpecificRole": "the partner who turns driven into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking driven to disappear.",
  "ordinaryLifeExpression": "Evidence of driven becomes the test beneath a reassuring message.",
  "blindSpot": "You may push too hard after closeness is already possible.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|love",
      "manifestationArena": "love",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by trust vs caution.",
      "perception": "The identity brings driven to closeness, where promises and pacing are tested.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you push too hard"
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
    "blindSpot": "You may push too hard after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning driven.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "One Clear Detail",
  "intro": "A tender message lands well, but you notice the practical part of the promise still has no shape.",
  "pull_quote": "You do not need more reassurance when one small follow-through can make the warmth feel real.",
  "deeper_read": "You are quick to spot what has not been settled, especially when affection is paired with a plan for shared time. Rather than pressing for certainty or letting the detail slide, ask what the promise looks like this week and leave room for an ordinary, workable answer.",
  "watch_for": "A sweet exchange turns into rapid questions when no time, place, or next step has been named.",
  "move": "Reply warmly, then suggest one specific follow-through detail they can confirm without turning it into a test."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"One Clear Detail\",\"intro\":\"A tender message lands well, but you notice the practical part of the promise still has no shape.\",\"pull_quote\":\"You do not need more reassurance when one small follow-through can make the warmth feel real.\",\"deeper_read\":\"You are quick to spot what has not been settled, especially when affection is paired with a plan for shared time. Rather than pressing for certainty or letting the detail slide, ask what the promise looks like this week and leave room for an ordinary, workable answer.\",\"watch_for\":\"A sweet exchange turns into rapid questions when no time, place, or next step has been named.\",\"move\":\"Reply warmly, then suggest one specific follow-through detail they can confirm without turning it into a test.\"}",
    "parsedResponse": {
      "title": "One Clear Detail",
      "intro": "A tender message lands well, but you notice the practical part of the promise still has no shape.",
      "pull_quote": "You do not need more reassurance when one small follow-through can make the warmth feel real.",
      "deeper_read": "You are quick to spot what has not been settled, especially when affection is paired with a plan for shared time. Rather than pressing for certainty or letting the detail slide, ask what the promise looks like this week and leave room for an ordinary, workable answer.",
      "watch_for": "A sweet exchange turns into rapid questions when no time, place, or next step has been named.",
      "move": "Reply warmly, then suggest one specific follow-through detail they can confirm without turning it into a test."
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
      "output_tokens": 159,
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
  "identity": "Virgo × Tiger",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for driven shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you react too quickly"
  ],
  "identitySpecificRole": "the person who translates driven into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after driven has filled the day.",
  "ordinaryLifeExpression": "A physical change gives driven somewhere to be practiced at home.",
  "blindSpot": "You may struggle with patience.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|home",
      "manifestationArena": "home",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by stability vs change.",
      "perception": "The need for driven shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "changes the placement of one object before debating the whole household",
        "protects a private corner when you react too quickly"
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
    "blindSpot": "You may struggle with patience.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without driven running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room to Land",
  "intro": "A familiar room may ask for one practical adjustment after a day that has left little space to settle.",
  "pull_quote": "You do not need to redesign the household; one useful change can make the room easier to return to.",
  "deeper_read": "You may notice the problem quickly and start moving an object before anyone has finished discussing the whole setup. Let that first action serve the shared room: create a clear place where recovery can happen, rather than letting urgency set the tone for everyone.",
  "watch_for": "You shift a chair, basket, or charger while someone is still explaining why the room feels crowded.",
  "move": "Choose one shared-space surface and clear it for a quiet, everyday use before changing anything else."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room to Land\",\"intro\":\"A familiar room may ask for one practical adjustment after a day that has left little space to settle.\",\"pull_quote\":\"You do not need to redesign the household; one useful change can make the room easier to return to.\",\"deeper_read\":\"You may notice the problem quickly and start moving an object before anyone has finished discussing the whole setup. Let that first action serve the shared room: create a clear place where recovery can happen, rather than letting urgency set the tone for everyone.\",\"watch_for\":\"You shift a chair, basket, or charger while someone is still explaining why the room feels crowded.\",\"move\":\"Choose one shared-space surface and clear it for a quiet, everyday use before changing anything else.\"}",
    "parsedResponse": {
      "title": "Make Room to Land",
      "intro": "A familiar room may ask for one practical adjustment after a day that has left little space to settle.",
      "pull_quote": "You do not need to redesign the household; one useful change can make the room easier to return to.",
      "deeper_read": "You may notice the problem quickly and start moving an object before anyone has finished discussing the whole setup. Let that first action serve the shared room: create a clear place where recovery can happen, rather than letting urgency set the tone for everyone.",
      "watch_for": "You shift a chair, basket, or charger while someone is still explaining why the room feels crowded.",
      "move": "Choose one shared-space surface and clear it for a quiet, everyday use before changing anything else."
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
      "output_tokens": 158,
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
  "identity": "Virgo × Tiger",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by driven.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you push too hard"
  ],
  "identitySpecificRole": "the friend who uses driven to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's driven.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around driven.",
  "blindSpot": "You spot the problem and move before discussion catches up.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by driven.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you push too hard"
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
    "blindSpot": "You spot the problem and move before discussion catches up.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the driven dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Clearly",
  "intro": "When a friend smooths things over, you notice who keeps getting assigned the role nobody named.",
  "pull_quote": "A specific invitation can say more honestly than another quick fix for the group dynamic.",
  "deeper_read": "You may be ready to reorganize the plan before anyone names what is happening, especially when one person is always expected to be available or helpful. Instead, let usefulness lead: invite that person to something concrete, with the time and expectation stated plainly.",
  "watch_for": "Notice if someone says “it’s fine” while the same favor quietly lands with them again.",
  "move": "Send one direct invitation that names the plan, the timing, and that they are welcome to decline."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room Clearly\",\"intro\":\"When a friend smooths things over, you notice who keeps getting assigned the role nobody named.\",\"pull_quote\":\"A specific invitation can say more honestly than another quick fix for the group dynamic.\",\"deeper_read\":\"You may be ready to reorganize the plan before anyone names what is happening, especially when one person is always expected to be available or helpful. Instead, let usefulness lead: invite that person to something concrete, with the time and expectation stated plainly.\",\"watch_for\":\"Notice if someone says “it’s fine” while the same favor quietly lands with them again.\",\"move\":\"Send one direct invitation that names the plan, the timing, and that they are welcome to decline.\"}",
    "parsedResponse": {
      "title": "Make Room Clearly",
      "intro": "When a friend smooths things over, you notice who keeps getting assigned the role nobody named.",
      "pull_quote": "A specific invitation can say more honestly than another quick fix for the group dynamic.",
      "deeper_read": "You may be ready to reorganize the plan before anyone names what is happening, especially when one person is always expected to be available or helpful. Instead, let usefulness lead: invite that person to something concrete, with the time and expectation stated plainly.",
      "watch_for": "Notice if someone says “it’s fine” while the same favor quietly lands with them again.",
      "move": "Send one direct invitation that names the plan, the timing, and that they are welcome to decline."
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

## money

Validator: accepted
Retries: 0

### Manifestation

```json
{
  "identity": "Virgo × Tiger",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by driven meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you react too quickly"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to driven comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what driven makes tempting.",
  "blindSpot": "You regret the choice when you push too hard.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|money",
      "manifestationArena": "money",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by driven meets comfort, scarcity, status, and future options.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "compares the relief of a purchase with the option it removes",
        "waits for evidence before you react too quickly"
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
    "blindSpot": "You regret the choice when you push too hard.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a driven choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Price the Relief",
  "intro": "Before tapping buy, you notice the comfort expense and the flexibility it would quietly take off the table.",
  "pull_quote": "The useful question is not whether it helps, but which later option you are spending to get it.",
  "deeper_read": "You can spot the tradeoff quickly today: a small purchase, a bill paid early, or an upgrade that makes the afternoon easier. Let the immediate relief and the future option share the same line in your budget before acting; speed is useful, but pushing hard can make the choice feel expensive later.",
  "watch_for": "You compare a convenience purchase with the amount left for a planned expense, then reach for checkout anyway.",
  "move": "Name one future use for the money, then decide whether today’s relief is worth that exact trade."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Price the Relief\",\"intro\":\"Before tapping buy, you notice the comfort expense and the flexibility it would quietly take off the table.\",\"pull_quote\":\"The useful question is not whether it helps, but which later option you are spending to get it.\",\"deeper_read\":\"You can spot the tradeoff quickly today: a small purchase, a bill paid early, or an upgrade that makes the afternoon easier. Let the immediate relief and the future option share the same line in your budget before acting; speed is useful, but pushing hard can make the choice feel expensive later.\",\"watch_for\":\"You compare a convenience purchase with the amount left for a planned expense, then reach for checkout anyway.\",\"move\":\"Name one future use for the money, then decide whether today’s relief is worth that exact trade.\"}",
    "parsedResponse": {
      "title": "Price the Relief",
      "intro": "Before tapping buy, you notice the comfort expense and the flexibility it would quietly take off the table.",
      "pull_quote": "The useful question is not whether it helps, but which later option you are spending to get it.",
      "deeper_read": "You can spot the tradeoff quickly today: a small purchase, a bill paid early, or an upgrade that makes the afternoon easier. Let the immediate relief and the future option share the same line in your budget before acting; speed is useful, but pushing hard can make the choice feel expensive later.",
      "watch_for": "You compare a convenience purchase with the amount left for a planned expense, then reach for checkout anyway.",
      "move": "Name one future use for the money, then decide whether today’s relief is worth that exact trade."
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
      "output_tokens": 169,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1231
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
  "identity": "Virgo × Tiger",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by driven active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you react too quickly"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from driven can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when driven keeps usefulness moving.",
  "blindSpot": "Emotions are strong but often directed into action",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by driven active after the useful work is done.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "ends one maintenance loop before checking for another",
        "puts the phone away when you react too quickly"
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
    "blindSpot": "Emotions are strong but often directed into action",
    "naturalMove": "Close one open loop, then protect the remaining hour from the driven maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Remaining Hour",
  "intro": "After finishing one necessary task, you may notice your hand reaching for the next small obligation.",
  "pull_quote": "Rest becomes practical when you stop treating an unplanned hour as something that needs fixing.",
  "deeper_read": "You are quick to spot what still needs attention, especially once a maintenance loop is already in motion. Tonight, usefulness does not require a perfect handoff: close one open task, put the phone away, and let the quiet hour remain unfinished by design.",
  "watch_for": "You finish a chore, then open your phone and immediately scan for another thing to handle.",
  "move": "Set the phone across the room after one completed task, and keep the next hour unassigned."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Remaining Hour\",\"intro\":\"After finishing one necessary task, you may notice your hand reaching for the next small obligation.\",\"pull_quote\":\"Rest becomes practical when you stop treating an unplanned hour as something that needs fixing.\",\"deeper_read\":\"You are quick to spot what still needs attention, especially once a maintenance loop is already in motion. Tonight, usefulness does not require a perfect handoff: close one open task, put the phone away, and let the quiet hour remain unfinished by design.\",\"watch_for\":\"You finish a chore, then open your phone and immediately scan for another thing to handle.\",\"move\":\"Set the phone across the room after one completed task, and keep the next hour unassigned.\"}",
    "parsedResponse": {
      "title": "The Remaining Hour",
      "intro": "After finishing one necessary task, you may notice your hand reaching for the next small obligation.",
      "pull_quote": "Rest becomes practical when you stop treating an unplanned hour as something that needs fixing.",
      "deeper_read": "You are quick to spot what still needs attention, especially once a maintenance loop is already in motion. Tonight, usefulness does not require a perfect handoff: close one open task, put the phone away, and let the quiet hour remain unfinished by design.",
      "watch_for": "You finish a chore, then open your phone and immediately scan for another thing to handle.",
      "move": "Set the phone across the room after one completed task, and keep the next hour unassigned."
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
      "output_tokens": 152,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1210
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
  "identity": "Virgo × Tiger",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for driven is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you push too hard"
  ],
  "identitySpecificRole": "the contributor who can accept driven without performing a larger identity",
  "recognition": "Confidence settles when praise names the driven contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger driven performance.",
  "blindSpot": "Acts Useful, Shows Teeth",
  "naturalMove": "Credit the contribution accurately, then stop before you push too hard.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for driven is tested by praise, attribution, and visible competence.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you push too hard"
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
    "blindSpot": "Acts Useful, Shows Teeth",
    "naturalMove": "Credit the contribution accurately, then stop before you push too hard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Land",
  "intro": "When someone names your contribution, you can accept the credit without turning the moment into another performance.",
  "pull_quote": "A clear “thank you” lets the result be visible without asking you to prove it twice.",
  "deeper_read": "You may be ready to point out the next issue or explain exactly how much effort went into the result. Instead, state your part accurately if needed, then let the finished work carry its own weight for a minute.",
  "watch_for": "After praise in a meeting or message thread, notice the urge to immediately add another task or correction.",
  "move": "Reply with a specific thank-you and one factual sentence about your contribution, then return to the work."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Land\",\"intro\":\"When someone names your contribution, you can accept the credit without turning the moment into another performance.\",\"pull_quote\":\"A clear “thank you” lets the result be visible without asking you to prove it twice.\",\"deeper_read\":\"You may be ready to point out the next issue or explain exactly how much effort went into the result. Instead, state your part accurately if needed, then let the finished work carry its own weight for a minute.\",\"watch_for\":\"After praise in a meeting or message thread, notice the urge to immediately add another task or correction.\",\"move\":\"Reply with a specific thank-you and one factual sentence about your contribution, then return to the work.\"}",
    "parsedResponse": {
      "title": "Let It Land",
      "intro": "When someone names your contribution, you can accept the credit without turning the moment into another performance.",
      "pull_quote": "A clear “thank you” lets the result be visible without asking you to prove it twice.",
      "deeper_read": "You may be ready to point out the next issue or explain exactly how much effort went into the result. Instead, state your part accurately if needed, then let the finished work carry its own weight for a minute.",
      "watch_for": "After praise in a meeting or message thread, notice the urge to immediately add another task or correction.",
      "move": "Reply with a specific thank-you and one factual sentence about your contribution, then return to the work."
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
      "output_tokens": 150,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1192
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
  "identity": "Virgo × Tiger",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by driven is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you react too quickly"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as driven reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a driven working style.",
  "blindSpot": "You release the work by leting usefulness outrank exactness for a minute.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by driven is reducing friction or preserving confinement.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "marks the repeated step that creates the most rework",
        "changes the sequence before you react too quickly"
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
    "blindSpot": "You release the work by leting usefulness outrank exactness for a minute.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this driven rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Loosen the Sequence",
  "intro": "A routine step that once kept things moving now stands out because it creates the same avoidable rework.",
  "pull_quote": "You do not need to defend the exact order when a small adjustment makes the task genuinely easier.",
  "deeper_read": "You are quick to spot where the sequence stops serving the result, especially in a schedule, ritual, or repeated task. Before irritation turns into a wholesale overhaul, test one useful change and let the rest of the routine remain ordinary.",
  "watch_for": "Notice the moment you reach to change the whole system after repeating one frustrating step.",
  "move": "Swap the most repetitive step with the next one once, then keep the version that reduces rework."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Loosen the Sequence\",\"intro\":\"A routine step that once kept things moving now stands out because it creates the same avoidable rework.\",\"pull_quote\":\"You do not need to defend the exact order when a small adjustment makes the task genuinely easier.\",\"deeper_read\":\"You are quick to spot where the sequence stops serving the result, especially in a schedule, ritual, or repeated task. Before irritation turns into a wholesale overhaul, test one useful change and let the rest of the routine remain ordinary.\",\"watch_for\":\"Notice the moment you reach to change the whole system after repeating one frustrating step.\",\"move\":\"Swap the most repetitive step with the next one once, then keep the version that reduces rework.\"}",
    "parsedResponse": {
      "title": "Loosen the Sequence",
      "intro": "A routine step that once kept things moving now stands out because it creates the same avoidable rework.",
      "pull_quote": "You do not need to defend the exact order when a small adjustment makes the task genuinely easier.",
      "deeper_read": "You are quick to spot where the sequence stops serving the result, especially in a schedule, ritual, or repeated task. Before irritation turns into a wholesale overhaul, test one useful change and let the rest of the routine remain ordinary.",
      "watch_for": "Notice the moment you reach to change the whole system after repeating one frustrating step.",
      "move": "Swap the most repetitive step with the next one once, then keep the version that reduces rework."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1057,
      "input_tokens_details": {
        "cache_write_tokens": 1054,
        "cached_tokens": 0
      },
      "output_tokens": 152,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1209
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
  "identity": "Virgo × Tiger",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The reactive response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you push too hard"
  ],
  "identitySpecificRole": "the organizer who makes the conflict precise enough to repair",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by directness vs patience.",
      "perception": "The reactive response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you push too hard"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the organizer who makes the conflict precise enough to repair",
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
  "title": "Make Repair Specific",
  "intro": "A small disagreement sharpens when you name its actual impact instead of filling in the other person's motive.",
  "pull_quote": "The useful boundary is not a verdict; it is the one change needed to make repair possible.",
  "deeper_read": "You may be ready to act before the conversation has caught up, especially after a tone shift or avoided point. Slow the escalation by separating what was said or done from what you think it meant, then make the next step concrete enough for someone to answer.",
  "watch_for": "Notice if you start building a case from their tone before naming the specific impact on you.",
  "move": "Say what changed, cite the relevant detail, and ask for one repair condition before continuing the argument."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Repair Specific\",\"intro\":\"A small disagreement sharpens when you name its actual impact instead of filling in the other person's motive.\",\"pull_quote\":\"The useful boundary is not a verdict; it is the one change needed to make repair possible.\",\"deeper_read\":\"You may be ready to act before the conversation has caught up, especially after a tone shift or avoided point. Slow the escalation by separating what was said or done from what you think it meant, then make the next step concrete enough for someone to answer.\",\"watch_for\":\"Notice if you start building a case from their tone before naming the specific impact on you.\",\"move\":\"Say what changed, cite the relevant detail, and ask for one repair condition before continuing the argument.\"}",
    "parsedResponse": {
      "title": "Make Repair Specific",
      "intro": "A small disagreement sharpens when you name its actual impact instead of filling in the other person's motive.",
      "pull_quote": "The useful boundary is not a verdict; it is the one change needed to make repair possible.",
      "deeper_read": "You may be ready to act before the conversation has caught up, especially after a tone shift or avoided point. Slow the escalation by separating what was said or done from what you think it meant, then make the next step concrete enough for someone to answer.",
      "watch_for": "Notice if you start building a case from their tone before naming the specific impact on you.",
      "move": "Say what changed, cite the relevant detail, and ask for one repair condition before continuing the argument."
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
      "output_tokens": 157,
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
  "identity": "Virgo × Tiger",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by driven competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you react too quickly"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects driven and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for driven.",
  "blindSpot": "You delay when you react too quickly.",
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
    "signPair": "Virgo × Tiger",
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
      "manifestationKey": "Virgo × Tiger|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You spot the problem and move before discussion catches up. Growth begins when you let usefulness outrank exactness for a minute. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by driven competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with focused, driven, and powerful when activated. Then you channel energy into action.",
      "pressureOrGrowth": "Under pressure, you first react too quickly.",
      "observableBehaviors": [
        "asks what evidence would make the opening worth leaving a proven position",
        "builds a reversible test before you react too quickly"
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
    "blindSpot": "You delay when you react too quickly.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about driven.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before Departure",
  "intro": "An appealing offer may ask you to leave what works, but you do not need to decide all at once.",
  "pull_quote": "The useful question is not whether the opening is safe, but what evidence would make it worth testing.",
  "deeper_read": "You spot the upside quickly; the risk is answering before the details catch up. Instead of treating the offer as a permanent exit, set a time-limited trial with one proof point—scope, revenue, workload, or a clear deadline—that lets ambition meet evidence.",
  "watch_for": "Notice whether you answer the offer immediately or ask which proof point would justify leaving your current position.",
  "move": "Propose a two-week reversible test, define one result to observe, and set the date for reviewing it."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before Departure\",\"intro\":\"An appealing offer may ask you to leave what works, but you do not need to decide all at once.\",\"pull_quote\":\"The useful question is not whether the opening is safe, but what evidence would make it worth testing.\",\"deeper_read\":\"You spot the upside quickly; the risk is answering before the details catch up. Instead of treating the offer as a permanent exit, set a time-limited trial with one proof point—scope, revenue, workload, or a clear deadline—that lets ambition meet evidence.\",\"watch_for\":\"Notice whether you answer the offer immediately or ask which proof point would justify leaving your current position.\",\"move\":\"Propose a two-week reversible test, define one result to observe, and set the date for reviewing it.\"}",
    "parsedResponse": {
      "title": "Proof Before Departure",
      "intro": "An appealing offer may ask you to leave what works, but you do not need to decide all at once.",
      "pull_quote": "The useful question is not whether the opening is safe, but what evidence would make it worth testing.",
      "deeper_read": "You spot the upside quickly; the risk is answering before the details catch up. Instead of treating the offer as a permanent exit, set a time-limited trial with one proof point—scope, revenue, workload, or a clear deadline—that lets ambition meet evidence.",
      "watch_for": "Notice whether you answer the offer immediately or ask which proof point would justify leaving your current position.",
      "move": "Propose a two-week reversible test, define one result to observe, and set the date for reviewing it."
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
      "output_tokens": 789,
      "output_tokens_details": {
        "reasoning_tokens": 622
      },
      "total_tokens": 1854
    }
  }
]
```
