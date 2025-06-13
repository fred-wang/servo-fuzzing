#!/bin/bash

BASE_ARGS=-xzf
if [ $# -lt 2 ] ; then
    echo "Usage: $0 TESTCASE_DIRECTORY SERVO_BIN [SERVO_EXTRA_ARGS]"
    exit 1
else
    TESTCASE_DIRECTORY=$1
    SERVO_BIN_AND_ARGS=${@:2}
fi

# Try running servo with arguments and about:blank to catch any issue early.
$SERVO_BIN_AND_ARGS $BASE_ARGS about:blank || exit

# Run all the testcases in parallel and collect the output.
TIMEOUT=5s
for t in $(ls $TESTCASE_DIRECTORY/*.html); do
    echo "Running" $t
    RUST_BACKTRACE=1 $SERVO_BIN_AND_ARGS -xfz $t > $t.txt 2>&1 &
done
sleep $TIMEOUT

echo
echo "Timout of $TIMEOUT reached, killing all running instances..."
list_descendants ()
{
  local children=$(ps -o pid= --ppid "$1")
  for pid in $children; do list_descendants "$pid"; done
  echo "$children"
}
kill $(list_descendants $$) > /dev/null 2>&1

echo
echo "Unknown panic messages:"
./print-unknown-panic.sh $TESTCASE_DIRECTORY
