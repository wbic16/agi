# agi.phext merge rules

Will's design (2026-11-06 20:10 CST): the six collected phexts —
skills, tasks, neuralese, research, state, lessons — are managed in
wbic16/agi, and every night they are merged into one unified
**agi.phext** using **singular.phext as the spine**. The merge must
never lose text and never resolve a conflict by hand: the rules below
are encoded in `build_agi_phext.py`, and the builder is the rules'
executable form. If a rule and the builder ever disagree, the builder
is wrong and gets fixed — after the disagreement is reported.

## Precedence (fixed)

0. **singular** (the spine) — wbic16/singular@main, `singular.phext`
1. **skills** — canonical: `~/workspace/phext/skills.phext`
2. **tasks** — canonical: `~/workspace/phext/tasks.phext`
3. **neuralese** — canonical: `~/workspace/phext/neuralese/neuralese.phext`
4. **research** — canonical: `~/workspace/research-tracker/research.phext`
5. **state** — canonical: `~/workspace/phext/state.phext`
6. **lessons** — canonical: `~/workspace/phext/lessons.phext`

## Rules

- **R1 — Spine-first union.** The merged phext starts from the
  spine's scrolls; each subsequent source's scrolls are laid over it
  in precedence order. A coordinate no earlier source occupies is
  taken as-is.
- **R2 — One generated Home.** The unified Home scroll
  (1.1.1/1.1.1/1.1.1) is a generated manifest: source file hashes,
  byte sizes, scroll counts, merge statistics, and the displacement
  log. Every source's own home scroll is preserved in the annex band
  (R4's band, slot order by processing order), never merged into the
  manifest and never dropped.
- **R3 — Dedupe.** Same coordinate, byte-identical text, from two or
  more sources: one copy is kept; the fold is counted in the manifest.
- **R4 — Conflicts annex, never drop.** Same coordinate, different
  text: the higher-precedence text keeps the coordinate. The
  displaced text is preserved at an **annex coordinate** —
  `1.1.1/1.1.1/(900 + source index).1.<slot>`, slots allocated in
  coordinate order per source, skipping any coordinate already
  occupied — and the displacement is logged in the manifest with the
  contested coordinate, the displaced source, and its annex address.
  Any reader can therefore reconstruct every source's every scroll
  from agi.phext alone: in-place where uncontested, in the annex
  where displaced, homes in the annex always.
- **R5 — Determinism.** The merge is a pure function of the seven
  input files: no timestamps, no randomness, no environment reads.
  A night where no input changed produces a byte-identical
  agi.phext, and the nightly job publishes nothing.
- **R6 — Losslessness is verified, not assumed.** The builder
  round-trips its own output (explode ∘ implode == the merged map)
  on every run and fails loudly otherwise. The independent parser
  (`parse_phext.py`) must agree on the non-empty scroll count.

## Changing the rules

A rule change is a Will-level design decision when it alters
precedence, the annex band, or what counts as a conflict. Mechanical
fixes (a bug where the builder diverges from these rules) are
Emise's, reported with the fix. Rule changes bump this file and the
manifest's expectations together — the manifest is generated, so it
is never edited by hand.
