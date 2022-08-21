IMAGE=pxjam/backup-postgres-s3

build:
	docker buildx build --platform linux/amd64 \
		--progress=plain \
		-t ${IMAGE}:latest .

test-run:
	docker-compose up --force-recreate --build --remove-orphans
