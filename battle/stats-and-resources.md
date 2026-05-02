# Stats & Resources

> **Foundational rule.** Outgoing damage and resource cost are properties of the **move itself** — defined by the Chain Strikes, spells, and psychic powers a character learns, not by their stats. Stats govern *pool size* and *recovery only*. A 50-HP-cost Chain Strike costs 50 HP whether the user is a fighter or a mage; the fighter simply has more HP to spend it from. Player skill at the input minigames (Perfect vs Good hits, S-rank vs C-rank casts) is what scales damage upward from the move's printed value.

## Core Stats

Each character has five stats. Four govern resource pools and recovery; the fifth governs input precision in combat.

| Stat | Governs |
|---|---|
| **Vitality** | Maximum HP |
| **Stamina** | HP recovery rate (per-turn Active refresh and per-Rest Reserve recovery) |
| **Magic** | Maximum MP |
| **Spirit** | MP recovery rate (per-turn Active refresh and per-Rest Reserve recovery) |
| **Agility** | Width of input timing windows in all combat minigames |

### Agility — the matchup stat

Agility scales the width of timing windows for **strikes** (Chain Strikes, spells) and for **counters** (defensive R-counter, see [Defense & Counter](defense-and-counter.md)). Critically, the effective window is determined by the **differential** between the two characters involved:

- **When you attack**: window width scales with `your Agility − target's Agility`. A faster attacker has more forgiving timing; a slower attacker against a quick defender has tighter windows.
- **When you counter**: window width scales with `your Agility − attacker's Agility`. A fast defender has wider counter windows; a slow defender trying to counter a fast attacker has almost no window at all.

This makes Agility a **matchup stat**, not a flat power-up. A high-Agility character feels sluggish against an opponent who matches them and devastating against slower foes. A low-Agility character finds windows opening up as enemies become more agile around them — they're the underdog who shines against fast bosses.

Effect on Chain Strike vulnerability: longer combos that hang in the air (see [Chain Strikes](chain-strikes.md)) become **more punishable when the attacker is slow** — the defender's counter window stays open longer relative to a fast attacker's quick-recovery chain.

## The Two-Gauge System

Both HP and MP are split into two gauges, layered visually on the same bar:

- **Reserve (inner gauge)** — the character's lasting pool. **Either Reserve hitting zero is death.** A character dies if their HP Reserve is depleted *or* if their MP Reserve is depleted. MP is not just casting fuel; it is a second life pool that keeps the character alive.
- **Active (outer gauge)** — the resource the player spends first. The Active gauge is **always capped by the current Reserve**.

### How the gauges interact

Costs and damage spend Active first, then **overflow into Reserve** once Active is empty. Reserve never refunds Active — it is consumed when Active runs out.

