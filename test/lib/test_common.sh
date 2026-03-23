#!/bin/sh

pause()
{
    printf '\n%*s\n' "80" "" | tr " " "-"
    printf "Press enter to continue..."
    printf '\n%*s\n' "80" "" | tr " " "-"
    read -r _
}

tree()
{
    command tree --noreport --condense -pugsF --dirsfirst -C "$(realpath "$1")"
}

track()
{
    sudo "$SCRIPT_DIR/../bin/track.sh" "$@"
}

status()
{
    sudo "$SCRIPT_DIR/../bin/status.sh" "$@"
}

untrack()
{
    sudo "$SCRIPT_DIR/../bin/untrack.sh" "$@"
}