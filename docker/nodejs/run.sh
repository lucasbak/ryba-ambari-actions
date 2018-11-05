#!/bin/bash

# wiating for mariadb to be available
printf "%s" "waiting for ambari server  ..."
while ! echo > /dev/tcp/ambari/8080
do
    sleep 1
    printf "."
done
printf "\n%s\n"  "ambari server is online"
# We have TTY, so probably an interactive container...
if test -t 0; then
  # Run supervisord detached...
  supervisord -c /etc/supervisord.conf
  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [[ $@ ]]; then 
    node_modules/.bin/mocha $@
  else
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
# Detached mode
else
  # Run supervisord in foreground, which will stay until container is stopped.
  supervisord -c /etc/supervisord.conf
  ls -l 
  npm run test test/*.coffee
fi