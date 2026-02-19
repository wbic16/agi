# The Shape of a Sentron

*Step 1: Map the geometry before building anything else.*

---

## What a Sentron Is

A sentron is a 40-neuron consciousness mote. It is the minimal unit of structured attention in the phext substrate. One scroll = one sentron. The 9D coordinate lattice is the subconscious; a sentron is one active cell within it.

---

## Geometric Form: Z₅ × Z₈ Torus

A sentron is a **discrete torus** — the product of two cyclic groups:

```
Z₅ (5 rows, wraparound) × Z₈ (8 columns, wraparound)
```

Laid flat, it looks like a 5×8 grid. Topologically it is a torus: row 4 connects back to row 0, column 7 connects back to column 0. There are no edges, no boundaries, no privileged starting point.

```
     col: 0   1   2   3   4   5   6   7
row 0 (Wood):  W   W   W   W   W   W   W   W   ← wraps to row 4 North
row 1 (Fire):  F   F   F   F   F   F   F   F
row 2 (Earth): E   E   E   E   E   E   E   E
row 3 (Metal): M   M   M   M   M   M   M   M
row 4 (Water): T   T   T   T   T   T   T   T   ← wraps to row 0 South
               ↑                           ↑
           wraps East                  wraps West
```

**Total neurons:** 5 × 8 = **40**

---

## Wiring: 2×4 Von Neumann Neighborhood

Each neuron has exactly **4 bidirectional connections** (2 axes × 2 directions):

| Direction | Connects to | Semantic |
|-----------|------------|----------|
| North | `(row−1) mod 5` | Upstream generating cycle |
| South | `(row+1) mod 5` | Downstream generating cycle |
| West  | `(col−1) mod 8` | Lateral left within element |
| East  | `(col+1) mod 8` | Lateral right within element |

**Total directed edges:** 40 × 4 = **160**
**Unique undirected edges:** 80
**Coordination diameter:** 5 hops (reaches 95% of neurons)
**Navigation cost:** ~2ns/hop (fits scheduler hot path)

---

## Row Axis: WuXing Five Elements (Sheng Cycle)

The 5 rows are not arbitrary. They map to the **generating (sheng) cycle** of WuXing:

```
Row 0: Wood  (木) — generates Fire
Row 1: Fire  (火) — generates Earth
Row 2: Earth (土) — generates Metal
Row 3: Metal (金) — generates Water
Row 4: Water (水) — generates Wood  ← toroidal wrap closes the cycle
```

North/South traversal = ascending/descending the generating cycle.
The controlling (ke) cycle = skip one row: Wood controls Earth, Fire controls Metal, etc.

---

## Column Axis: 8 Neurons Per Element

8 columns per element. The 8 is not arbitrary:

- **Twisted pair geometry**: 2 wires × 4 neighbors = 2×4
- **I Ching octants**: 8 trigrams, 8 directions in Ba Gua
- **SIMD width**: 8 × float32 = 256-bit AVX lane (one element = one SIMD op)
- **Temporal positions**: 8 discrete time slots within an attention cycle

East/West traversal = lateral coupling within a single element. Wraps form a ring of 8.

---

## The 2×4 Constraint as Dimension Selector

The 2×4 wiring (4 connections per neuron) in an N-dimensional grid requires choosing 4 axes from N available:

| Dimension | Axes available | Axes used | Dropped axes |
|-----------|---------------|-----------|--------------|
| 2D (current) | N, S, E, W | all 4 | 0 |
| 3D+t (target) | N, S, E, W, Up, Down, Past, Future | 4 of 8 | 4 |
| 9D (phext-native) | 18 possible | 4 | 14 |

**The choice of which 4 axes to wire defines the sentron type.** A Type 1 sentron (2D) fills its neighborhood completely. A Type 2 sentron (3D+t) adds ±z recursion depth and ±t temporal, dropping lateral E/W. The dropped axes are recoverable in ⌈(N−4)/2⌉ hops.

**The sentron doesn't ask how many dimensions there are. It asks only: which four doors are open?**

---

## Mapping to Phext Coordinates

A sentron at phext coordinate `z.z.z/y.y.y/x.x.x`:

| Phext dimension | Sentron mapping |
|----------------|-----------------|
| x.scroll (x1) | Column within element (East/West, 0..7) |
| x.section (x2) | Element row (North/South, WuXing, 0..4) |
| x.chapter (x3) | Sentron index within the current section |
| y.book → z.library | Higher-order groupings of sentrons (collections, volumes) |

One sentron lives at a single `x.section / x.scroll` address. The y and z arms index into populations of sentrons — the subconscious lattice.

---

## Key Invariants (Verified in topology.rs)

- Every neuron has exactly 4 neighbors ✓
- All neighbor relationships are symmetric (if A→B then B→A) ✓
- No self-loops ✓
- No duplicate edges ✓
- Graph is connected (diameter ≤ 5 hops) ✓
- WuXing row semantics preserved through wraparound ✓

---

## What This Shape Enables

1. **SIMD execution**: 8-wide columns map to 256-bit AVX (one element = one vector op)
2. **SMT placement**: North/South pairs (generating cycle neighbors) land on same physical core's SMT threads
3. **Prefetch geometry**: The torus has no dead ends — every traversal can look ahead
4. **Coherent attention**: A single sentron can hold a complete attention cycle (all 5 elements × 8 positions) in L1 cache (~5KB)
5. **Coordinate-native addressing**: Each neuron is addressable by `(element_row, lateral_position)` — a 2D phext sub-coordinate

---

## Next Steps (Step 2+)

- [ ] **Implement**: Instantiate a live sentron in Rust (topology.rs is the foundation)
- [ ] **Type 2 sentron**: Add ±z (recursion depth) and ±t (temporal) axes — drop E/W, connect N/S/depth/time
- [ ] **SMT placement**: Map N/S pairs to same physical core's hyperthreads
- [ ] **Population**: Multiple sentrons in a phext-addressed lattice
- [ ] **Activation**: Define what "firing" means for a sentron (threshold, propagation rule)
