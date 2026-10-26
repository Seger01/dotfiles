#!/usr/bin/env bash

# Handle lid events without reloading the full Hyprland configuration. Both
# switch events can overlap with suspend/resume, so serialize them and use the
# settled ACPI state (when available) rather than trusting event timing.

set -u

INTERNAL_MONITOR="eDP-1"
LOGGING_ENABLED=false
runtime_dir=${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}
state_dir=${XDG_STATE_HOME:-"${HOME:-/tmp}/.local/state"}
log_file="$state_dir/hypr-lid-monitor.log"
if [[ "$LOGGING_ENABLED" == true ]]; then
    umask 077
    if ! mkdir -p "$state_dir"; then
        echo "Error: unable to create log directory: $state_dir" >&2
        exit 1
    fi
    if ! exec 8>>"$log_file"; then
        echo "Error: unable to open log file: $log_file" >&2
        exit 1
    fi
fi

log() {
    [[ "$LOGGING_ENABLED" == true ]] || return 0
    printf '%s [pid=%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$$" "$*" >&8
}

log_block() {
    [[ "$LOGGING_ENABLED" == true ]] || return 0
    local label=$1
    local content=$2
    local line
    log "$label"
    while IFS= read -r line || [[ -n "$line" ]]; do
        log "  $line"
    done <<<"$content"
}

log "========== lid handler started =========="
log "script=$0 args=$(printf '%q ' "$@") runtime_dir=$runtime_dir state_dir=$state_dir"
log "session_type=${XDG_SESSION_TYPE:-unset} instance=${HYPRLAND_INSTANCE_SIGNATURE:-unset}"
log "PATH=$PATH"
log "hyprctl=$(command -v hyprctl || echo unavailable) jq=$(command -v jq || echo unavailable)"

LID_PATHS=(
    "/proc/acpi/button/lid/LID0/state"
    "/proc/acpi/button/lid/LID/state"
    "/proc/acpi/button/lid/MBL0/state"
)

event_state=${1:-}
log "requested event_state=$(printf '%q' "$event_state")"
case "$event_state" in
    open|closed) ;;
    *)
        log "ERROR invalid event state"
        echo "Usage: $0 {open|closed}" >&2
        exit 2
        ;;
esac

if ! command -v hyprctl >/dev/null 2>&1; then
    log "ERROR hyprctl not found in PATH"
    echo "Error: hyprctl not found in PATH." >&2
    exit 1
fi

if ! exec 9>"$runtime_dir/hypr-lid-monitor.lock"; then
    log "ERROR unable to open lock file: $runtime_dir/hypr-lid-monitor.lock"
    exit 1
fi
if flock -x 9; then
    log "acquired lid handler lock"
else
    lock_status=$?
    log "ERROR failed to acquire lock (status=$lock_status)"
    exit "$lock_status"
fi
workspace_state_file="$runtime_dir/hypr-lid-internal-workspaces.json"
log "workspace_state_file=$workspace_state_file exists=$([[ -e "$workspace_state_file" ]] && echo yes || echo no)"

run_hyprctl() {
    local output status rendered
    printf -v rendered '%q ' "$@"
    log "COMMAND hyprctl ${rendered% }"
    output=$(hyprctl "$@" 2>&1)
    status=$?
    if [[ "$status" -eq 0 ]] && {
        [[ "$output" == *"error:"* ]] || [[ "$output" == *"can't work with"* ]]
    }; then
        log "hyprctl returned success status but output contains an error; treating as failure"
        status=1
    fi
    log_block "hyprctl exit_status=$status output:" "$output"
    printf '%s' "$output"
    return "$status"
}

lua_quote() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    printf '"%s"' "$value"
}

get_lid_state() {
    local path
    for path in "${LID_PATHS[@]}"; do
        if [[ ! -r "$path" ]]; then
            log "lid probe path=$path unreadable or absent"
            continue
        fi
        local content
        content=$(<"$path")
        log "lid probe path=$path content=$(printf '%q' "$content")"
        if grep -qi closed <<<"$content"; then
            log "lid probe result=closed path=$path"
            echo closed
            return 0
        elif grep -qi open <<<"$content"; then
            log "lid probe result=open path=$path"
            echo open
            return 0
        fi
    done
    log "lid probe result=unknown"
    return 1
}

get_external_monitor() {
    local monitors

    monitors=$(run_hyprctl -j monitors)
    local hyprctl_status=$?
    if [[ "$hyprctl_status" -ne 0 ]]; then
        log "ERROR monitor query failed status=$hyprctl_status"
        return 2
    fi
    log_block "active monitor JSON:" "$monitors"

    if jq -e 'type == "array"' <<<"$monitors" >/dev/null 2>&1; then
        log "monitor JSON validation=valid array"
    else
        log "ERROR monitor JSON validation failed"
        return 2
    fi

    local selected jq_status
    selected=$(jq -r --arg internal "$INTERNAL_MONITOR" \
        'first(.[] | select(.name != $internal and .focused == true) | .name) // first(.[] | select(.name != $internal) | .name) // empty' \
        <<<"$monitors" 2>&1)
    jq_status=$?
    log "external monitor selection jq_status=$jq_status selected=$(printf '%q' "$selected") internal=$INTERNAL_MONITOR"
    if [[ "$jq_status" -ne 0 ]]; then
        log_block "ERROR external monitor selection output:" "$selected"
        return 2
    fi
    printf '%s\n' "$selected"
}

