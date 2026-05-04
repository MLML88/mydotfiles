#!/bin/bash

killall waybar
killall swaync

waybar &
swaync &

