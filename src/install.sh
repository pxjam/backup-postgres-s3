#!/bin/bash

ln -snf "/usr/share/zoneinfo/$BAKPGS3_TIMEZONE" /etc/localtime
echo "$BAKPGS3_TIMEZONE" >/etc/timezone

apt-get update
apt-get install -y \
	cron \
	curl \
	s3cmd \
	postgresql-client

touch log.txt