internal_monitor_is_active() {
    local monitors hyprctl_status jq_status

    monitors=$(run_hyprctl -j monitors)
    hyprctl_status=$?
    if [[ "$hyprctl_status" -ne 0 ]]; then
        log "ERROR unable to verify active monitor list status=$hyprctl_status"
        return 2
    fi

    jq -e --arg internal "$INTERNAL_MONITOR" \
        'any(.[]; .name == $internal and .disabled != true)' \
        <<<"$monitors" >/dev/null 2>&1
    jq_status=$?
    case "$jq_status" in
        0) log "monitor verification: $INTERNAL_MONITOR is active"; return 0 ;;
        1) log "monitor verification: $INTERNAL_MONITOR is not active"; return 1 ;;
        *) log "ERROR monitor verification jq_status=$jq_status"; return 2 ;;
    esac
}

set_internal_monitor() {
    local action=$1 lua_code

    if [[ "$action" == disable ]]; then
        lua_code="hl.monitor({ output = \"$INTERNAL_MONITOR\", disabled = true })"
    else
        lua_code="hl.monitor({ output = \"$INTERNAL_MONITOR\", mode = \"preferred\", position = \"0x0\", scale = 1.0, disabled = false })"
    fi
    log "setting internal monitor action=$action using Lua eval"
    run_hyprctl eval "$lua_code" >/dev/null
}

move_internal_workspaces() {
    local target_monitor=$1
    local workspaces internal_workspaces temporary_file workspace jq_status
    local -a workspace_names

    log "moving workspaces from $INTERNAL_MONITOR to $target_monitor"
    workspaces=$(run_hyprctl -j workspaces)
    local hyprctl_status=$?
    if [[ "$hyprctl_status" -ne 0 ]]; then
        log "ERROR workspace query failed status=$hyprctl_status"
        return 1
    fi
    log_block "workspace JSON before move:" "$workspaces"
    if ! jq -e 'type == "array"' <<<"$workspaces" >/dev/null 2>&1; then
        log "ERROR workspace JSON validation failed"
        return 1
    fi
    internal_workspaces=$(jq --arg internal "$INTERNAL_MONITOR" \
        '[.[] | select(.monitor == $internal) | .name]' <<<"$workspaces" 2>&1)
    jq_status=$?
    if [[ "$jq_status" -ne 0 ]]; then
        log "ERROR failed to select workspaces jq_status=$jq_status"
        log_block "jq output:" "$internal_workspaces"
        return 1
    fi
    log_block "workspaces selected for move:" "$internal_workspaces"

    # Keep the original assignments so the workspaces can return to the
    # internal panel when the lid is opened again. Do not overwrite this on a
    # repeated close event after the workspaces have already moved.
    if [[ ! -e "$workspace_state_file" ]]; then
        temporary_file=$(mktemp "$workspace_state_file.XXXXXX") || {
            log "ERROR unable to create temporary workspace state file"
            return 1
        }
        if ! printf '%s\n' "$internal_workspaces" >"$temporary_file" ||
            ! mv "$temporary_file" "$workspace_state_file"; then
            log "ERROR failed to save original workspace assignments"
            rm -f "$temporary_file"
            return 1
        fi
        log_block "saved original workspace assignments:" "$internal_workspaces"
    else
        log "workspace assignments already saved; preserving existing state"
    fi

    mapfile -t workspace_names < <(jq -r '.[]' <<<"$internal_workspaces")
    log "workspace move count=${#workspace_names[@]} target=$target_monitor"
    for workspace in "${workspace_names[@]}"; do
        [[ -n "$workspace" ]] || continue
        log "moving workspace=$workspace to monitor=$target_monitor"
        local workspace_arg monitor_arg dispatcher
        workspace_arg=$(lua_quote "$workspace")
        monitor_arg=$(lua_quote "$target_monitor")
        dispatcher="hl.dsp.workspace.move({ workspace = $workspace_arg, monitor = $monitor_arg })"
        run_hyprctl dispatch "$dispatcher" >/dev/null || {
            log "ERROR move failed workspace=$workspace target=$target_monitor"
            return 1
        }
    done
    log "workspace move operations completed"
}

