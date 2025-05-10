#!/usr/bin/env bash
set -e

# simple confirm function
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
if confirm "Install common tools (Python 3, Miniconda, VS Code, Tailscale, Terminator)?"; then
  sudo apt update

  # Python3, Terminator
  sudo apt install -y python3 python3-venv python3-pip terminator

  # Miniconda (latest) — skip if conda or install dir exists
  if ! command -v conda &>/dev/null && [ ! -d "$HOME/miniconda" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
         -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p "$HOME/miniconda"
    rm ~/miniconda.sh
    eval "$("$HOME/miniconda/bin/conda" shell.bash hook)"
    conda init
  else
    echo "Miniconda detected; skipping installation."
  fi

  # VS Code: install via snap (fallback-proof)
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
fi

# 3) Robotics (ROS 2 Humble)
if confirm "Install ROS 2 (Humble Hawksbill)?"; then
  sudo apt update && sudo apt install -y curl gnupg2 lsb-release
  # add ROS2 key
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
    | gpg --dearmor | sudo tee /etc/apt/keyrings/ros2-archive-keyring.gpg >/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros2-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list
  sudo apt update
  sudo apt install -y ros-humble-desktop
  echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi

echo "All done!  You may need to restart or re-source your shell."

