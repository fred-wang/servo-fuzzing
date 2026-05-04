#!/bin/bash

REPEAT_COUNT=10
PARALLEL_COUNT=100
TIMEOUT=2s
REGEXP=$1
TMP_FILE_PREFIX=/tmp/servo-fuzzer-reproduce

for i in $(seq 1 $REPEAT_COUNT); do

  echo "$i/$REPEAT_COUNT: running $PARALELL_COUNT instances in parallel...";

  for j in $(seq 1 $PARALLEL_COUNT); do
    "${@:2}" &>$TMP_FILE_PREFIX-$i-$j &
  done

  sleep $TIMEOUT
  list_descendants ()
  {
    local children=$(ps -o pid= --ppid "$1")
    for pid in $children; do list_descendants "$pid"; done
    echo "$children"
  }
  kill -9 $(list_descendants $$)

done

REPRODUCED_COUNT=0
for i in $(seq 1 $REPEAT_COUNT); do
  for j in $(seq 1 $PARALLEL_COUNT); do
    if egrep -q "$REGEXP" $TMP_FILE_PREFIX-$i-$j; then
         ((REPRODUCED_COUNT=REPRODUCED_COUNT+1))
    fi
  done
done

echo "Reproducibility: $REPRODUCED_COUNT/$(($PARALLEL_COUNT*$REPEAT_COUNT)) ($(($REPRODUCED_COUNT/$REPEAT_COUNT))%)"
