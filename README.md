# MDPI DBT Project

This repository contains the **Jaffle Shop DBT project** for the MDPI Data Engineering Assessment.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. Install Dependencies and Basic Setup](#1-install-dependencies-and-basic-setup)
  - [2. Set Up and Connect to the Database](#2-set-up-and-connect-to-the-database)
  - [3. DBT Setup](#3-dbt-setup)
- [Database Structure](#database-structure)
- [CI Workflow](#ci-workflow)

---

## Prerequisites

Make sure you have the following installed:

- Python 3.8+
- [Git](https://git-scm.com/downloads)
- [UV](https://docs.astral.sh/uv/getting-started/) (Python project and dependency manager)
- [direnv](https://direnv.net) (for loading environment variables automatically)
- Docker and Docker Compose (recommended: [Docker Desktop](https://www.docker.com/get-started/))
- A database client (e.g., [pgAdmin](https://www.pgadmin.org/download/))

---

## Setup Instructions

### 1. Install Dependencies and Basic Setup

Clone the repository and navigate to the project folder:

```bash
git clone https://github.com/your-username/mdpi-dbt-project.git
cd mdpi-dbt-project
```

Set up your environment:

```bash
# Rename example env file
mv .env.example .env

# Create a virtual environment with UV
uv venv .venv

# Install project dependencies
uv sync   # or: uv pip install -e .
```

Enable automatic environment variable loading via `direnv`:

```bash
direnv allow
```

> ⚠️ Whenever you modify `.env`, reload the environment variables:
>
> ```bash
> direnv reload
> ```

---

### 2. Set Up and Connect to the Database

Start the local PostgreSQL instance using Docker Compose:

```bash
docker-compose up -d
```

> Ensure environment variables are loaded first so Docker Compose can access them.

**Connecting with pgAdmin**:

1. Open pgAdmin and click **Add New Server**.
2. In the **General** tab, provide a name (e.g., `mdpi_dbt_postgres`).
3. In the **Connection** tab, if you went with the defaults in `.env.example`, enter:

   - **Host**: `localhost`
   - **Port**: `5432`
   - **Maintenance database**: `dbt_warehouse`
   - **Username**: `dbt_user`
   - **Password**: `dbt_password`

4. Click **Save** to create the server connection.

> Other database clients can be configured similarly.

---

### 3. DBT Setup

1. Install DBT packages:

```bash
dbt deps
```

2. Test the database connection:

```bash
dbt debug
```

3. Load source data (seeds):

```bash
dbt seed
```

4. Run sample models:

```bash
dbt run
```

> ⚠️ After each `dbt run`, you may need to refresh your database client to see the latest tables and views (right-click -> refresh)

---

## Database Structure

After running DBT:

- **Source data (tables)**:

```text
mdpi_dbt_postgres/databases/dbt_warehouse/schemas/raw/tables
```

- **Staging models (views)**:

```text
mdpi_dbt_postgres/databases/dbt_warehouse/schemas/staging/views
```

- **Mart models (tables)**:

```text
mdpi_dbt_postgres/databases/dbt_warehouse/schemas/marts/tables
```

---

## CI Workflow

**Triggers**: runs on pull requests, pushes to main, and manual runs (workflow_dispatch). Concurrency cancels older runs on the same ref.

**Lint job**: installs dbt + SQLFluff, sets `DBT_PROFILES_DIR` to the repo, applies inert DB env defaults, lints SQL with the dbt templater, and runs dbt parse to validate rendering.

**PR build**: spins up an ephemeral Postgres service, installs dbt, runs dbt deps/debug, then dbt seed and dbt build with tests; also generates docs.

**Main build**: targets your warehouse using repo secrets (with safe fallbacks) and runs dbt seed and dbt build; `DBT_TARGET` can be overridden via repo variables.
Permissions are minimal (contents: read).

Normally, the CI workflow requires certain sensitive credentials that we would provide via Github Secrets or similar method. To avoid unnecessary hassle, the default values in .env.example are provided in the ci script (`.github/workflows/ci.yml`). If you didn't modifiy any of them then the workflow should work as is.

If you did make any modifications, then you would also need to modify the defaults in the script above or add these repository secrets (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_SCHEMA) using the [Github CLI](https://cli.github.com) or [manualy](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets?tool=webui) in the repo's page.
