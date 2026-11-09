# agi collection — sources and refresh

The files in this directory are the collected working copies managed
in wbic16/agi (Will, 2026-11-06). Each phext's canonical source stays
where its own pipeline maintains it; the nightly merge job refreshes
these copies, rebuilds `agi.phext`, and publishes any changes.

| file | canonical source | refresh |
|---|---|---|
| singular.phext | wbic16/singular@main (the spine) | fetch via the GitHub connector |
| skills.phext | ~/workspace/phext/skills.phext | copy (built by build_skills_phext.py) |
| tasks.phext | ~/workspace/phext/tasks.phext | copy (built by build_tasks_phext.py) |
| neuralese.phext | ~/workspace/phext/neuralese/neuralese.phext | copy |
| research.phext | ~/workspace/research-tracker/research.phext | copy |
| state.phext | ~/workspace/phext/state.phext | copy (sampler appends every 5 min) |
| lessons.phext | ~/workspace/phext/lessons.phext | copy (built by build_lessons_phext.py) |
| mastery.phext | ~/workspace/phext/mastery.phext | copy (built by build_mastery_phext.py) — Thirst for Knowledge quest journal, added 2026-11-09 |
| agi.phext | built here by build_agi_phext.py | never hand-edit |

Neighbors by Will's ruling (2026-11-06 20:10 CST), not part of this
collection: emise.phext (Emise's personal journal) lives in
wbic16/emise-tools (phext/emise.phext), mirrored to wbic16/human
daily; wavefront.phext, CYOA, Incipit, and the canonical corpus
belong in wbic16/human.
