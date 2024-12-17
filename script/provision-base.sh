#!/bin/bash
set -e

USERS=(vagrant debian root rootless)

sudo install -m 0755 -d /etc/apt/keyring

sudo apt-get update && \
sudo apt-get upgrade -y && \
sudo apt-get install -y \
  ca-certificates \
  curl

sudo curl \
  -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyring/docker.asc

sudo chmod a+r /etc/apt/keyring/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyring/docker.asc] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y containerd.io

export K3S_KUBECONFIG_MODE=644

sudo curl -sfL https://get.k3s.io | sh -s - "$@"

if [ -f /etc/rancher/k3s/k3s.yaml ]; then

  for USER in "${USERS[@]}"; do

    if id "$USER" &>/dev/null; then

      sudo mkdir -p /home/${USER}/.kube

      sudo cp /etc/rancher/k3s/k3s.yaml /home/${USER}/.kube/config

      sudo chmod 644 /home/${USER}/.kube/config

      sudo chown ${USER}:${USER} /home/${USER}/.kube/config

      sudo chmod o-r /home/${USER}/.kube/config

      sudo chmod g-r /home/${USER}/.kube/config

    fi

  done

fi
