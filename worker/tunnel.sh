#!/bin/bash


if [[ -z "$1" ]]; then
    WORKER=$(hostname | sed 's|.*-\([0-9]*\)$|\1|')
    echo "using worker ID $WORKER"
else
    WORKER=$1
fi

set -u
if [[ -f ".ssh/id_ecdsa" ]]; then
    chmod 0600 .ssh/id_ecdsa
else
    echo "SSH ID missing."
fi

export NOW=`date +%y%m%d_%H%M%S`
export LOG=$0.log
export TIMEOUT=10
export SUBNET=10.0.$WORKER
function log {
  TS=$(date +%H:%M:%S)
  echo "$TS | $WORKER" >> $LOG
}
log "Checking connectivity to new-ci ..."
if ping -q -c 1 -w $TIMEOUT $SUBNET.2 > /dev/null
then
  log OK
else
  log "NO CONNECTION"
  PIDS=$(ps -a -o pid,ppid,cmd | grep ssh | grep gerrit-ci.gerritforge.com | grep -v grep | awk '{print $1}')
  log "Killing stale PIDs $PIDS"
  for i in $PIDS; do kill -9 $i; done
  /usr/sbin/pppd updetach noauth silent nodeflate pty "/usr/bin/ssh -p 1022 gerrit-ci.gerritforge.com /usr/sbin/pppd nodetach  notty noauth" ipparam vpn $SUBNET.1:$SUBNET.2 >> $LOG 2>> $LOG
  sleep 10 # Wait for tunnel to come up
  systemctl daemon-reload
  systemctl restart docker
fi
