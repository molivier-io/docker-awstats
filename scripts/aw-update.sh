#!/bin/sh

# Run awstats on all sites in /etc/awstats

echo "START aw-update"

echo "Running additional provisioning"
for f in /aw-update.d/*
do
        case "$f" in
          */*.sh) echo "$0: running $f" && . "$f" ;;
        esac
done

cd /etc/awstats
        for SITE_CONF in $(ls awstats.*.conf)
        do
                SITE=${SITE_CONF%%.conf}
                SITE=${SITE#awstats.}
                echo "Update ${SITE} from ${SITE_CONF}"
                awstats.pl -config=${SITE} -update
        done

echo "STOP aw-update"
exit 0
