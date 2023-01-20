#!/bin/sh

# Set sleep timers so the macs don't go to sleep while installing 
software!
pmset -a sleep 360
pmset -a disksleep 360
pmset -a displaysleep 360

exit 0
