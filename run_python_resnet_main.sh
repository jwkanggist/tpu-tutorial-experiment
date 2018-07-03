#! /bin/bash

echo RUN RESNET TRAINING  BY TPU
export DATA_DIR=./data

python ./tpu/models/official/resnet/resnet_main.py \
	  --tpu=$USER-tpu \
	  --data_dir=$DATA_DIR\
	  --model_dir=${STORAGE_BUCKET}/resnet