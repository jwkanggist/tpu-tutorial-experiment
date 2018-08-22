# tpu-tutorial-experiments
Cloud TPU tutorial and ImageNet TPU benchmark
- Since Jeju Google Deep Learning Camp 2018
- Special thanks to Sourabh and Yu-han @ Google


> [Readme for KOR is provided in this link](https://docs.google.com/document/d/1WSs8nn9Z-ViG-j2nRQfEFzxMqnviPJ2lOibocmRCssk/edit#heading=h.3winycxo9ejn)

## About
Easy GCP TPU training in Jeju Google Deep Learning Camp 2018

#### Documentation (KOR, gslide links)
- [Jaewook Kang, "어머! TPU! 이건 꼭 써야해!", Aug. 2018](https://docs.google.com/presentation/d/1LqlZc8IjXzp255UIXWQRBRGvvqwnLzkz1qAoq5YD1hs/edit#slide=id.p1)

#### Dependencies
- macOS and command line interface only
- Tensorflow >= 1.8


## ImageNet Benchmarks

| Models                                            |  Top1 Acc (paper)  |  TPU Trained Acc  | TPU Training time   | Execution  |
| ------------------                                | :---------------:  | :-----------: | :-----------------: | :----------:
| [Mobilenet v1](https://arxiv.org/abs/1704.04861)  |  70.60%            |  71.27%       |  1d 23h 57m         | [run_mobilenet_main.sh](https://github.com/jwkanggist/tpu-tutorial-experiment/blob/master/run_mobilenet_main.sh)
| [Resnet-50](https://arxiv.org/abs/1512.03385)     |  79.26%            |  76.19%       |  12h                | [run_resnet_main.sh](https://github.com/jwkanggist/tpu-tutorial-experiment/blob/master/run_resnet_main.sh)



## gcloud SDK Installation 
You need to install gcloud SDK directly from [the link](https://cloud.google.com/sdk/docs/quickstart-macos):

- what we must configure are that
    - account
    - project
    - a default compute region and zone
    
> Note that the zone should be set to `us-central1-f` in this Google camp.
- You can check your configuration by 
```bash
$ gcloud config list
[compute]
region = us-central1
zone = us-central1-f
[core]
account = jwkang10@gmail.com
disable_usage_reporting = False
project = ordinal-virtue-208004

Your active configuration is: [default]
``` 


## TPU Instance Creation and Deletion
The use of GCP TPU has three steps:

```
1) Related API enabling 
2) Virtual machine(vm) instance generation + ssh connection to the vm
3) TPU instance generation in the vm
```

#### 1) API enabling (local)
In order to use TPU, enabling of below two APIs must be performed.
- Cloud TPU API enabling  
- Cloud Engine API enabling

#### 2) VM instance generation + ssh access (local)
Basically. our aim is to use TPUs in a certain GCP zone 
by creating a virtual machine on cloud.
- The zones, where the TPU can be used, is limited ([see for detail info](https://cloud.google.com/tpu/docs/regions))
- For create VM, we have `create_vm_instance.sh`:
```bash
#! /bin/bash
# create_vm_instance.sh

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
```
> Note that in order to use TPU, you first need permission from Google. 

Then, now you can connect to your vm by `ssh`.

```bash
gcloud compute ssh $USER-vm
```
#### 3) TPU instance generation (vm)
In the vm, you need three configuration for the TPU use.
- your project name
- your zone
- your tpu ip 

`create_tpu_instance.sh` provides the above configutation + TPU instance generation.

```bash
#! /bin/bash
#create_tpu_instance.sh

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
```

After finishing the TPU use, we need to remove the TPU instance.
by `delete_tpu_instance.sh`.

```bash
#! /bin/bash
# delete_tpu_instance.sh

export YOUR_ZONE=us-central1-f

echo DELETE TPU INSTANCE
gcloud alpha compute tpus delete $USER-tpu --zone=$YOUR_ZONE
```

## Run ResNet Tutorial 
Google prepare a perfect example for the TPU use practice. 
> For this tutorial, you need to connect to the vm holding a tpu instance,  by 
`$ gcloud compute ssh $USER-vm` 


- This tutorial includes below steps:

```bash
1) Downloading MNIST dataset and converting to TFrecord
2) GCP Bucket generation for holding the TFrecord dataset
3) Git clone TPU tutorial repo 
4) Run ResNet codes by TPU 
```

#### 1) Downloading MNIST dataset and converting to TFrecord
- `create_mnistdata_to_tfrecord.sh`

```bash
#! /bin/bash
# create_mnistdata_to_tfrecord.sh

echo Downloading and converting the MNIST data to TFRecords
python  /usr/share/tensorflow/tensorflow/examples/how_tos/reading_data/convert_to_records.py --directory=./data
gunzip ./data/*.gz
```

#### 2) GCP Bucket generation for holding the TFrecord dataset
For the TPU use, we need to create `Bucket`. We have two main purpose to use the Bucket in GCP. 
- For holding dataset in training
- For storing `.ckpt` generated by training

Here, we just create single bucket and use it for above two purpose. 
However, in your actual training, we recommend to create two different buckets for dataset and `.ckpt`. 

```bash
#! /bin/bash

echo CREATE BUCKET
export STORAGE_BUCKET=gs://mnist_tfrecord
export YOUR_PRJ_NAME=ordinal-virtue-208004
export YOUR_ZONE=us-central1-f

gsutil mb -l ${YOUR_ZONE} -p ${YOUR_PRJ_NAME} ${STORAGE_BUCKET}

echo COPY DATA TO BUCKET FROM /DATA DIR
gsutil cp -r ./data ${STORAGE_BUCKET}
```


#### 3) Git clone TPU tutorial repo 
First we need to git clone the tutorial Resnet codes from the Tensorflow repository.
>An important note here is that we should switch git branch from `master` to `r1.8`.
because the master branch does not support tf.estimator for the TPU use. 

```bash
#! /bin/bash
# gitclone_resnet_repo.sh

echo git clone Resnet repository
git clone https://github.com/tensorflow/tpu.git ./tpu

echo First you need to checkout to /r1.8 branch
cd ./tpu
git branch -r
git checkout -t origin/r1.8
cd ..
```

#### 4) Run ResNet codes by TPU 
Only remaining is to run `resnet_main.py` with 

```bash
echo =============================================
echo RUN RESNET TRAINING  BY TPU
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

rm -rf /tmp/gcs_filesystem*
python ./tpu/models/official/resnet/resnet_main.py \
      --use_tpu=True\
	  --tpu=$USER-tpu \
	  --data_dir=$DATA_DIR\
	  --model_dir=${STORAGE_BUCKET}/resnet
```



## References
- [Custom setting Google doc for GCP-TPU](https://cloud.google.com/tpu/docs/custom-setup)
- [Resnet-tpu Google doc](https://cloud.google.com/tpu/docs/tutorials/resnet)
- [TPU Google tutorial github repo](https://github.com/tensorflow/tpu/tree/master/models/official/resnet
)

## Feedback
- Jaewook Kang (jwkang10@gmail.com)