#!/bin/bash

# Exit script immediately on any error
set -e

HOSTS_FILE_PATH="/etc/hosts"
HOST_DOMAIN="host.docker.internal"
KNOWN_HOSTS_FILE="${HOME}/.ssh/known_hosts"

echo "[Entrypoint] ${APPLICATION_NAME}"

echo "[Entrypoint] Create GIT config"
cat << EOF > /root/.gitconfig
[url "https://${GIT_PERSONAL_ACCESS_TOKEN}@${GIT_DOMAIN}"]
  insteadOf = git://github
[user]
	name = ${GIT_USERNAME}
	email = ${GIT_USER_EMAIL}
[github]
	user = ${GIT_USERNAME}
	token = ${GIT_PERSONAL_ACCESS_TOKEN}
EOF

echo "[Entrypoint] Add GIT domain to ${KNOWN_HOSTS_FILE}"
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan "${GIT_DOMAIN}" >> "${KNOWN_HOSTS_FILE}"

HOST_IP=$(ip route | awk 'NR==1 {print $3}')
echo "[Entrypoint] Host IP found (${HOST_IP})"

# Requiered to cross access the host machine / container
echo "[Entrypoint] Adding Host IP and Domain (${HOST_IP}/${HOST_DOMAIN}) to ${HOSTS_FILE_PATH}"
echo "$HOST_IP $HOST_DOMAIN" >> ${HOSTS_FILE_PATH}

echo "[Entrypoint] Start supervisor"
supervisord -n -c /etc/supervisor/supervisord.conf
