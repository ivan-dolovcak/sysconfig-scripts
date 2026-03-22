#!/usr/bin/awk -f

BEGIN { lineFound=0 }

$5 == path {
    lineFound=1

    if (file_deleted)
        next
    
    if ($0 != stat)
        updated=1

    print stat
    next
}

{ print }

END {
    if (!lineFound && !file_deleted) {
        print stat
        exit 1 # line inserted
    }
    if (updated)
        exit 2 # line updated
    
    if (file_deleted)
        exit 3 # line deleted
}