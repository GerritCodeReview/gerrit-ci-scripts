This holds scripts for spinning up extra workers for gerrit CI on GCE.

VMs should be created as:

 * named city-hackathon-40, city-hackathon-41, etc; the numbers should
   be free in the CI master

 * Machine: 24 CPUs/90G RAM.

 * Disk: RHEL 7 hardened image on 100G SSD Persistent Disk

 * SSH: add your personal key.

Here is a gcloud command:

```
num=51
CITY=...
for zone in us-east4-a \
  us-central1-c \
  us-east1-b \
  us-west1-b \
  europe-west1-b \
  europe-west4-a ; \
do
  gcloud \
   --project=${GCE_PROJECT} \
   compute instances create \
   --custom-cpu=24 \
   --custom-memory=90 \
   --image-project eip-images \
   --image-family rhel-7-drawfork \
   --boot-disk-size=100GB \
   --boot-disk-type=pd-ssd \
   --zone=${zone} \
   ${CITY}-hackathon-${num} &
   num=$(($num+1))
done
wait
```

Install your own key:

```
for n in $(seq 51 56) ; do
  gcloud --project=${GCE_PROJECT} compute ssh ${CITY}-hackathon-${n} --command='echo KEY >> .ssh/authorized_keys'
done
```


```sh

IPS=$(gcloud --project=${GCE_PROJECT} compute instances list  | awk '{print $9;}')
for DEST in $IPS ; do
    echo $DEST
    scp -o StrictHostKeyChecking=no $HOME/.ssh/gerritforge/id_ecdsa ${DEST}:
    scp worker/* ${DEST}:
    ssh ${DEST} 'sudo sh -x $(pwd)/setup.sh'
done
```
