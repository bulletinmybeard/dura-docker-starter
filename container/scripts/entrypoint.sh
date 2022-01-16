#!/bin/bash

# Exit script immediately on any error
set -e

echo "[Entrypoint] ${APPLICATION_NAME}"

#echo "[Entrypoint] Authenticate GIT client with access-token for ${GIT_HOSTER_DOMAIN}'"
#git config --global url."https://${GIT_PERSONAL_ACCESS_TOKEN}:@${GIT_HOSTER_DOMAIN}"

HOSTS_FILE_PATH="/etc/hosts"
HOST_DOMAIN="host.docker.internal"

HOST_IP=$(ip route | awk 'NR==1 {print $3}')
echo "[Entrypoint] Host IP found (${HOST_IP})"

# Requiered to cross access the host machine / container
echo "[Entrypoint] Adding Host IP and Domain (${HOST_IP}/${HOST_DOMAIN}) to ${HOSTS_FILE_PATH}"
echo "$HOST_IP $HOST_DOMAIN" >> ${HOSTS_FILE_PATH}

echo "[Entrypoint] Run supervisor"
supervisord -n -c /etc/supervisor/supervisord.conf
