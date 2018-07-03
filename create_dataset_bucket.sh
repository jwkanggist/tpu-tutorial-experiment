#! /bin/bash

echo CREATE BUCKET
export STORAGE_BUCKET=gs://mnist_tfrecord
gsutil mb -l us-central1 -p ordinal-virtue-208004 ${STORAGE_BUCKET}

echo COPY DATA TO BUCKET FROM /DATA DIR
gsutil cp -r ./data ${STORAGE_BUCKET}