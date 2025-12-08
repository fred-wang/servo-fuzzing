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
# Use sed -e '/message/, +3d' to delete already reported issues.
#
# Notes:
# - Use backslash to escape backtick and other special characters.
# - If the panic message spans more than one line, use +4d, +5d, etc.
# - If the panic message is too generic please use a more specific regexp e.g.
#   "/called \`Option::unwrap()\` on a \`None\` value (.\+prim_store\/image.rs:[0-9]\+)$/,+3d"

for file in $(ls $TESTCASE_DIRECTORY/*.txt); do
    cat $file \
    | sed -e "/Cache should have been filled from traversal/,+3d" \
    | sed -e "/Couldn't find common ancestor (.\+dom\/document.rs:[0-9]\+)/,+3d" \
    | sed -e "/Too many open files/,+3d" \
    | sed -e "/Unknown top-level browsing context (.\+constellation\/constellation.rs:[0-9]\+)$/,+3d" \
    | sed -e "/assertion failed: !self.loader.borrow().events_inhibited() (.\+dom\/document.rs:[0-9]\+)/,+3d" \
    | sed -e "/assertion failed: src.width == map.width && src.width == dest.width/,+3d" \
    | sed -e "/byte index [0-9]\+ is not a char boundary/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+dom\/documentorshadowroot.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+dom\/html\/htmloptionscollection.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+dom\/window.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+nodelist.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+prim_store\/image.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/point.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+style\/matching.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: BoolError { message: \"Failed to link elements/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: Io(Os { code: 32, kind: BrokenPipe, message: \"Broken pipe\" }) (.\+components\/shared\/net\/lib.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: \"SendError(..)\" (.\+webrender\/src\/render_backend.rs:[0-9]\+)$/,+3d" \
    | sed -e "/called \`Result::unwrap()\` on an \`Err\` value: \"element linking failed: BoolError/,+3d" \
    | sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+components\/layout\/table\/layout.rs:[0-9]\+)$/,+3d" \
    | sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+components\/shared\/compositing\/display_list.rs:[0-9]\+)$/,+3d" \
    | sed -e "/internal error: entered unreachable code (.\+webrender\/src\/picture.rs:[0-9]\+)$/,+3d" \
    | grep -B5 -A10 'servoshell::panic_hook::panic_hook' \
    ;
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done
