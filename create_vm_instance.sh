#! /bin/bash

export YOUR_PRJ_NAME=ordinal-virtue-208004
export YOUR_ZONE=us-central1-f


echo  Set your proj and zone again
gcloud config set project $YOUR_PRJ_NAME
gcloud config set compute/zone $YOUR_ZONE



echo CRATE GCLOUD VM
gcloud compute instances create $USER-vm \
  --machine-type=n1-standard-2 \
  --image-project=ml-images \
  --image-family=tf-1-8 \
  --scopes=cloud-platform


