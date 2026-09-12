#!/usr/bin/env bash
#
# hypr-reload-fancy
#
# - If lid is OPEN: just run `hyprctl reload` and exit.
# - If lid is CLOSED: run `hyprctl reload` and then disable the internal monitor.
#

# -------- CONFIG --------

# Name of the internal display as seen in `hyprctl monitors`
INTERNAL_MONITOR="eDP-1"

# Candidate paths for lid state. One of these should exist.
LID_PATHS=(
  "/proc/acpi/button/lid/LID0/state"
  "/proc/acpi/button/lid/LID/state"
  "/proc/acpi/button/lid/MBL0/state"
)

# ------------------------

find_lid_file() {
  for p in "${LID_PATHS[@]}"; do
    if [[ -f "$p" ]]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

get_lid_state() {
  local lid_file
  lid_file=$(find_lid_file) || {
    echo "unknown"
    return 0
  }
  if grep -qi "closed" "$lid_file"; then
    echo "closed"
  elif grep -qi "open" "$lid_file"; then
    echo "open"
  else
    echo "unknown"
  fi
}

# -------- MAIN --------

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "Error: hyprctl not found in PATH."
  exit 1
fi

state=$(get_lid_state)
echo "Lid state: ${state}"

if [[ "$state" != "closed" ]]; then
  echo "Lid is open → reloading and re-enabling internal monitor."

  hyprctl reload
  sleep 1

  hyprctl eval "hl.monitor { output = '${INTERNAL_MONITOR}', disabled = false }"

  sleep 1

  pkill -SIGUSR2 waybar 2>/dev/null

  exit 0
fi

# Lid is closed: full reload, then disable internal monitor.
echo "Lid is closed → reloading and disabling internal monitor."

hyprctl reload
sleep 1

hyprctl eval "hl.monitor { output = '${INTERNAL_MONITOR}', disabled = true }"

sleep 1

# Reload waybar to pick up new monitor layout
pkill -SIGUSR2 waybar 2>/dev/null

echo "Done."
