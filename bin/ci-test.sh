#!/usr/bin/env bash
#
# Test script for the project. To be ran on each build within a CI environment.
# Here is are the Setup commands for CodeShip:
# nvm install
# npm install
# npm install -g david depcheck
# gem install scss_lint
# Here is the Test pipeline commands:
# ./bin/ci-test.sh


# Fail on first line that fails.
set -e

# To only run things on master:
# if [ "$CI_BRANCH" == "master" ];
# then
# fi

# Make sure the front-end build works.
npm run dist

# Start the server if relevant.
npm run start -s &
SERVER_PID=$!

# Only lint files updated in the last commit.
# A bit counterintuitive but our linting is not there yet.
NEW_FILES=$(git --no-pager diff --name-only HEAD..HEAD~1)
JS_FILES=$(echo "$NEW_FILES" | { grep client/js || true; })
SASS_FILES=$(echo "$NEW_FILES" | { grep client/sass || true; })

if [ -n "$JS_FILES" ];
then
    npm run linter:js -s -- $JS_FILES
fi

if [ -n "$SASS_FILES" ];
then
    # Sass file linting errors cannot break the build
    npm run linter:sass -s -- $SASS_FILES || echo ok
fi

# Project tests.
npm run test -s

# Link checking
hyperlink "http://example.com/"

# Kill the server if relevant.
kill $SERVER_PID

## Dependencies checking.
david || echo ok
depcheck || echo ok

exit 0
