#!/bin/bash

# create micah user; note: if you can't login it may be because ubuntu decided to lock the user account for some reason, change ! to * in /etc/shadow for the user
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
passwd -dl root

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
apt-get install --yes docker-ce=5:25.0.5-1~ubuntu.22.04~jammy docker-ce-cli=5:25.0.5-1~ubuntu.22.04~jammy containerd.io docker-buildx-plugin docker-compose-plugin
# for ubuntu 24.04, no idea what the `5:` is at the start of the versions...
# apt-get install --yes docker-ce=5:28.2.2-1~ubuntu.24.04~noble docker-ce-cli=5:28.2.2-1~ubuntu.24.04~noble containerd.io=1.7.27-1 docker-buildx-plugin=0.24.0-1~ubuntu.24.04~noble docker-compose-plugin=2.36.2-1~ubuntu.24.04~noble

# Move docker data location to another drive with
# mkdir /docker-data-drive
# chmod a+rx /docker-data-drive
# fdisk /dev/sdb
# # create partition table
# # create partition
# mkfs.ext4 /dev/sdb1
# echo "/dev/sdb1 /docker-data-drive ext4 defaults 0 0" | sudo tee -a /etc/fstab
# mount -a
# ln -s /docker-data-drive /var/lib/docker
# cat << EOF > /etc/docker/daemon.json
# { 
#   "data-root": "/docker-data-drive"
# }
# EOF

# start docker
systemctl start docker
