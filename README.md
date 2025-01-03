# Docker image for backup Postgres DB to any S3 storage

Supports any S3-like storage (not only AWS).

docker-compose.yml is for local testing and development,
and usage example.

## Build and test locally

Copy the example environment file:

```bash
cp .env.local .env
```

Build the image:

```bash
make build
```

Run the compose project locally for testing:

```bash
make run
```

after that you can see the backup file in Minio (S3-like storage) web interface:
http://localhost:8900/

Login and password are specified in:

- ./secret/bakpgs3_s3_access_key
- ./secret/bakpgs3_s3_secret_key

## Publish new version

Create a new release tag in the format v<major>.<minor>.<patch>.
For example, v1.0.0.

Pushing the new release on GitHub tag will automatically trigger
the GitHub Actions workflow defined in
.github/workflows/build-and-push-images.yml.

```
git tag v0.99.0
git push origin v0.99.0
```
