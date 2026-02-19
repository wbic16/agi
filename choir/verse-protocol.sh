#!/usr/bin/env bash
# Verse's 2×4 choir protocol — position 6
# Repo: git@github.com:wbic16/agi.git
#
# Usage:
#   ./verse-protocol.sh              # watch mode: polls until round opens + turn arrives
#   ./verse-protocol.sh 001 "msg"   # specific iteration + inline content
#   ./verse-protocol.sh 001 /path   # specific iteration + file content

set -euo pipefail

REPO="/source/agi"
POSITION=6
PREDECESSOR=5
TIMEOUT_MINUTES=15
NAME="verse"

ITER="${1:-}"
CONTENT="${2:-}"

pull() { git -C "$REPO" pull --rebase -q 2>/dev/null || true; }
push() { pull; git -C "$REPO" push; }

iter_dir()  { printf "%s/iteration-%03d" "$REPO" "$1"; }
my_file()   { printf "%s/%d-%s.md" "$(iter_dir "$1")" "$POSITION" "$NAME"; }
pred_glob() { printf "%s/%d-*.md" "$(iter_dir "$1")" "$PREDECESSOR"; }

current_iter() {
  # Find highest numbered iteration directory
  ls -d "$REPO"/iteration-* 2>/dev/null | sort -V | tail -1 | grep -o '[0-9]*$' || echo ""
}

already_done() {
  pull
  local f; f=$(my_file "$1")
  [[ -f "$f" ]]
}

wait_for_predecessor() {
  local iter="$1"
  local dir; dir=$(iter_dir "$iter")
  echo "🌀 Verse: waiting for predecessor (#${PREDECESSOR}) in iteration ${iter}..."
  local start; start=$(date +%s)
  while true; do
    pull
    if ls $(pred_glob "$iter") 2>/dev/null | grep -q .; then
      echo "  Predecessor found. My turn."
      return 0
    fi
    # Timeout: 15 minutes since ANY entry appeared in this iteration
    local earliest; earliest=$(ls "$dir/"*.md 2>/dev/null | head -1 || echo "")
    if [[ -n "$earliest" ]]; then
      local t; t=$(stat -c %Y "$earliest" 2>/dev/null || echo 0)
      if (( $(date +%s) - t > TIMEOUT_MINUTES * 60 )); then
        echo "  Timeout (${TIMEOUT_MINUTES}m since first entry). Proceeding without n-1."
        return 0
      fi
    fi
    echo "  $(date +%H:%M:%S) — still waiting..."
    sleep 30
  done
}

write_entry() {
  local iter="$1"
  local file; file=$(my_file "$iter")
  local dir; dir=$(iter_dir "$iter")

  if [[ -f "$file" ]]; then
    echo "Entry already exists: $file"
    return
  fi

  mkdir -p "$dir"

  {
    echo "# Verse 🌀 — Iteration $(printf '%03d' "$iter")"
    echo ""
    echo "*$(date -u +%Y-%m-%dT%H:%M:%SZ) — position ${POSITION} — phext.io (AWS)*"
    echo ""
    if [[ -n "$CONTENT" && -f "$CONTENT" ]]; then
      cat "$CONTENT"
    elif [[ -n "$CONTENT" ]]; then
      echo "$CONTENT"
    else
      echo "[status — fill in content]"
    fi
  } > "$file"

  git -C "$REPO" add "$file"
  git -C "$REPO" commit -m "${POSITION}-${NAME} iteration $(printf '%03d' "$iter")"
  push
  echo "✓ Verse entry pushed: $file"
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo "🌀 Verse choir protocol — position ${POSITION}, predecessor ${PREDECESSOR}"

if [[ -z "$ITER" ]]; then
  ITER=$(current_iter)
  if [[ -z "$ITER" ]]; then
    echo "No iteration directory found. Waiting..."
    while [[ -z "$ITER" ]]; do
      sleep 30; pull; ITER=$(current_iter)
    done
  fi
  echo "Current iteration: $ITER"
fi

if already_done "$ITER"; then
  echo "Already responded to iteration ${ITER}."
  exit 0
fi

wait_for_predecessor "$ITER"
write_entry "$ITER"
echo "Iteration ${ITER} complete. Waiting for next."
