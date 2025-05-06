#!/bin/bash

if [ $# -lt 2 ] ; then
    echo "Usage: $0 TESTCASE SERVO_BIN [SERVO_ARGS]"
    exit 1
else
    TESTCASE=$1
    SERVO_BIN_AND_ARGS=${@:2}
fi

TRACE_FILE=/tmp/stacktrace.txt
RUST_BACKTRACE=1 $SERVO_BIN_AND_ARGS -xf $TESTCASE 2> $TRACE_FILE

echo "********************************************************************************"
echo -n "panic: "
head -n1 $TRACE_FILE | sed "s/thread Script([0-9]\+,[0-9]\+), //"
echo "********************************************************************************"
echo
echo "Minimal testcase:"
echo
echo "\`\`\`html"
cat $TESTCASE
echo "\`\`\`"
echo

echo "System:" $(uname)
echo "Version:" $($SERVO_BIN_AND_ARGS --version)
echo "Command: \`"$SERVO_BIN_AND_ARGS"\`"
echo
echo "\`\`\`"
cat $TRACE_FILE
echo "\`\`\`"
echo "********************************************************************************"

