FROM ubuntu:24.04
LABEL maintainer="Jeroen Hartgers"

# Set Brussels timezone
ADD /etc/timezone /etc/timezone
RUN apt-get update \
    && apt-get -y install tzdata apt-utils \
    && apt-get upgrade -y \
    && rm  -f /etc/localtime \
    && ln -sf /usr/share/zoneinfo/Europe/Brussels  /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && date

# Install graphite 1.1.10-5 \
# Install graphite-carbon 1.1.7-1.1 (unfortunately no newer version available)
RUN  apt-get -y install  \
     graphite-web \
     graphite-carbon \
 && apt policy graphite-web graphite-carbon

# Fix import imp problem in Python 3.12
RUN sed -i "s/import\ imp/import\ importlib/g" /usr/lib/python3/dist-packages/carbon/routers.py

# Remove warning "CryptographyDeprecationWarning: CAST5 has been deprecated"
RUN sed -i "/cast128-cbc/d" /usr/lib/python3/dist-packages/twisted/conch/ssh/transport.py \
 && sed -i "/cast128-ctr/d" /usr/lib/python3/dist-packages/twisted/conch/ssh/transport.py

# Remove warning "CryptographyDeprecationWarning: Blowfish has been deprecated"
RUN sed -i "/blowfish-cbc/d" /usr/lib/python3/dist-packages/twisted/conch/ssh/transport.py \
 && sed -i "/blowfish-ctr/d" /usr/lib/python3/dist-packages/twisted/conch/ssh/transport.py

# Carbon Cache
RUN sed -i s/CARBON_CACHE_ENABLED=false/CARBON_CACHE_ENABLED=true/g /etc/default/graphite-carbon \
 && service carbon-cache start

COPY etc/graphite/local_settings.py /etc/graphite/local_settings.py

# SymLink local_settings
RUN ln -s /etc/graphite/local_settings.py \
          /usr/lib/python3/dist-packages/graphite/local_settings.py \
 && echo "DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'" >> /usr/lib/python3/dist-packages/graphite/settings.py \
 && sed -i '/SECRET_KEY/d' /usr/lib/python3/dist-packages/graphite/settings.py \
 && echo "SECRET_KEY = 'PasswordPlaceholder4u'" >> /usr/lib/python3/dist-packages/graphite/settings.py \
 && ln -s /usr/lib/python3/dist-packages/graphite/settings.py \
          /etc/graphite/settings.py

# Migrate
RUN django-admin migrate --settings=graphite.settings \
 && chown _graphite:_graphite /var/lib/graphite/graphite.db

# Install Apache
RUN apt-get -y install \
    apache2  \
    libapache2-mod-wsgi-py3 \
 && cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available \
 && sed -i '/WSGIProcessGroup\ _graphite/a \ \ \ \ \ \ WSGIApplicationGroup\ %{GLOBAL}' /etc/apache2/sites-available/apache2-graphite.conf \
 && a2dissite 000-default \
 && a2ensite apache2-graphite \
 && mkdir -p /var/log/apache2 \
 && chmod -R 755 /var/log/apache2 \
 && service apache2 start \
 && chown -R _graphite:_graphite /var/log/graphite /var/log/apache2 \
 && service apache2 restart

# Set default user and password
ENV DJANGO_SUPERUSER_PASSWORD=Wh01sAfR4iDOfTheB16BAdWolf
ENV DJANGO_SUPERUSER_USERNAME=django
ENV DJANGO_SUPERUSER_EMAIL=fake.address@yourcompany.com

RUN django-admin createsuperuser --noinput --settings=graphite.settings \
 && ln -s /usr/lib/python3/dist-packages/django/contrib/admin/static/admin/ /usr/share/graphite-web/static/admin

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Default ports expose
EXPOSE 80 2003-2004 7002

ENTRYPOINT ["/entrypoint.sh"]
