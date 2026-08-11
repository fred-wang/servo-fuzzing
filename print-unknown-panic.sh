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
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+euclid-0.22.14\/src\/size.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46202
    sed -e "/called \`Option::unwrap()\` on a \`None\` value (.\+tiny-skia-path-0.12.0\/src\/rect.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46338
    sed -e "/attempt to add with overflow (.\+compute\/grid\/types\/named.rs:[0-9]\+)$/,+3d" | # https://github.com/servo/servo/issues/46234
    grep -B5 -A10 'servoshell::panic_hook::panic_hook';
    if [ $? -eq 0 ]; then
        echo -n $file | sed "s/.txt//"
        echo " crashed!"
    fi
done

# Below are some issues that have been hit by fuzzers in the past, but for which we don't have a reliable test case:
# JS String copy routine failed mozjs-0.17.0/src/conversions.rs:676 # https://github.com/servo/servo/issues/46197
# called `Option::unwrap()` on a `None` value (thread Script#1, at components/script/dom/node/node.rs:1715
# internal error: entered unreachable code (thread Script#1, at components/script/dom/node/node.rs:788 https://github.com/servo/servo/issues/45795
