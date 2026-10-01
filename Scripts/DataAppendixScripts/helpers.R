# =============================================================================
# helpers.R -- Shared packages, constants, and reusable functions
# =============================================================================
# Source it once at the beginning of an analytical chapter to load
# the packages and objects shared by the project.

# --- Packages ----------------------------------------------------------------

library(lavaan)
library(semTools)
library(semPower)
library(semPlot)
library(simsem)
library(MASS)
library(ggplot2)
library(dplyr)
library(here)
library(knitr)
library(quantreg)
library(parallel)
library(tibble)
library(purrr)
library(stringr)
library(readr)
library(careless)
library(modi)
library(psych)
library(likert)

# --- Configuration -----------------------------------------------------------

# Number of Monte Carlo replications at every value of N.
REP <- 10

# Number of Monte Carlo replications at fixed value of N.
SIM <- 1000

# Sample-size sequences.
SEQ <- rep(101:400, each = REP)

# Target N used to inspect power and cutoffs after varying N simulations.
N_TARGET <- 200

# Random seed used by simsem to make the simulations reproducible.
SEED <- 123321

# A priori decision criteria.
ALPHA <- 0.05
POWER <- 0.80

# Number of observed indicators in the four-domain WHOQOL-Bref model.
P <- 24

# Fit indices used to evaluate power and derive model-calibrated cutoffs.
FITS <- c("rmsea", "srmr", "cfi", "tli")
FITS_ROB <- c("rmsea.robust", "srmr", "cfi.robust", "tli.robust")

# Conventional cutoffs retained only as descriptive reference values.
RULE_OF_THUMB <- c(
  rmsea = 0.06,
  cfi = 0.95,
  tli = 0.95,
  srmr = 0.06
)

# Mild non-normality based on Yoshitake et al. (2015). Across the 24 items,
# skewness ranges from -1 to +1 and kurtosis ranges from 1.7 to 2.0.
DIST <- bindDist(
  skewness = seq(-1, 1, length.out = P),
  kurtosis = seq(1.7, 2, length.out = P)
)

# Missing Complete at Random (MCAR) percent
P_MCAR <- 0.10

#
options(max.print = 1e6)

# --- Reusable plotting function ---------------------------------------------
# Helper functions for plotting SEM diagrams with semPlot, using consistent styling across all models.

# Colors for latent variable groups: psychological (psy), physical (phy), social (scl), and environmental (env). The colors are chosen to be visually distinct and consistent across all diagrams, with a neutral ink color for edges and labels.
COLS <- c(
  psy = "#F18C22",
  phy = "#87CBCC",
  scl = "#a0b7d2",
  env = "#d8da54"
)

INK <- "#0D232C"

# Circle layout version of the path diagram, with standardized estimates as
# edge labels, Portuguese abbreviations for latent variables, and color coding
# for latent variable groups.
plot_color <- function(model) {
  plot_model <- semPlot::semPlotModel(model)

  # semPaths() receives one label per node.  Keep the observed-item labels and
  # replace only the latent-variable labels with the project abbreviations.
  node_labels <- plot_model@Vars[["name"]]
  latent_labels <- c(
    psycho = "PSI",
    physical = "FIS",
    social = "SOC",
    environment = "AMB"
  )

  latent_nodes <- !plot_model@Vars[["manifest"]]
  node_labels[latent_nodes] <- unname(
    latent_labels[plot_model@Vars[["name"]][latent_nodes]]
  )

  semPlot::semPaths(
    plot_model,
    whatLabels = "est",
    style = "lisrel",
    layout = "circle",
    intercepts = FALSE,
    thresholds = FALSE,
    residuals = FALSE,
    groups = "latents",
    nodeLabels = node_labels,
    reorder = FALSE,
    color = COLS,
    edge.color = INK,
    border.color = INK,
    label.color = INK,
    sizeLat = 9,
    sizeMan = 5,
    sizeMan2 = 5,
    label.cex = 1.2,
    edge.label.cex = 1.2,
    edge.label.bg = TRUE,
    weighted = FALSE,
    mar = c(2, 1.5, 2, 1.5)
  )
}
