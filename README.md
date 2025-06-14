# Docker image for backup Postgres DB to any S3 storage

Supports any S3-like storage (not only AWS).

This container is designed to be run by host cron rather than having an internal cron daemon.
The container runs the backup once and exits, making it perfect for scheduled execution.

compose.yml is for local testing and development, and usage example.

## Volumes

The container uses one volume:

- `backup-logs` - Stores backup logs (persistent)

## Build and test locally

Copy the example environment file:

```bash
cp .env.local.example .env
```

Build the image:

```bash
make build
```

Run the compose project locally for testing:

```bash
make run
```

After running compose, you should see the backup file in Minio (S3-like storage) web interface:
http://localhost:8900/

Then you can manually run the backup container again, and should
get a new backup file with the current date in the name.

```bash
docker compose run --rm backup
```

Also you can schedule the backup to check if it works correctly:

```crontab
* * * * * docker compose -f /path/to/compose.yml run --rm backup
```

## Usage: Environment Variables vs Docker Secrets

You can run the stack using either environment variables or Docker secrets for sensitive values (DB password, S3 keys).

### 1. Using Environment Variables (simple, for local/dev)

- Edit `.env` (or `.env.local.example`) and set:
	- `BAKPGS3_DB_PASSWORD`, `BAKPGS3_S3_ACCESS_KEY`, `BAKPGS3_S3_SECRET_KEY`
- Use the default `compose.yml`:

```bash
docker compose up --build
```

### 2. Using Docker Secrets (recommended for production)

- Place secret files in the `secrets/` directory:
	- `secrets/bakpgs3_db_password`, `secrets/bakpgs3_s3_access_key`, `secrets/bakpgs3_s3_secret_key`
- Use the `compose.secrets.yml` file:

```bash
docker compose -f compose.secrets.yml up --build
```

If both an environment variable and a Docker secret are set, the environment variable takes precedence.

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
