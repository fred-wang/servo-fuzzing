#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "Usage: $0 TESTCASE_DIRECTORY"
    exit 1
else
    TESTCASE_DIRECTORY=$1
fi

# The panic messages are selected obtained by grepping around the pattern
# "servoshell::panic_hook::panic_hook".
#
# Use sed -e '/message/, +3d' to delete already reported issues. You can find
# the history of reported issues together with reduced testcases in the
# minimized_testcases directory.
#
# Notes:
# - Use backslash to escape backtick and other special characters.
# - If the panic message spans more than one line, use +4d, +5d, etc.
# - If the panic message is too generic please use a more specific regexp e.g.
#   "/called \`Option::unwrap()\` on a \`None\` value (.\+prim_store\/image.rs:[0-9]\+)$/,+3d"

for file in $(ls $TESTCASE_DIRECTORY/*.txt); do
    cat $file \
    | sed -e "/Attempting to create a [0-9]\+x[0-9]\+ window\/document/,+3d" \
    | sed -e "/Blob ancestry should be only one level./,+3d" \
    | sed -e "/Cache should have been filled from traversal/,+3d" \
    | sed -e "/Failed to get browsing context info from constellation./,+3d" \
    | sed -e "/Sliced blobs should use create_sliced_url_id instead of promote./,+3d" \
    | sed -e "/SystemFontService has already exited./,+3d" \
    | sed -e "/Trying to get host from a detached shadow root/,+3d" \
    | sed -e "/assertion failed: !GetCurrentRealmOrNull/,+3d" \
    | sed -e "/assertion failed: !self.loader.borrow().events_inhibited()/,+3d" \
    | sed -e "/byte index [0-9]\+ is not a char boundary/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+canvas_context.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+nodelist.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+prim_store\/image.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/point.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/size.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: BoolError { message: \"Failed to link elements/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: Disconnected (.\+canvas_state.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: Parameter(ParameterError { kind: DimensionMismatch, underlying: None })/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: RecvError (.\+audio\/context.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: \"element linking failed: BoolError/,+3d" \
    | sed -e "/error receiving hit test result: Disconnected/,+3d" \
    | sed -e "/failed to send message to system font service/,+3d" \
    | sed -e "/out of bounds. \(Row\|Column\) must be less than [0-9]\+, but is [0-9]\+/,3d" \
    | sed -e "/slice index starts at [0-9]\+ but ends at [0-9]\+/,+3d" \
    | grep -B5 -A10 'servoshell::panic_hook::panic_hook' \
    ;
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done
