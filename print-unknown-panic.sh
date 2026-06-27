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
    sed -e "/NaN should be between 0 and 1 (.\+src\/color.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45945
    sed -e "/OriginZero grid line cannot be less than the number of negative grid lines (.\+grid\/types\/coordinates.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45939
    sed -e "/OriginZero grid line cannot be more than the number of positive grid lines (.\+grid\/types\/coordinates.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45938
    sed -e "/Parsing shouldn't fail as descriptors are valid by construction: Syntax(None) (.\+components\/script\/dom\/css\/fontface.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/44537
    sed -e "/Should never try to get clip before adding it to WebRender display list (.\+layout\/display_list\/mod.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46021
    sed -e "/animate should only be used for interpolating or accumulating transforms (.\+style\/values\/animated\/transform.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45981
    sed -e "/assertion failed: \*progress > 1. (.\+style\/servo\/animation.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45950
    sed -e "/assertion failed: count_cell.get() > 0 (.\+components\/script\/dom\/document\/document.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42854
    sed -e "/assertion failed: self.inclusive_ancestors(shadow_including).any(|ancestor|$/,+4d" | # https://github.com/servo/servo/issues/45947
    sed -e "/assertion failed: src.width == dest.width && src.height == dest.height (.\+src\/filter\/lighting.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45171
    sed -e "/assertion failed: src1.\(width\|height\) == src2.\(width\|height\) && src1.\(width\|height\) == dest.\(width\|height\) (.\+src\/filter\/composite.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45175
    sed -e "/assertion failed: src\.\(width\|height\) == map\.\(width\|height\) && src\.\(width\|height\) == dest\.\(width\|height\) (.\+displacement_map.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/38849
    sed -e "/attempt to \(substract\|add\) with overflow (.\+compute\/grid\/types\/.\+.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45949
    sed -e "/bug: this is an unexpected case - please open a bug and talk to #gfx team! (.\+src\/spatial_tree.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45732
    sed -e "/bug: unable to map mix-blend content into parent (.\+src\/picture.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42292
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/alpha_runs.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45168
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+src\/rect.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/42258
    sed -e "/called \`Result::unwrap()\` on an \`Err\` value: TryFromIntError(()) (.\+taffy\/stylo_taffy\/convert.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45881
    sed -e "/entered unreachable code: Unexpected direct descendant PositioningContext of inline. (.\+components\/layout\/display_list\/paint_traversal.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45740
    sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+css\/cssrulelist.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46025
    sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+layout\/display_list\/clip.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46026
    sed -e "/index out of bounds: the len is [0-9]\+ but the index is [0-9]\+ (.\+paint\/display_list.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46023
    sed -e "/internal error: entered unreachable code (.\+src\/tile_cache\/mod.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/45740
    sed -e "/slice index starts at [0-9]\+ but ends at [0-9]\+ (.\+grid\/types\/grid_item.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46022
    grep -B5 -A10 'servoshell::panic_hook::panic_hook';
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done
