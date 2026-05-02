# Open Questions

## Battle systems

1. Does difficulty come from **tighter windows** at higher levels, or from **more complex patterns** (more notes per spell, more guards per AoE)?
2. Should rhythm magic use **on-screen notes** (Guitar Hero style) or **audio-only cues** (more immersive, less accessible)?
3. How does the game handle players who struggle with timing? (Assist mode? Wider windows as an accessibility option?)
4. Should **psychic powers** use a distinct minigame variant from elemental rhythm magic — e.g. pattern memorization, sustained focus inputs — to mechanically embody their "mental" nature?

## Agility & windows

5. **Agility scaling formula**: how does the Agility differential map to window width? Linear (`base + k * (atkAgi - defAgi)`)? Capped (so a 100-point gap doesn't trivialize windows)? Curve-based?
6. **Floor on input windows**: even a maxed-Agility differential against a slow target shouldn't make windows so wide that timing becomes irrelevant. Where does that floor sit?
7. **Equal-Agility default**: when attacker and defender Agility are equal, is the window comfortable or tight? (This is the baseline experience — most fights will be near this.)

## Resource model

8. **Reserve recovery between battles**: does walking the world map slowly recover Reserve, or is Rest required? (The latter makes overland travel a resource-management layer.)
9. **Status condition design space**: how many status conditions in total, and how heavily do they target the recovery loop vs. doing direct damage / debuffs?

## Mana Veil

10. Are there hybrid damage types (e.g. **psychophysical**) that split between HP and MP, or do all attacks fall cleanly into one of the three categories?
11. Does toggling the Veil on/off cost a turn, an action, or is it a free swap at the start of the character's turn?
12. Can enemies **strip** a partial-Veil buff (dispel effects), and how visible should partial-Veil percentages be in the UI?

## Characters & progression

13. **Party size in battle**: 3 active from a roster of 5? All 5? Does the party size interact with turn order or pacing?
14. **Chain Strike slot limits**: are slot counts per character final, or should some characters earn extra slots through specific quests?
15. **Mastery pacing**: how many completions to reach each mastery level? Should this scale with the Chain's complexity, or be flat across all moves?
16. **Equipment scarcity**: how many equipment slots per character? If equipment is the primary source of tactical variety, how many distinct pieces exist per category?
17. **Exploration gating**: can the player sequence-break to get late-game Chain Strikes or Sheet Music early, or are acquisition points gated by story/ability?

## World

18. Is the world's story tied to the music/rhythm metaphor, or is that purely mechanical flavor?
