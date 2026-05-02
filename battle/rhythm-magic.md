# Magical Casting — Rhythm Magic

Magic is its own minigame: when a spell is selected, the screen transitions to a **rhythm interface**. Notes scroll along a track (or radiate outward, TBD visual direction); the player must hit them in time.

**Cost**: each spell has a base MP cost drawn from the **Active MP gauge**. Tier 1 spells cost roughly 10–20 MP; high-tier spells can cost 60+. Magic and Spirit therefore play the same dual role as Vitality / Stamina, governing both survivability against magical attrition *and* the player's casting capacity per turn.

## Mechanics

- Each spell has a unique **score**: BPM, note count, pattern complexity.
- Tier 1 spells (e.g. *Spark*, *Frostkiss*) are short — 4–6 notes at moderate BPM.
- Tier 3 spells (e.g. *Meteor Cantata*, *Glacial Requiem*) are long, complex sequences — possibly 16+ notes with held notes and double-presses.
- Performance is graded:
  - **S-rank cast** → max damage + bonus effect (crit, extra hit, status)
  - **A/B** → standard
  - **C** → reduced power
  - **Fail (too many misses)** → spell fizzles, Active MP partially refunded
- Spells are learned by finding [Sheet Music](../progression/sheet-music-acquisition.md) in the world. No spell shops.

## Schools of magic

Spells fall into two broad damage families:

- **Elemental magic** — fire, frost, lightning, earth, etc. Damages HP (default routing). The most common school, available to most magical characters.
- **Psychic powers** — mind blasts, dread, mental crushes, sanity erosion. Damages **MP** instead of HP, and bypasses **Mana Veil** (see [Damage Routing](stats-and-resources.md#damage-routing)). A specialty school for characters with the aptitude — and a hard counter to shield-mages.

Both schools use the rhythm interface by default. Whether psychic powers warrant a *distinct* minigame variant — e.g. memorization or pattern-matching to mechanically embody "mental" rather than "sonic" magic — is flagged in [Open Questions](../open-questions.md).

## Groove Meter (working name)

- A persistent meter fills with successful note hits across all casts in a battle.
- When full, the next spell is cast at **double power** OR can be **chain-cast** with another spell back-to-back without an extra turn.
- Encourages players to use magic frequently rather than hoarding MP.

## Elemental rhythms

- Each element has a signature *feel* — Fire spells are fast and aggressive (high BPM, syncopated), Water spells are flowing (sustained held notes), Earth spells are heavy and deliberate (slow, low BPM with strong downbeats), etc. This makes elemental identity audible, not just visual.
