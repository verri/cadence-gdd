# Battle System Overview

Combat is **turn-based with active inputs**. On the player's turn, they pick a command (Attack, Guard, Skill, Magic, Rest, Item). On the enemy's turn, the player still has agency — defense is never automatic.

A turn flows as:
1. **Start of turn** — Active gauges of HP and MP refresh (rate set by Stamina / Spirit).
2. **Player command** — physical actions cost Active HP, magical actions cost Active MP. Each runs its own minigame (timing, rhythm).
3. **Enemy action** — the player engages a defense input.
4. **End of turn** — counters, status effects, and Counter Bar charges resolve.

The full resource model is in [Stats & Resources](battle/stats-and-resources.md). The reactive **Counter Bar** sits outside HP/MP entirely — it fills via successful defense and is spent on counter actions (see [Defense & Counter](battle/defense-and-counter.md)).
