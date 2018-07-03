#! /bin/bash

echo git clone Resnet repository
git clone https://github.com/tensorflow/tpu.git ./tpu

echo First you need to checkout to /r1.8 branch

cd ./tpu
git branch -r
git checkout -t origin/r1.8
cd ..
