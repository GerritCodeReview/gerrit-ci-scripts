This holds scripts for spinning up extra workers for gerrit CI on GCE.

VMs should be created as:

 * named city-hackathon-40, city-hackathon-41, etc; the numbers should
   be free in the CI master

 * Machine: 24 CPUs/90G RAM.

 * Disk: RHEL 7 hardened image on 100G SSD Persistent Disk

 * SSH: add your personal key.

Here is a gcloud command:

```
gcloud compute instances create \
   --custom-cpu=24 \
   --custom-memory=90 \
   --image-project eip-images \
   --image-family rhel-7-drawfork \
   --boot-disk-size=100GB \
   --boot-disk-type=pd-ssd \
   --zone=us-east4-a \
   city-hackathon-44
```

Install your own key:

```
gcloud compute ssh city-hackathon-44 --command='echo KEY >> .ssh/authorized_keys'
```



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

