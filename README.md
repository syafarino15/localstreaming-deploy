# Deployment repository — only tracks what is not application source.

This repository holds the two things that are shared across all applications
and must be versioned independently:

| Path | Contents |
|---|---|
| `POV/` | Deployment bundle for the mini PC: Docker Compose, nginx routing, database init, install/export scripts |
| `Documents/` | Requirement specification, FE/BE rules and the menu/flow audit |

Application source lives in its own repositories:

| Application | Repository |
|---|---|
| Go backend (two databases) | `localstreaming-backend` |
| Next.js CMS | `localstreaming-web` |
| Expo Android TV | `localstreaming-tv` |

## What is deliberately not here

- Exported Docker images (`POV/images/*.tar`) are too large for git and are
  produced by `POV/scripts/export-images.sh`, then carried on a flashdisk.
- `POV/.env` contains real credentials; the mini PC generates it from
  `.env.example` during `install.sh`.
- Media (`POV/storage/`) is content, not code.

## Deploying

```bash
cd POV
cp .env.example .env      # adjust passwords, JWT secret and node key
sudo ./scripts/install.sh
./scripts/healthcheck.sh
```

The stack starts PostgreSQL with two separate databases, `stayin_main` and
`stayin_local`. `POV/postgres/init/01-create-databases.sql` creates the second
one on first boot; the backend applies its own migration set to each.
