#!/usr/bin/env bash
set -e

echo "Updating Fedora..."
sudo dnf upgrade --refresh -y

echo "Installing repo tools..."
sudo dnf install -y dnf-plugins-core curl wget git nano

echo "Installing RPM Fusion..."
sudo dnf install -y \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh -y

echo "Installing lean KDE desktop with Wi-Fi/Bluetooth tray support..."
sudo dnf install -y \
sddm plasma-desktop plasma-workspace plasma-nm bluedevil plasma-pa \
kde-gtk-config kde-settings xdg-desktop-portal-kde kdeplasma-addons \
breeze-icon-theme breeze-gtk dolphin konsole kate ark spectacle gwenview \
NetworkManager NetworkManager-wifi bluez bluez-tools \
pipewire pipewire-pulseaudio pipewire-alsa wireplumber pavucontrol

echo "Installing gaming tools..."
sudo dnf install -y \
steam mangohud gamemode gamescope lutris heroic-games-launcher

echo "Installing useful apps..."
sudo dnf install -y \
fastfetch btop mission-center unzip p7zip p7zip-plugins

echo "Installing codecs..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
sudo dnf group install -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || true
sudo dnf group install -y sound-and-video || true

echo "Installing LACT..."
sudo dnf copr enable -y ilyaz/LACT
sudo dnf install -y lact
sudo systemctl enable lactd --now

echo "Installing OpenRGB..."
sudo dnf install -y openrgb i2c-tools || true

echo "Installing CachyOS kernel..."
sudo dnf copr enable -y bieszczaders/kernel-cachyos
sudo dnf install -y kernel-cachyos kernel-cachyos-devel-matched

echo "Enabling services..."
sudo systemctl enable NetworkManager --now
sudo systemctl enable bluetooth --now
sudo systemctl enable sddm --force
sudo systemctl set-default graphical.target
sudo systemctl enable fstrim.timer

echo "Disabling Wi-Fi power save..."
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<EOF
[connection]
wifi.powersave = 2
EOF

sudo systemctl restart NetworkManager || true

echo "Setting gaming file limits..."
sudo tee /etc/security/limits.d/99-gaming.conf >/dev/null <<EOF
@users soft nofile 1048576
@users hard nofile 1048576
EOF

echo "Setup complete. Reboot now."
