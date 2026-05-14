# Update packages
yay -Sy

# Install tools
# nautilus - File explorer
# ddcutil - Command-line for brightness, color, and input source
# pavucontrol - PulseAudio
# awww - Wallpaper tool
yay -S --needed nautilus ddcutil pavucontrol awww

# Install configuration tools
# waybar - Simple bar maker
# wlogout - Simple logout menu
# quickshell - More advanced, able to make bar, notification, launcher menu, and etc
yay -S --needed waybar wlogout hyprlock hyprsunset quickshell-git

# Install Essentials
# swaync - Used for notification panel
# cliphist, wl-clipboard, wl-clip-persist - Used for copy clipboard
# hyprshot - Used for screenshots
yay -S --needed swaync cliphist wl-clipboard wl-clip-persist hyprshot lazygit

# Install bluetooth
yay -S --needed bluez bluez-utils blueman

# Install fonts
yay -S --needed ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-rubik-vf
