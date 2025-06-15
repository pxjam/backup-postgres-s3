# Docker image for backing up a Postgres DB to any S3 storage

Supports any S3-like storage (not only AWS).

This container is designed to be run by host cron rather than having an internal cron daemon.
The container runs the backup once and exits, making it perfect for scheduled execution.

The `compose.yml` file is for local testing, development, and usage examples.

## Logs

Logs are stored in `/app/logs` inside the container.

You can mount a local directory to persist backup logs: `./logs:/app/logs`.

## Security Features

- Runs as non-root user (UID/GID 1001) for enhanced security
- Supports both environment variables and Docker secrets for sensitive data

## Build and test locally

Copy the example environment file:

```bash
cp .env.local.example .env
```

Build the image:

```bash
make build
```

Run the Compose project locally for testing:

```bash
make run
```

After running Compose, you should see the backup file in the Minio (S3-like storage) web interface:
http://localhost:8900/

Then you can manually run the backup container again, and you should
get a new backup file with the current date in the name.

```bash
docker compose run --rm backup
```

You can also schedule the backup:

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

- Place secret files in the `secrets/` directory, for example:
	- `secrets/bakpgs3_db_password`
	- `secrets/bakpgs3_s3_access_key`
	- `secrets/bakpgs3_s3_secret_key`
- Use the `compose.secrets.yml` file:

```bash
docker compose -f compose.secrets.yml up --build
```

If both an environment variable and a Docker secret are set, the environment variable takes precedence.

## Backup Storage Structure

Backups are organized in S3 with intelligent folder structure:

- `daily/` - Regular daily backups
- `weekly/` - Sunday backups (retained longer)
- `monthly/` - First day of month backups
- `yearly/` - January 1st backups

Each backup file includes timestamp: `projectname.YYYY-MM-DD_HH-MM-SS.sql.gz`

## Publishing a new version

Create a new release tag in the format `v<major>.<minor>.<patch>`.
For example, `v1.0.0`.

Pushing a new release tag on GitHub will automatically trigger
the GitHub Actions workflow defined in
`.github/workflows/build-and-push-images.yml`.

The image is built for multiple platforms (linux/amd64, linux/arm64) and published to:

- Docker Hub: `pxjam/backup-postgres-s3`
- GitHub Container Registry: `ghcr.io/pxjam/backup-postgres-s3`

```bash
git tag v0.99.0
git push origin v0.99.0
```

## Version 1.0.0 Breaking Changes

- The image now runs as a non-root user (UID/GID 1001) for enhanced security.
- Ability to use both Docker secrets and environment variables for sensitive data.
- No built-in cron; the container runs once and exits, suitable for host cron scheduling.
