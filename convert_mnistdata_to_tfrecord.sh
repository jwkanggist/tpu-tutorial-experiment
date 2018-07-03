#! /bin/bash

echo Downloading and converting the MNIST data to TFRecords

python  /usr/share/tensorflow/tensorflow/examples/how_tos/reading_data/convert_to_records.py --directory=./data
gunzip ./data/*.gz