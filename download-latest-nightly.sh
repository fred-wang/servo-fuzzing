#!/bin/bash

FILENAME=servo-x86_64-linux-gnu.tar.gz
URL=https://download.servo.org/nightly/linux/$FILENAME

rm -rf $FILENAME
wget $URL
tar -xvzf $FILENAME