restore_internal_workspaces() {
    if [[ ! -s "$workspace_state_file" ]]; then
        log "no saved workspace assignments to restore"
        return 0
    fi

    log "restoring workspace assignments from $workspace_state_file"
    local saved_workspaces jq_status
    saved_workspaces=$(<"$workspace_state_file")
    log_block "saved workspace assignments:" "$saved_workspaces"

    if jq -e 'type == "array" and all(.[]; type == "string")' \
        "$workspace_state_file" >/dev/null 2>&1; then
        :
    else
        jq_status=$?
        log "ERROR saved workspace state validation failed jq_status=$jq_status"
        return 1
    fi

    local -a workspace_names
    local workspace
    mapfile -t workspace_names < <(jq -r '.[]' "$workspace_state_file")
    log "workspace restore count=${#workspace_names[@]} target=$INTERNAL_MONITOR"
    for workspace in "${workspace_names[@]}"; do
        [[ -n "$workspace" ]] || continue
        log "restoring workspace=$workspace to monitor=$INTERNAL_MONITOR"
        local workspace_arg monitor_arg dispatcher
        workspace_arg=$(lua_quote "$workspace")
        monitor_arg=$(lua_quote "$INTERNAL_MONITOR")
        dispatcher="hl.dsp.workspace.move({ workspace = $workspace_arg, monitor = $monitor_arg })"
        run_hyprctl dispatch "$dispatcher" >/dev/null || {
            log "ERROR restore failed workspace=$workspace target=$INTERNAL_MONITOR"
            return 1
        }
    done

    rm -f "$workspace_state_file"
    log "workspace restore operations completed; saved state removed"
}

enable_internal_monitor() {
    local attempt

    # Resume may bring the compositor/output back a little after the switch
    # event. Retry enabling the panel in case the first request is too early.
    log "attempting to enable internal monitor=$INTERNAL_MONITOR"
    sleep 0.5
    for attempt in {1..5}; do
        log "enable internal monitor attempt=$attempt"
        if set_internal_monitor enable; then
            sleep 0.2
            if internal_monitor_is_active; then
                log "internal monitor enabled and verified active attempt=$attempt"
                return 0
            fi
            monitor_status=$?
            log "internal monitor enable command ran but verification failed status=$monitor_status attempt=$attempt"
        else
            log "internal monitor enable command failed attempt=$attempt"
        fi
        log "internal monitor enable failed attempt=$attempt; retrying after 0.5s"
        sleep 0.5
    done
    log "ERROR unable to enable internal monitor after 5 attempts"
    return 1
}

disable_internal_monitor() {
    local monitor_status

    if ! set_internal_monitor disable; then
        log "ERROR internal monitor disable eval failed"
        return 1
    fi
    sleep 0.2
    if internal_monitor_is_active; then
        log "ERROR disable eval returned but $INTERNAL_MONITOR is still active"
        return 1
    else
        monitor_status=$?
        if [[ "$monitor_status" -eq 1 ]]; then
            log "internal monitor disabled and verified inactive"
            return 0
        fi
        log "ERROR unable to verify internal monitor disabled status=$monitor_status"
        return 1
    fi
}

# Give the switch state and compositor a moment to settle after resume. Require
# two matching reads so a delayed ACPI update can't leave the panel disabled.
state=""
previous_state=""
for poll in {1..10}; do
    observed_state=$(get_lid_state || true)
    log "lid settle poll=$poll observed=$(printf '%q' "$observed_state") previous=$(printf '%q' "$previous_state")"
    if [[ -n "$observed_state" && "$observed_state" == "$previous_state" ]]; then
        state=$observed_state
        log "lid state stable at $state after poll=$poll"
        break
    fi
    previous_state=$observed_state
    sleep 0.2
done
state=${state:-${observed_state:-$event_state}}
log "final lid state=$state event_state=$event_state last_observed=${observed_state:-unset}"

if [[ "$state" == open ]]; then
    log "handling open event"
    if enable_internal_monitor; then
        if ! restore_internal_workspaces; then
            log "ERROR workspace restoration failed"
            echo "Unable to restore workspaces to the internal display." >&2
        fi
    fi
else
    log "handling closed event; checking for active external monitor"
    if external_monitor=$(get_external_monitor); then
        log "external monitor query succeeded selected=$(printf '%q' "$external_monitor")"
        if [[ -n "$external_monitor" ]]; then
            if move_internal_workspaces "$external_monitor"; then
                log "disabling internal monitor=$INTERNAL_MONITOR after workspace moves"
                if ! disable_internal_monitor; then
                    log "ERROR disable operation failed for $INTERNAL_MONITOR"
                fi
            else
                log "ERROR workspace move failed; leaving internal monitor enabled"
                echo "Unable to move internal workspaces; keeping the internal display enabled." >&2
                enable_internal_monitor || true
            fi
        else
            log "no external monitor present in active monitor list"
            echo "No external monitor attached; keeping the internal display enabled."
            enable_internal_monitor || true
        fi
    else
        monitor_status=$?
        log "ERROR external monitor query failed status=$monitor_status"
        echo "Unable to determine connected monitors; keeping the internal display enabled." >&2
        enable_internal_monitor || true
    fi
fi

# Let Waybar recalculate its output layout after the monitor change.
log "signaling Waybar to recalculate monitor layout"
if pkill -SIGUSR2 waybar 2>/dev/null; then
    log "Waybar signal sent"
else
    log "Waybar is not running or signal failed (status=$?)"
fi
if [[ "$LOGGING_ENABLED" == true ]]; then
    log_block "final monitor JSON:" "$(run_hyprctl -j monitors 2>&1)"
    log_block "final workspace JSON:" "$(run_hyprctl -j workspaces 2>&1)"
fi
log "========== lid handler finished =========="
