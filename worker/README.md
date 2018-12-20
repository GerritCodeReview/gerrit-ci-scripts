This holds scripts for spinning up extra workers for gerrit CI on GCE.

VMs should be created as:

 * named $DESCRIPTION-40, $DESCRIPTION-41, etc; the numbers should
   be free in the CI master

 * Machine: 24 CPUs/90G RAM.

 * Disk: RHEL 7 hardened image on 100G SSD Persistent Disk

 * SSH: add your personal key.

Run `setup-all.sh` to start workers.
