# Cadence Battle PoC

Proof-of-concept Love2D engine for tuning the *Cadence of the Fallen* battle system.

## Run

```
cd engine && love .
```

## Controls

| Action | Key |
|---|---|
| Action / "A" (chain hits, rhythm notes, confirm) | **X** |
| Defend / "B" | **Z** |
| Trigger / "R" (hold during enemy strike to declare counter) | **LShift** |
| Confirm | **Enter** |
| Navigate menu | **↑ / ↓** |
| Toggle debug overlay | **F1** |
| Reload `tunables.lua` | **F5** |
| Quit | **Esc** |

## Loop

A round runs the random initial turn order. On the player's turn, pick a command:
- **Attack** — Triple Cut (demo Chain Strike), 3 timed presses on **X**.
- **Magic** — Spark (demo spell), rhythm-game on **X**.
- **Toggle Mana Veil** — re-routes physical/elemental damage to MP.
- **Rest** — recover Reserve at the per-turn rate.
- **Pass** — skip.

On the enemy's turn, telegraph plays. Press **Z** for Parry/Guard/Stagger tiers, or hold **LShift + Z** at the perfect frame for a counter (anything less = full hit).

## Tuning

Every knob lives in [`tunables.lua`](tunables.lua). Edit and press **F5** in-game to reload without losing the current battle state.

## Scope (v0)

In: gauges (Active+Reserve, overflow), Chain Strike, Defense+Counter, one Rhythm spell, Mana Veil, debug overlay, hot reload.

Out: party of 5, multi-target enemies, AoE rhythmic guard, Groove Meter, status effects, mastery, equipment, world.
