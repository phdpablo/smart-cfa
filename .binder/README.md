# smart-cfa on Binder

[![Launch smart-cfa on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio)

This link opens the Portuguese development branch. Binder uses the files **pushed to GitHub**, not uncommitted local changes. To test an exact revision, replace `pt_version` in the URL with its full commit SHA.

The compatibility environment intentionally uses `rocker/binder:4.4.2` (R 4.4.2), while the primary local/Docker/CI environment uses R 4.5.2. Quarto is pinned to **1.9.37** in both. The R version difference is intentional and must be checked again when analytical packages are introduced; `renv.lock` currently records R 4.5.2 and only the environment manager.

After the environment starts, open the RStudio terminal:

```bash
cd /home/rstudio
R --version
quarto --version
quarto render --to all
```

Results are written to `docs/`. Download the PDF or browse the HTML output. Binder sessions are temporary; save any results you need before the session ends.

The Dockerfile installs TinyTeX through Quarto. TeX packages are not frozen to a dated repository; first builds and missing-package downloads require network access.

To check the same Dockerfile locally from the repository root:

```bash
docker build -f .binder/Dockerfile -t smart-cfa-binder-test .
docker run --rm --entrypoint /bin/bash smart-cfa-binder-test -lc 'cd /home/rstudio && quarto render --to all'
```

A successful local image test checks the configured environment. It does not by itself verify the public MyBinder service, its build limits, or its browser session startup.
