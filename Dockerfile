FROM ubuntu:24.04

COPY src/* /root/

ENV BAKPGS3_TIMEZONE="Europe/London"
ENV BAKPGS3_CRON_TIME=""
ENV BAKPGS3_S3_ENDPOINT=""
ENV BAKPGS3_PROJECT_NAME=""
ENV BAKPGS3_S3_REGION=""
ENV BAKPGS3_DB_USER=""

RUN chmod 755 /root/*.sh && \
	 /root/install.sh

CMD ["/root/run.sh"]
