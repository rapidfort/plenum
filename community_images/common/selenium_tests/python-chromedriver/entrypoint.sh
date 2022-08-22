#!/bin/bash

set -x
set -e

if [[ -z "$SERVER" ]]; then
    echo "Must provide SERVER in environment" 1>&2
    exit 1
fi

if [[ -z "$PORT" ]]; then
    echo "Must provide PORT in environment" 1>&2
    exit 1
fi


. /usr/workspace/bash_helper.sh

# run pytest
with_backoff pytest -s /usr/workspace/selenium_tests --server "$SERVER" --port "$PORT"
