# Docker Graphite Ubuntu

Due to the large amount of CVE's in the docker-graphite-statsd repository, I tried to update it, but was unsuccesful, due to the python library incompatabilities.

I then decided to create a new image based on Ubuntu 24. I used the guide *"Install and Setup Graphite on Ubuntu Server 22.04 via APT Repository " from Lup Peng Loke as a base for this image.

## Includes the following components in its initial release
* Host OS: Ubuntu Server 24.04
* Python Version: 3.12.3-0
* Django Version: 4.2.11-1
* Graphite Version
  * graphite-web: 1.1.10-5
  * graphite-carbon: 1.1.7-1.1
* Apache Server Version: Apache/2.4.58 (Ubuntu)

## Mapped Ports

| Host | Container |         Service |
|------|:---------:|----------------:|
| 80   |    80     |          apache |
| 2003 |   2003    | carbon receiver |
| 2004 |   2004    | carbon receiver |
| -    |   7002    |    carbon-cache |

## Mounted Volumes

| Host            | Container         | Notes                        |
|-----------------|-------------------|------------------------------|
| DOCKER ASSIGNED | /var/log/graphite | graphite log files           |
| DOCKER ASSIGNED | /storage          | graphite db and whisper data |

## Tunables
Additional environment variables that can be set in kubernetes configmap and kubernetes secret

* GRAPHITE_ADMIN_MAIL: mail address of the new user
* GRAPHITE_ADMIN_PWD: password for the new user
* GRAPHITE_ADMIN_USER: username of the new user

## Wish list / TODO list

* To run the container as _graphite user and not root
* Remove the old standard Django user
