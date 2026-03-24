## Docker Environment for Reproducible Research

This directory contains the configuration files for a fully reproducible computational environment using Docker. A **pre-built image** is published on [Docker Hub](https://hub.docker.com/r/phdpablo/smart-cfa), so end users do not need to build anything locally — just pull and run.

### What's Included

- **`Dockerfile`**: Defines how the image was built (included for transparency). End users do not need this file.
- **`docker-compose.yml`**: Pulls the pre-built image from Docker Hub and starts the container.
- **`start.bat` / `start.sh`**: One-click launcher scripts for Windows and Unix-like systems (macOS, Linux).
- **`stop.bat` / `stop.sh`**: Scripts to pause the running container (data is preserved inside).

### Prerequisites

1. **Docker**: Download and install [Docker Desktop](https://docs.docker.com/get-docker/) and make sure it is running.

### Quick Start

1. **Open a Terminal/Command Prompt** and navigate to this `docker/` directory:
   ```bash
   cd docker
   ```

2. **Launch the Environment:**
   - **Windows:** Double-click `start.bat`, or run `start.bat` in the terminal.
   - **macOS/Linux:** Run `./start.sh` (you may need `chmod +x start.sh` first).

3. **Access RStudio:**
   - The script waits ~30 seconds for initialization, then opens `http://127.0.0.1:8787` in your browser.
   - No login is required (`DISABLE_AUTH=true`).
   - All project files are available inside the container at `/home/rstudio/`.

4. **Verify Reproducibility:**
   - In the RStudio Terminal, run:
     ```bash
     quarto render
     ```
   - The rendered manuscript will be generated in the `docs/` directory.

5. **Stop the Environment:**
   - **Windows:** Double-click `stop.bat`, or run `stop.bat`.
   - **macOS/Linux:** Run `./stop.sh`.
   - The container is **paused** (not deleted). Run `start` again to resume.

### Alternative Methods

If you prefer not to use the helper scripts:

**Using Docker Compose:**
```bash
cd docker
docker compose up -d          # Start the container
docker compose stop           # Pause the container
docker compose down           # Stop and remove the container
```

**Using Docker directly:**
```bash
docker pull phdpablo/smart-cfa:4.5.2
docker run -d --name smart-cfa -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true phdpablo/smart-cfa:4.5.2
```

### How It Works

- The image `phdpablo/smart-cfa:4.5.2` is **self-contained**: all project files, R packages (via `renv`), and LaTeX dependencies are embedded.
- No volume mounts are needed — the repository files are already inside the image.
- On first start, LaTeX formats are regenerated (~30 seconds) via the `init-latex.sh` script.
- The `Dockerfile` is included in the repository for full transparency on how the image was built. You can uncomment the `build:` section in `docker-compose.yml` to rebuild locally if desired.

### Troubleshooting

- **Docker not running:** Start Docker Desktop before running the scripts.
- **Port 8787 in use:** Stop any other service using that port, or edit `docker-compose.yml` to change the host port (e.g., `127.0.0.1:8788:8787`).
- **First run is slow:** The image download (~2–4 GB) and LaTeX format sync take time on the first run. Subsequent starts are fast.
- **Container logs:** Run `docker compose logs` in this directory to inspect issues.
