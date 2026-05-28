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
    sed -e "/Cache should have been filled from traversal (.\+components\/media\/audio\/graph.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/36850
    sed -e "/PainterSurfmanDetails not found for PainterId (.\+components\/webgl\/webgl_thread.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42414
    sed -e "/Parsing shouldn't fail as descriptors are valid by construction: Syntax(None) (.\+components\/script\/dom\/css\/fontface.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/44537
    sed -e "/Should always have at least one SharedInlineStyles (.\+components\/layout\/flow\/inline\/construct.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45085
    sed -e "/Should have at least one SharedInlineStyle for the root of an IFC (.\+components\/layout\/flow\/inline\/mod.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45172
    sed -e "/Should only call \`scrollable_overflow()\` after calculating overflow (.\+components\/layout\/fragment_tree\/box_fragment.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/41207
    sed -e "/Trying to collect rules for a detached pseudo-element (.\+style\/dom.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45170
    sed -e "/assertion \`left == right\` failed$/,+5d" | # https://github.com/servo/servo/issues/45167
    sed -e "/assertion failed: count_cell.get() > 0 (.\+components\/script\/dom\/document\/document.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42854
    sed -e "/assertion failed: src.width == dest.width && src.height == dest.height (.\+src\/filter\/lighting.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45171
    sed -e "/assertion failed: src1.\(width\|height\) == src2.\(width\|height\) && src1.\(width\|height\) == dest.\(width\|height\) (.\+src\/filter\/composite.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45175
    sed -e "/assertion failed: src\.\(width\|height\) == map\.\(width\|height\) && src\.\(width\|height\) == dest\.\(width\|height\) (.\+displacement_map.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/38849
    sed -e "/bug: unable to map mix-blend content into parent (.\+src\/picture.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42292
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/alpha_runs.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45168
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/point.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/36870
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/rect.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42258
    sed -e "/called \`Result::unwrap()\` on an \`Err\` value: HierarchyRequest(Some(\"Parent has an element child\")) (.\+components\/script\/dom\/servoparser\/mod.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/20218
    sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+style\/servo\/animation.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45008
    sed -e "/internal error: entered unreachable code (.\+src\/picture.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42476
    grep -B5 -A10 'servoshell::panic_hook::panic_hook';
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done
