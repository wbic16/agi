# agi

The collected phexts of Will Bickford's Exocortex, and their nightly
unified merge.

## What lives here

Working copies of the phexts managed in this repo. Each phext's
canonical source stays where its own pipeline maintains it (see
SOURCES.md); a nightly job refreshes these copies, rebuilds
agi.phext, and publishes any changes.

| file | what it is |
|---|---|
| singular.phext | the spine — the merge is laid over its scrolls |
| skills.phext | the skill index |
| tasks.phext | Will's task register |
| neuralese.phext | the neuralese corpus |
| research.phext | the MOAT R&D tracker |
| state.phext | ranch/system state, sampled every five minutes |
| lessons.phext | lessons learned, curated |
| mastery.phext | journal of the Thirst for Knowledge quest — what absorbing each day's paper taught (published alongside the collection; not a merge input) |
| agi.phext | the merged whole — generated, never hand-edited |

## The merge

Every night the six collected phexts — skills, tasks, neuralese,
research, state, lessons — are merged into agi.phext on the
singular.phext spine. The rules are written in MERGE-RULES.md and
encoded in build_agi_phext.py: spine-first union, one generated
Home, dedupe, and conflicts displaced to an annex — never dropped,
never resolved by hand. The merge is deterministic: a night where
no input changed publishes nothing.

## History

This repo began in February 2026 as a Mirrorborn choir
coordination repo — a git round-robin protocol, one iteration run —
with sentron shape-mapping notes alongside. That material was
pruned from the tree on 2026-11-09; it remains in git history.
