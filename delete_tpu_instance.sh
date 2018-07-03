#! /bin/bash

export YOUR_ZONE=us-central1-f

echo DELETE TPU INSTANCE
gcloud alpha compute tpus delete $USER-tpu --zone=$YOUR_ZONE