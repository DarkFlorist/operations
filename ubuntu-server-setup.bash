#!/bin/bash

# create micah user
adduser --disabled-password --shell /bin/bash --home /home/micah --gecos '' micah
usermod -aG sudo micah

# allow sudo without password
echo "micah ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/micah

# move authorized_keys to micah user profile
mkdir /home/micah/.ssh
chown micah:micah /home/micah/.ssh
cp /root/.ssh/authorized_keys /home/micah/.ssh/authorized_keys
chown micah:micah /home/micah/.ssh/authorized_keys
chmod 640 /home/micah/.ssh/authorized_keys
chmod 700 /home/micah/.ssh

# disable root user
sed -i "s/^PermitRootLogin .*$/PermitRootLogin no/" /etc/ssh/sshd_config

# disable password authentication
sed -i "s/^PasswordAuthentication .*$/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^UsePAM .*$/UsePAM no/" /etc/ssh/sshd_config
echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config

# restart ssh so above changes take effect
systemctl restart ssh

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

# Move docker data location to another drive with
# mount /dev/sdb1 /docker-data-drive
# TODO: add to fstab so it survives restarts
# chmod a+rx /docker-data-drive
# ln -s /docker-data-drive /var/lib/docker
# cat << EOF > /etc/docker/daemon.json
# { 
#   "graph": "/docker-data-drive"
# }
# EOF

# start docker
systemctl start docker
