# Smart Choices for Measurement Models: Executable Manuscript Tutorial for your CFA in R Environment

[![Cite Preprint](https://img.shields.io/badge/Cite%20Preprint-PDF-red)](https://doi.org/10.31234/osf.io/2dy3z) [![TIER Protocol 4.0](https://img.shields.io/badge/TIER%20Protocol-4.0-green)](https://www.projecttier.org/tier-protocol/protocol-4-0/) [![GitHub Pages](https://img.shields.io/github/deployments/phdpablo/smart-cfa/github-pages?label=GitHub%20Pages)](https://phdpablo.github.io/smart-cfa/) [![OSF](https://img.shields.io/badge/OSF-10.31234/osf.io/2dy3z-blue)](https://doi.org/10.31234/osf.io/2dy3z) [![License](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/) [![R version](https://img.shields.io/badge/R-4.5.2-orange)](https://www.r-project.org/) [![Quarto](https://img.shields.io/badge/Quarto-1.9.37-orange)](https://quarto.org/) [![Docker](https://img.shields.io/badge/Docker-4.45.0-orange)](https://www.docker.com/) [![renv](https://img.shields.io/badge/renv-1.2.4-orange)](https://rstudio.github.io/renv/)

> Rogers, P., & Georgeto, S. M. (2024). *Smart Choices for Measurement Models: Executable Manuscript Tutorial for your Confirmatory Factor Analysis in R Environment.* <https://doi.org/10.31234/osf.io/2dy3z>

This repository contains the **developing reproducible materials** for the tutorial article on Confirmatory Factor Analysis (CFA) using R. The article guides applied social scientists through key decisions in CFA — from measurement model selection and power analysis to estimation, model fit, and modification — within a dynamic document framework that promotes open science principles (reproducibility, replicability, and transparency).

The manuscript is structured as a Quarto book and built using the [ARTE template](https://github.com/phdpablo/article-template) (Article Reproducibility Template & Environment). The live rendered version is available at: <https://phdpablo.github.io/smart-cfa/>

### Key Features

- ✅ **Comprehensive CFA guidelines** covering recommended practices, pitfalls, and reporting standards
- ✅ **Reproducible document** using Quarto with embedded R code (`lavaan` package)
- ✅ **Pre-rendered website** in `docs/` folder (GitHub Pages)
- ✅ **Docker environment** for computational reproducibility verification
- ✅ **TIER Protocol 4.0** compliant folder structure

## About the Article

This tutorial article pursues three objectives:

1. **Compile guidelines** for applying CFA — a widely used technique in applied social sciences — covering recommended practices, pitfalls to avoid, and reporting standards.
2. **Demonstrate** these guidelines through a real-world example implemented entirely in R with the `lavaan` package.
3. **Structure the narrative** using open science tools (Quarto, renv, Docker, GitHub) to ensure reproducibility, replicability, and transparency.

**Key topics covered:**

- Measurement model selection and theoretical justification
- Power analysis for CFA
- Data pre-processing (missing data, outliers, assumptions)
- Estimation procedures (ML and robust variants for continuous items)
- Model fit evaluation (global and local fit indices)
- Model comparisons and modifications

**Keywords:** Confirmatory Factor Analysis, Structural Equation Modeling, Internal Structure Validity, Open Science, `lavaan`.

## Access the Materials

| Resource | Description | Link |
| :-- | :-- | :-- |
| **📄 Preprint** | Original paper on PsyArXiv | [doi.org/10.31234/osf.io/2dy3z](https://doi.org/10.31234/osf.io/2dy3z) |
| **🌐 Tutorial Website** | Pre-rendered complete tutorial | [phdpablo.github.io/smart-cfa](https://phdpablo.github.io/smart-cfa/) |
| **🚀 MyBinder** | Run interactively in the cloud (no install) | [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio) |
| **📦 Docker Image** | Self-contained reproducible environment | [hub.docker.com/r/phdpablo/smart-cfa](https://hub.docker.com/r/phdpablo/smart-cfa) |

## Repository Structure

The project follows the [TIER Protocol 4.0](https://www.projecttier.org/tier-protocol/protocol-4-0/) folder structure:

```
smart-cfa/
├── index.qmd              # Abstract
├── 01_intro.qmd           # Introdução
├── 02_background.qmd      # Fundamentação e escolhas inteligentes
├── 03_model_selection.qmd # Seleção do modelo de medida
├── 04_pa.qmd              # Análise de poder
├── 05_preprocessing.qmd   # Pré-processamento
├── 06_estimation.qmd      # Estimação
├── 07_model_fit.qmd       # Ajuste do modelo
├── 08_model_comparison.qmd # Comparações e modificações
├── 09_conclusion.qmd      # Conclusões
├── references.qmd         # References
├── _quarto.yml            # Quarto project configuration
├── references.bib         # BibTeX references
├── apa7ed.csl             # APA 7th edition citation style
├── render_cleanup.R       # Post-render cleanup script
├── Data/                  # Input, intermediate, and analysis data
├── Scripts/               # Processing, analysis, and appendix scripts
├── Output/                # Results and data appendix outputs
├── docker/                # Docker configuration for reproducibility
├── .binder/               # Binder configuration for cloud interactive environment
└── docs/                  # Pre-rendered website (GitHub Pages)
```

Each subdirectory under `Data/`, `Scripts/`, and `Output/` contains a `README.md` with an overview, contents, and guidelines.

## Quick Start

### Option 1: View Pre-Rendered Website (Fastest)

Simply visit the deployed website — no installation needed:

**<https://phdpablo.github.io/smart-cfa/>**

The `gh-pages` branch of the repository contains the complete pre-rendered tutorial.

### Option 2: Cloud environment (MyBinder)

[![Launch RStudio on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/phdpablo/smart-cfa/pt_version?urlpath=rstudio)

The link targets the Portuguese development branch. Binder reads the latest pushed files, so local changes must be committed and pushed before they are available there. For an exact reproduction, replace the branch name with a full commit SHA. See [.binder/README.md](.binder/README.md).

### Option 3: Local rendering

Use **R 4.5.2** and **Quarto 1.9.37**, with TinyTeX for PDF output. Quarto is pinned for this project; do not update it automatically.

```bash
git clone --branch pt_version https://github.com/phdpablo/smart-cfa.git
cd smart-cfa
R -e "renv::restore(prompt = FALSE)"
quarto install tinytex --no-prompt
quarto render --to all
```

### Option 4: Docker

Build the current checkout, rather than relying on a prebuilt image containing older source files:

```bash
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up -d
```

Open <http://127.0.0.1:8787>, then run `quarto render --to all` in the RStudio terminal. See [docker/README.md](docker/README.md).

## Build validation and publication

The workflow `.github/workflows/deploy.yml` builds HTML and PDF on pushes to `pt_version` and `main`, and on pull requests to `main`. Each successful build provides a downloadable `smart-cfa-<commit>` artifact containing `docs/`.

- `main` builds and pull-request builds do **not** publish the site with this workflow.
- A push to `pt_version` publishes the validated output to `gh-pages`.
- Manual runs validate by default. Publishing requires selecting `pt_version` and enabling the publish input.
- The publication step reuses the validated output without rendering again.

GitHub Pages must serve the `gh-pages` branch from `/`. Local uncommitted workflow changes cannot run on GitHub Actions; commit and push the changes to validate them remotely. A local render does not establish that the remote workflow passed.

## Reproduction scope and versions

| Component | Primary environment | Binder compatibility environment |
| --- | --- | --- |
| R | 4.5.2 | 4.4.2 |
| Quarto | 1.9.37, fixed | 1.9.37, fixed |
| R dependencies | `renv.lock` | Same lock file, with the intentional R-version difference |
| PDF engine | TinyTeX | TinyTeX |

The current milestone contains narrative and bibliography; analytical R packages and simulations have not yet been introduced. The lock file therefore contains only `renv`. Add analytical dependencies as their code is implemented, not as a speculative package list.

TinyTeX packages and base-image tags can change upstream. Record image digests and actual TeX versions for a reproduction test; these configurations do not claim a fully frozen historical environment. Docker, Binder and CI validation should be repeated when computation is added.

## Citation

If you use or build upon this work, please cite:

Rogers, P., & Georgeto, S. M. (2024). Smart Choices for Measurement Models: Executable Manuscript Tutorial for your Confirmatory Factor Analysis in R Environment. <https://doi.org/10.31234/osf.io/2dy3z>

**BibTeX:**

```bibtex
@misc{rogers2024smartcfa,
  title  = {Smart Choices for Measurement Models: Executable Manuscript Tutorial
            for your Confirmatory Factor Analysis in R Environment},
  author = {Rogers, Pablo and Georgeto, S{\'e}rgio M.},
  year   = {2024},
  month  = jun,
  doi    = {10.31234/osf.io/2dy3z},
  url    = {https://doi.org/10.31234/osf.io/2dy3z},
  note   = {PsyArXiv Preprint}
}
```

This repository was built using the **ARTE** template. If you reuse the template infrastructure, please also cite:

Rogers, P., & Limongi, R. (2025). Open Science in Three Acts: Foundations, Practice, and Implementation - Third Act. *BAR - Brazilian Administration Review*, *22*(3), e250162. <https://doi.org/10.1590/1807-7692bar2025250162>

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/) — see the [LICENSE](LICENSE) file for details.
