#!/usr/bin/env python3
import subprocess

# The name of polybar bar which houses the main spotify module and the control modules.
PARENT_BAR = "bar"

# Set the source audio player here.
# Players supporting the MPRIS spec are supported.
# Examples: spotify, vlc, chrome, mpv, and others.
# Use `playerctld` to always detect the latest player.
# See more here: https://github.com/altdesktop/playerctl/#selecting-players-to-control
PLAYER = "playerctld"

# Format of the information displayed
# Eg. {{ artist }} - {{ album }} - {{ title }}
# See more attributes here: https://github.com/altdesktop/playerctl/#printing-properties-and-metadata
FORMAT = "{{ title }} - {{ artist }}"

# Sends $2 as a message to all polybar PIDs that are part of $1


def update_hooks(pids, message):
    for pid in pids:
        subprocess.run(["polybar-msg", "-p", str(pid), "hook", "spotify-play-pause",
                       message], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Get the PIDs of polybar processes with the specified name


def get_parent_bar_pids():
    try:
        process = subprocess.run(
            ["pgrep", "-a", "polybar"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        lines = process.stdout.splitlines()
        return [int(line.split()[0]) for line in lines if PARENT_BAR in line]
    except subprocess.CalledProcessError:
        return []

# Get the player status and metadata


def get_player_info():
    try:
        status_process = subprocess.run(
            ["playerctl", "--player", PLAYER, "status"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        status = status_process.stdout.strip()
        metadata_process = subprocess.run(["playerctl", "--player", PLAYER, "metadata",
                                          "--format", FORMAT], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        metadata = metadata_process.stdout.strip()
        return status, metadata
    except subprocess.CalledProcessError:
        return "No player is running", ""


if __name__ == "__main__":
    parent_bar_pids = get_parent_bar_pids()
    player_status, player_metadata = get_player_info()

    if "--status" in subprocess.sys.argv:
        print(player_status)
    else:
        if player_status == "Stopped":
            print("No music is playing")
        elif player_status == "Paused":
            update_hooks(parent_bar_pids, "2")
            print(player_metadata)
        elif player_status == "No player is running":
            print(player_status)
        else:
            update_hooks(parent_bar_pids, "1")
            print(player_metadata)
