#!/bin/sh

if [[ -z "$num" ]]; then
  echo "Must set 'num'"
  exit 1
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "Must set 'DESCRIPTION'"
  exit 1
fi

if [[ -z "$GCE_PROJECT" ]]; then
  echo "Must set 'GCE_PROJECT'"
  exit 1
fi

n=num
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
   ${DESCRIPTION}-${n} &
   n=$(($n+1))
done
wait


# Install our key
KEY=$(ssh-add -L |grep -v cert)
for n in $(seq ${num} $((${num} + 5))) ; do
  gcloud --project=${GCE_PROJECT} compute ssh ${DESCRIPTION}-${n} \
    --command="echo ${KEY} >> .ssh/authorized_keys"
done

# setup docker.
IPS=$(gcloud --project=${GCE_PROJECT} compute instances list  | awk '{print $9;}')
for DEST in $IPS ; do
    echo $DEST && \
    scp -o StrictHostKeyChecking=no $HOME/.ssh/gerritforge/id_ecdsa ${DEST}: && \
    scp worker/* ${DEST}: && \
    # this takes a while.
    ssh ${DEST} 'sudo sh -x $(pwd)/setup.sh' &
done
wait
