# Battle System Overview

Combat is **turn-based with active inputs**. On the player's turn, they pick a command (Attack, Guard, Skill, Magic, Rest, Item). On the enemy's turn, the player still has agency — defense is never automatic.

A turn flows as:
1. **Start of turn** — Active gauges of HP and MP refresh (rate set by Stamina / Spirit).
2. **Player command** — physical actions cost Active HP, magical actions cost Active MP. Each runs its own minigame (timing, rhythm).
3. **Enemy action** — the player engages a defense input.
4. **End of turn** — status effects and turn counters resolve.

The full resource model is in [Stats & Resources](battle/stats-and-resources.md). Counter is always available — the player declares it by holding R during any enemy strike (see [Defense & Counter](battle/defense-and-counter.md)). There is no charge or meter gating it; the cost is the risk of taking the full hit on a missed read.
