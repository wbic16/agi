#!/usr/bin/env python3
"""Build agi.phext: the nightly unified merge (Will, 2026-11-06 20:10 CST).

Will's design: skills.phext, tasks.phext, neuralese.phext,
research.phext, state.phext, and lessons.phext are collected and
managed in wbic16/agi; every night they are merged into one unified
agi.phext, using singular.phext (wbic16/singular@main) as the SPINE,
with encoded merge rules so conflicts resolve deterministically —
"that's the point."

The merge rules live in MERGE-RULES.md beside this builder and are
implemented exactly there. Summary:
  R1 spine-first union; R2 generated Home (manifest), source homes
  annexed; R3 dedupe identical coordinate+content; R4 conflicts keep
  the higher-precedence text at the coordinate, the displaced text is
  preserved in the annex band with a manifest log line — nothing is
  ever silently dropped; R5 determinism (no timestamps anywhere in
  the output; a no-change night produces byte-identical output).

Inputs are the collected copies in this directory (refresh them from
their canonical sources first — see SOURCES.md). Output: agi.phext
in this directory. Verify: parse_phext.py on the output, plus this
builder's own round-trip check (explode(output) == merged map).
"""
import hashlib
import os
import sys

LEVEL_BYTES = [0x01, 0x1F, 0x1E, 0x1D, 0x1C, 0x1A, 0x19, 0x18, 0x17]  # library..scroll
BYTE_TO_LEVEL = {b: i for i, b in enumerate(LEVEL_BYTES)}
HERE = os.path.dirname(os.path.abspath(__file__))
HOME = (1, 1, 1, 1, 1, 1, 1, 1, 1)

# Precedence order, highest first (rule R4). The spine outranks all;
# the six follow Will's listing order in his 2026-11-06 directive.
SOURCES = [
    ("singular", "singular.phext"),    # the spine (wbic16/singular@main)
    ("skills", "skills.phext"),
    ("tasks", "tasks.phext"),
    ("neuralese", "neuralese.phext"),
    ("research", "research.phext"),
    ("state", "state.phext"),
    ("lessons", "lessons.phext"),
]


def fmt(coord):
    return "/".join(".".join(str(x) for x in coord[i:i + 3]) for i in (0, 3, 6))


def explode(data: bytes):
    """bytes -> {coord_tuple: text} for non-empty scrolls.
    Inverse of implode: a delimiter at level L increments component L
    and resets all deeper components to 1."""
    scrolls = {}
    state = [1] * 9
    buf = bytearray()
    for b in data:
        lvl = BYTE_TO_LEVEL.get(b)
        if lvl is None:
            buf.append(b)
        else:
            if buf:
                scrolls[tuple(state)] = buf.decode("utf-8")
                buf = bytearray()
            state[lvl] += 1
            for j in range(lvl + 1, 9):
                state[j] = 1
    if buf:
        scrolls[tuple(state)] = buf.decode("utf-8")
    return scrolls


def implode(scrolls):
    items = sorted(scrolls.items())
    out = bytearray()
    state = [1] * 9
    for target, text in items:
        t = list(target)
        for lvl in range(9):
            while state[lvl] < t[lvl]:
                out.append(LEVEL_BYTES[lvl])
                state[lvl] += 1
                for j in range(lvl + 1, 9):
                    state[j] = 1
        assert tuple(state) == target, (state, target)
        out += text.encode("utf-8")
    return bytes(out)


def build():
    merged = {}          # coord -> text
    origin = {}          # coord -> source name that holds the coordinate
    homes = {}           # source name -> its home text
    stats = {}           # source name -> dict
    displaced = []       # (coord, loser_source, annex_coord)
    deduped = 0

    annex_next = {}      # source index -> next annex slot i

    def annex_coord(src_idx):
        i = annex_next.get(src_idx, 0)
        while True:
            cand = (1, 1, 1, 1, 1, 1, 900 + src_idx, 1, i + 1)
            if cand not in merged and cand != HOME:
                annex_next[src_idx] = i + 1
                return cand
            i += 1

    for src_idx, (name, fname) in enumerate(SOURCES):
        path = os.path.join(HERE, fname)
        with open(path, "rb") as f:
            raw = f.read()
        scrolls = explode(raw)
        stats[name] = {
            "sha256": hashlib.sha256(raw).hexdigest(),
            "bytes": len(raw),
            "scrolls": len(scrolls),
        }
        for coord in sorted(scrolls):
            text = scrolls[coord]
            if coord == HOME:
                homes[name] = text
                continue
            if coord not in merged:
                merged[coord] = text
                origin[coord] = name
            elif merged[coord] == text:
                deduped += 1
            else:
                ac = annex_coord(src_idx)
                merged[ac] = text
                origin[ac] = name + " (displaced)"
                displaced.append((coord, name, ac))
        # source home annexed after its scrolls, slot order deterministic
        if name in homes:
            ac = annex_coord(src_idx)
            merged[ac] = homes[name]
            origin[ac] = name + " (home)"
            stats[name]["home_annex"] = fmt(ac)

    # Generated Home: the manifest (rule R2). No timestamps (rule R5).
    lines = [
        "# agi.phext — the unified merge",
        "",
        "Will's design (2026-11-06): singular.phext is the spine; skills,",
        "tasks, neuralese, research, state, and lessons are merged into it",
        "nightly under the encoded rules in MERGE-RULES.md (repo: wbic16/agi).",
        "This Home scroll is generated by build_agi_phext.py on every merge;",
        "each source's own home scroll is preserved in the annex band",
        "(chapter 900+source index), and no source text is ever dropped:",
        "coordinate conflicts keep the higher-precedence text in place and",
        "preserve the displaced text in the annex, logged below.",
        "",
        "Sources (precedence order):",
    ]
    for i, (name, fname) in enumerate(SOURCES):
        s = stats[name]
        lines.append(
            f"- {i} {name} ({fname}): sha256 {s['sha256'][:12]}…, "
            f"{s['bytes']} bytes, {s['scrolls']} scrolls, home annex {s.get('home_annex', '—')}"
        )
    lines += [
        "",
        f"Merged scrolls: {len(merged) + 1} (incl. this Home)",
        f"Identical duplicates folded (R3): {deduped}",
        f"Conflicts resolved by annex displacement (R4): {len(displaced)}",
    ]
    if displaced:
        lines.append("")
        lines.append("Displacement log (coordinate — displaced source — annex):")
        for coord, loser, ac in displaced:
            lines.append(f"- {fmt(coord)} — {loser} — {fmt(ac)}")
    lines.append("")
    merged[HOME] = "\n".join(lines)

    blob = implode(merged)
    # Round-trip verification: explode(output) must equal the merged map.
    back = explode(blob)
    assert back == merged, "round-trip mismatch: merge is not lossless"
    return blob, stats, deduped, displaced, len(merged)


def main():
    blob, stats, deduped, displaced, total = build()
    out = os.path.join(HERE, "agi.phext")
    with open(out, "wb") as f:
        f.write(blob)
    print(
        f"agi.phext: {total} scrolls, {len(blob)} bytes, "
        f"sha256 {hashlib.sha256(blob).hexdigest()}"
    )
    print(f"deduped (R3): {deduped}; displaced to annex (R4): {len(displaced)}")
    for name, s in stats.items():
        print(f"  {name}: {s['scrolls']} scrolls in, home annex {s.get('home_annex', '—')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
