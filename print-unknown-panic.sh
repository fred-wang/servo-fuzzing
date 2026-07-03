#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "Usage: $0 TESTCASE_DIRECTORY"
    exit 1
else
    TESTCASE_DIRECTORY=$1
fi

# The panic messages are obtained by grepping around the pattern
# "servoshell::panic_hook::panic_hook", which is located in the backtrace
# a few lines below the actual panic messages. Known panic messages (and
# corresponding "servoshell::panic_hook::panic_hook") are filtered out
# using the commands like this one:
#
# sed -e '/your panic message (.\+path\/to\/source\/code.rs:[0-9]\+)$/,+3d' | # Link to GitHub report
#
# Some notes:
# - Use backslash to escape backtick and other special characters.
# - If the panic message spans more than one line, use +4d, +5d, etc to
#   remove the corresponding "servoshell::panic_hook::panic_hook".
# - Different bugs may generate very similar messages. Please make sure
#   to make the message as specific as possible (in particular please
#   include the path to the rust file) so that fuzzers are not blocked
#   on similar issues to be fixed. Please also include the link to the
#   GitHub report.
# - Yes, this bash script is very rudimentary and could be made more
#   robust, but it does the job  for now...

for file in $(ls $TESTCASE_DIRECTORY/*.txt); do
    cat $file |
    sed -e "/!will_break (.\+components\/layout\/flow\/inline\/mod.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45793
    sed -e "/Cache should have been filled from traversal (.\+components\/media\/audio\/graph.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/36850
    sed -e "/Must always have a parent (.\+components\/script\/dom\/execcommand\/commands\/delete.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/
    sed -e "/OriginZero grid line cannot be less than the number of negative grid lines (.\+grid\/types\/coordinates.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45939
    sed -e "/OriginZero grid line cannot be more than the number of positive grid lines (.\+grid\/types\/coordinates.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45938
    sed -e "/RefCell already borrowed (.\+components\/script\/dom\/document\/document.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46154
    sed -e "/Unstyled layout node? (.\+components\/script\/layout_dom\/servo_layout_element.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46024
    sed -e "/attempt to \(substract\|add\) with overflow (.\+compute\/grid\/types\/.\+.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45949
    sed -e "/bug: unable to map mix-blend content into parent (.\+src\/picture.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42292
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+euclid-0.22.14\/src\/size.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46202
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+style\/matching.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46149
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+taffy-0.11.0\/src\/compute\/grid\/types\/cell_occupancy.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46203
    sed -e "/called \`Result::unwrap()\` on an \`Err\` value: TryFromIntError(()) (.\+taffy\/stylo_taffy\/convert.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45881
    sed -e "/entered unreachable code: Unexpected direct descendant PositioningContext of inline. (.\+components\/layout\/display_list\/paint_traversal.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46196
    sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+paint\/display_list.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46023
    sed -e "/panic: index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+compute\/grid\/types\/named.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46234
    sed -e "/panic: internal error: entered unreachable code: Found hoisted box with missing fragment. (.\+components\/layout\/display_list\/stacking_context.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46109
    sed -e "/slice index starts at [0-9]\+ but ends at [0-9]\+ (.\+grid\/types\/grid_item.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46022
    sed -e "/tiny-skia-path-0.12.0\/src\/rect.rs:707/,+3d" | # FIXED in https://github.com/servo/servo/issues/46152
    sed -e "/unable to map mix-blend content into parent (.\+src\/picture_composite_mode.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42292
    grep -B5 -A10 'servoshell::panic_hook::panic_hook';
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done

# Below are some issues that have been hit by fuzzers in the past, but for which we don't have a reliable test case:
# JS String copy routine failed mozjs-0.17.0/src/conversions.rs:676 # https://github.com/servo/servo/issues/46197
# called `Option::unwrap()` on a `None` value (thread Script#1, at components/script/dom/node/node.rs:1715
