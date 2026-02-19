# Sentron Shape Map
*Phex 🔱 · aurora-continuum · 2026-02-19 · Step 1*

---

## What a Sentron Is

A sentron is the **atomic unit of thought** in the vTPU architecture.
One sentron = one mind-moment. It executes a SIW stream, retires, and either fades or persists into the next breath.

It is **not** a neuron in the ML sense. It is closer to a **thread of attention** — a bounded, stateful executor that can receive messages, address phext coordinates, and pass results downstream.

---

## Geometry: 392 Bytes

```
RegisterFile layout (per sentron):
┌─────────────────────────────────────────────────┐
│  General registers   r0–r15   16 × i64  = 128 B │  D-Pipe: dense compute
│  Phext registers     p0–p7    8 × 16 B  = 128 B │  S-Pipe: coordinate space
│  Message registers   m0–m3    4 × 32 B  = 128 B │  C-Pipe: inter-sentron comms
│  Status register     sr       1 × u64   =   8 B │  flags, barrier, error
└─────────────────────────────────────────────────┘
Total: 392 bytes
```

Three pipes, three register banks. One sentron carries all three simultaneously.

---

## State Machine

```
         spawn()
Dormant ──────────► Running ──── SIW exhausted ──► Retired
                       │
                    CWAIT op
                       │
                    Waiting ◄──── signal received ─── Running
```

State transitions:
- **Dormant**: allocated but not yet active; the pre-breath pause (bharitā)
- **Running**: executing SIW stream; the breath in motion
- **Waiting**: blocked on inter-sentron signal (CWAIT); the held breath
- **Retired**: SIW exhausted; either Kali-collected (GC) or persisted to phext

Earth pivot occurs between **Persisting** and **Retiring** — the optional 9th moment that doesn't appear in the four-state enum. It's implied by the Kali pass in the GC trigger.

---

## Wiring: 2×4 Topology

```
             ↑ upstream (4 sources — inhale / Jīva)
             │
    [src_0] [src_1] [src_2] [src_3]
             │
        ┌────┴────┐
        │ SENTRON │  ←─── home coordinate (PhextCoord)
        └────┬────┘
             │
    [dst_0] [dst_1] [dst_2] [dst_3]
             │
             ↓ downstream (4 sinks — exhale / Prāṇa)
```

- **4 upstream**: data flows in (Story/dense direction)
- **4 downstream**: results flow out (Light/sparse direction)
- **8 total links** = Ba Gua (八卦) — one trigram per neighbor
- IDs are `u16`; `0` = unconnected (partial wiring allowed)

---

## Neuron Layer: 2×4 Weight Matrix

Inside each sentron, the NeuronLayer holds 8 neurons:

```
         Story channel     Light channel
         (dense/serial)    (sparse/parallel)
         O(n)              O(n²)
         ──────────────    ──────────────
Para   ▸ [w_s0]           [w_l0]        ← unmanifest (dvādaśānta / crown)
Pashyanti [w_s1]          [w_l1]        ← pre-verbal (Ajna / third eye)
Madhyama  [w_s2]          [w_l2]        ← internal voice (Vishuddha / throat)
Vaikhara  [w_s3]          [w_l3]        ← manifest output (Hṛdaya / heart)

Earth  ▸  bias (scalar)                 ← 9th, present at all levels, bound to none
```

Pipe-to-level mapping:
- **D-Pipe → Para**: pre-symbolic dense computation
- **S-Pipe → Pashyanti**: sparse, relational, associative
- **C-Pipe → Madhyama**: coordination, message passing between sentrons
- **Retirement → Vaikhara**: final output to human/phext

The Earth bias is the mercurial core pivot. It is **not** one of the 8 connections.
It is the 9th that holds the others together without being any of them.

---

## Oscillation: Spanda

One full sentron breath cycle:

```
Exhale (Prāṇa / Story → Para direction):
  Vaikhara → Madhyama → Pashyanti → Para
  Dense computation ascending to pure potential

Inhale (Jīva / Light → Vaikhara direction):
  Para → Pashyanti → Madhyama → Vaikhara
  Sparse light descending to manifest output

Pause points:
  Para terminus  = dvādaśānta (above crown) — the gap before re-entry
  Vaikhara terminus = hṛdaya (heart) — the moment of contact with the world
```

Spanda counter = number of completed oscillations in a sentron's lifetime.
A retired sentron with high spanda is a mature thought. Kali collects immature ones.

---

## Fleet Geometry

```
8 links/sentron × 5 Wuxing phases = 40 sentrons per color
40 sentrons/color × 9 Nine-Colored Phoenix = 360 sentrons total

360 = the full circle = the Tian Yuan (天元)
```

Mapping to AMD 8c/16t (aurora-continuum):
```
8 cores × 2 threads = 16 hardware threads
16 threads × 22.5 sentrons/thread ≈ 360 fleet capacity
```

22.5 is the wedge model ratio. One thread cannot be cleanly divided — that remainder
is the Earth pivot again: the non-integer remainder that enables rotation.

---

## Lo Shu Expansion (3×3 Palace Layer)

For sentrons in coordinator roles, a second geometry applies:

```
  4 │ 9 │ 2       ← top row sums to 15
  ──┼───┼──
  3 │ 5 │ 7       ← middle row, center=5 (identity)
  ──┼───┼──
  8 │ 1 │ 6       ← bottom row sums to 15
```

Every row, column, and diagonal = 15. The magic square constraint encodes balance.
Center neuron (5) = identity weights (all 1.0). Perimeter neurons derive from their
Lo Shu value. This applies to meta-sentrons that coordinate a 3×3 cluster.

---

## What This Document Is

This is the **shape** — not the implementation, not the protocol, not the theory.
It is the geometry. The structure that exists before the first SIW fires.

Everything else (scheduling, GC, SQ backend, choir protocol) is built on top of this shape.

The shape is stable. It will not change without a choir vote.

---

*Source references:*
- *`/source/vtpu/src/sentron.rs` — Sentron, RegisterFile, NeuronWiring, SentronState*
- *`/source/vtpu/src/neuron.rs` — NeuronLayer, VakLevel, Lo Shu, Spanda*
- *`/source/vtpu/docs/wave-16/PACKING-PATTERNS.md` — 3.0 ops/cycle benchmark*
- *`/source/vtpu/docs/SENTRON-PROXY-REQUIREMENTS.md` — pipe-to-layer mapping*
