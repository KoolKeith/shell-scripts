#!/bin/bash
# Author: Natenom (natenom@natenom.name)
# License: GPLv3
# Version 0.0.2
# Lastedit 2011-06-05
# Stop server, push murmur.sqlite from current backup to the backup server, chown, start server.

ORIG_DB="/backup/serverx/murmur.sqlite"
TMP_DIR="/tmp/$$"
RESULT_DB=${TMP_DIR}/murmur.sqlite
SQLITE3=$(which sqlite3)
SSH_KEY_FILE="/home/user/ssh-private-key"
REMOTE_DB="/home/murmur-user/murmur.sqlite"
REMOTE_HOST="ip.ip.ip.ip"
REMOTE_SSH_PORT="22"
REMOTE_MURMUR_RUNAS="murmur-user"
REMOTE_MURMUR_BINARY="murmur.x86"
REMOTE_ADMIN_USER="root"


case $1 in
  push)
      [ ! -d ${TMP_DIR} ] && mkdir ${TMP_DIR}
      read -p "First step is to copy the backuped database into a temporary directory on your local host. Press Enter." a
      cp "${ORIG_DB}" "${RESULT_DB}"
      echo "Copied database to temporary directory."

      read -p "Next steps are text replacements for the temporary database. Press Enter." a
      ${SQLITE3} "${RESULT_DB}" 'update config set value="" where key="registerpassword";'
      echo "OK - Replaced registerpasswort to not let the backup server appear in the serverlist :)"
      ${SQLITE3} "${RESULT_DB}" 'update config set value="Natemologie-Zentrum (Ersatzserver)" where key="registername" and server_id=1;'
      echo "OK - Replaced registername into the backup server name."
      ${SQLITE3} "${RESULT_DB}" 'update config set value="<div style='\''font-size:24pt;color:red'\''>Dies ist der Ersatzserver ... <a href='\''mumble://mumble1.natenom.name:64738/?version=1.2.0&url=http://natenom.name&title=Natemologie-Zentrum'\''>Hier klicken um auf den Hauptserver zu gelangen.</a></div>" where key="welcometext" and server_id=1;'
      echo "OK - Replaced the welcometext message."
      ${SQLITE3} "${RESULT_DB}" 'vacuum;'
      echo "OK - Cleaned the database (vacuum)."

      read -p "Next step is to kill the running murmur server on the remote host. Press Enter." a
      ssh -i "${SSH_KEY_FILE}" -p ${REMOTE_SSH_PORT} ${REMOTE_ADMIN_USER}@${REMOTE_HOST} su ${REMOTE_MURMUR_RUNAS} -c \""killall ${REMOTE_MURMUR_BINARY}"\"
      echo "OK - Killed ${REMOTE_MURMUR_BINARY}."

      read -p "Next step is to upload the database to the remote host. Press Enter. " a
      scp -i "${SSH_KEY_FILE}" -P ${REMOTE_SSH_PORT} "${RESULT_DB}" ${REMOTE_ADMIN_USER}@${REMOTE_HOST}:"${REMOTE_DB}"
      echo "OK - Finished database uploading."

      read -p "Next steps are chown the new database and starting the murmur server. Press Enter." a
      ssh -i "${SSH_KEY_FILE}" -p ${REMOTE_SSH_PORT} ${REMOTE_ADMIN_USER}@${REMOTE_HOST} chown ${REMOTE_MURMUR_RUNAS} "\"${REMOTE_DB}\""
      ssh -i "${SSH_KEY_FILE}" -p ${REMOTE_SSH_PORT} ${REMOTE_ADMIN_USER}@${REMOTE_HOST} su ${REMOTE_MURMUR_RUNAS} -c \""cd && ./${REMOTE_MURMUR_BINARY}"\"
      echo "OK - chowned database on remote host and startet murmur server."

      read -p "Next step is to remove temporarily created files on your local host." a
      rm -ri "${TMP_DIR}"
      echo "OK - Removed temporary files."
      echo "Bye :)"

      shift
      ;;
  *)
      cat << END 
Usage: $0 push

Current settings are:
  ORIG_DB=${ORIG_DB}
  TMP_DIR=${TMP_DIR}
  RESULT_DB=${RESULT_DB}
  SQLITE3=${SQLITE3}
  SSH_KEY_FILE=${SSH_KEY_FILE}
  REMOTE_DB=${REMOTE_DB}
  REMOTE_HOST=${REMOTE_HOST}
  REMOTE_SSH_PORT=${REMOTE_SSH_PORT}
  REMOTE_MURMUR_RUNAS=${REMOTE_MURMUR_RUNAS}
END
      ;;
esac