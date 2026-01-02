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

disable_internal_monitor() {
  echo "→ Disabling internal monitor: ${INTERNAL_MONITOR}"
  hyprctl keyword "monitor" "${INTERNAL_MONITOR}, disable" >/dev/null 2>&1
}

# -------- MAIN --------

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "Error: hyprctl not found in PATH."
  exit 1
fi

state=$(get_lid_state)
echo "Lid state: ${state}"

# If lid is open (or unknown), just do a normal reload and exit.
if [[ "$state" != "closed" ]]; then
  echo "Lid is not closed → running plain 'hyprctl reload'."
  exec hyprctl reload
fi

# Lid is closed: reload then enforce internal screen off
echo "Lid is closed → reloading and forcing internal monitor off."

if ! hyprctl reload; then
  echo "Hyprland reload failed."
  exit 1
fi

# small delay so Hyprland can reapply monitor config
sleep 1

disable_internal_monitor

echo "Done."
