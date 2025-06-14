FROM ubuntu:24.04

COPY src/* /root/

ENV BAKPGS3_TIMEZONE="Europe/London"
ENV BAKPGS3_S3_ENDPOINT=""
ENV BAKPGS3_PROJECT_NAME=""
ENV BAKPGS3_S3_REGION=""
ENV BAKPGS3_DB_USER=""

RUN chmod 755 /root/*.sh && \
	apt-get update && \
	apt-get install -y \
		curl \
		rclone \
		postgresql-client

CMD ["/root/run.sh"]
