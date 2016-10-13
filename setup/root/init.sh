#!/bin/bash

# exit script if return code != 0
set -e

# set user nobody to specified user id (non unique)
echo "[info] Env var PUID defined as ${PUID}"
usermod -o -u "${PUID}" nobody

# set group users to specified group id (non unique)
echo "[info] Env var PGID defined as ${PGID}"
groupmod -o -g "${PGID}" users

# check for config file and create a minimal one if it doesn't exist
if [[ ! -f "/config/squid.conf" ]]; then
	echo "[info] Env var PGID defined as ${PGID}"
	tar -C /config -xzf /root/squid-config.tar.gz
fi

# check for presence of perms file, if it exists then skip setting
# permissions, otherwise recursively set on /config and /cache
if [[ ! -f "/config/perms.txt" ]]; then
	# set permissions for /config and /cache volume mapping
	echo "[info] Setting permissions recursively on /config and /cache..."
	find /config -type d -exec chown $PUID:$PGID {} \; -exec chmod 2770 {} \;
	find /cache  -type d -exec chown $PUID:$PGID {} \; -exec chmod 2770 {} \;
	find /config -type f -exec chown $PUID:$PGID {} \; -exec chmod 0660 {} \;
	find /cache  -type f -exec chown $PUID:$PGID {} \; -exec chmod 0660 {} \;
	echo "This file prevents permissions from being applied/re-applied to /config, if you want to reset permissions then please delete this file and restart the container." > /config/perms.txt
else
	echo "[info] Permissions already set for /config and /cache"
fi

# check whether to initialize the squid disk swap
if [[ ! -f "/config/REMOVE_TO_INITIALIZE_SWAP" ]]; then
	su nobody -c "/usr/bin/squid -z"
	cat <<EOF >/config/REMOVE_TO_INITIALIZE_SWAP
This file prevents the init.sh script from initializing disk swap directories.
Remove this file to initialize then. This should only be necessary if the
configuration directive 'cache_dir' is changed.
EOF
fi

# set permissions inside container
if [[ -n $PIPEWORK_WAIT ]]; then
	echo "[info] Waiting on interface eth1 to come up"
	/root/pipework --wait
fi

echo "[info] Starting Supervisor..."

# run supervisor
umask 002
"/usr/bin/supervisord" -c "/etc/supervisor.conf" -n
