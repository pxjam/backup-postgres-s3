FROM postgres:17.5

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	curl \
	rclone \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1001 app && \
    useradd -m -u 1001 -g 1001 app && \
	 mkdir -p /app/logs && chown -R app:app /app

WORKDIR /app

COPY src/* /app/

RUN chmod 755 /app/*.sh && \
    chown app:app /app/*.sh

USER app

CMD ["/app/run.sh"]
