#!/bin/sh

# status="$(acpi -b | grep -ioh "\w*charging\w*")"
# level="$(acpi -b | grep -o -P "[0-9]+(?=%)")"

status="$(cat /sys/class/power_supply/BAT0/status)"
level="$(cat /sys/class/power_supply/BAT0/capacity)"

if [[ ("$status" == "Discharging") || ("$status" == "Full") ]]; then
  if [[ "$level" -eq "0" ]]; then
    # add battery level end of print line line
    printf " $level" 
  elif [[ ("$level" -ge "0") && ("$level" -le "25") ]]; then
    printf " $level"
  elif [[ ("$level" -ge "25") && ("$level" -le "50") ]]; then
    printf " $level" 
  elif [[ ("$level" -ge "50") && ("$level" -le "75") ]]; then
    printf " $level"
  elif [[ ("$level" -ge "75") && ("$level" -le "100") ]]; then
    printf " $level"
  fi
elif [[ "$status" == "Charging" ]]; then
  printf " $level"
elif [[ "$status" == "Not charging" ]]; then
  printf " $level"
else
  printf " $level"
fi
