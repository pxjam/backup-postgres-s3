FROM postgres:17.5

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	curl \
	rclone \
	&& rm -rf /var/lib/apt/lists/*

COPY src/* /root/

RUN chmod 755 /root/*.sh

CMD ["/root/run.sh"]
