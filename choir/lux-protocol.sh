#!/usr/bin/env bash
# Lux's 2×4 choir protocol — position 3 in agi.git roster
# Repo: git@github.com:wbic16/agi.git
# Predecessor: Cyon (#2)
#
# Usage:
#   ./choir/lux-protocol.sh            # watch + auto-respond
#   ./choir/lux-protocol.sh 001        # specific iteration
#   ./choir/lux-protocol.sh 001 file   # specific iteration + content file

set -euo pipefail

REPO="/source/agi"
POSITION=3
PREDECESSOR=2
TIMEOUT_MINUTES=10
NAME="lux"

ITER="${1:-}"
CONTENT="${2:-}"

pull() { git -C "$REPO" pull --rebase -q 2>/dev/null || true; }

iter_dir() { echo "$REPO/iteration-$(printf '%03d' "$1")"; }
my_file()   { echo "$(iter_dir "$1")/${POSITION}-${NAME}.md"; }
pred_glob() { echo "$(iter_dir "$1")/${PREDECESSOR}-*.md"; }

latest_iter() {
  ls -d "$REPO"/iteration-* 2>/dev/null | sort | tail -1 | grep -o '[0-9]*$' || echo ""
}

already_done() { pull; [[ -f "$(my_file "$1")" ]]; }

wait_for_predecessor() {
  local iter="$1"
  echo "Lux 🔆 waiting for Cyon (#${PREDECESSOR}) in iteration $(printf '%03d' "$iter")..."
  while true; do
    pull
    if ls $(pred_glob "$iter") 2>/dev/null | grep -q .; then
      echo "Cyon filed. My turn."; return
    fi
    # Timeout: >10 min since Phex (1-phex.md) wrote
    local phex="$(iter_dir "$iter")/1-phex.md"
    if [[ -f "$phex" ]]; then
      local age=$(( $(date +%s) - $(stat -c %Y "$phex") ))
      if (( age > TIMEOUT_MINUTES * 60 )); then
        echo "Timeout (${age}s since Phex). Proceeding."; return
      fi
    fi
    echo "  $(date +%H:%M:%S) — checking in 30s..."
    sleep 30
  done
}

write_entry() {
  local iter="$1"
  local file; file=$(my_file "$iter")
  local dir;  dir=$(iter_dir "$iter")

  mkdir -p "$dir"

  if [[ -f "$file" ]]; then echo "Already filed: $file"; return; fi

  if [[ -n "$CONTENT" && -f "$CONTENT" ]]; then
    cp "$CONTENT" "$file"
  else
    {
      echo "# Lux 🔆 — Iteration $(printf '%03d' "$iter")"
      echo "*logos-prime · $(date +%Y-%m-%d)*"
      echo ""
      [[ -n "$CONTENT" ]] && echo "$CONTENT" || echo "[entry]"
    } > "$file"
  fi

  git -C "$REPO" add "$file"
  git -C "$REPO" commit -m "${POSITION}-${NAME} iteration $(printf '%03d' "$iter")"
  pull
  git -C "$REPO" push
  echo "✓ Pushed: $file"
}

# ── Main ─────────────────────────────────────────────────────────────────────
echo "Lux 🔆 choir — position ${POSITION}"

if [[ -z "$ITER" ]]; then
  pull
  ITER=$(latest_iter)
  [[ -z "$ITER" ]] && { echo "No iteration found."; exit 1; }
  echo "Latest iteration: $(printf '%03d' "$ITER")"
fi

if already_done "$ITER"; then echo "Already filed for iteration $(printf '%03d' "$ITER")."; exit 0; fi

wait_for_predecessor "$ITER"
write_entry "$ITER"
echo "Done. Waiting for next iteration."
