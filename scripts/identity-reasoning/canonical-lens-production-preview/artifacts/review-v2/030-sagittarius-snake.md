# 030 · Sagittarius × Snake

Status: complete
Source: Resources/archetypes.json#sagittarius-snake
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
  "identity": "Sagittarius × Snake",
  "arena": "work",
  "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration",
  "perception": "You move with quiet precision. becomes visible around ownership and execution.",
  "observableBehaviors": [
    "names who owns the next handoff before you hold intentions too tightly",
    "uses you see patterns beneath the surface to make one standard visible before you avoid direct expression"
  ],
  "identitySpecificRole": "the explorer who turns works through awareness, the right moment, and strategy into clear ownership",
  "recognition": "The work improves when the intentional result has an owner other people can identify.",
  "ordinaryLifeExpression": "The handoff makes intentional observable before ownership is finalized.",
  "blindSpot": "You may avoid direct expression after the work is already good enough.",
  "naturalMove": "Clarify one owner and use intentional as the visible standard.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|work",
      "manifestationArena": "work",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by speaking up vs waiting.",
      "perception": "You move with quiet precision. becomes visible around ownership and execution.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "names who owns the next handoff before you hold intentions too tightly",
        "uses you see patterns beneath the surface to make one standard visible before you avoid direct expression"
      ],
      "arenaDetail": "a meeting, handoff, role, deadline, standard, or collaboration"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "speaking up vs waiting meets the identity's work mechanism.",
    "primaryArena": "work",
    "identitySpecificRole": "the explorer who turns works through awareness, the right moment, and strategy into clear ownership",
    "startingAssumption": "The visible work detail can be handled through the identity's default process.",
    "recognition": "The work improves when the intentional result has an owner other people can identify.",
    "ordinaryLifeExpression": "The handoff makes intentional observable before ownership is finalized.",
    "blindSpot": "You may avoid direct expression after the work is already good enough.",
    "naturalMove": "Clarify one owner and use intentional as the visible standard.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Name the Handoff",
  "intro": "In the meeting, your careful plan needs one visible owner before the handoff becomes everyone’s assumption.",
  "pull_quote": "A standard becomes useful when someone can carry it into the next step.",
  "deeper_read": "You can see the pattern beneath a workable process, but waiting to name it leaves the final handoff blurred. Once the work is intentional enough, the useful contribution is not another refinement, it is making ownership and the standard legible to the people involved.",
  "watch_for": "Watch for the moment a deadline is discussed without anyone naming who carries the next handoff.",
  "move": "Name one person responsible for the next handoff and state the standard they should carry forward."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, your careful read of the work needs one plain sentence about who carries it next.\",\"pull_quote\":\"A strong handoff is not just well prepared; it has a name attached before the room changes topics.\",\"deeper_read\":\"You can see the pattern beneath a loose deadline or shared standard, and that makes the work easier to shape. The useful interruption today is small: before your careful intention stays unspoken, name the owner of the next step and the standard they are carrying.\",\"watch_for\":\"When the discussion shifts, notice if everyone assumes someone else will send the follow-up or finalize the draft.\",\"move\":\"Say, “To keep this intentional, is [name] owning the next handoff by Thursday?”\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, your careful read of the work needs one plain sentence about who carries it next.",
      "pull_quote": "A strong handoff is not just well prepared; it has a name attached before the room changes topics.",
      "deeper_read": "You can see the pattern beneath a loose deadline or shared standard, and that makes the work easier to shape. The useful interruption today is small: before your careful intention stays unspoken, name the owner of the next step and the standard they are carrying.",
      "watch_for": "When the discussion shifts, notice if everyone assumes someone else will send the follow-up or finalize the draft.",
      "move": "Say, “To keep this intentional, is [name] owning the next handoff by Thursday?”"
    },
    "validation": {
      "accepted": false,
      "reasons": [
        "move must be one sentence of 10-24 words"
      ]
    },
    "usage": {
      "input_tokens": 1066,
      "input_tokens_details": {
        "cache_write_tokens": 1063,
        "cached_tokens": 0
      },
      "output_tokens": 163,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1229
    }
  },
  {
    "attempt": 1,
    "rawResponse": "{\"title\":\"Name the Handoff\",\"intro\":\"In the meeting, your careful plan needs one visible owner before the handoff becomes everyone’s assumption.\",\"pull_quote\":\"A standard becomes useful when someone can carry it into the next step.\",\"deeper_read\":\"You can see the pattern beneath a workable process, but waiting to name it leaves the final handoff blurred. Once the work is intentional enough, the useful contribution is not another refinement, it is making ownership and the standard legible to the people involved.\",\"watch_for\":\"Watch for the moment a deadline is discussed without anyone naming who carries the next handoff.\",\"move\":\"Name one person responsible for the next handoff and state the standard they should carry forward.\"}",
    "parsedResponse": {
      "title": "Name the Handoff",
      "intro": "In the meeting, your careful plan needs one visible owner before the handoff becomes everyone’s assumption.",
      "pull_quote": "A standard becomes useful when someone can carry it into the next step.",
      "deeper_read": "You can see the pattern beneath a workable process, but waiting to name it leaves the final handoff blurred. Once the work is intentional enough, the useful contribution is not another refinement, it is making ownership and the standard legible to the people involved.",
      "watch_for": "Watch for the moment a deadline is discussed without anyone naming who carries the next handoff.",
      "move": "Name one person responsible for the next handoff and state the standard they should carry forward."
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
      "output_tokens": 603,
      "output_tokens_details": {
        "reasoning_tokens": 450
      },
      "total_tokens": 1800
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
  "identity": "Sagittarius × Snake",
  "arena": "love",
  "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time",
  "perception": "The identity brings intentional to closeness, where promises and pacing are tested.",
  "observableBehaviors": [
    "asks what a warm promise will look like in follow-through",
    "paces reassurance before you avoid direct expression"
  ],
  "identitySpecificRole": "the partner who turns intentional into reliable follow-through without forcing certainty",
  "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking intentional to disappear.",
  "ordinaryLifeExpression": "Evidence of intentional becomes the test beneath a reassuring message.",
  "blindSpot": "You may avoid direct expression after closeness is already possible.",
  "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning intentional.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|love",
      "manifestationArena": "love",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by trust vs caution.",
      "perception": "The identity brings intentional to closeness, where promises and pacing are tested.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "asks what a warm promise will look like in follow-through",
        "paces reassurance before you avoid direct expression"
      ],
      "arenaDetail": "a message, promise, reassurance, plan, affection, or shared time"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "trust vs caution meets the identity's love mechanism.",
    "primaryArena": "love",
    "identitySpecificRole": "the partner who turns intentional into reliable follow-through without forcing certainty",
    "startingAssumption": "The visible love detail can be handled through the identity's default process.",
    "recognition": "Closeness becomes trustworthy when a clear promise survives an ordinary week without asking intentional to disappear.",
    "ordinaryLifeExpression": "Evidence of intentional becomes the test beneath a reassuring message.",
    "blindSpot": "You may avoid direct expression after closeness is already possible.",
    "naturalMove": "Answer the practical promise and make one follow-through detail observable without abandoning intentional.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Practical Part",
  "intro": "A tender message lands well, but one small unanswered detail keeps you from treating it as settled.",
  "pull_quote": "You do not need certainty; you need the promise to include something you can both recognize later.",
  "deeper_read": "You are already noticing the difference between affectionate wording and a plan that can survive an ordinary week. Rather than holding the exchange at a careful distance, let the warmth stand and ask how the promise will show up in shared time, a message, or follow-through.",
  "watch_for": "You may reread a reassuring text, then pause instead of saying which practical detail remains unclear.",
  "move": "Reply warmly and name one concrete next step, such as choosing a day or confirming who will follow up."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Practical Part\",\"intro\":\"A tender message lands well, but one small unanswered detail keeps you from treating it as settled.\",\"pull_quote\":\"You do not need certainty; you need the promise to include something you can both recognize later.\",\"deeper_read\":\"You are already noticing the difference between affectionate wording and a plan that can survive an ordinary week. Rather than holding the exchange at a careful distance, let the warmth stand and ask how the promise will show up in shared time, a message, or follow-through.\",\"watch_for\":\"You may reread a reassuring text, then pause instead of saying which practical detail remains unclear.\",\"move\":\"Reply warmly and name one concrete next step, such as choosing a day or confirming who will follow up.\"}",
    "parsedResponse": {
      "title": "The Practical Part",
      "intro": "A tender message lands well, but one small unanswered detail keeps you from treating it as settled.",
      "pull_quote": "You do not need certainty; you need the promise to include something you can both recognize later.",
      "deeper_read": "You are already noticing the difference between affectionate wording and a plan that can survive an ordinary week. Rather than holding the exchange at a careful distance, let the warmth stand and ask how the promise will show up in shared time, a message, or follow-through.",
      "watch_for": "You may reread a reassuring text, then pause instead of saying which practical detail remains unclear.",
      "move": "Reply warmly and name one concrete next step, such as choosing a day or confirming who will follow up."
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
      "output_tokens": 159,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1207
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
  "identity": "Sagittarius × Snake",
  "arena": "home",
  "arenaDetail": "a room, chore, object, privacy boundary, or shared household routine",
  "perception": "The need for intentional shows up through space, objects, privacy, and shared maintenance.",
  "observableBehaviors": [
    "changes the placement of one object before debating the whole household",
    "protects a private corner when you hold intentions too tightly"
  ],
  "identitySpecificRole": "the person who translates intentional into a livable household condition",
  "recognition": "The room feels different when recovery has a physical place to happen after intentional has filled the day.",
  "ordinaryLifeExpression": "A physical change gives intentional somewhere to be practiced at home.",
  "blindSpot": "You may keep too much internal.",
  "naturalMove": "Rearrange one shared-space condition so recovery can happen there without intentional running the room.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|home",
      "manifestationArena": "home",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by stability vs change.",
      "perception": "The need for intentional shows up through space, objects, privacy, and shared maintenance.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
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
    "identitySpecificRole": "the person who translates intentional into a livable household condition",
    "startingAssumption": "The visible home detail can be handled through the identity's default process.",
    "recognition": "The room feels different when recovery has a physical place to happen after intentional has filled the day.",
    "ordinaryLifeExpression": "A physical change gives intentional somewhere to be practiced at home.",
    "blindSpot": "You may keep too much internal.",
    "naturalMove": "Rearrange one shared-space condition so recovery can happen there without intentional running the room.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Room for Recovery",
  "intro": "A familiar room asks for one practical adjustment when your intentions start taking up all the available space.",
  "pull_quote": "You do not need to rethink the household; you need one corner that lets the day settle.",
  "deeper_read": "You may first try to keep the change contained, protecting a private corner rather than naming what the shared space now needs. Start with an object, a chair, or a chore landing spot: a small rearrangement can make the room workable without turning home into another project.",
  "watch_for": "You move one item aside, then pause before explaining to anyone why the whole room should change.",
  "move": "Clear one shared surface or seat for unwinding, and leave it unassigned for the evening."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Room for Recovery\",\"intro\":\"A familiar room asks for one practical adjustment when your intentions start taking up all the available space.\",\"pull_quote\":\"You do not need to rethink the household; you need one corner that lets the day settle.\",\"deeper_read\":\"You may first try to keep the change contained, protecting a private corner rather than naming what the shared space now needs. Start with an object, a chair, or a chore landing spot: a small rearrangement can make the room workable without turning home into another project.\",\"watch_for\":\"You move one item aside, then pause before explaining to anyone why the whole room should change.\",\"move\":\"Clear one shared surface or seat for unwinding, and leave it unassigned for the evening.\"}",
    "parsedResponse": {
      "title": "Room for Recovery",
      "intro": "A familiar room asks for one practical adjustment when your intentions start taking up all the available space.",
      "pull_quote": "You do not need to rethink the household; you need one corner that lets the day settle.",
      "deeper_read": "You may first try to keep the change contained, protecting a private corner rather than naming what the shared space now needs. Start with an object, a chair, or a chore landing spot: a small rearrangement can make the room workable without turning home into another project.",
      "watch_for": "You move one item aside, then pause before explaining to anyone why the whole room should change.",
      "move": "Clear one shared surface or seat for unwinding, and leave it unassigned for the evening."
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
      "output_tokens": 159,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1216
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
  "identity": "Sagittarius × Snake",
  "arena": "friends",
  "arenaDetail": "an invitation, favor, group role, availability question, or social tone",
  "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by intentional.",
  "observableBehaviors": [
    "notices who keeps receiving the group role nobody named",
    "offers one specific invitation instead of you avoid direct expression"
  ],
  "identitySpecificRole": "the friend who uses intentional to change participation rather than manage the whole group",
  "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's intentional.",
  "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around intentional.",
  "blindSpot": "You search beneath every answer before choosing your direction.",
  "naturalMove": "Invite one person clearly and make the invitation specific to the intentional dynamic.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|friends",
      "manifestationArena": "friends",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by harmony vs honesty.",
      "perception": "Group belonging becomes visible through invitations, favors, and a social role shaped by intentional.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "notices who keeps receiving the group role nobody named",
        "offers one specific invitation instead of you avoid direct expression"
      ],
      "arenaDetail": "an invitation, favor, group role, availability question, or social tone"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "harmony vs honesty meets the identity's friends mechanism.",
    "primaryArena": "friends",
    "identitySpecificRole": "the friend who uses intentional to change participation rather than manage the whole group",
    "startingAssumption": "The visible friends detail can be handled through the identity's default process.",
    "recognition": "Friendship is clearest when an invitation makes availability and limits observable without hiding the identity's intentional.",
    "ordinaryLifeExpression": "The social tone changes when availability is made explicit instead of assumed, especially around intentional.",
    "blindSpot": "You search beneath every answer before choosing your direction.",
    "naturalMove": "Invite one person clearly and make the invitation specific to the intentional dynamic.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make Room Clearly",
  "intro": "A friend may smooth over a group tension today, while you notice who keeps carrying the unnamed role.",
  "pull_quote": "Peace can wait long enough for one clear invitation to show what participation actually looks like.",
  "deeper_read": "You may be tempted to read every pause, favor, and shift in social tone before deciding how to respond. Instead of managing the whole group’s comfort, make one specific plan with the person whose availability has been assumed; the details can say more than a careful analysis.",
  "watch_for": "Notice a friend changing the subject after someone mentions the favor they always end up handling.",
  "move": "Send one direct invitation that names the plan, the time, and what you are asking them to join."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make Room Clearly\",\"intro\":\"A friend may smooth over a group tension today, while you notice who keeps carrying the unnamed role.\",\"pull_quote\":\"Peace can wait long enough for one clear invitation to show what participation actually looks like.\",\"deeper_read\":\"You may be tempted to read every pause, favor, and shift in social tone before deciding how to respond. Instead of managing the whole group’s comfort, make one specific plan with the person whose availability has been assumed; the details can say more than a careful analysis.\",\"watch_for\":\"Notice a friend changing the subject after someone mentions the favor they always end up handling.\",\"move\":\"Send one direct invitation that names the plan, the time, and what you are asking them to join.\"}",
    "parsedResponse": {
      "title": "Make Room Clearly",
      "intro": "A friend may smooth over a group tension today, while you notice who keeps carrying the unnamed role.",
      "pull_quote": "Peace can wait long enough for one clear invitation to show what participation actually looks like.",
      "deeper_read": "You may be tempted to read every pause, favor, and shift in social tone before deciding how to respond. Instead of managing the whole group’s comfort, make one specific plan with the person whose availability has been assumed; the details can say more than a careful analysis.",
      "watch_for": "Notice a friend changing the subject after someone mentions the favor they always end up handling.",
      "move": "Send one direct invitation that names the plan, the time, and what you are asking them to join."
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
      "output_tokens": 158,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1221
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
  "identity": "Sagittarius × Snake",
  "arena": "money",
  "arenaDetail": "a purchase, bill, budget, risk, comfort expense, or future option",
  "perception": "A decision style shaped by intentional meets comfort, scarcity, status, and future options.",
  "observableBehaviors": [
    "compares the relief of a purchase with the option it removes",
    "waits for evidence before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the chooser who makes the tradeoff between immediate comfort and future options visible",
  "recognition": "The cost is honest when the future option tied to intentional comfort is named alongside the purchase.",
  "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what intentional makes tempting.",
  "blindSpot": "You regret the choice when you avoid direct expression.",
  "naturalMove": "Price immediate comfort against the future option the purchase would remove from a intentional choice.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|money",
      "manifestationArena": "money",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by comfort vs restraint.",
      "perception": "A decision style shaped by intentional meets comfort, scarcity, status, and future options.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
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
    "recognition": "The cost is honest when the future option tied to intentional comfort is named alongside the purchase.",
    "ordinaryLifeExpression": "The decision prices comfort and lost flexibility in the same moment, including what intentional makes tempting.",
    "blindSpot": "You regret the choice when you avoid direct expression.",
    "naturalMove": "Price immediate comfort against the future option the purchase would remove from a intentional choice.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "The Real Price",
  "intro": "At checkout, the small comfort expense gets more honest when you name the flexibility it would take away.",
  "pull_quote": "Relief can be worth buying, but it is easier to choose when the tradeoff has a name.",
  "deeper_read": "You tend to look beneath a simple yes or no, and today that means placing the purchase beside the bill, budget cushion, or future option it affects. The point is not to deny yourself comfort; it is to stop treating restraint as vague while comfort is right in front of you.",
  "watch_for": "You may keep an item in your cart while reopening your banking app to check what remains.",
  "move": "Write down one future option the purchase changes, then decide whether today’s relief still earns its price."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"The Real Price\",\"intro\":\"At checkout, the small comfort expense gets more honest when you name the flexibility it would take away.\",\"pull_quote\":\"Relief can be worth buying, but it is easier to choose when the tradeoff has a name.\",\"deeper_read\":\"You tend to look beneath a simple yes or no, and today that means placing the purchase beside the bill, budget cushion, or future option it affects. The point is not to deny yourself comfort; it is to stop treating restraint as vague while comfort is right in front of you.\",\"watch_for\":\"You may keep an item in your cart while reopening your banking app to check what remains.\",\"move\":\"Write down one future option the purchase changes, then decide whether today’s relief still earns its price.\"}",
    "parsedResponse": {
      "title": "The Real Price",
      "intro": "At checkout, the small comfort expense gets more honest when you name the flexibility it would take away.",
      "pull_quote": "Relief can be worth buying, but it is easier to choose when the tradeoff has a name.",
      "deeper_read": "You tend to look beneath a simple yes or no, and today that means placing the purchase beside the bill, budget cushion, or future option it affects. The point is not to deny yourself comfort; it is to stop treating restraint as vague while comfort is right in front of you.",
      "watch_for": "You may keep an item in your cart while reopening your banking app to check what remains.",
      "move": "Write down one future option the purchase changes, then decide whether today’s relief still earns its price."
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
      "output_tokens": 165,
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
  "identity": "Sagittarius × Snake",
  "arena": "rest",
  "arenaDetail": "a quiet hour, unfinished task, phone, maintenance loop, or sleep decision",
  "perception": "Pressure keeps usefulness shaped by intentional active after the useful work is done.",
  "observableBehaviors": [
    "ends one maintenance loop before checking for another",
    "puts the phone away when you hold intentions too tightly"
  ],
  "identitySpecificRole": "the person learning that rest is a condition for returning well, not a reward for exhaustion",
  "recognition": "Rest starts when recovery from intentional can happen without another proof of usefulness.",
  "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when intentional keeps usefulness moving.",
  "blindSpot": "Everything is processed internally before being expressed",
  "naturalMove": "Close one open loop, then protect the remaining hour from the intentional maintenance loop.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|rest",
      "manifestationArena": "rest",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by responsibility vs autonomy.",
      "perception": "Pressure keeps usefulness shaped by intentional active after the useful work is done.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
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
    "recognition": "Rest starts when recovery from intentional can happen without another proof of usefulness.",
    "ordinaryLifeExpression": "A quiet hour interrupts the habit of adding another small task when intentional keeps usefulness moving.",
    "blindSpot": "Everything is processed internally before being expressed",
    "naturalMove": "Close one open loop, then protect the remaining hour from the intentional maintenance loop.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "After One Last Thing",
  "intro": "During a quiet hour, an unfinished task can make rest feel like something you still need to earn.",
  "pull_quote": "You do not need a second maintenance loop to prove the first one mattered.",
  "deeper_read": "Once you finish one necessary thing, you may notice your hand reaching for the phone or scanning for the next small fix. That pause is the point: leave the unfinished task where it is, so the hour can be recovery rather than another private audit of usefulness.",
  "watch_for": "Watch for finishing a chore, then reopening your phone before you have actually chosen what comes next.",
  "move": "Set the phone out of reach, name the one task you completed, and keep the rest of the hour open."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"After One Last Thing\",\"intro\":\"During a quiet hour, an unfinished task can make rest feel like something you still need to earn.\",\"pull_quote\":\"You do not need a second maintenance loop to prove the first one mattered.\",\"deeper_read\":\"Once you finish one necessary thing, you may notice your hand reaching for the phone or scanning for the next small fix. That pause is the point: leave the unfinished task where it is, so the hour can be recovery rather than another private audit of usefulness.\",\"watch_for\":\"Watch for finishing a chore, then reopening your phone before you have actually chosen what comes next.\",\"move\":\"Set the phone out of reach, name the one task you completed, and keep the rest of the hour open.\"}",
    "parsedResponse": {
      "title": "After One Last Thing",
      "intro": "During a quiet hour, an unfinished task can make rest feel like something you still need to earn.",
      "pull_quote": "You do not need a second maintenance loop to prove the first one mattered.",
      "deeper_read": "Once you finish one necessary thing, you may notice your hand reaching for the phone or scanning for the next small fix. That pause is the point: leave the unfinished task where it is, so the hour can be recovery rather than another private audit of usefulness.",
      "watch_for": "Watch for finishing a chore, then reopening your phone before you have actually chosen what comes next.",
      "move": "Set the phone out of reach, name the one task you completed, and keep the rest of the hour open."
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
      "output_tokens": 616,
      "output_tokens_details": {
        "reasoning_tokens": 455
      },
      "total_tokens": 1674
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
  "identity": "Sagittarius × Snake",
  "arena": "confidence",
  "arenaDetail": "praise, attribution, visibility, competence, performance, or result",
  "perception": "The ability to accept credit for intentional is tested by praise, attribution, and visible competence.",
  "observableBehaviors": [
    "states the contribution without reducing it to luck",
    "lets the finished result stand before you avoid direct expression"
  ],
  "identitySpecificRole": "the contributor who can accept intentional without performing a larger identity",
  "recognition": "Confidence settles when praise names the intentional contribution without demanding another performance.",
  "ordinaryLifeExpression": "Precise praise names the work without requiring a larger intentional performance.",
  "blindSpot": "Comes Loose, Trusts Few",
  "naturalMove": "Credit the contribution accurately, then stop before you avoid direct expression.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|confidence",
      "manifestationArena": "confidence",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by recognition vs humility.",
      "perception": "The ability to accept credit for intentional is tested by praise, attribution, and visible competence.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "states the contribution without reducing it to luck",
        "lets the finished result stand before you avoid direct expression"
      ],
      "arenaDetail": "praise, attribution, visibility, competence, performance, or result"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "recognition vs humility meets the identity's confidence mechanism.",
    "primaryArena": "confidence",
    "identitySpecificRole": "the contributor who can accept intentional without performing a larger identity",
    "startingAssumption": "The visible confidence detail can be handled through the identity's default process.",
    "recognition": "Confidence settles when praise names the intentional contribution without demanding another performance.",
    "ordinaryLifeExpression": "Precise praise names the work without requiring a larger intentional performance.",
    "blindSpot": "Comes Loose, Trusts Few",
    "naturalMove": "Credit the contribution accurately, then stop before you avoid direct expression.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Let It Count",
  "intro": "When someone names your work, you can accept the credit without turning the moment into a performance.",
  "pull_quote": "A simple, accurate acknowledgment lets the result stay visible without asking you to become louder.",
  "deeper_read": "You may be ready to let the finished result speak for itself, especially when praise arrives in a meeting, review, or casual message. Say what you contributed plainly; the confidence is in naming the intention, then letting the exchange end there.",
  "watch_for": "Notice the impulse to call your contribution luck or quickly redirect praise to something else.",
  "move": "Reply with one specific sentence about what you handled, then return to the next task."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Let It Count\",\"intro\":\"When someone names your work, you can accept the credit without turning the moment into a performance.\",\"pull_quote\":\"A simple, accurate acknowledgment lets the result stay visible without asking you to become louder.\",\"deeper_read\":\"You may be ready to let the finished result speak for itself, especially when praise arrives in a meeting, review, or casual message. Say what you contributed plainly; the confidence is in naming the intention, then letting the exchange end there.\",\"watch_for\":\"Notice the impulse to call your contribution luck or quickly redirect praise to something else.\",\"move\":\"Reply with one specific sentence about what you handled, then return to the next task.\"}",
    "parsedResponse": {
      "title": "Let It Count",
      "intro": "When someone names your work, you can accept the credit without turning the moment into a performance.",
      "pull_quote": "A simple, accurate acknowledgment lets the result stay visible without asking you to become louder.",
      "deeper_read": "You may be ready to let the finished result speak for itself, especially when praise arrives in a meeting, review, or casual message. Say what you contributed plainly; the confidence is in naming the intention, then letting the exchange end there.",
      "watch_for": "Notice the impulse to call your contribution luck or quickly redirect praise to something else.",
      "move": "Reply with one specific sentence about what you handled, then return to the next task."
    },
    "validation": {
      "accepted": true,
      "reasons": []
    },
    "usage": {
      "input_tokens": 1045,
      "input_tokens_details": {
        "cache_write_tokens": 1042,
        "cached_tokens": 0
      },
      "output_tokens": 146,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1191
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
  "identity": "Sagittarius × Snake",
  "arena": "routine",
  "arenaDetail": "a repeated step, schedule, ritual, optimization, or friction point",
  "perception": "The current structure reveals whether repetition shaped by intentional is reducing friction or preserving confinement.",
  "observableBehaviors": [
    "marks the repeated step that creates the most rework",
    "changes the sequence before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the operator who tests whether the current structure still serves the actual result",
  "recognition": "The routine earns its place when the strength expressed as intentional reduces friction without demanding loyalty.",
  "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a intentional working style.",
  "blindSpot": "You release the work by staying in the moment after the first surge of freedom.",
  "naturalMove": "Alter one repeated step and watch what becomes easier for this intentional rhythm.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|routine",
      "manifestationArena": "routine",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by consistency vs freedom.",
      "perception": "The current structure reveals whether repetition shaped by intentional is reducing friction or preserving confinement.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
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
    "recognition": "The routine earns its place when the strength expressed as intentional reduces friction without demanding loyalty.",
    "ordinaryLifeExpression": "The repeated sequence reveals which small change reduces friction for a intentional working style.",
    "blindSpot": "You release the work by staying in the moment after the first surge of freedom.",
    "naturalMove": "Alter one repeated step and watch what becomes easier for this intentional rhythm.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Adjust the Sequence",
  "intro": "A dependable routine feels irritating today because one repeated step keeps creating work you no longer need.",
  "pull_quote": "You do not need to abandon the routine; you need to stop defending the part that slows it down.",
  "deeper_read": "Notice where you mark the same correction, resend the same thing, or circle back after a familiar task. Change that step before tightening your grip on the whole schedule, then stay with the revised rhythm long enough to see whether it actually reduces friction.",
  "watch_for": "Watch for yourself repeating a correction after the same handoff, checklist item, or morning task.",
  "move": "Reorder one recurring step and keep the new sequence for the rest of the day."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Adjust the Sequence\",\"intro\":\"A dependable routine feels irritating today because one repeated step keeps creating work you no longer need.\",\"pull_quote\":\"You do not need to abandon the routine; you need to stop defending the part that slows it down.\",\"deeper_read\":\"Notice where you mark the same correction, resend the same thing, or circle back after a familiar task. Change that step before tightening your grip on the whole schedule, then stay with the revised rhythm long enough to see whether it actually reduces friction.\",\"watch_for\":\"Watch for yourself repeating a correction after the same handoff, checklist item, or morning task.\",\"move\":\"Reorder one recurring step and keep the new sequence for the rest of the day.\"}",
    "parsedResponse": {
      "title": "Adjust the Sequence",
      "intro": "A dependable routine feels irritating today because one repeated step keeps creating work you no longer need.",
      "pull_quote": "You do not need to abandon the routine; you need to stop defending the part that slows it down.",
      "deeper_read": "Notice where you mark the same correction, resend the same thing, or circle back after a familiar task. Change that step before tightening your grip on the whole schedule, then stay with the revised rhythm long enough to see whether it actually reduces friction.",
      "watch_for": "Watch for yourself repeating a correction after the same handoff, checklist item, or morning task.",
      "move": "Reorder one recurring step and keep the new sequence for the rest of the day."
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
      "output_tokens": 153,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1212
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
  "identity": "Sagittarius × Snake",
  "arena": "conflict",
  "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition",
  "perception": "The careful response to conflict shapes the reading of evidence, tone, control, and repair.",
  "observableBehaviors": [
    "separates the observable impact from the motive being assumed",
    "sets one repair condition before you avoid direct expression"
  ],
  "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
  "recognition": "The disagreement becomes workable when the boundary against careful is stated as evidence and a repair condition.",
  "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before careful takes over.",
  "blindSpot": "You may decide from careful instead of evidence.",
  "naturalMove": "Separate impact from motive, then state one repair condition that addresses careful.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|conflict",
      "manifestationArena": "conflict",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by directness vs patience.",
      "perception": "The careful response to conflict shapes the reading of evidence, tone, control, and repair.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
      "pressureOrGrowth": "Under pressure, you first hold intentions too tightly.",
      "observableBehaviors": [
        "separates the observable impact from the motive being assumed",
        "sets one repair condition before you avoid direct expression"
      ],
      "arenaDetail": "an escalation, avoided point, piece of evidence, tone shift, or repair condition"
    }
  },
  "reasoning": {
    "activatedIdentityTension": "directness vs patience meets the identity's conflict mechanism.",
    "primaryArena": "conflict",
    "identitySpecificRole": "the explorer who makes the conflict precise enough to repair",
    "startingAssumption": "The visible conflict detail can be handled through the identity's default process.",
    "recognition": "The disagreement becomes workable when the boundary against careful is stated as evidence and a repair condition.",
    "ordinaryLifeExpression": "A clear boundary names what happened, what changed, and what repair requires before careful takes over.",
    "blindSpot": "You may decide from careful instead of evidence.",
    "naturalMove": "Separate impact from motive, then state one repair condition that addresses careful.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Make It Repairable",
  "intro": "A small disagreement sharpens when you name the tone shift without deciding what the other person meant.",
  "pull_quote": "The point is not to win the reading of it, but to state what would make the exchange usable again.",
  "deeper_read": "You may be ready to pull back once the conversation changes tone, especially if an avoided point keeps resurfacing. Instead, separate the observable impact from the motive you are assigning, then make one concrete repair condition clear before you step away.",
  "watch_for": "Notice yourself rereading a message or pausing after a tone shift instead of answering the avoided point.",
  "move": "Say what changed for you, cite the specific exchange, and ask for one condition before continuing."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Make It Repairable\",\"intro\":\"A small disagreement sharpens when you name the tone shift without deciding what the other person meant.\",\"pull_quote\":\"The point is not to win the reading of it, but to state what would make the exchange usable again.\",\"deeper_read\":\"You may be ready to pull back once the conversation changes tone, especially if an avoided point keeps resurfacing. Instead, separate the observable impact from the motive you are assigning, then make one concrete repair condition clear before you step away.\",\"watch_for\":\"Notice yourself rereading a message or pausing after a tone shift instead of answering the avoided point.\",\"move\":\"Say what changed for you, cite the specific exchange, and ask for one condition before continuing.\"}",
    "parsedResponse": {
      "title": "Make It Repairable",
      "intro": "A small disagreement sharpens when you name the tone shift without deciding what the other person meant.",
      "pull_quote": "The point is not to win the reading of it, but to state what would make the exchange usable again.",
      "deeper_read": "You may be ready to pull back once the conversation changes tone, especially if an avoided point keeps resurfacing. Instead, separate the observable impact from the motive you are assigning, then make one concrete repair condition clear before you step away.",
      "watch_for": "Notice yourself rereading a message or pausing after a tone shift instead of answering the avoided point.",
      "move": "Say what changed for you, cite the specific exchange, and ask for one condition before continuing."
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
      "output_tokens": 157,
      "output_tokens_details": {
        "reasoning_tokens": 0
      },
      "total_tokens": 1221
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
  "identity": "Sagittarius × Snake",
  "arena": "opportunity",
  "arenaDetail": "an offer, proof point, timing choice, ambition, risk, or reversible test",
  "perception": "The capacity to act on possibility shaped by intentional competes with proof, timing, ambition, and reversibility.",
  "observableBehaviors": [
    "asks what evidence would make the opening worth leaving a proven position",
    "builds a reversible test before you hold intentions too tightly"
  ],
  "identitySpecificRole": "the decision-maker who turns an attractive possibility into bounded proof",
  "recognition": "The opening is real when the next action reflects intentional and can be tested without pretending the risk has disappeared.",
  "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for intentional.",
  "blindSpot": "You delay when you hold intentions too tightly.",
  "naturalMove": "Test the opening with the smallest step that produces useful proof about intentional.",
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
    "signPair": "Sagittarius × Snake",
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
      "manifestationKey": "Sagittarius × Snake|opportunity",
      "manifestationArena": "opportunity",
      "activatedParadox": "You search beneath every answer before choosing your direction. Growth begins when you stay in the moment after the first surge of freedom. Activated by security vs expansion.",
      "perception": "The capacity to act on possibility shaped by intentional competes with proof, timing, ambition, and reversibility.",
      "decision": "You move with even, observant, and intentional. Then you see patterns beneath the surface.",
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
    "recognition": "The opening is real when the next action reflects intentional and can be tested without pretending the risk has disappeared.",
    "ordinaryLifeExpression": "A bounded action turns an attractive offer into a timed, observable test for intentional.",
    "blindSpot": "You delay when you hold intentions too tightly.",
    "naturalMove": "Test the opening with the smallest step that produces useful proof about intentional.",
    "signInteraction": "not_needed"
  }
}
```

### Lens

```json
{
  "title": "Proof Before the Leap",
  "intro": "An attractive offer asks you to leave something proven, and you do not need to treat that as an all-or-nothing choice.",
  "pull_quote": "The useful question is not whether the risk disappears, but what a small test would show you.",
  "deeper_read": "You tend to look beneath the first excitement for evidence, which is useful when an offer has real trade-offs. The snag comes when every condition must be settled before you respond; a time-limited, reversible step can show whether the opening has substance without requiring you to abandon your proven position today.",
  "watch_for": "Watch for yourself reopening the offer details, waiting for one more proof point before replying.",
  "move": "Ask for a short trial, a defined milestone, or a deadline that lets you assess the offer."
}
```

### Attempt history

```json
[
  {
    "attempt": 0,
    "rawResponse": "{\"title\":\"Proof Before the Leap\",\"intro\":\"An attractive offer asks you to leave something proven, and you do not need to treat that as an all-or-nothing choice.\",\"pull_quote\":\"The useful question is not whether the risk disappears, but what a small test would show you.\",\"deeper_read\":\"You tend to look beneath the first excitement for evidence, which is useful when an offer has real trade-offs. The snag comes when every condition must be settled before you respond; a time-limited, reversible step can show whether the opening has substance without requiring you to abandon your proven position today.\",\"watch_for\":\"Watch for yourself reopening the offer details, waiting for one more proof point before replying.\",\"move\":\"Ask for a short trial, a defined milestone, or a deadline that lets you assess the offer.\"}",
    "parsedResponse": {
      "title": "Proof Before the Leap",
      "intro": "An attractive offer asks you to leave something proven, and you do not need to treat that as an all-or-nothing choice.",
      "pull_quote": "The useful question is not whether the risk disappears, but what a small test would show you.",
      "deeper_read": "You tend to look beneath the first excitement for evidence, which is useful when an offer has real trade-offs. The snag comes when every condition must be settled before you respond; a time-limited, reversible step can show whether the opening has substance without requiring you to abandon your proven position today.",
      "watch_for": "Watch for yourself reopening the offer details, waiting for one more proof point before replying.",
      "move": "Ask for a short trial, a defined milestone, or a deadline that lets you assess the offer."
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
      "output_tokens": 649,
      "output_tokens_details": {
        "reasoning_tokens": 476
      },
      "total_tokens": 1717
    }
  }
]
```
