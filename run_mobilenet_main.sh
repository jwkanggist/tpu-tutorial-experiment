#! /bin/bash

echo =============================================
echo RUN MOBILENET_V1 TRAINING  BY TPU
echo JAEWOOK KANG JEJU GOOGLE CAMP 2018
echo =============================================

echo "       _                 _         "
echo " _   _| |__  _   _ _ __ | |_ _   _ "
echo "| | | | '_ \| | | | '_ \| __| | | |"
echo "| |_| | |_) | |_| | | | | |_| |_| |"
echo " \__,_|_.__/ \__,_|_| |_|\__|\__,_|"



echo "  .------------------------."
echo "  |  Hi ! Google Camp 2018 |"
echo "  '------------------------'"
echo "      ^      (\_/)"
echo "      '----- (O.o)"
echo "             (> <)"
OS="$(uname -s)"
OS_X="Darwin"

echo ${OS}

export DATA_DIR=gs://imagenet_tfrecords
export STORAGE_BUCKET=gs://tpu_test_results

python ./tpu/models/official/mobilenet/mobilenet.py \
      --use_tpu=True\
	  --tpu=$USER-tpu \
	  --data_dir=$DATA_DIR\
	  --model_dir=${STORAGE_BUCKET}/mobilebet_v1
