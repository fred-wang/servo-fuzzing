#!/bin/bash

FILENAME=servo-latest.tar.gz
URL=https://download.servo.org/nightly/linux/$FILENAME

rm -rf $FILENAME
wget $URL
tar -xvzf $FILENAME
