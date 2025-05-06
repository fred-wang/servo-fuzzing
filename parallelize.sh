#!/bin/bash

COUNT=10
TIMEOUT=2s

for i in $(seq 1 $COUNT); do
  $@ 2>&1 &
done
sleep $TIMEOUT
list_descendants ()
{
  local children=$(ps -o pid= --ppid "$1")
  for pid in $children; do list_descendants "$pid"; done
  echo "$children"
}
kill -9 $(list_descendants $$)
