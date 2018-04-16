This holds scripts for spinning up extra workers for gerrit CI on GCE.

VMs should be created as:

 * named city-hackathon-40, city-hackathon-41, etc; the numbers should
   be free in the CI master
 
 * Machine: 24 CPUs/90G RAM.
 
 * Disk: RHEL 7 hardened image on 100G SSD Persistent Disk

 * SSH: add your personal key.


Steps:

1. Become root `sudo su -`

1. `yum install -y git`

1. Install the private key under .ssh/id_ecdsa, available to gerritcodereview-team members.

1. Download:

    ```
    git clone https://gerrit.googlesource.com/gerrit-ci-scripts/
    ```

1. Run setup.sh (one time)

    ```
    sh gerrit-ci-scripts/worker/setup.sh
    ```

1. Run tunnel.sh (TODO(hanwen): setup in crontab from setup.sh)

    ```
    sh gerrit-ci-scripts/worker/tunnel.sh 
    ```

