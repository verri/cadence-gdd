# Defensive Reactions — Defense & Counter

When an enemy attacks, the camera shifts to a defensive view. A **telegraph** plays (wind-up animation + audio cue), then a defense input window opens.

The player has two intents available, declared by which buttons they hold:

- **Defend** (default): press **B** at the right moment to Parry/Guard the strike.
- **Counter** (commitment): hold **R** *during* the enemy's strike to declare a counter attempt. Press **B** at the perfect moment to land the counter. Anything less than perfect → take the full hit.

## Tiers of Defense (B alone)

| Input timing | Result | Damage routing |
|---|---|---|
| Perfect (frame-tight) | **Parry** | Negated entirely |
| Good | **Guard** | Reduced damage → Active gauge only |
| Late / mistimed | **Stagger** | Reduced damage → Active first, overflow to Reserve, brief stun |
| No input | **Hit** | Full damage → Active first, overflow to Reserve |

The Active/Reserve split (see [Two-Gauge System](stats-and-resources.md#the-two-gauge-system)) is what makes the timing tiers meaningfully different. Even a mid-grade Guard preserves long-term action economy; a Stagger or Hit eats into the character's lasting capacity.

## Counter (Hold R + B)

Counter is a **declared bet**. By holding R, the player commits to a high-stakes read on the enemy's strike:

- **B at perfect timing** → counter lands. The character interrupts the enemy's strike, takes no damage, and immediately performs a counter-strike at standard physical damage.
- **B mistimed, or no B press** → take the **full hit** as if undefended. The R-commitment voids the safety net that normal Defense provides.

Counter is therefore strictly riskier than Defend. It exists for two reasons:

1. **Reading combos.** Long enemy Chains (and bosses winding up signature attacks) leave large counter windows (see [Vulnerability Rule](chain-strikes.md#the-vulnerability-rule)). A player who reads the boss's heavy combo coming can declare counter and turn the most dangerous moment of the fight into a free counter-attack opportunity.
2. **Skill expression.** A perfect counter is *cool* in a way no Parry can be — it's the player saying "I see you" and being right.

### Counter cost

A successful counter costs Active HP equal to a basic strike (the counter-attack itself is a real action, paid for accordingly). A failed counter costs nothing extra — but you've already taken full damage from the missed defense, so it's plenty expensive.

### Agility and counter windows

The width of the perfect-counter window scales with `your Agility − attacker's Agility` (see [Agility](stats-and-resources.md#agility--the-matchup-stat)). Against a slow heavy-hitter, a fast character has a generous counter window and can punish freely. Against a faster opponent, the window narrows toward frame-perfect — countering an ultra-fast enemy is a feat reserved for skilled players or favorable matchups.

## Multi-target attacks

Boss AoEs require a **rhythmic guard pattern** — multiple defense windows in a sequence (this is where defense flirts with the magic system, intentionally). Counter is not available against AoEs; only Defend.
