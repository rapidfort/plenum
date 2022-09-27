#!/bin/bash

set -x
set -e

# Add common commands here which should be present in all hardened images

function run_commands()
{
    local cmd="$1"
    if command -v "$cmd" --help &> /dev/null
    then
        "$cmd" --help
    fi
}

sleep 1

declare -a command_array=(
    cp mkdir chmod ls mv rm ln rmdir chgrp chown touch cat grep sed tar sort head date
)

for cmd in "${command_array[@]}"
do
    run_commands "$cmd"
done

# add clear command
if command -v clear -V &> /dev/null
then
    clear -V
fi

# invoke tzdata package
TZBase=$(LC_ALL=C TZ=UTC0 date)
UTdate=$(LC_ALL=C TZ=UTC0 date -d "$TZBase")
TZdate=$(unset TZ ; LANG=C date -d "$TZBase")
echo "Local time is now:      $TZdate."
echo "Universal Time is now:  $UTdate."
