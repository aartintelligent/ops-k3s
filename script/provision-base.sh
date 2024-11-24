#!/bin/bash
set -e

install -m 0755 -d /etc/apt/keyring

apt-get update && \
apt-get upgrade -y && \
apt-get install -y \
  ca-certificates \
  curl

curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyring/docker.asc

chmod a+r /etc/apt/keyring/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyring/docker.asc] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io

USERS=(vagrant rootless)

for USER in "${USERS[@]}"; do

  if id "$USER" &>/dev/null; then

    usermod -aG docker ${USER}

  fi

done

systemctl reload docker

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode=644

USERS=(vagrant rootless)

for USER in "${USERS[@]}"; do

  if id "$USER" &>/dev/null; then

    mkdir -p /home/${USER}/.kube

    cp /etc/rancher/k3s/k3s.yaml /home/${USER}/.kube/config

    chmod 644 /home/${USER}/.kube/config

    chown ${USER}:${USER} /home/${USER}/.kube/config

    chmod o-r /home/${USER}/.kube/config

    chmod g-r /home/${USER}/.kube/config

  fi

done
