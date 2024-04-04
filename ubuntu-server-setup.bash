#!/bin/bash

# Add Docker's official GPG key:
apt-get update
apt-get install --yes ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# install docker v25.0.5-1 via apt package manager
apt-get install docker-ce=5:25.0.5-1~ubuntu.22.04~jammy docker-ce-cli=5:25.0.5-1~ubuntu.22.04~jammy containerd.io docker-buildx-plugin docker-compose-plugin

# start docker
systemctl start docker
