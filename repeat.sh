#!/bin/bash
COUNT=10

for i in $(seq 1 $COUNT); do
    $@;
done