| Event | Where it draws from |
|---|---|
| Player uses a physical action (cost X HP) | Active HP first; any remainder spills into Reserve HP |
| Player uses a magical action (cost X MP) | Active MP first; any remainder spills into Reserve MP |
| Successfully defended attack | Active gauge only (no Reserve loss) |
| Stagger / failed defense | Active gauge first; remainder spills into Reserve |
| Start of turn | Active partially refreshes (rate depends on Stamina / Spirit, see normalization below) |
| Rest | Reserve recovers (see [Rest & Recovery](#rest--recovery)) |
| HP Reserve **or** MP Reserve hits zero | Character is KO'd |

Worked example *(updated to reflect overflow)*:
> Vitality 150 → 150 max HP. Active HP starts the turn at 60.
> - The character uses a 50-cost Chain Strike → Active HP drops 60→10. Reserve still 150.
> - Next turn they only refresh Active to 30 (Stamina-dependent). They use the same Chain Strike. Cost 50 vs Active 30 → Active goes to 0, the remaining **20 spills into Reserve**, dropping max HP from 150 to 130.
> - An enemy attacks for 50 and they fail defense. Active is already 0, so the full 50 spills to Reserve → max HP drops from 130 to 80.
> The lesson: **over-spending eats your own life.** A reckless big-cost combo when Active is low is functionally self-harm.

### Why this matters at the table

- Skilled defense preserves both **damage prevention** and **action economy** for future turns.
- The Active gauge is a per-turn **budget**; spending past it is a real cost, not a free fallback.
- Long fights become a slow attrition: every failed defense and every overcommitted turn compounds — less Reserve means less Active means fewer choices per turn means closer to death.
- High Stamina / Spirit characters can spend more aggressively within a turn (their gauge refills strongly); low Stamina / Spirit characters must pace themselves or risk biting into Reserve.
- **MP is now a survival stat for everyone**, not just casters. Even a pure fighter cares about losing MP Reserve, because zero MP Reserve = death.

### Turn order

Turn order is **fixed for the duration of a battle** and **randomly determined at battle start**. Every active combatant takes exactly one turn per round, in the same sequence each round. This eliminates speed-as-frequency as a balance concern: every character refreshes Active gauge once per round, no character takes more turns than another, and Stamina/Spirit cleanly govern *how much* recovery happens rather than *how often*.

Random initial order adds variance to encounters — the same fight can play out differently if turn order favors the player or the enemy. Players can't game-plan around fixed initiative, which forces in-the-moment adaptation each engagement.

## Damage Routing

Damage is **typed**, and each type has a default destination:

| Damage type | Default routing | Examples |
|---|---|---|
| **Physical** | HP | Sword strikes, Chain Strikes, basic enemy attacks |
| **Elemental** | HP | Fire, frost, lightning, earth — the core rhythm-magic schools |
| **Psychic** | MP | Mind blasts, telepathic strikes, dread, sanity erosion |

The Active/Reserve split applies regardless of type: a successfully defended psychic blast hits Active MP only; a failed defense against the same blast hits the MP Reserve.

### Mana Veil (mage-class ability)

Some characters — mages most prominently — possess a **Mana Veil** that redirects incoming **physical and elemental** damage into their MP pool instead of HP. The Veil is a **toggleable in-battle command**: a character can raise or lower it on their turn, like switching stances.

While the Veil is active:

- Physical attacks route to Active MP (overflowing into MP Reserve), not HP.
- Elemental damage routes the same way.
- **Psychic powers ignore the Veil entirely** — they were going to MP regardless. No double penalty, but no protection either.

Because either Reserve hitting zero is death (see [Two-Gauge System](#the-two-gauge-system)), the Veil is not a "free" defense — it trades HP-attrition for MP-attrition. A mage facing a brutal physical attacker may keep the Veil up to leverage their large MP pool as armor. A mage low on MP Reserve will *drop* the Veil and take HP damage instead, choosing which pool to bleed from. This makes Veil management a recurring tactical decision, not a passive effect.

Psychic damage hard-counters Veiled mages: it always goes to MP, so a mage tanking physicals through the Veil while taking psychic blasts is on a fast track to MP Reserve = 0 = death.

**Partial Veil** can be granted by **equipment, items, or temporary spell effects** — e.g. an amulet that redirects 30% of physical damage into MP, a buff spell that grants Veil for three turns, or a class hybrid item. This opens design space for "spellsword" archetypes between pure fighter and pure mage without making them a base class.

This produces a distinctive **survival arc** for mages: their deep magical reserves act as armor, but the same pool that powers their casting also keeps them alive — every spell they throw is digging into their own defense.

- **Fighters** are largely indifferent to psychic damage at low intensities (small MP pool means a small death pool — but also a smaller target), and vulnerable to elemental.
- **Mages** convert physical and elemental into MP-attrition while the Veil holds, but psychic bypasses their core defense and is a hard counter.
- **Mixed parties** can rotate front-liners based on enemy damage profile.

## Rest & Recovery

### The recovery formula

Recovery happens at two cadences and follows a single linear formula. Both stats (Stamina, Spirit) range 0–100. At each end of the range:

| Stat value | Active refresh / turn | Reserve recovery / Rest |
|---|---|---|
| 0 | 10% of max | 10% of max |
| 100 | 20% of max | 20% of max |

Linear in between. So a Stamina-50 character refreshes 15% of max HP per turn, and recovers 15% of max HP per Rest. The same applies to Spirit / MP.

**"Max" = the full pool from Vitality (HP) or Magic (MP).** Recovery percentages are calculated against the unchanging cap, *not* against current Reserve. A character whose Reserve has dropped from 150 to 90 still refreshes Active based on the full 150 — making recovery predictable and easy to read.

| Pool | When it recovers | Governed by | Calculated against |
|---|---|---|---|
| Active HP | Start of every turn | Stamina | Max HP (Vitality) |
| Active MP | Start of every turn | Spirit | Max MP (Magic) |
| Reserve HP | On Rest | Stamina | Max HP (Vitality) |
| Reserve MP | On Rest | Spirit | Max MP (Magic) |

### Vitality vs. Stamina — the design intent

The two stats produce different *kinds* of durability:

- **Vitality = cushion.** A bigger pool means more Reserve damage you can absorb before death.
- **Stamina = efficiency.** A higher refresh rate means you can spend more aggressively per turn relative to your pool size.

A high-Vitality / low-Stamina character is a tank with a sluggish action economy. A low-Vitality / high-Stamina character is a glass cannon with a snappy action economy. They might recover similar *absolute* HP per turn, but they play completely differently.

### Active overflow → Reserve

If a character's Active gauge is **already at cap** when start-of-turn recovery triggers, the would-be refresh **overflows into Reserve recovery instead**.

Partial overflow works as expected: if Active is 90/100 and refresh is 20, Active fills to 100 (using 10) and the remaining 10 goes to Reserve.

This rule does several things:

- **Rewards efficient play.** Defending well + spending modestly = passive Reserve healing over time, paid for in tempo (you have to skip offensive turns to keep Active full).
- **Creates real "spend or save" choices.** A character with 90/100 Active facing a weak enemy might *not* attack this turn — letting the refresh tick into Reserve instead. Tempo trades against long-term durability, turn by turn.
- **Softens death spirals.** A character at low Reserve who defends well claws back gradually, instead of bleeding out helplessly.
- **Sharpens Stamina's identity.** High Stamina means more Active refresh, which (when Active is full) means more overflow to Reserve. Stamina governs both fast-twitch and slow-burn durability via the *same* mechanic.

### Rest implementations

Rest is available in multiple forms (exact balance TBD):
- **In-battle Rest command** — spend a turn defending only; recover Reserve at the standard formula rate.
- **Camp / Inn** — out-of-combat full Rest, recovering both Reserves to full or near-full.
- **Item-based** — rare consumables that restore Reserve mid-fight without spending a turn.

Note that with the overflow mechanic, a player can effectively "soft-Rest" by playing defensively for several turns — letting the overflow heal Reserve without spending an explicit Rest turn. The dedicated Rest command is for when you need a bigger recovery faster.

### Status conditions modify recovery

Status conditions can alter the rules above — this is a major piece of the encounter-design toolbox. Examples (illustrative, full list TBD):

- **Bleed** — Active HP does not refresh at start of turn; overflow is also disabled.
- **Burnout** — Active MP does not refresh at start of turn.
- **Cursed** — Rest cannot recover Reserve. The character must be cleansed first.
- **Blessed** — Active gauge refresh is doubled this turn.
- **Drained** — Stamina (or Spirit) is treated as halved for recovery calculations.
- **Inspired** — first action of next turn refunds its Active cost on success.

Status conditions interacting with the recovery loop is what makes some enemies *hard* without being numerically overtuned — a mid-tier enemy that applies Bleed and Burnout simultaneously is functionally a clock counting down to death.
