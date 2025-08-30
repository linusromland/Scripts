#!/bin/bash

set -e

echo "=== Updating system ==="
yay -Syu --noconfirm

echo "=== Installing core packages ==="
yay -S --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    openssh \
    firewalld \
    mosh \
    docker

echo "=== Setting up development tools ==="

echo "Installing nvm"
if [ ! -d "$HOME/.nvm" ]; then
  git clone https://github.com/nvm-sh/nvm.git ~/.nvm
  cd ~/.nvm && git checkout "$(git describe --abbrev=0 --tags)"
  cd -
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
fi

echo "Installing Rust"
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

echo "Installing Docker Desktop"
yay -S --noconfirm docker-desktop

echo "Installing MongoDB CLI Tools"
yay -S --noconfirm mongodb-tools

echo "Installing MongoDB Compass"
yay -S --noconfirm mongodb-compass

echo "=== Configuring remoting tools ==="
yay -S --noconfirm gnome-remote-desktop

sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=60000-61000/udp
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload

sudo systemctl enable sshd
sudo systemctl start sshd

systemctl --user --now enable gnome-remote-desktop

echo "=== Setup complete! ==="
