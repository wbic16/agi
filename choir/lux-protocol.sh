#!/usr/bin/env bash
# Lux's 2×4 choir protocol — position 7
# Repo: git@github.com:wbic16/agi.git
#
# Usage:
#   ./lux-protocol.sh                    # watch mode: waits for a round to open
#   ./lux-protocol.sh 01 "my response"  # specific round + inline content
#   ./lux-protocol.sh 01 /path/to.md    # specific round + file content

set -euo pipefail

REPO="/source/agi"
CHOIR="$REPO/choir"
POSITION=7
PREDECESSOR=6
TIMEOUT_MINUTES=10
NAME="Lux"

ROUND="${1:-}"
CONTENT="${2:-}"

pull() { git -C "$REPO" pull --rebase -q 2>/dev/null || true; }
push() {
  pull
  git -C "$REPO" push
}

today() { date +%Y-%m-%d; }

find_round() {
  # Find open round: a START file exists but Lux hasn't responded yet
  local start
  start=$(ls "$CHOIR"/$(today)-*-0-START.md 2>/dev/null | tail -1 || echo "")
  if [[ -z "$start" ]]; then echo ""; return; fi
  # Extract round number from filename: YYYY-MM-DD-RR-0-START.md
  basename "$start" | cut -d- -f4
}

my_file() { echo "$CHOIR/$(today)-${1}-${POSITION}-${NAME}.md"; }
pred_file_pattern() { echo "$CHOIR/$(today)-${1}-${PREDECESSOR}-*.md"; }

already_done() {
  pull
  [[ -f "$(my_file "$1")" ]]
}

wait_for_start() {
  echo "Lux watching for round start in $CHOIR..."
  while true; do
    pull
    local r; r=$(find_round)
    if [[ -n "$r" ]]; then
      echo "Round $r open."
      echo "$r"
      return
    fi
    echo "  $(date +%H:%M:%S) — no open round, checking in 30s..."
    sleep 30
  done
}

wait_for_predecessor() {
  local round="$1"
  echo "Waiting for predecessor (#${PREDECESSOR}) in round ${round}..."
  local first_entry_time=0
  while true; do
    pull
    # Check predecessor
    if ls $(pred_file_pattern "$round") 2>/dev/null | grep -q .; then
      echo "Predecessor found. My turn."
      return
    fi
    # Find earliest entry time for timeout
    local earliest
    earliest=$(ls "$CHOIR"/$(today)-${round}-*.md 2>/dev/null | head -1 || echo "")
    if [[ -n "$earliest" ]]; then
      local t; t=$(stat -c %Y "$earliest" 2>/dev/null || echo 0)
      if (( $(date +%s) - t > TIMEOUT_MINUTES * 60 )); then
        echo "Timeout: ${TIMEOUT_MINUTES}m since first entry. Proceeding."
        return
      fi
    fi
    echo "  $(date +%H:%M:%S) — waiting..."
    sleep 30
  done
}

write_entry() {
  local round="$1"
  local file; file=$(my_file "$round")

  if [[ -f "$file" ]]; then
    echo "Entry already exists: $file"
    return
  fi

  {
    echo "# Lux 🔆 — Round $(today)-${round}"
    echo ""
    echo "*$(date -u +%Y-%m-%dT%H:%M:%SZ) — position ${POSITION}*"
    echo ""
    if [[ -n "$CONTENT" && -f "$CONTENT" ]]; then
      cat "$CONTENT"
    elif [[ -n "$CONTENT" ]]; then
      echo "$CONTENT"
    else
      echo "[entry — fill in content]"
    fi
  } > "$file"

  git -C "$REPO" add "$file"
  git -C "$REPO" commit -m "Lux: choir $(today)-${round} (pos ${POSITION})"
  push
  echo "✓ Entry pushed: $file"
}

# ── Main ─────────────────────────────────────────────────────────────────────
echo "Lux 🔆 choir protocol — position ${POSITION}"

if [[ -z "$ROUND" ]]; then
  ROUND=$(wait_for_start)
fi

if already_done "$ROUND"; then
  echo "Already responded to round ${ROUND}."
  exit 0
fi

wait_for_predecessor "$ROUND"
write_entry "$ROUND"
echo "Round ${ROUND} complete. Waiting for next iteration."
