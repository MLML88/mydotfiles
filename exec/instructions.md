# Font size
setfont ter-132n

# Check if you're connected to the internet
# If not then do this
iwctl
device list

## If your device is powered off then turn on using
device wlan0 set-property Powered on

station wlan0 get-networks
station wlan0 connect <wifi-name>

# Then update your packages
pacman -Sy

# Install arch keyring
pacman -S archlinux-keyring

# Check if you have the archinstall
whereis archinstall

## if you don't have it then
pacman -S archinstall

# Clear disk space
lsblk

## For infomation
fdisk -l

## To edit disk
cfdisk <partition-name>

1G EFI System
?G Linux filesystem

# Format partitions

## For EFI System
mkfs.fat -F32 <partition-name>

## For Linux filesystem
mkfs.ext4 <partition-name>

# Mount

## Mount Linux filesysytem first
mount <partition-name> /mnt

## Then mount EFI System
mkdir /mnt/boot
mount <partition-name> /mnt/boot/

## To verify
lsblk

# Archinstall
archinstall

## Disk configuration
Pre-mounted configuration to /mnt

## Swap
Enable it
Pick zstd

## Bootloader
Refind/grub/system-md
Enable unified kernel image

## Set hostname(username) and password
## Create new user and add to sudo

## Profile
Desktop
Hyprland

## Applications
Enable bluetooth
Audio choose pipewire
Power management choose power-profiles-daemon

## Network config
Use network manager (default backend)

## Timezone
America/New_York

# Post package installation
pacman -S vlc gcc wget curl git make cmake fastfetch htop noto-fonts noto-fonts-cjk noto-fonts-emoji

# Reboot
reboot now

# Or shutdown
shutdown now

# On windows if you want to delete those paritiions
diskpart
list disk
select disk <number>
list partition
select partition <number>
delete partition override
