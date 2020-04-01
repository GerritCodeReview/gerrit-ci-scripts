#!/bin/bash -e
export DOCKER_HOST=`/sbin/ip route|awk '/default/ {print "tcp://"$3":2375"}'}`
