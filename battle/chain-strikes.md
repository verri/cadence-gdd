# Physical Combat — Chain Strikes *(LoD-inspired)*

When the player selects **Attack**, the character begins a **Chain Strike**: a sequence of timed button presses where the input prompt appears at the moment of impact.

**Cost**: each Chain Strike has a base HP cost drawn from the **Active HP gauge**. Longer / heavier Chains cost more — a basic three-hit Chain might cost 10–20 HP, a maxed seven-hit signature 60–80 HP. This makes Vitality and Stamina double-duty: they govern survival *and* offensive capacity.

## Mechanics

- Each character has a roster of Chain Strikes they discover in the world (see [Chain Strike Acquisition](../progression/chain-strike-acquisition.md)).
- A Chain Strike is a sequence of 3–7 hits. Each hit displays a shrinking ring or beat marker; the player presses the action button as it aligns. Window width scales with the Agility differential (see [Stats & Resources](stats-and-resources.md#agility--the-matchup-stat)).
- **Perfect** = full damage on that hit + chain continues
- **Good** = reduced damage + chain continues
- **Miss** = chain ends, partial damage, no completion bonus
- Completing a Chain Strike earns mastery progress toward that move's next tier (see [Mastery System](../progression/mastery-system.md)).

## The Vulnerability Rule

**Longer combos hit harder, but expose the user to counter.** Each strike in a Chain leaves a **counter window** open while the attack hangs in the air — the bigger the swing, the longer the window. The defender can use this window to attempt a **counter** (see [Defense & Counter](defense-and-counter.md)).

This means:
- Short, fast Chains are safe but cap out at moderate damage.
- Long, heavy Chains scale to devastating finishers, but every hit is a moment your opponent could capitalize on.
- The **finisher** of a long Chain has the largest counter window of all — punishing if read, glorious if it lands clean.
- Agility modulates the window: a slow attacker's Chain hangs longer (easier to counter); a fast attacker's Chain whips past (harder).

The same rule applies in reverse — **enemy combos open counter windows for the player**. Bosses winding up signature attacks become prime opportunities to interrupt and turn the fight.

## Variations

- **Branch inputs**: some advanced Chains (unlocked at [Mastery Level 2](../progression/mastery-system.md#chain-strike-mastery)) let the player pick different buttons mid-chain to choose between damage, status, or knockback finishers.
- **Mastery decay**: timing windows shrink as the move levels, but rewards scale (see [Mastery Level 3](../progression/mastery-system.md#chain-strike-mastery)).
- **Class flavor**: heavy weapon users have slower, harder-hitting chains (and bigger counter windows); agile classes have longer chains with tighter windows (and smaller counter windows).
