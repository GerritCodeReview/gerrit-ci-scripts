#!/bin/bash -e
echo 'Running buildifier check...'
buildifier --version
cd gerrit
EXITCODE=0
for buildfile in $((git show --diff-filter=AM --name-only --pretty="" HEAD | grep --regex "WORKSPACE\|BUILD\|\.bzl$") || true)
do
    BUILDIFIER_OUTPUT_FILE="$(mktemp)_buildifier_output.log"
    buildifier -format=text -v -mode=check $buildfile 2>&1 | tee $BUILDIFIER_OUTPUT_FILE
    if [[ -s $BUILDIFIER_OUTPUT_FILE ]]; then
        echo "Need Formatting:"
        echo "[$buildfile]"
        echo "Please fix manually or run buildifier $buildfile to auto-fix."
        buildifier -v -mode=diff $buildfile
        rm -rf $BUILDIFIER_OUTPUT_FILE
        EXITCODE=1
    fi
done
exit $EXITCODE
