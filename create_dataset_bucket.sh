#! /bin/bash

echo CREATE BUCKET
export STORAGE_BUCKET=gs://mnist_tfrecord
export YOUR_PRJ_NAME=ordinal-virtue-208004
export YOUR_ZONE=us-central1-f

gsutil mb -l ${YOUR_ZONE} -p ${YOUR_PRJ_NAME} ${STORAGE_BUCKET}

echo COPY DATA TO BUCKET FROM /DATA DIR
gsutil cp -r ./data ${STORAGE_BUCKET}