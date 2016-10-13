#!/bin/bash

# exit script if return code != 0
set -e

# define pacman packages
# pacman_packages="openssl pam perl libltdl libcap nettle systemd"

# install pre-reqs
# pacman -S --needed $pacman_packages --noconfirm

# call aor script (arch official repo)
source /root/aor.sh

# save the default configuration files in /root, then point /etc/squid to /config
cat <<EOF >/etc/squid/REMOVE_TO_INITIALIZE_SWAP
This file prevents the init.sh script from initializing disk swap directories.
Remove this file to initialize then. This will be necessary if your cache
directory has not been used before. First, edit 'squid.conf' and update the
'cache_dir' directive, then remove this file and restart the container.
EOF

# set up a basic working configuration
mkdir /etc/squid/log

cat <<EOF >>/etc/squid/squid.conf

# the following defaults were added by the container install.sh from jdelkins/arch-squid

cache_effective_user nobody
cache_effective_group users
pid_filename /config/squid.pid
cache_dir diskd /cache 51200 64 128
cache_log /config/log/cache.log
access_log daemon:/config/log/access.log
coredump_dir /config
EOF

tar -C /etc/squid -czf /root/squid-config.tar.gz .
rm -rf /etc/squid
ln -s /config /etc/squid

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
