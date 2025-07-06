#!/usr/bin/env python3.10

import time
import subprocess
import os

# Get the absolute path of the current Python script
script_directory = os.path.dirname(os.path.abspath(__file__))

# Replace 'your_script.sh' with the actual name of your Bash script
python_script_path = os.path.join(script_directory, 'get_music_status.py')

# try:
#     # Run the Bash script and capture the output
#     output = subprocess.check_output(
#         ['bash', bash_script_path], stderr=subprocess.STDOUT, text=True)
#
#     # Print the output
#     print("Bash script output:")
#     print(output)
#
# except subprocess.CalledProcessError as e:
#     # If the Bash script returns a non-zero exit code, handle the exception here
#     print(f"Error running Bash script: {e}")
#     print(f"Output: {e.output}")


def run_another_script():
    try:
        # Run the script_to_run.py script and capture its output
        output = subprocess.check_output(
            [python_script_path], universal_newlines=True)

        # Print the captured output
        # print("Output of script_to_run.py:")
        # print(output)
        return output
    except subprocess.CalledProcessError:
        # print(f"Error: {e}")
        return ""


def get_currently_playing():
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

    parent_bar_pids = get_parent_bar_pids()
    player_status, player_metadata = get_player_info()

    if "--status" in subprocess.sys.argv:
        return (player_status)
    else:
        if player_status == "Stopped":
            return ("No music is playing")
        elif player_status == "Paused":
            update_hooks(parent_bar_pids, "2")
            return (player_metadata)
        elif player_status == "No player is running":
            return (player_status)
        else:
            update_hooks(parent_bar_pids, "1")
            return (player_metadata)


current_time_seconds = time.time()


truncate_length = 40
amount_of_spaces = 3


def scroll_string(string):
    initial_string = string
    for x in range(amount_of_spaces):
        initial_string += " "
    string_length = len(initial_string)
    if string_length > truncate_length:
        current_time_seconds = time.time()
        current_time_int = int(current_time_seconds)

        start_point_string = current_time_int % (string_length)

        end_point_string = start_point_string + truncate_length

        remainder = 0

        if (end_point_string > string_length):
            remainder = end_point_string - string_length
            end_point_string = string_length

        string = initial_string[start_point_string: end_point_string]
        string += initial_string[0:remainder]

    if len(string) < truncate_length:
        difference = truncate_length - len(string)
        for x in range(difference):
            string += " "
    return string


musicoutput = get_currently_playing()

if musicoutput != "":
    musicoutput = scroll_string(musicoutput)
    # if len(musicoutput) > truncate_length:
    #     musicoutput = musicoutput[0:truncate_length]
    #     musicoutput += ".."
    print(musicoutput)
    exit(1)
else:
    print("")
    exit(0)
