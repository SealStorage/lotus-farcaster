#!/bin/sh
# Try to run lotus farcaster executing at the defined FREQUENCY. If farcaster take more time, the script will wait 10s before the next execution

# You can call this run script with a parameter that will then form part of the prometheus text exporter filename.
# This allows multiple Farcaster containers to run on the same host and all write their exporter values to its own file. 
# Start the container with a custom entrypoint like: ENTRYPOINT ["/usr/local/bin/docker_run_script.sh", "miner1"] to get
#   a file named /data/farcaster-miner1.prom

POSTFIX=$1

while true; do
    BEG=$(date +%s)
    echo $(date +"%a %d %H:%M:%S" --date="@$BEG") Start exporting
    if /usr/local/bin/lotus-exporter-farcaster.py  --farcaster-config-folder=/etc/farcaster > /data/farcaster${POSTFIX:+-$POSTFIX}.prom.$$
    then
        mv /data/farcaster${POSTFIX:+-$POSTFIX}.prom.$$ /data/farcaster${POSTFIX:+-$POSTFIX}.prom
    else
        rm /data/farcaster${POSTFIX:+-$POSTFIX}.prom.$$
    fi
    END=$(date +%s)
    DURATION=$(expr $END - $BEG)
    if [ "$DURATION" -ge 0"$FREQUENCY"  ]
    then
        SLEEP=10
    else
        SLEEP=$(expr 0$FREQUENCY - $DURATION)
    fi
    echo $(date +"%a %d %H:%M:%S" --date="@$END") Sleeping : $SLEEP
    sleep $SLEEP
done
