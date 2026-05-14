# Update packages
yay -Sy

yay -S --needed asusctl supergfxctl rog-control-center

# yay -S --needed nvidia-580xx-dkms nvidia-580xx-utils

sudo systemctl enable --now asusd
