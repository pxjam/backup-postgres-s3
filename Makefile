$(VERBOSE).SILENT:
SHELL := /bin/bash
CYAN := \033[0;36m
NC := \033[0m

IMAGE=pxjam/backup-postgres-s3

.DEFAULT_GOAL := help

help:
	grep -E '^[a-zA-Z_-]+:[ \t]+.*?# .*$$' $(MAKEFILE_LIST) | sort | awk -F ':.*?# ' '{printf "  ${CYAN}%-24s${NC}\t%s\n", $$1, $$2}'

build: # build docker image
	docker buildx build \
	--progress=plain \
	-t ${IMAGE}:latest .

run: # run local docker compose for testing
	docker compose up --force-recreate --build --remove-orphans

clean: # clean local docker compose
	docker compose down --volumes
	docker rmi ${IMAGE}:latest || true

clean-build-run: clean build run # clean and run local docker compose for testing
