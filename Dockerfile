FROM nginx:1.26.3-alpine3.20

# Credits to Patrick Braune for providing first versions
LABEL original_developer="Patrick Braune <https://github.com/pabra>" \
    maintainer="Just van den Broecke <justb4@gmail.com>"

# Generate GeoIP free library
RUN apk add --no-cache --virtual .build-deps perl-utils make \
    && yes | cpan Geo::IPfree \
    && apk del .build-deps

ARG TZDATA_VERSION=2024b-r0
ARG AWSTATS_VERSION=7.9-r0

RUN apk add --no-cache awstats=${AWSTATS_VERSION} tzdata=${TZDATA_VERSION} supervisor fcgiwrap \
    && mkdir -p /aw-setup.d && mkdir -p /aw-update.d \
    && chmod 1777 /run

# Configurations, some are templates to be substituted with env vars
ADD confs/awstats_env.conf confs/awstats_env.cron /etc/awstats/
ADD confs/awstats_nginx.conf /etc/nginx/conf.d/default.conf
ADD confs/supervisord.conf /etc/
ADD scripts/*.sh  /usr/local/bin/

# Default env vars
ENV AWSTATS_CONF_DIR="/etc/awstats" \
    AWSTATS_SITES_DIR="/etc/awstats/sites" \
    AWSTATS_CRON_SCHEDULE="*/15 * * * *" \
    AWSTATS_PATH_PREFIX="" \
    AWSTATS_CONF_LOGFILE="/var/local/log/access.log" \
    AWSTATS_CONF_LOGFORMAT="%host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot" \
    AWSTATS_CONF_SITEDOMAIN="mydomain.com" \
    AWSTATS_CONF_HOSTALIASES="localhost 127.0.0.1 REGEX[^.*$]" \
    AWSTATS_CONF_DEBUGMESSAGES="0" \
    AWSTATS_CONF_DNSLOOKUP="1"

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
