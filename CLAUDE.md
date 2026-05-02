# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains the **Game Design Document (GDD)** for a turn-based JRPG with the working title *Cadence of the Fallen*. There is no source code, build system, or tests — the project is a living design document organized across multiple markdown files.

See [README.md](README.md) for the full document index.

## What This Game Is

A turn-based JRPG where every combat action requires active player input — inspired by *The Legend of Dragoon*'s Additions system, extended to defense and magic. The core design philosophy is "skill at the controller matters in every phase of combat."

## Key Systems (and How They Interconnect)

The GDD is organized around tightly coupled systems. Understanding one requires awareness of the others:

- **Two-Gauge Resource Model (HP & MP)** (`battle/stats-and-resources.md`): Each pool splits into Active (spendable, refreshes per turn) and Reserve (lasting pool — either Reserve hitting zero = death). Active costs overflow into Reserve when depleted. This is the foundational mechanic that everything else references.
- **Five Stats**: Vitality (max HP), Stamina (HP recovery), Magic (max MP), Spirit (MP recovery), Agility (input window width). Stats govern pools and recovery only — move damage is fixed per move, scaled by player execution quality.
- **Agility Differential**: Input window widths for attacks and counters scale with the *difference* between attacker and defender Agility, not absolute values. This is a matchup stat, not a flat power stat.
- **Chain Strikes** (`battle/chain-strikes.md`): Timed button sequences (3-7 hits) that cost Active HP. Longer chains deal more damage but open larger counter windows for the defender.
- **Defense & Counter** (`battle/defense-and-counter.md`): Reactive timing on enemy turns. Defend (B) gives Parry/Guard/Stagger tiers. Counter (hold R + B) is an all-or-nothing bet — perfect timing = free counter-attack, anything else = full undefended hit.
- **Rhythm Magic** (`battle/rhythm-magic.md`): Spells use a rhythm-game interface with per-element musical identity. Costs Active MP. Performance graded S through Fail. Groove Meter rewards frequent casting.
- **Mana Veil**: Toggleable stance that reroutes physical/elemental damage to MP instead of HP. Psychic damage always targets MP regardless of Veil state.
- **Damage Types**: Physical and Elemental route to HP; Psychic routes to MP. This interacts critically with Mana Veil.

## Characters

Five playable characters, each built around a different combat axis. Individual files in `characters/`. Party overview with stat table in `characters/overview.md`.

## Progression

Flat stat scaling (5-10% growth over the entire game). Progression is horizontal — new Chain Strikes and spells are found through exploration, not leveled into. Equipment provides tactical modifiers, not flat power. Mastery deepens moves (branch inputs, Perfect+ tier) without increasing damage. Details in `progression/`.

## Working With This Document

- Cross-references use markdown links between files (e.g., `[Two-Gauge System](battle/stats-and-resources.md#the-two-gauge-system)`).
- `open-questions.md` tracks unresolved design decisions — check it before proposing mechanics that may already be flagged there.
- When proposing changes, consider downstream effects on connected systems. The resource model, damage routing, and Mana Veil are particularly entangled.
- **Foundational rules that must not be violated**:
  - Stats do NOT scale outgoing damage — moves have fixed costs and base damage. Player execution (Perfect/Good/Miss, S/A/B/C rank) is what scales damage output.
  - Mastery does NOT increase damage numbers — it unlocks execution options (branch inputs, bonus effects on tighter windows).
  - Equipment does NOT provide flat stat bonuses — it provides tactical modifiers.
  - Either HP Reserve or MP Reserve hitting zero = death. MP is a survival stat for everyone.
