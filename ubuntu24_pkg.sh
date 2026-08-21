#!/usr/bin/env bash
set -e

# Simple confirm function
confirm() {
  read -rp "$1 [y/N]: " ans
  case "$ans" in [Yy]*) true ;; *) false ;; esac
}

# Ensure basic prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt update
  sudo apt install -y curl
fi

# 1) Necessary tools
if confirm "Install common tools (VS Code, Tailscale, Terminator)?"; then
  sudo apt update

  # Terminator
  sudo apt install -y terminator

  # VS Code: install via snap (fallback-proof)
  if ! command -v code &>/dev/null; then
    sudo snap install code --classic
  fi

  # Tailscale (official install script) 
  if ! command -v tailscale &>/dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
  fi
fi

# 2) GPU / CUDA
if confirm "Install GPU support (NVIDIA drivers)?"; then
  sudo apt update
  sudo ubuntu-drivers autoinstall
  sudo apt install -y nvidia-cuda-toolkit
  echo "NOTE: A system reboot is required to active the NVIDIA drivers."
fi

# 3) Robotics (ROS 2 Jazzy)
if confirm "Install ROS 2 (Jazzy Jalisco)?"; then
  echo "Setting up UTF-8 Locale..."
  sudo apt update && sudo apt install -y locales
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
  export LANG=en_US.UTF-8

  echo "Enabling Ubuntu Universe Repository..."
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y universe

  echo "Installing official ROS 2 apt configuration utility..."
  sudo apt update && sudo apt install -y curl gnupg2 lsb-release
  
  # Fetch the modern configuration package automatically
  ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
  curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
  sudo apt install -y /tmp/ros2-apt-source.deb

  echo "Upgrading system suites (Critical to prevent Jazzy dependency conflicts)..."
  sudo apt update
  sudo apt full-upgrade -y

  echo "Installing ROS 2 Jazzy Desktop & Developer Tools..."
  sudo apt install -y ros-jazzy-desktop ros-dev-tools

  echo "Initializing rosdep..."
  sudo rosdep init || true
  rosdep update

  # Environment setup
  if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
  fi
fi

echo "All done! Please restart your terminal or run 'source ~/.bashrc'."
