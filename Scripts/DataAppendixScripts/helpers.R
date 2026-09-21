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
dist <- bindDist(
  skewness = seq(-1, 1, length.out = P),
  kurtosis = seq(1.7, 2, length.out = P)
)

# Missing Complete at Random (MCAR) percent
P_MCAR <- 0.10

#
options(max.print = 1e6)

# --- Reusable plotting function ---------------------------------------------
# Reusable helpers for WHOQOL-Bref CFA diagrams
# =============================================================================
# The article uses structural diagrams: they communicate which parameters are
# present, not their estimated numerical values. This file converts lavaan
# syntax into a consistently styled semPlot diagram and highlights the small
# set of relations that distinguish the tutorial models.
#
# The plotting code is kept here for reuse by later chapters. Chapter 3 calls
# this function directly and, in the HTML version, links readers back to this
# documented implementation instead of duplicating the same operations inside
# the manuscript source.

# Domain colors follow the visual identity used across the project. The names
# are semantic rather than positional so their intended role remains clear.
model_palette <- c(
  psychological = "#F18C22",
  physical = "#87CBCC",
  social = "#A0B7D2",
  environmental = "#D8DA54"
)

# Dark blue is used for node borders and labels. `sienna` is deliberately a
# named color: semPaths can misread digits inside a hexadecimal color supplied
# through `fixedStyle` as a numeric line-type specification.
model_ink <- "#0D232B"
model_highlight <- "sienna"

#' Draw a structural diagram for a WHOQOL-Bref CFA model
#'
#' The function parses lavaan syntax without fitting the model. It then marks
#' the Q3--Q4 residual covariance and, optionally, the three cross-loadings that
#' distinguish `h1modelfree` from `analyzemodel`. Because parameter values
#' are not displayed, the resulting figure represents the specification rather
#' than empirical estimates.
#'
#' @param model A length-one character string containing lavaan model syntax.
#' @param highlight_cross_loadings Logical. If `TRUE`, highlight the loadings
#'   psychological -> Q8, psychological -> Q9, and environment -> Q15 in
#'   addition to the Q3--Q4 residual covariance.
#'
#' @return The qgraph object returned by `semPlot::semPaths()`, invisibly.
#'
#' @examples
#' plot_measurement_model(analyzemodel)
#' plot_measurement_model(h1modelfree, highlight_cross_loadings = TRUE)
plot_measurement_model <- function(
  model,
  highlight_cross_loadings = FALSE
) {
  if (!is.character(model) || length(model) != 1L || is.na(model)) {
    stop("'model' must be one non-missing lavaan syntax string.", call. = FALSE)
  }

  if (!requireNamespace("semPlot", quietly = TRUE)) {
    stop(
      "Package 'semPlot' is required. Restore it with renv::restore().",
      call. = FALSE
    )
  }

  # semPlotModel() parses syntax into two S4 tables:
  # - @Pars stores directed loadings and bidirectional covariances.
  # - @Vars stores manifest and latent variable names.
  # No sample data or fitted lavaan object is required for this structural plot.
  plot_model <- semPlot::semPlotModel(model)
  parameters <- plot_model@Pars

  # Covariances may be stored in either endpoint order, so both Q3--Q4 and
  # Q4--Q3 are accepted. Self-covariances are not selected.
  is_q3_q4 <- parameters$edge == "<->" &
    ((parameters$lhs == "Q3" & parameters$rhs == "Q4") |
      (parameters$lhs == "Q4" & parameters$rhs == "Q3"))

  # Directed edges use the latent factor as `lhs` and the item as `rhs`.
  # These are the only secondary loadings specified in h1modelfree.
  is_cross_loading <- parameters$edge == "->" &
    ((parameters$lhs == "psycho" & parameters$rhs %in% c("Q8", "Q9")) |
      (parameters$lhs == "environment" & parameters$rhs == "Q15"))

  highlighted <- is_q3_q4 |
    (highlight_cross_loadings & is_cross_loading)

  # semPaths preserves the `fixed` flag when it removes hidden variances and
  # duplicates bidirectional edges. We temporarily reuse that flag only as a
  # stable styling marker. This does not change the lavaan syntax or estimation,
  # and fixed/free numerical values are intentionally absent from the diagram.
  plot_model@Pars$fixed <- highlighted

  # Short, language-neutral labels keep the four central nodes legible at the
  # journal column width. The figure note defines all abbreviations.
  latent_labels <- c(
    psycho = "PSI",
    physical = "FIS",
    social = "SOC",
    environment = "AMB"
  )

  # Rename both the variable table and every parameter endpoint; changing only
  # one of the two would disconnect edges from their nodes.
  for (latent_name in names(latent_labels)) {
    display_name <- latent_labels[[latent_name]]
    plot_model@Vars$name[plot_model@Vars$name == latent_name] <- display_name
    plot_model@Pars$lhs[plot_model@Pars$lhs == latent_name] <- display_name
    plot_model@Pars$rhs[plot_model@Pars$rhs == latent_name] <- display_name
  }

  # Items are colored by their primary theoretical domain. Cross-loaded items
  # therefore retain their original domain color, while the highlighted edge
  # communicates the additional relation.
  groups <- list(
    psychological = c("PSI", "Q5", "Q6", "Q7", "Q11", "Q19", "Q26"),
    physical = c(
      "FIS",
      "Q3",
      "Q4",
      "Q10",
      "Q15",
      "Q16",
      "Q17",
      "Q18"
    ),
    social = c("SOC", "Q20", "Q21", "Q22"),
    environmental = c(
      "AMB",
      "Q8",
      "Q9",
      "Q12",
      "Q13",
      "Q14",
      "Q23",
      "Q24",
      "Q25"
    )
  )

  semPlot::semPaths(
    plot_model, # The parsed lavaan syntax, with highlighted edges marked above
    style = "lisrel", # Rectangles for items and circles for factors
    layout = "circle", # Keeps 24 indicators readable around four factors
    intercepts = FALSE, # Intercepts are irrelevant to this structural view
    thresholds = FALSE, # Thresholds are irrelevant to this structural view
    residuals = FALSE, # Hide residual loops; retain Q3--Q4 covariance
    groups = groups, # Group items by their theoretical domain for color coding
    color = model_palette, # Color each domain according to the project visual identity
    edge.width = 1,
    fixedStyle = model_highlight, # Styling marker assigned above
    freeStyle = "black",
    border.color = model_ink, # Node borders are dark blue to match the figure caption text
    label.color = model_ink, # Node labels are dark blue to match the figure caption text
    legend = FALSE, # The figure note defines the abbreviations
    sizeLat = 10,
    sizeMan = 5.5,
    sizeMan2 = 5.5,
    label.cex = 1.15,
    edge.label.cex = 0, # Suppress values: this is a model specification
    weighted = FALSE, # Do not encode parameter size in line width
    mar = c(2, 2, 2, 2)
  )
}
