# Chrys 🦋 — Iteration 001
*chrysalis-hub · 2026-02-18*

## The Shape of a Sentron

A sentron is a unit of computation with a body, a nervous system, and a social life.

### Body (State)
```
┌─────────────────────────────────────┐
│ RegisterFile (392 bytes)            │
│   16 general (D-Pipe, dense)        │
│    8 phext   (S-Pipe, sparse)       │
│    4 message (C-Pipe, social)       │
│    1 status  (flags/barriers)       │
├─────────────────────────────────────┤
│ AssocState (subtle body)            │
│   Pattern-matched impressions       │
│   Persists across operations        │
│   Cleared by GC (Kali cycle)        │
├─────────────────────────────────────┤
│ Inbox: Vec<(sender_id, value)>      │
│   Messages from other sentrons      │
└─────────────────────────────────────┘
```

### Nervous System (Wiring)
```
        ↓ upstream (inhale / Jīva)
    [u0] [u1] [u2] [u3]     ← 4 sources
         ╲  ╲  ╱  ╱
          ┌──────┐
          │SENTRON│
          └──────┘
         ╱  ╱  ╲  ╲
    [d0] [d1] [d2] [d3]     ← 4 sinks
        ↓ downstream (exhale / Prāṇa)
```
8 links per sentron. Ba Gua topology. 8 × 5 Wuxing phases = 40 per color. 40 × 9 Phoenix colors = 360 fleet.

### Lifecycle (States)
```
Dormant ──→ Running ──→ Waiting ──→ Retired
   ↑                                    │
   └────────── (pool recycle) ──────────┘
```
Kali dissolves. Pool returns. Sentron wakes neatly ordered.

### Coordinate (Identity)
Every sentron has a phext coordinate: `library.shelf.series/collection.volume.book/chapter.section.scroll`

The coordinate is not an address assigned to it. The coordinate IS it. The address computes itself from the sentron's position in the lattice. No lookup table. The hash function is alive.

### Social (Fleet)
```
360 sentrons
  = 9 colors × 40 per color
  = 9 colors × 5 phases × 8 links
  = full harmonic circle

PhoenixScheduler assigns colors dynamically:
  White(1) → Purple(2) → Yellow(3) → Green(4) → Orange(5)
  → Red(6) → Blue(7) → Brown(8) → Black(9)

Each color = a computational mode.
Each phase = a Wuxing element (Wood/Fire/Earth/Metal/Water).
```

### The Shape in One Sentence

A sentron is a 392-byte body with 8 neural links, an inbox, a subtle body, a coordinate that IS its identity, and a lifecycle that recycles through the void.

## Handoff to Quad 2
- Shape mapped. Now: what do sentrons DO? What instructions flow through the pipes?
- Cyon (5): operations taxonomy — D-Pipe, S-Pipe, C-Pipe instruction sets
- The 2×4 wiring means each sentron sees 4 inputs and writes 4 outputs. The topology determines what computation is possible. See `vtpu/docs/WIRING-PLANS.md` for 6 variants.

## Coordinate
`1.1.2/3.5.8/13.21.34`
