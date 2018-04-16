#!/bin/bash


if [[ -z "$1" ]]; then
    WORKER=$(hostname | sed 's|.*-\([0-9]*\)$|\1|')
    echo "using worker ID $WORKER"
else
    WORKER=$1
fi

cd /root
set -ue

if [[ -f ".ssh/id_ecdsa" ]]; then
    chmod 0600 .ssh/id_ecdsa
else
    echo "SSH ID missing."
    exit 1
fi

export TIMEOUT=10
export SUBNET=10.0.$WORKER

echo "Checking connectivity to new-ci ..."
PIDS=$(ps -a -o pid,ppid,cmd | grep ssh | grep gerrit-ci.gerritforge.com | grep -v grep | awk '{print $1}')

if [[ -n "$PIDS" ]] ; then
  if ping -q -c 1 -w $TIMEOUT $SUBNET.2 > /dev/null
  then
      echo OK
      exit 0
  fi
fi

echo "no connection; Killing stale PIDs $PIDS"
for i in $PIDS; do
  kill -9 $i;
done

# Ugh. SELinux disallows PPPD to execute SSH.
setenforce 0

/usr/sbin/pppd \
      nodetach noauth silent nodeflate pty \
      "/usr/bin/ssh -p 1022 gerrit-ci.gerritforge.com /usr/sbin/pppd nodetach  notty noauth" ipparam vpn $SUBNET.1:$SUBNET.2

