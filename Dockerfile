FROM ubuntu:24.04

COPY src/* /root/

RUN chmod 755 /root/*.sh && \
	apt-get update && \
	apt-get install -y \
		curl \
		rclone \
		postgresql-client

CMD ["/root/run.sh"]
