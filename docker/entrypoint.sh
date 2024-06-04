#!/bin/bash

set -e

# Preparation of directories
mkdir -p     /var/log/apache2 /var/log/graphite
chmod -R 775 /var/log/apache2 /var/log/graphite
chown -R _graphite:_graphite  /var/log/graphite /var/log/apache2

# Django user changes for superuser
if [[ -n "${GRAPHITE_ADMIN_MAIL}" ]] && [[ "${GRAPHITE_ADMIN_MAIL}" != DJANGO_SUPERUSER_EMAIL ]]; then
    export DJANGO_SUPERUSER_EMAIL=${GRAPHITE_ADMIN_MAIL}
    export DJANGO_CHANGE_EMAIL_DETECTED=true
fi
if [[ -n "${GRAPHITE_ADMIN_PWD}" ]] && [[ "${GRAPHITE_ADMIN_PWD}" != DJANGO_SUPERUSER_PASSWORD ]]; then
    export DJANGO_SUPERUSER_PASSWORD=${GRAPHITE_ADMIN_PWD}
    export DJANGO_CHANGE_PWD_DETECTED=true
fi
if [[ -n "${GRAPHITE_ADMIN_USER}" ]] && [[ "${GRAPHITE_ADMIN_USER}" != DJANGO_SUPERUSER_USERNAME ]]; then
    export DJANGO_SUPERUSER_USERNAME=${GRAPHITE_ADMIN_USER}
    export DJANGO_CHANGE_USER_DETECTED=true
    django-admin createsuperuser --noinput --settings=graphite.settings
fi

# When using external storage such as Longhorn or NAS, mounted to /storage, for graphite.db
if [ ! -f /storage/graphite.db ] && [ -d /storage ] && [ -f /var/lib/graphite/graphite.db ]; then
    mv /var/lib/graphite/graphite.db /storage/graphite.db
    ln -s /storage/graphite.db /var/lib/graphite/graphite.db
    if [ `id -u` -ne 0 ]; then
      echo "Please run this chown as root"
    else
      chown -R _graphite:_graphite /storage/graphite.db
    fi
elif [ -f /storage/graphite.db ] && [ ! -L /var/lib/graphite/graphite.db ]; then
    rm -f /var/lib/graphite/graphite.db
    ln -s /storage/graphite.db /var/lib/graphite/graphite.db
    if [ `id -u` -ne 0 ]; then
      echo "Please run this chown as root"
    else
      chown -R _graphite:_graphite /storage/graphite.db
    fi
fi

# When using external storage such as Longhorn or NAS, mounted to /storage, for whisper
if [ ! -d /storage/whisper ] && [ -d /storage ] && [ -d /var/lib/graphite/whisper ]; then
    mv /var/lib/graphite/whisper /storage/whisper
    ln -s /storage/whisper /var/lib/graphite/whisper
    if [ `id -u` -ne 0 ]; then
      echo "Please run this chown as root"
    else
      chown -R _graphite:_graphite /storage/whisper
    fi
elif [ -d /storage/whisper ] && [ ! -L /var/lib/graphite/whisper ]; then
    rm -rf /var/lib/graphite/whisper
    ln -s /storage/whisper /var/lib/graphite/whisper
    if [ `id -u` -ne 0 ]; then
      echo "Please run this chown as root"
    else
      chown -R _graphite:_graphite /storage/whisper
    fi
fi

# Services
service carbon-cache start
service apache2 start

# Tail
tail -f /dev/null
