#! /bin/bash

export YOUR_PRJ_NAME=ordinal-virtue-208004
export YOUR_ZONE=us-central1-f
export TPU_IP=10.240.6.2

echo  Set your proj and zone again
gcloud config set project $YOUR_PRJ_NAME
gcloud config set compute/zone $YOUR_ZONE

echo  CREATE TPU INSTANCE
gcloud alpha compute tpus create $USER-tpu \
	--range=${TPU_IP/%2/0}/29 --version=1.8 --network=default
echo CHECK YOUR TPU INSTANCE
gcloud alpha compute tpus list