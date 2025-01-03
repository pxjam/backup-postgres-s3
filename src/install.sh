#!/bin/bash

apt-get update
apt-get install -y \
	cron \
	curl \
	rclone \
	postgresql-client

touch log.txt
